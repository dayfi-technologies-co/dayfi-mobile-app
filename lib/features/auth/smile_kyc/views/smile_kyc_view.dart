import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/smile_kyc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smile_id/products/biometric/smile_id_biometric_kyc.dart';

class SmileKycView extends ConsumerStatefulWidget {
  final bool showBackButton;
  final bool fromSignup;
  final KycVerificationMode mode;

  const SmileKycView({
    super.key,
    this.showBackButton = false,
    this.fromSignup = false,
    this.mode = KycVerificationMode.tier2,
  });

  @override
  ConsumerState<SmileKycView> createState() => _SmileKycViewState();
}

class _SmileKycViewState extends ConsumerState<SmileKycView> {
  final _ninController = TextEditingController();
  final _bvnController = TextEditingController();
  final _smileKycApi = SmileKycApiService(networkService);

  int _step = 0;
  bool _busy = false;
  bool _bvnDone = false;
  bool _showSelfieSdk = false;
  String? _error;
  String? _bvnJobId;

  @override
  void initState() {
    super.initState();
    if (widget.mode == KycVerificationMode.tier3) {
      _step = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileViewModelProvider.notifier).loadUserProfile();
      await _loadKycStatus();
    });
  }

  Future<void> _loadKycStatus() async {
    try {
      final status = await _smileKycApi.fetchKycStatus();
      if (!mounted) return;

      await ref
          .read(profileViewModelProvider.notifier)
          .applyKycProfileSnapshot(status);

      final bvnVerified = status['bvnVerified'] == true;
      final ninVerified = status['ninVerified'] == true;
      final tierLevel =
          status['tierLevel'] as int? ??
          int.tryParse(
            (status['level']?.toString() ?? '').replaceAll('level-', ''),
          ) ??
          1;

      if (widget.mode == KycVerificationMode.tier3) {
        if (ninVerified || tierLevel >= 3) {
          if (widget.showBackButton && mounted) {
            _popVerificationSuccess('Verification complete.');
          }
        }
        return;
      }

      if (bvnVerified && tierLevel >= 2) {
        if (widget.showBackButton && mounted) {
          _popVerificationSuccess(_ngnReadyMessage(status));
        } else if (widget.fromSignup && mounted) {
          appRouter.pushNamed(AppRoute.createPasscodeView);
        }
        return;
      }

      if (bvnVerified) {
        setState(() {
          _bvnDone = true;
        });
      }
    } catch (_) {}
  }

  String _ngnReadyMessage(Map<String, dynamic>? outcome) {
    final account = outcome?['ngnAccount'] as Map<String, dynamic>?;
    final acct = account?['accountNumber']?.toString().trim() ?? '';
    if (acct.isNotEmpty) {
      return 'Your NGN bank account is ready.';
    }
    return 'Verification complete.';
  }

  void _popVerificationSuccess(String message) {
    Navigator.of(context).pop(<String, dynamic>{
      'success': true,
      'message': message,
    });
  }

  Future<void> _finishTier2({
    String? successMessage,
    Map<String, dynamic>? outcome,
  }) async {
    if (!mounted) return;

    final message = successMessage ?? _ngnReadyMessage(outcome);

    if (widget.fromSignup && !widget.showBackButton) {
      TopSnackbar.showSafe(context, message: message);
      appRouter.pushNamed(AppRoute.createPasscodeView);
      return;
    }

    _popVerificationSuccess(message);
  }

  Future<void> _applyKycOutcome(Map<String, dynamic> outcome) async {
    await ref
        .read(profileViewModelProvider.notifier)
        .applyKycProfileSnapshot(outcome);
    await ref.read(walletHubProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _ninController.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '');
    if (raw.contains('status code 400')) {
      return 'Verification is still processing. Wait a few seconds and try again.';
    }
    return raw;
  }

  String _friendlySmileError(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('already enrolled') ||
        lower.contains('wrong job type')) {
      return 'This account was already verified with Smile ID. Tap Retry — we\'ll reset and continue.';
    }
    if (msg.contains('-1005') ||
        lower.contains('connection was lost') ||
        lower.contains('network connection was lost') ||
        lower.contains('nsurlerrordomain')) {
      return 'Selfie upload failed — your connection dropped. Stay on Wi‑Fi or mobile data and try again.';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Verification timed out. Try again on a stable connection.';
    }
    if (msg.contains('status code 400')) {
      return 'Smile ID could not finish verification. Wait a moment and try again.';
    }
    if (lower.contains('cancel')) {
      return 'Verification cancelled. You can try again when ready.';
    }
    if (msg.length > 120) {
      return 'Smile ID could not complete verification. Check your connection and try again.';
    }
    return msg;
  }

  void _handleSmileFailure(String msg) {
    if (!mounted) return;
    final friendly = _friendlySmileError(msg);
    setState(() {
      _error = friendly;
      _showSelfieSdk = false;
      _busy = false;
    });
    TopSnackbar.show(context, message: friendly, isError: true);
  }

  Future<void> _completeBvnWithRetry({
    required String resultJson,
    required String jobId,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 8; attempt++) {
      try {
        await _smileKycApi.completeSmileKyc(
          smileResultJson: resultJson,
          idType: 'BVN',
          jobId: jobId,
        );
        return;
      } catch (e) {
        lastError = e;
        final msg = _friendlyError(e).toLowerCase();
        final retryable =
            msg.contains('processing') ||
            msg.contains('wait') ||
            msg.contains('retry') ||
            (e is ApiError && e.errorType == 400);
        if (!retryable || attempt >= 7) rethrow;
        await Future.delayed(Duration(seconds: 2 + attempt));
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> _onBvnSuccess(String resultJson) async {
    final jobId = _bvnJobId;
    if (jobId == null || jobId.isEmpty) {
      TopSnackbar.show(
        context,
        message: 'Verification session expired. Please try again.',
        isError: true,
      );
      return;
    }

    Map<String, dynamic> capture = {};
    try {
      capture = json.decode(resultJson) as Map<String, dynamic>;
    } catch (_) {}

    final submitted = capture['didSubmitBiometricKycJob'] == true;
    if (!submitted) {
      TopSnackbar.show(
        context,
        message: 'Selfie was not submitted. Please complete the flow again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _completeBvnWithRetry(resultJson: resultJson, jobId: jobId);
      final outcome = await _smileKycApi.fetchKycStatus();
      await _applyKycOutcome(outcome);
      if (mounted) {
        setState(() {
          _bvnDone = true;
          _busy = false;
          _showSelfieSdk = false;
        });
        if (widget.mode == KycVerificationMode.tier2) {
          await _finishTier2(outcome: outcome);
        } else {
          TopSnackbar.show(context, message: 'BVN verified with Smile ID');
          setState(() => _step = 1);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        final message = _friendlyError(e);
        setState(() => _error = message);
        TopSnackbar.show(context, message: message, isError: true);
      }
    }
  }

  Future<void> _submitBvn() async {
    final bvn = _bvnController.text.trim();
    if (bvn.length != 11 || !RegExp(r'^\d{11}$').hasMatch(bvn)) {
      TopSnackbar.show(
        context,
        message: 'Enter your valid 11-digit BVN to continue',
        isError: true,
      );
      return;
    }

    setState(() {
      _error = null;
      _busy = true;
    });

    try {
      final outcome = await _smileKycApi.verifyBvnWithSmile(bvn: bvn);
      await _applyKycOutcome(outcome);
      if (!mounted) return;

      setState(() {
        _bvnDone = true;
        _busy = false;
      });

      if (widget.mode == KycVerificationMode.tier2) {
        await _finishTier2(outcome: outcome);
      } else {
        TopSnackbar.show(context, message: 'BVN verified');
        setState(() => _step = 1);
      }
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(e);
      setState(() {
        _error = message;
        _busy = false;
      });
      TopSnackbar.show(context, message: message, isError: true);
    }
  }

  Future<void> _startSelfieStep() async {
    final bvn = _bvnController.text.trim();
    if (bvn.length != 11 || !RegExp(r'^\d{11}$').hasMatch(bvn)) {
      TopSnackbar.show(
        context,
        message: 'Enter your valid 11-digit BVN to continue',
        isError: true,
      );
      return;
    }

    final user = ref.read(profileViewModelProvider).user;
    if (user == null) return;

    setState(() {
      _error = null;
      _busy = true;
    });

    try {
      await _smileKycApi.prepareBvnVerification();
      if (!mounted) return;
      setState(() {
        _bvnJobId =
            '${user.userId}-bvn-${DateTime.now().millisecondsSinceEpoch}';
        _showSelfieSdk = true;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(e);
      setState(() {
        _error = message;
        _busy = false;
      });
      TopSnackbar.show(context, message: message, isError: true);
    }
  }

  void _retrySelfieStep() {
    setState(() {
      _showSelfieSdk = false;
      _bvnJobId = null;
    });
    _startSelfieStep();
  }

  Future<void> _submitNin() async {
    final nin = _ninController.text.trim();
    if (nin.length != 11) {
      TopSnackbar.show(
        context,
        message: 'Enter your 11-digit NIN',
        isError: true,
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outcome = await _smileKycApi.verifyNinWithSmile(nin: nin);
      await _applyKycOutcome(outcome);

      if (!mounted) return;

      TopSnackbar.show(
        context,
        message:
            widget.mode == KycVerificationMode.tier3
                ? 'Tier 3 verification complete. Your limits have been increased.'
                : 'Verification complete.',
      );

      if (widget.fromSignup && !widget.showBackButton) {
        TopSnackbar.showSafe(
          context,
          message:
              widget.mode == KycVerificationMode.tier3
                  ? 'Tier 3 verification complete. Your limits have been increased.'
                  : 'Verification complete.',
        );
        appRouter.pushNamed(AppRoute.createPasscodeView);
      } else if (widget.showBackButton) {
        _popVerificationSuccess(
          widget.mode == KycVerificationMode.tier3
              ? 'Tier 3 verification complete.'
              : 'Verification complete.',
        );
      } else {
        appRouter.pushNamed(AppRoute.createPasscodeView);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyError(e);
        });
        TopSnackbar.show(context, message: _error!, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileViewModelProvider).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading:
            widget.showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                )
                : null,
        title: Text(
          widget.mode == KycVerificationMode.tier3
              ? 'Verify NIN (Tier 3)'
              : 'Verify identity (Tier 2)',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child:
            _busy && _step == 1
                ? const DayfiLoadingCenter()
                : _step == 0
                ? _buildBvnStep(user)
                : _buildNinStep(),
      ),
    );
  }

  Widget _buildBvnStep(dynamic user) {
    if (user == null) {
      return const DayfiLoadingCenter();
    }

    final jobId =
        _bvnJobId ??=
            '${user.userId}-bvn-${DateTime.now().millisecondsSinceEpoch}';

    if (_busy) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const DayfiLoadingIndicator(),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                'Confirming your BVN…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!_showSelfieSdk) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your BVN. We verify it with Flutterwave and Smile ID — then take a quick selfie.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'BVN (11 digits)',
              hintText: 'Enter your 11-digit BVN',
              controller: _bvnController,
              maxLength: 11,
              keyboardType: TextInputType.number,
              formatter: FilteringTextInputFormatter.digitsOnly,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontFamily: 'Chirp',
                    letterSpacing: -.25,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Verify BVN',
              onPressed: _busy ? null : _submitBvn,
              fullWidth: true,
              applyFeatureInset: false,
              height: 48,
              borderRadius: 12,
              backgroundColor: AppColors.purple500ForTheme(context),
              textColor: AppColors.neutral0,
              fontFamily: 'Chirp',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy ? null : _startSelfieStep,
              child: Text(
                'Verify with selfie instead',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple500ForTheme(context),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Retry BVN verification',
                onPressed: _busy ? null : _submitBvn,
                fullWidth: true,
                applyFeatureInset: false,
                height: 44,
                borderRadius: 12,
                backgroundColor: Theme.of(context).colorScheme.surface,
                textColor: AppColors.purple500ForTheme(context),
                fontFamily: 'Chirp',
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Text(
            'BVN entered. Take a quick selfie to complete Tier 2 verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontFamily: 'Chirp'),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: SmileIDBiometricKYC(
            country: 'NG',
            idType: 'BVN',
            idNumber: _bvnController.text.trim(),
            entered: true,
            userId: user.userId,
            jobId: jobId,
            firstName: user.firstName,
            lastName: user.lastName,
            dob: user.dateOfBirth,
            personalDetailsConsentGranted: true,
            contactInformationConsentGranted: true,
            documentInformationConsentGranted: true,
            allowNewEnroll: true,
            onSuccess: _onBvnSuccess,
            onError: _handleSmileFailure,
          ),
        ),
      ],
    );
  }

  Widget _buildNinStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 48,
            color: AppColors.purple500ForTheme(context),
          ),
          const SizedBox(height: 16),
          Text(
            _bvnDone ? 'BVN verified' : 'Tier 3 — NIN verification',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your 11-digit NIN. We verify it with Smile ID to unlock Tier 3 limits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'NIN (11 digits)',
            hintText: 'Enter your 11-digit NIN',
            controller: _ninController,
            maxLength: 11,
            keyboardType: TextInputType.number,
            formatter: FilteringTextInputFormatter.digitsOnly,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 14),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _busy ? null : _submitNin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple500ForTheme(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _busy
                    ? const DayfiLoadingIndicator(size: 22, color: Colors.white)
                    : const Text(
                      'Verify NIN',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
