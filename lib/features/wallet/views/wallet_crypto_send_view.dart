import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/wallet/constants/crypto_network_catalog.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/widgets/crypto_network_picker.dart';
import 'package:dayfi/features/wallet/widgets/crypto_recipient_recents_sheet.dart';
import 'package:dayfi/features/recipients/helpers/recipient_save_helper.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// On-chain send (USDC / EURC), aligned with dayfi.wallet SendScreen.
class WalletCryptoSendView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const WalletCryptoSendView({super.key, required this.selectedData});

  @override
  ConsumerState<WalletCryptoSendView> createState() =>
      _WalletCryptoSendViewState();
}

class _WalletCryptoSendViewState extends ConsumerState<WalletCryptoSendView> {
  final _toController = TextEditingController();
  final _memoController = TextEditingController();
  String _asset = 'USDC';
  String _networkKey = 'stellar';
  Map<String, dynamic>? _assetsMap;
  List<CryptoNetworkOption> _networks = CryptoNetworkCatalog.defaultsForReceive();

  static const _assetMeta = {'USDC': (label: 'USDC'), 'EURC': (label: 'EURC')};

  @override
  void initState() {
    super.initState();
    _assetsMap = {
      'USDC': _networks.map((n) => n.key).toList(),
      'EURC': ['stellar', 'ethereum'],
    };
    final receive =
        widget.selectedData['receiveCurrency']?.toString().toUpperCase() ??
        widget.selectedData['debitCurrency']?.toString().toUpperCase() ??
        'USD';
    _asset = receive == 'EUR' ? 'EURC' : 'USDC';
    final prefillAddress =
        widget.selectedData['cryptoAddress'] ??
        widget.selectedData['accountNumber'] ??
        widget.selectedData['toAddress'];
    if (prefillAddress != null && prefillAddress.toString().trim().isNotEmpty) {
      _toController.text = prefillAddress.toString().trim();
    }
    final prefillNetwork =
        widget.selectedData['cryptoNetwork']?.toString().toLowerCase() ??
        widget.selectedData['network']?.toString().toLowerCase();
    if (prefillNetwork != null && prefillNetwork.isNotEmpty) {
      if (prefillNetwork.contains('eth')) {
        _networkKey = 'ethereum';
      } else if (CryptoNetworkCatalog.find(_networks, prefillNetwork) != null) {
        _networkKey = prefillNetwork;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadSendConfig());
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String get _sendCurrency {
    final receive =
        widget.selectedData['receiveCurrency']?.toString().toUpperCase() ??
        widget.selectedData['debitCurrency']?.toString().toUpperCase() ??
        'USD';
    return receive == 'EUR' ? 'EUR' : 'USD';
  }

  bool get _saveRecipientOnly =>
      widget.selectedData['saveRecipientOnly'] == true;

  Future<void> _loadSendConfig() async {
    try {
      final config = await locator<PaymentService>().fetchCryptoSendConfig();
      if (!mounted) return;
      setState(() {
        _networks = CryptoNetworkCatalog.parseSendNetworks(config);
        _assetsMap = config['assets'] as Map<String, dynamic>?;
        _applyDefaults();
      });
    } catch (_) {
      /* defaults already seeded in initState */
    }
  }

  void _applyDefaults() {
    final nets = _networkKeysForAsset;
    if (nets.isEmpty) return;
    final current = CryptoNetworkCatalog.find(_networks, _networkKey);
    if (current == null || !nets.contains(_networkKey)) {
      final firstEnabled = nets.firstWhere(
        (k) => CryptoNetworkCatalog.find(_networks, k)?.enabled == true,
        orElse: () => nets.first,
      );
      _networkKey = firstEnabled;
    }
  }

  List<String> get _networkKeysForAsset =>
      CryptoNetworkCatalog.sendNetworkKeysForAsset(
        _assetsMap,
        _asset,
        _networks,
      );

  CryptoNetworkOption? get _selectedNetwork =>
      CryptoNetworkCatalog.find(_networks, _networkKey);

  String _networkLabel(String key) =>
      CryptoNetworkCatalog.find(_networks, key)?.name ??
      (key.isEmpty ? key : key[0].toUpperCase() + key.substring(1));

  String? _recipientAddress() {
    final network = _selectedNetwork;
    if (network == null) return null;
    return CryptoNetworkCatalog.isValidRecipientAddress(
          network,
          _toController.text,
        )
        ? _toController.text.trim()
        : null;
  }

  bool get _canContinue {
    final network = _selectedNetwork;
    if (network == null || !network.enabled) return false;
    if (_recipientAddress() == null) return false;
    return _networkKeysForAsset.contains(_networkKey);
  }

  String get _recipientHint {
    final network = _selectedNetwork;
    if (network == null) return 'Wallet address';
    return CryptoNetworkCatalog.recipientHint(network);
  }

  void _showNetworkPicker() {
    final assetLabel = _assetMeta[_asset]?.label ?? _asset;
    final keys = _networkKeysForAsset;
    final pickerNetworks =
        keys
            .map((k) => CryptoNetworkCatalog.find(_networks, k))
            .whereType<CryptoNetworkOption>()
            .toList();

    showCryptoNetworkPickerSheet(
      context: context,
      title: 'Choose network',
      subtitle: 'Send $assetLabel — network fees shown below',
      networks: pickerNetworks,
      selectedKey: _networkKey,
      onSelected: (network) {
        setState(() => _networkKey = network.key);
      },
    );
  }

  Future<void> _handleContinue() async {
    HapticHelper.mediumImpact();
    final to = _recipientAddress();
    if (to == null) {
      TopSnackbar.show(
        context,
        message: 'Enter a valid $_recipientHint',
        isError: true,
      );
      return;
    }

    final network = _selectedNetwork;
    if (network == null || !network.enabled) {
      TopSnackbar.show(
        context,
        message: '${network?.name ?? 'This network'} send is not available yet',
        isError: true,
      );
      return;
    }

    if (_saveRecipientOnly) {
      await _saveRecipient(to);
      return;
    }

    final displayCurrency = _sendCurrency;
    Navigator.pushNamed(
      context,
      AppRoute.sendView,
      arguments: {
        'selectedData': {
          ...widget.selectedData,
          'cryptoSend': true,
          'cryptoAddress': to,
          'cryptoAsset': _asset,
          'cryptoNetwork': _networkKey,
          'cryptoMemo': _memoController.text.trim(),
          'cryptoNetworkFeeUsd': network.estimatedNetworkFeeUsd,
          'cryptoPlatformFeeUsd':
              network.platformFeeUsd,
          'sendCurrency': displayCurrency,
          'debitCurrency': displayCurrency,
          'sendCountry': countryCodeForPayCurrency(displayCurrency),
          'receiveCurrency': displayCurrency,
          'receiveCountry': countryCodeForPayCurrency(displayCurrency),
          'recipientDeliveryMethod': 'crypto',
        },
      },
    );
  }

  Future<void> _saveRecipient(String address) async {
    final entry = RecipientSaveHelper.crypto(
      address: address,
      networkKey: _networkKey,
      currency: _sendCurrency,
    );
    await RecipientSaveHelper.save(ref, entry);
    if (!mounted) return;
    RecipientSaveHelper.completeSaveRecipientOnlyNavigation(context);
  }

  Future<void> _showRecentsSheet() async {
    FocusScope.of(context).unfocus();
    final result = await showCryptoRecipientRecentsSheet(
      context: context,
      ref: ref,
      currency: _sendCurrency,
    );
    if (result == null || !mounted) return;

    final address = result.source.accountNumber?.trim();
    if (address == null || address.isEmpty) return;

    setState(() {
      _toController.text = address;
      final network = result.source.networkId?.toLowerCase() ?? '';
      if (network.contains('eth')) {
        _networkKey = 'ethereum';
      } else if (network.isNotEmpty &&
          CryptoNetworkCatalog.find(_networks, network) != null) {
        _networkKey = network;
      } else if (network.isEmpty || network.contains('stellar')) {
        _networkKey = 'stellar';
      }
      final assetCurrency = (result.ledgerCurrency ?? _sendCurrency).toUpperCase();
      _asset = assetCurrency == 'EUR' ? 'EURC' : 'USDC';
      _applyDefaults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetLabel = _assetMeta[_asset]?.label ?? _asset;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final network = _selectedNetwork;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => Navigator.pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svgs/notificationn.svg',
                height: 40,
                color: Theme.of(context).colorScheme.surface,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Add Recipient',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _saveRecipientOnly
                      ? 'Save a crypto recipient for future $assetLabel transfers.'
                      : 'Add a crypto recipient to proceed with your $assetLabel transfer.',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Chirp',
                    color: onSurface.withOpacity(0.75),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              CryptoNetworkSelectorField(
                iconAsset: CryptoNetworkCatalog.iconAsset(_networkKey),
                value: network?.name ?? _networkLabel(_networkKey),
                onTap: _showNetworkPicker,
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'via $assetLabel on ${network?.name ?? _networkLabel(_networkKey)}',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    color: onSurface.withOpacity(0.45),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Recipient address',
                hintText: _recipientHint,
                controller: _toController,
                shouldReadOnly: false,
                onChanged: (_) => setState(() {}),
              ),
              if (network?.rail == 'stellar') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Memo (optional)',
                  hintText: 'Max 28 characters',
                  controller: _memoController,
                  maxLength: 28,
                ),
              ],
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: PrimaryButton(
                  text: _saveRecipientOnly ? 'Save Recipient' : 'Enter Amount',
                  onPressed: _canContinue ? _handleContinue : null,
                  fullWidth: true,
                  borderRadius: 40,
                  height: 48,
                  backgroundColor:
                      _canContinue
                          ? AppColors.purple500
                          : AppColors.purple500ForTheme(context).withOpacity(.15),
                  textColor:
                      _canContinue
                          ? AppColors.neutral0
                          : AppColors.neutral0.withOpacity(.20),
                  fontFamily: 'Chirp',
                  letterSpacing: -.7,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              if (!_saveRecipientOnly)
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: AppColors.purple500ForTheme(context),
                    ),
                    onPressed: _showRecentsSheet,
                    child: Text(
                      'See recents and beneficiaries',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        color: AppColors.purple500ForTheme(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.40,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
