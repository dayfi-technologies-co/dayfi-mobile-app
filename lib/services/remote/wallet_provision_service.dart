import 'dart:async';
import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

/// [index] is 0..n-1, [label] is user-facing, [completed] when that step finished.
typedef ProvisionProgressCallback =
    void Function(int index, String label, bool completed);

class WalletProvisionOutcome {
  final bool success;
  final String? errorMessage;

  const WalletProvisionOutcome({
    required this.success,
    this.errorMessage,
  });
}

/// Starts async wallet provisioning on the API, polls status, persists optional
/// recovery phrase to secure storage, and updates cached user flags when the
/// server returns them.
///
/// Backend (`dayfi_backend`):
/// - `POST /payments/wallet-provision/start` → `{ data: { job_id } }` or
///   `{ data: { status: "completed", current_step: "finalize", ... } }`.
/// - `GET /payments/wallet-provision/status/:jobId` → `{ data: { status,
///   current_step, recovery_phrase?, is_wallet_backed_up? } }`.
class WalletProvisionService {
  WalletProvisionService({required NetworkService networkService})
    : _networkService = networkService;

  final NetworkService _networkService;

  static const _stepIds = <String>[
    'stellar_wallet',
    'ethereum_wallet',
    'fund_stellar',
    'trustlines',
    'finalize',
  ];

  static String _label(String id) {
    switch (id) {
      case 'stellar_wallet':
        return 'Creating Stellar wallet';
      case 'ethereum_wallet':
        return 'Creating Ethereum wallet';
      case 'fund_stellar':
        return 'Funding Stellar account';
      case 'trustlines':
        return 'Opening stablecoin trustlines';
      case 'finalize':
        return 'Securing keys on this device';
      default:
        return id;
    }
  }

  void _emitSteps(
    ProvisionProgressCallback cb, {
    required int lastCompletedIndexInclusive,
  }) {
    for (var i = 0; i < _stepIds.length; i++) {
      cb(i, _label(_stepIds[i]), i <= lastCompletedIndexInclusive);
    }
  }

  void _emitFromPayload(
    ProvisionProgressCallback cb,
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] as String?)?.toLowerCase() ?? '';
    if (_statusIsComplete(status)) {
      _emitSteps(cb, lastCompletedIndexInclusive: _stepIds.length - 1);
      return;
    }
    final raw =
        (data['current_step'] as String?) ??
        (data['currentStep'] as String?) ??
        (data['step'] as String?) ??
        '';
    var cur = _stepIds.indexOf(raw);
    if (cur < 0) {
      cur = 0;
    }
    final doneThrough = status == 'failed' ? -1 : (cur > 0 ? cur - 1 : -1);
    _emitSteps(cb, lastCompletedIndexInclusive: doneThrough);
  }

  static bool _statusIsComplete(String? s) {
    if (s == null) return false;
    final v = s.toLowerCase();
    return v == 'completed' || v == 'success' || v == 'done';
  }

  Map<String, dynamic> _parseBody(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      final d = json.decode(raw);
      if (d is Map<String, dynamic>) return d;
      if (d is Map) return Map<String, dynamic>.from(d);
    }
    return {};
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> root) {
    final d = root['data'];
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
    return root;
  }

  Future<void> _applyCompletion(Map<String, dynamic> data) async {
    final phrase =
        data['recovery_phrase'] as String? ??
        data['recoveryPhrase'] as String? ??
        data['mnemonic'] as String?;
    if (phrase != null && phrase.trim().isNotEmpty) {
      await secureStorage.write(
        StorageKeys.walletRecoveryPhrase,
        phrase.trim(),
      );
    }
    final userMap = await localCache.getUser();
    final backed =
        data['is_wallet_backed_up'] as bool? ??
        data['isWalletBackedUp'] as bool?;
    if (backed != null) {
      userMap['is_wallet_backed_up'] = backed;
    } else if (phrase != null && phrase.trim().isNotEmpty) {
      userMap['is_wallet_backed_up'] = false;
    }
    localCache.setUser = userMap;
  }

  /// Trustlines + Horizon can exceed 90s; allow up to ~4 minutes of polling.
  static const _maxPollAttempts = 120;

  Future<WalletProvisionOutcome> runWithProgress(
    ProvisionProgressCallback onProgress,
  ) async {
    try {
      final startResp = await _networkService.call(
        '${F.baseUrl}${UrlConfig.walletProvisionStart}',
        RequestMethod.post,
        data: <String, dynamic>{},
      );
      final root = _parseBody(startResp.data);
      final data = _unwrap(root);

      if (_statusIsComplete(data['status'] as String?)) {
        _emitFromPayload(onProgress, data);
        await _applyCompletion(data);
        return const WalletProvisionOutcome(success: true);
      }

      final jobId =
          data['job_id'] as String? ??
          data['jobId'] as String? ??
          data['id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        return const WalletProvisionOutcome(
          success: false,
          errorMessage: 'Unexpected response from server',
        );
      }

      for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        final st = await _networkService.call(
          '${F.baseUrl}${UrlConfig.walletProvisionStatus}/$jobId',
          RequestMethod.get,
        );
        final dm = _unwrap(_parseBody(st.data));
        _emitFromPayload(onProgress, dm);
        final status = (dm['status'] as String?)?.toLowerCase() ?? '';
        if (_statusIsComplete(status)) {
          await _applyCompletion(dm);
          return const WalletProvisionOutcome(success: true);
        }
        if (status == 'failed' || status == 'error') {
          return WalletProvisionOutcome(
            success: false,
            errorMessage:
                dm['error'] as String? ??
                dm['message'] as String? ??
                'Provisioning failed',
          );
        }
      }
      return const WalletProvisionOutcome(
        success: false,
        errorMessage: 'Timed out waiting for wallet provisioning',
      );
    } catch (e) {
      if (e is ApiError) {
        return WalletProvisionOutcome(
          success: false,
          errorMessage: e.errorDescription ?? 'Provisioning failed',
        );
      }
      return WalletProvisionOutcome(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> confirmRecoveryPhraseBackedUp() async {
    try {
      await _networkService.call(
        '${F.baseUrl}${UrlConfig.walletBackupConfirmed}',
        RequestMethod.post,
        data: <String, dynamic>{},
      );
    } catch (_) {}
    await secureStorage.delete(StorageKeys.walletRecoveryPhrase);
    final m = await localCache.getUser();
    m['is_wallet_backed_up'] = true;
    localCache.setUser = m;
  }
}
