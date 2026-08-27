import 'dart:async' show unawaited;
import 'package:dayfi/common/constants/username_copy.dart';

import 'package:dayfi/features/send/helpers/send_amount_limits.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_web_dialog.dart';
import 'package:dayfi/features/send/constants/send_copy.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/common/utils/number_formatter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView>
    with WidgetsBindingObserver {
  String? _lastDeliveryMethod;
  final TextEditingController _sendAmountController = TextEditingController();
  final TextEditingController _receiveAmountController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _sendAmountFocus = FocusNode();
  final FocusNode _receiveAmountFocus = FocusNode();
  bool _isCheckingWallet = false;

  /// Coalesces provider-driven controller work so it never runs synchronously during build.
  SendState? _pendingSendListenPrevious;
  bool _sendListenWorkScheduled = false;

  // Track last fetched country/currency to avoid duplicate rate API calls
  String? _lastFetchedSendCountry;
  String? _lastFetchedSendCurrency;

  // Track last wallet fetch to avoid duplicate API calls
  DateTime? _lastWalletFetchTime;

  // Cached fiat wallet snapshot (NGN primary) for balance checks on this screen.
  Future<void> _fetchWalletDetails() async {
    try {
      await ref.read(walletHubProvider.notifier).load(showLoading: false);
    } catch (e) {
      AppLogger.error('Error fetching wallet balance: $e');
    }
  }

  // Route argument helpers (populated when opened via named route)
  BeneficiaryWithSource? _initialBeneficiaryWithSource;
  bool _openedFromRecipients = false;
  bool _didLoadRouteArgs = false;
  bool _prefillSendAmountApplied = false;
  double? _routePrefillSendAmount;

  // Stored data from send_add_recipients_view
  Map<String, dynamic>? _recipientData;
  Map<String, dynamic>? _selectedData;
  Map<String, dynamic>? _senderData;

  bool get _isCryptoSend => _selectedData?['cryptoSend'] == true;

  String _cryptoDisplayCurrency() {
    final asset = _selectedData?['cryptoAsset']?.toString().toUpperCase() ?? '';
    if (asset == 'EURC') return 'EUR';
    return _selectedData?['sendCurrency']?.toString().toUpperCase() ?? 'USD';
  }

  String _cryptoNetworkLabel() {
    final network =
        _selectedData?['cryptoNetwork']?.toString().toLowerCase() ?? 'stellar';
    switch (network) {
      case 'ethereum':
      case 'eth':
        return 'Ethereum';
      case 'bsc':
        return 'BNB Smart Chain';
      case 'arbitrum':
        return 'Arbitrum One';
      case 'mantle':
        return 'Mantle Network';
      case 'sonic':
        return 'Sonic';
      case 'xdc':
        return 'XDC Network';
      case 'stellar':
        return 'Stellar';
      default:
        return network.isEmpty
            ? 'Stellar'
            : network[0].toUpperCase() + network.substring(1);
    }
  }

  double _cryptoNetworkFeeUsd() {
    return double.tryParse(
          _selectedData?['cryptoNetworkFeeUsd']?.toString() ?? '',
        ) ??
        0;
  }

  double _cryptoPlatformFeeUsd() {
    return double.tryParse(
          _selectedData?['cryptoPlatformFeeUsd']?.toString() ?? '',
        ) ??
        SendCopy.transferFeeUsd;
  }

  String _cryptoEnterAmountDescription() {
    return SendCopy.cryptoEnterAmount(
      currency: _cryptoDisplayCurrency(),
      address: RecipientHistoryHelper.truncateAddress(
        _selectedData?['cryptoAddress']?.toString() ?? '',
      ),
      network: _cryptoNetworkLabel(),
    );
  }

  BeneficiaryWithSource? _beneficiaryFromRoute() {
    if (_initialBeneficiaryWithSource != null) {
      return _initialBeneficiaryWithSource;
    }
    final fromSelected = _selectedData?['beneficiaryWithSource'];
    if (fromSelected is BeneficiaryWithSource) return fromSelected;
    final prefill = _selectedData?['prefillBeneficiary'];
    if (prefill is BeneficiaryWithSource) return prefill;
    return null;
  }

  String? _resolvedRecipientDisplayName() {
    final beneficiary = _beneficiaryFromRoute();
    if (beneficiary != null) {
      final label = RecipientHistoryHelper.primaryLabel(
        beneficiary.beneficiary,
        beneficiary.source,
      );
      if (label.isNotEmpty && label != 'Recipient') return label;
    }

    for (final source in [
      _recipientData?['name'],
      _recipientData?['accountName'],
      _selectedData?['recipientName'],
      _selectedData?['accountName'],
    ]) {
      final name = source?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }

    final dayfiId = _selectedData?['dayfiId']?.toString().trim();
    if (dayfiId != null && dayfiId.isNotEmpty) {
      return dayfiId.startsWith('@') ? dayfiId : '@$dayfiId';
    }

    return null;
  }

  String _enterAmountDescription() {
    if (_isCryptoSend) return _cryptoEnterAmountDescription();
    final name = _resolvedRecipientDisplayName();
    if (name != null) return SendCopy.sendingToRecipient(name);
    return SendCopy.enterAmount;
  }

  // Helper function to get full country name from country code
  String _getCountryName(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'Nigeria';
      case 'GH':
        return 'Ghana';
      case 'RW':
        return 'Rwanda';
      case 'KE':
        return 'Kenya';
      case 'UG':
        return 'Uganda';
      case 'TZ':
        return 'Tanzania';
      case 'ZA':
        return 'South Africa';
      case 'BF':
        return 'Burkina Faso';
      case 'BJ':
        return 'Benin';
      case 'BW':
        return 'Botswana';
      case 'CD':
        return 'Democratic Republic of Congo';
      case 'CG':
        return 'Republic of Congo';
      case 'CI':
        return 'Côte d\'Ivoire';
      case 'CM':
        return 'Cameroon';
      case 'GA':
        return 'Gabon';

      case 'MW':
        return 'Malawi';
      case 'ML':
        return 'Mali';
      case 'SN':
        return 'Senegal';
      case 'TG':
        return 'Togo';
      case 'ZM':
        return 'Zambia';
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      case 'CA':
        return 'Canada';
      default:
        return countryCode ?? 'Unknown';
    }
  }

  // Helper function to get flag SVG path from country code
  String _getFlagPath(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'assets/icons/svgs/world_flags/nigeria.svg';
      case 'GH':
        return 'assets/icons/svgs/world_flags/ghana.svg';
      case 'RW':
        return 'assets/icons/svgs/world_flags/rwanda.svg';
      case 'KE':
        return 'assets/icons/svgs/world_flags/kenya.svg';
      case 'UG':
        return 'assets/icons/svgs/world_flags/uganda.svg';
      case 'TZ':
        return 'assets/icons/svgs/world_flags/tanzania.svg';
      case 'ZA':
        return 'assets/icons/svgs/world_flags/south africa.svg';
      case 'BF':
        return 'assets/icons/svgs/world_flags/burkina faso.svg';
      case 'BJ':
        return 'assets/icons/svgs/world_flags/benin.svg';
      case 'BW':
        return 'assets/icons/svgs/world_flags/botswana.svg';
      case 'CD':
        return 'assets/icons/svgs/world_flags/democratic republic of congo.svg';
      case 'CG':
        return 'assets/icons/svgs/world_flags/republic of the congo.svg';
      case 'CI':
        return 'assets/icons/svgs/world_flags/ivory coast.svg';
      case 'CM':
        return 'assets/icons/svgs/world_flags/cameroon.svg';
      case 'GA':
        return 'assets/icons/svgs/world_flags/gabon.svg';
      case 'MW':
        return 'assets/icons/svgs/world_flags/malawi.svg';
      case 'ML':
        return 'assets/icons/svgs/world_flags/mali.svg';
      case 'SN':
        return 'assets/icons/svgs/world_flags/senegal.svg';
      case 'TG':
        return 'assets/icons/svgs/world_flags/togo.svg';
      case 'ZM':
        return 'assets/icons/svgs/world_flags/zambia.svg';
      case 'US':
        return 'assets/icons/svgs/world_flags/united states.svg';
      case 'GB':
        return 'assets/icons/svgs/world_flags/united kingdom.svg';
      case 'CA':
        return 'assets/icons/svgs/world_flags/canada.svg';
      default:
        return 'assets/icons/svgs/world_flags/nigeria.svg'; // fallback
    }
  }

  // Helper function to get currency from country code
  String _getCurrencyFromCountry(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'NGN';
      case 'GH':
        return 'GHS';
      case 'RW':
        return 'RWF';
      case 'KE':
        return 'KES';
      case 'UG':
        return 'UGX';
      case 'TZ':
        return 'TZS';
      case 'ZA':
        return 'ZAR';
      case 'BF':
        return 'XOF';
      case 'BJ':
        return 'XOF';
      case 'BW':
        return 'BWP';
      case 'CD':
        return 'CDF';
      case 'CG':
        return 'XAF';
      case 'CI':
        return 'XOF';
      case 'CM':
        return 'XAF';
      case 'GA':
        return 'XAF';
      case 'MW':
        return 'MWK';
      case 'ML':
        return 'XOF';
      case 'SN':
        return 'XOF';
      case 'TG':
        return 'XOF';
      case 'ZM':
        return 'ZMW';
      case 'US':
        return 'USD';
      case 'GB':
        return 'GBP';
      case 'CA':
        return 'CAD';
      default:
        return 'NGN'; // Default to Nigeria
    }
  }

  // Helper function to get network/bank name from recipient data
  String _getNetworkName() {
    // Try recipient data first (from add recipients view)
    if (_recipientData != null) {
      final networkName = _recipientData!['networkName'] as String?;
      if (networkName != null && networkName.isNotEmpty) {
        return networkName;
      }
    }

    // Try selected data (from navigation)
    if (_selectedData != null) {
      final networkName = _selectedData!['networkName'] as String?;
      if (networkName != null && networkName.isNotEmpty) {
        return networkName;
      }
    }

    // Try beneficiary source network
    if (_initialBeneficiaryWithSource != null) {
      final source = _initialBeneficiaryWithSource!.source;
      final networkId = source.networkId;
      if (networkId != null && networkId.isNotEmpty) {
        // Try to find the network in the send state
        final sendState = ref.read(sendViewModelProvider);
        final network = sendState.networks.firstWhere(
          (n) => n.id == networkId,
          orElse: () => Network(id: null, name: null),
        );
        if (network.name != null && network.name!.isNotEmpty) {
          return network.name!;
        }
      }
    }

    return '';
  }

  // Flags to prevent infinite loops when updating controller text
  bool _isUpdatingSendController = false;
  bool _isUpdatingReceiveController = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to focus changes on send amount field
    _sendAmountFocus.addListener(_handleSendAmountFocusChange);
    // Listen to focus changes on receive amount field
    _receiveAmountFocus.addListener(_handleReceiveAmountFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure no text field has focus when the widget is first built
      FocusScope.of(context).unfocus();
      // Clear controllers and reset the send form on fresh entry so fields are empty
      // This ensures users don't see stale/prefilled amounts when starting a new send flow
      final viewModel = ref.read(sendViewModelProvider.notifier);

      // Reset the viewmodel form values
      try {
        viewModel.resetSendForm();
      } catch (e) {
        // ignore errors from reset
      }

      // Clear UI controllers safely
      _isUpdatingSendController = true;
      _isUpdatingReceiveController = true;
      _sendAmountController.clear();
      _receiveAmountController.clear();
      _isUpdatingSendController = false;
      _isUpdatingReceiveController = false;

      // Set receiver/send country and currency from route arguments BEFORE initialization
      String? routeSendCountry;
      String? routeSendCurrency;
      String? routeReceiveCountry;
      String? routeReceiveCurrency;
      String? routeDeliveryMethod;

      if (_selectedData != null) {
        routeReceiveCountry = _selectedData!['receiveCountry'] as String?;
        routeReceiveCurrency = _selectedData!['receiveCurrency'] as String?;
        routeSendCountry = _selectedData!['sendCountry'] as String?;
        routeSendCurrency =
            (_selectedData!['sendCurrency'] ?? _selectedData!['debitCurrency'])
                ?.toString();
        routeDeliveryMethod =
            _selectedData!['recipientDeliveryMethod'] as String?;

        if (routeReceiveCurrency != null && routeReceiveCurrency.isNotEmpty) {
          final receiveCur = routeReceiveCurrency.toUpperCase();
          routeReceiveCountry =
              (routeReceiveCountry != null && routeReceiveCountry.isNotEmpty)
                  ? routeReceiveCountry.toUpperCase()
                  : countryForCurrency(receiveCur);
          viewModel.updateReceiveCountry(routeReceiveCountry, receiveCur);
        }

        if (routeDeliveryMethod != null && routeDeliveryMethod.isNotEmpty) {
          viewModel.updateDeliveryMethod(routeDeliveryMethod);
        }
      }

      // Apply pay-with before initialize so defaults don't collapse to NGN→NGN.
      if (routeSendCurrency != null && routeSendCurrency.isNotEmpty) {
        final receiveCur =
            routeReceiveCurrency?.toUpperCase() ??
            ref.read(sendViewModelProvider).receiverCurrency;
        final sendCur = resolvePayWithCurrencyForTransfer(
          payWithCurrency: routeSendCurrency,
          receiveCurrency: receiveCur.isNotEmpty ? receiveCur : 'NGN',
        );
        final sendCountry =
            (routeSendCountry != null && routeSendCountry.isNotEmpty)
                ? routeSendCountry.toUpperCase()
                : countryCodeForPayCurrency(sendCur);
        ref.read(selectedDebitCurrencyProvider.notifier).state = sendCur;
        await viewModel.updateSendCountry(sendCountry, sendCur);
      }

      // Initialize viewmodel if needed (will preserve receiver country/currency set above)
      if (!viewModel.isInitialized && !viewModel.isInitializing) {
        try {
          await viewModel.initialize();
        } catch (e) {
          // Log error but don't crash the app
        }
      }

      // Re-apply pay-with after init in case defaults overwrote route args.
      if (routeSendCurrency != null && routeSendCurrency.isNotEmpty) {
        final receiveCur =
            routeReceiveCurrency?.toUpperCase() ??
            ref.read(sendViewModelProvider).receiverCurrency;
        final sendCur = resolvePayWithCurrencyForTransfer(
          payWithCurrency: routeSendCurrency,
          receiveCurrency: receiveCur.isNotEmpty ? receiveCur : 'NGN',
        );
        final sendCountry =
            (routeSendCountry != null && routeSendCountry.isNotEmpty)
                ? routeSendCountry.toUpperCase()
                : countryCodeForPayCurrency(sendCur);
        ref.read(selectedDebitCurrencyProvider.notifier).state = sendCur;
        await viewModel.updateSendCountry(sendCountry, sendCur);
      } else {
        final payWith = ref.read(selectedDebitCurrencyProvider);
        final receiveCur = ref.read(sendViewModelProvider).receiverCurrency;
        final sendCur = resolvePayWithCurrencyForTransfer(
          payWithCurrency: payWith,
          receiveCurrency: receiveCur.isNotEmpty ? receiveCur : 'NGN',
        );
        await viewModel.updateSendCountry(
          countryCodeForPayCurrency(sendCur),
          sendCur,
        );
      }
      if (routeReceiveCurrency != null && routeReceiveCurrency.isNotEmpty) {
        final receiveCur = routeReceiveCurrency.toUpperCase();
        final receiveCountry =
            (routeReceiveCountry != null && routeReceiveCountry.isNotEmpty)
                ? routeReceiveCountry.toUpperCase()
                : countryForCurrency(receiveCur);
        await viewModel.updateReceiveCountry(receiveCountry, receiveCur);
      }
      if (routeDeliveryMethod != null && routeDeliveryMethod.isNotEmpty) {
        viewModel.updateDeliveryMethod(routeDeliveryMethod);
      }

      // Fetch rates only if country/currency has changed since last fetch
      try {
        final currentState = ref.read(sendViewModelProvider);
        if (_lastFetchedSendCountry != currentState.sendCountry ||
            _lastFetchedSendCurrency != currentState.sendCurrency) {
          await viewModel.updateSendCountry(
            currentState.sendCountry,
            currentState.sendCurrency,
          );
          _lastFetchedSendCountry = currentState.sendCountry;
          _lastFetchedSendCurrency = currentState.sendCurrency;
        }
      } catch (e) {
        AppLogger.error('Error fetching rates on SendView init: $e');
      }

      // Fetch fresh wallet balance on screen load (with caching to avoid duplicates)
      final now = DateTime.now();
      if (_lastWalletFetchTime == null ||
          now.difference(_lastWalletFetchTime!).inSeconds > 30) {
        await _fetchWalletDetails();
        _lastWalletFetchTime = now;
      }

      unawaited(KycFlowNavigation.prefetchCanSendMoney(ref));

      analyticsService.trackScreenView(screenName: 'SendView');

      await _applyPrefillSendAmountIfNeeded();
    });
  }

  double? _readPrefillSendAmountFromArgs(Map<String, dynamic> args) {
    final top = args['prefillSendAmount'];
    if (top is num && top > 0) return top.toDouble();
    final selected = args['selectedData'];
    if (selected is Map<String, dynamic>) {
      final nested = selected['prefillSendAmount'];
      if (nested is num && nested > 0) return nested.toDouble();
    }
    return null;
  }

  Future<void> _applyPrefillSendAmountIfNeeded() async {
    if (_prefillSendAmountApplied) return;

    final amount = _routePrefillSendAmount ??
        (_selectedData?['prefillSendAmount'] as num?)?.toDouble();
    if (amount == null || amount <= 0) return;

    final viewModel = ref.read(sendViewModelProvider.notifier);
    if (!viewModel.isInitialized && !viewModel.isInitializing) {
      try {
        await viewModel.initialize();
      } catch (_) {
        return;
      }
    }

    final cleanValue = amount == amount.truncateToDouble()
        ? '${amount.toInt()}.00'
        : amount.toStringAsFixed(2);
    final formattedWithCommas = StringUtils.formatNumberWithCommas(cleanValue);

    _isUpdatingSendController = true;
    _sendAmountController.value = TextEditingValue(
      text: formattedWithCommas,
      selection: TextSelection.collapsed(offset: formattedWithCommas.length),
    );
    _isUpdatingSendController = false;

    viewModel.updateSendAmount(cleanValue);
    _selectedData?['sendAmount'] = cleanValue;
    _prefillSendAmountApplied = true;
  }

  String _spendCurrencyForSend(SendState state) {
    final sendCur = state.sendCurrency.trim().toUpperCase();
    if (sendCur.isNotEmpty) return sendCur;
    return ref.read(selectedDebitCurrencyProvider).toUpperCase();
  }

  // Future<void> _fetchWalletDetails() async {
  //   try {
  //     await ref.read(walletHubProvider.notifier).load(showLoading: false);
  //   } catch (e) {
  //     AppLogger.error('Error fetching wallet balance: $e');
  //   }
  // }

  Future<bool> _hasInsufficientBalance(
    SendState state, {
    bool forceRefresh = false,
  }) async {
    final hubState = ref.read(walletHubProvider);
    final cacheFresh =
        !forceRefresh &&
        hubState.hub != null &&
        _lastWalletFetchTime != null &&
        DateTime.now().difference(_lastWalletFetchTime!).inSeconds < 30;

    if (!cacheFresh) {
      try {
        await ref
            .read(walletHubProvider.notifier)
            .load(showLoading: false)
            .timeout(const Duration(seconds: 8));
        _lastWalletFetchTime = DateTime.now();
      } catch (e) {
        AppLogger.error('Error fetching wallet balance: $e');
        if (hubState.hub == null) return true;
      }
    } else {
      unawaited(
        ref.read(walletHubProvider.notifier).load(showLoading: false).catchError(
          (_) {},
        ),
      );
    }

    if (!mounted) return true;

    final hub = ref.read(walletHubProvider).hub;
    final currency = _spendCurrencyForSend(state);
    final displayBalance = hub?.balanceInDisplayCurrency(currency) ?? 0;

    final totalAmount =
        double.tryParse(state.totalToPay.replaceAll(',', '')) ?? 0.0;
    if (totalAmount <= 0) {
      final sendAmount =
          double.tryParse(state.sendAmount.replaceAll(',', '')) ?? 0.0;
      if (sendAmount <= 0) return false;
    }

    return displayBalance <= 0 || displayBalance < totalAmount;
  }

  Future<bool> _checkWalletBalanceAndNavigate(SendState state) async {
    try {
      if (mounted) {
        setState(() => _isCheckingWallet = true);
      }

      final insufficient = await _hasInsufficientBalance(state);

      if (!mounted) return false;

      if (insufficient) {
        setState(() => _isCheckingWallet = false);
        _showInsufficientBalanceDialog();
        return true;
      }

      if (mounted) setState(() => _isCheckingWallet = false);
      return false;
    } catch (e) {
      if (mounted) setState(() => _isCheckingWallet = false);
      AppLogger.error('Error checking wallet balance: $e');
      return false;
    }
  }

  // Show insufficient balance dialog
  void _showInsufficientBalanceDialog({int pendingTransactionCount = 0}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => _buildInsufficientBalanceDialog(
            pendingTransactionCount: pendingTransactionCount,
          ),
    );
  }

  // Insufficient Balance Dialog Widget
  Widget _buildInsufficientBalanceDialog({int pendingTransactionCount = 0}) {
    return DayfiWebDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBalanceDialogIcon(),
            SizedBox(height: 24),
            _buildBalanceDialogTitle(
              pendingTransactionCount: pendingTransactionCount,
            ),
            SizedBox(height: 16),
            _buildBalanceDialogButtons(),
          ],
        ),
      ),
    );
  }

  // Dialog Icon
  Widget _buildBalanceDialogIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.warning400, AppColors.warning600],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.warning500.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // child: Icon(
      //   Icons.account_balance_wallet_outlined,
      //   color: Colors.white,
      //   size: 40,
      // ),
    );
  }

  // Dialog Title
  Widget _buildBalanceDialogTitle({int pendingTransactionCount = 0}) {
    String message =
        "Your wallet balance is too low to send this amount. Please add funds and try again.";

    if (pendingTransactionCount > 0) {
      message =
          "You have $pendingTransactionCount pending transaction${pendingTransactionCount > 1 ? 's' : ''} that ${pendingTransactionCount > 1 ? 'are' : 'is'} reserving funds from your balance. Please wait for ${pendingTransactionCount > 1 ? 'them' : 'it'} to complete or add more funds.";
    }

    return Text(
      message,
      style: TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Dialog Buttons
  Widget _buildBalanceDialogButtons() {
    return Column(
      children: [
        _buildBalanceDialogConfirmButton(),
        SizedBox(height: 12),
        _buildBalanceDialogCancelButton(),
      ],
    );
  }

  // Confirm Button
  Widget _buildBalanceDialogConfirmButton() {
    return PrimaryButton(
      text: 'Add Funds',
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoute.addMoneySelectWalletView);
      },
      backgroundColor: AppColors.purple500,
      textColor: AppColors.neutral0,
      borderRadius: 38,
      height: 48.00000,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
  }

  // Cancel Button
  Widget _buildBalanceDialogCancelButton() {
    return SecondaryButton(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      borderColor: Colors.transparent,
      textColor: AppColors.purple500ForTheme(context),
      width: double.infinity,
      fullWidth: true,
      height: 48.00000,
      borderRadius: 38,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
  }

  void _handleSendAmountFocusChange() {
    // When focus is lost, check if we need to add ".00"
    if (!_sendAmountFocus.hasFocus) {
      final currentText = _sendAmountController.text.trim();
      if (currentText.isNotEmpty) {
        // Remove commas for checking
        final cleanValue = NumberFormatterUtils.removeCommas(currentText);

        // Check if it's a valid number and doesn't have a decimal point
        final number = double.tryParse(cleanValue);
        if (number != null && !cleanValue.contains('.')) {
          // Add ".00" to the value
          final formattedValue = '$cleanValue.00';
          final formattedWithCommas = StringUtils.formatNumberWithCommas(
            formattedValue,
          );

          // Update controller
          _isUpdatingSendController = true;
          _sendAmountController.value = TextEditingValue(
            text: formattedWithCommas,
            selection: TextSelection.collapsed(
              offset: formattedWithCommas.length,
            ),
          );
          _isUpdatingSendController = false;

          // Update viewmodel
          ref
              .read(sendViewModelProvider.notifier)
              .updateSendAmount(formattedValue);
        }
      }
    }
  }

  void _handleReceiveAmountFocusChange() {
    // When focus is lost, check if we need to add ".00"
    if (!_receiveAmountFocus.hasFocus) {
      final currentText = _receiveAmountController.text.trim();
      if (currentText.isNotEmpty) {
        // Remove commas for checking
        final cleanValue = NumberFormatterUtils.removeCommas(currentText);

        // Check if it's a valid number and doesn't have a decimal point
        final number = double.tryParse(cleanValue);
        if (number != null && !cleanValue.contains('.')) {
          // Add ".00" to the value
          final formattedValue = '$cleanValue.00';
          final formattedWithCommas = StringUtils.formatNumberWithCommas(
            formattedValue,
          );

          // Update controller
          _isUpdatingReceiveController = true;
          _receiveAmountController.value = TextEditingValue(
            text: formattedWithCommas,
            selection: TextSelection.collapsed(
              offset: formattedWithCommas.length,
            ),
          );
          _isUpdatingReceiveController = false;

          // Update viewmodel
          ref
              .read(sendViewModelProvider.notifier)
              .updateReceiveAmount(formattedValue);
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sendAmountFocus.removeListener(_handleSendAmountFocusChange);
    _receiveAmountFocus.removeListener(_handleReceiveAmountFocusChange);
    _sendAmountController.dispose();
    _receiveAmountController.dispose();
    _searchController.dispose();
    _sendAmountFocus.dispose();
    _receiveAmountFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, ensure keyboard is dismissed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).unfocus();
          // Refresh wallet balance when app resumes (with caching)
          final now = DateTime.now();
          if (_lastWalletFetchTime == null ||
              now.difference(_lastWalletFetchTime!).inSeconds > 30) {
            unawaited(_fetchWalletDetails());
            _lastWalletFetchTime = now;
          }
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadRouteArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _routePrefillSendAmount = _readPrefillSendAmountFromArgs(args);
        if (args['beneficiaryWithSource'] is BeneficiaryWithSource) {
          _initialBeneficiaryWithSource =
              args['beneficiaryWithSource'] as BeneficiaryWithSource;
          _openedFromRecipients = args['fromRecipients'] == true;

          // Pre-configure the send state based on beneficiary data
          if (_openedFromRecipients && _initialBeneficiaryWithSource != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _configureSendStateForBeneficiary();
            });
          }
        } else if (args['recipientData'] is Map<String, dynamic>) {
          // Store data from send_add_recipients_view
          _recipientData = args['recipientData'] as Map<String, dynamic>;
          _selectedData = args['selectedData'] as Map<String, dynamic>? ?? {};
          _senderData = args['senderData'] as Map<String, dynamic>? ?? {};
        }
      }
      if (_selectedData == null &&
          args is Map<String, dynamic> &&
          args['selectedData'] is Map<String, dynamic>) {
        _selectedData = args['selectedData'] as Map<String, dynamic>;
      }
      _didLoadRouteArgs = true;
    }
  }

  /// Configure send state based on beneficiary data
  void _configureSendStateForBeneficiary() async {
    if (_initialBeneficiaryWithSource == null) return;

    final beneficiary = _initialBeneficiaryWithSource!.beneficiary;
    final source = _initialBeneficiaryWithSource!.source;
    final viewModel = ref.read(sendViewModelProvider.notifier);

    // Ensure viewModel is initialized before configuring
    if (!viewModel.isInitialized && !viewModel.isInitializing) {
      try {
        await viewModel.initialize();
      } catch (e) {
        // print('Error initializing in _configureSendStateForBeneficiary: $e');
        return;
      }
    }

    // Determine delivery method based on account type
    String deliveryMethod = '';
    final String receiveCountry;
    final String receiveCurrency;
    if (RecipientHistoryHelper.isBankOrMobileRecipient(
      _initialBeneficiaryWithSource!,
    )) {
      receiveCountry = RecipientHistoryHelper.resolveReceiveCountry(
        _initialBeneficiaryWithSource!,
      );
      receiveCurrency = RecipientHistoryHelper.resolveReceiveCurrency(
        _initialBeneficiaryWithSource!,
      );
    } else {
      final ledger =
          _initialBeneficiaryWithSource!.ledgerCurrency?.trim().toUpperCase();
      if (ledger != null && ledger.isNotEmpty) {
        receiveCurrency = ledger;
        receiveCountry = countryForCurrency(ledger);
      } else {
        receiveCountry =
            beneficiary.country.isNotEmpty ? beneficiary.country : 'NG';
        receiveCurrency = _getCurrencyFromCountry(receiveCountry);
      }
    }

    if (source.accountType?.toLowerCase() == 'dayfi') {
      deliveryMethod = 'dayfi_tag';
    } else if (source.accountType?.toLowerCase() == 'bank') {
      // Use 'bank' to match the API channel type
      deliveryMethod = 'bank';
    } else if (source.accountType?.toLowerCase() == 'mobile' ||
        source.accountType?.toLowerCase() == 'mobile_money' ||
        source.accountType?.toLowerCase() == 'momo') {
      deliveryMethod = 'mobile_money';
    }

    // Update the send state with beneficiary's currency and country
    viewModel.updateReceiveCountry(receiveCountry, receiveCurrency);

    if (deliveryMethod.isNotEmpty) {
      viewModel.updateDeliveryMethod(deliveryMethod);
    }

    await _applyPrefillSendAmountIfNeeded();
  }

  void _scheduleSendProviderListenWork(SendState? previous) {
    if (!_sendListenWorkScheduled) {
      _pendingSendListenPrevious = previous;
      _sendListenWorkScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendListenWorkScheduled = false;
        if (!mounted) return;
        final prev = _pendingSendListenPrevious;
        _pendingSendListenPrevious = null;
        final next = ref.read(sendViewModelProvider);
        _applySendProviderListenWork(prev, next);
      });
    }
    // If a frame callback is already queued, keep the earliest `previous` and apply against
    // the latest state when the callback runs (avoids losing the first transition).
  }

  void _applySendProviderListenWork(SendState? previous, SendState next) {
    // --- Detect delivery method change and trigger re-initialization ---
    if (_lastDeliveryMethod != null &&
        next.selectedDeliveryMethod != _lastDeliveryMethod) {
      _lastDeliveryMethod = next.selectedDeliveryMethod;
      unawaited(
        ref.read(sendViewModelProvider.notifier).forceReinitialize().catchError(
          (_) {},
        ),
      );
    } else {
      _lastDeliveryMethod = next.selectedDeliveryMethod;
    }

    // ---- Handle SEND amount ----
    if (previous?.sendAmount != next.sendAmount && !_isUpdatingSendController) {
      _isUpdatingSendController = true;

      final hadSendFocus = _sendAmountFocus.hasFocus;
      final hadReceiveFocus = _receiveAmountFocus.hasFocus;

      final newSendText = StringUtils.formatNumberWithCommas(next.sendAmount);
      if (_sendAmountController.text != newSendText) {
        _sendAmountController.value = TextEditingValue(
          text: newSendText,
          selection: TextSelection.collapsed(offset: newSendText.length),
        );
      }

      if (!hadSendFocus && !hadReceiveFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) FocusScope.of(context).unfocus();
        });
      }

      _isUpdatingSendController = false;
    }

    // ---- Handle RECEIVE amount ----
    if (previous?.receiverAmount != next.receiverAmount &&
        !_isUpdatingReceiveController) {
      _isUpdatingReceiveController = true;

      final hadSendFocus = _sendAmountFocus.hasFocus;
      final hadReceiveFocus = _receiveAmountFocus.hasFocus;

      final newReceiveText = StringUtils.formatNumberWithCommas(
        next.receiverAmount,
      );
      if (_receiveAmountController.text != newReceiveText) {
        _receiveAmountController.value = TextEditingValue(
          text: newReceiveText,
          selection: TextSelection.collapsed(offset: newReceiveText.length),
        );
      }

      if (!hadSendFocus && !hadReceiveFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) FocusScope.of(context).unfocus();
        });
      }

      _isUpdatingReceiveController = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);

    ref.listen<SendState>(sendViewModelProvider, (previous, next) {
      _scheduleSendProviderListenWork(previous);
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,

          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap:
                () => {
                  Navigator.pop(context),
                  FocusScope.of(context).unfocus(),
                },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        // size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "Enter Amount",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   Padding(
          //     padding: EdgeInsets.only(right: 18),
          //     child: InkWell(
          //       splashColor: Colors.transparent,
          //       highlightColor: Colors.transparent,
          //       onTap: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => NotificationsView(),
          //           ),
          //         );
          //       },
          //       child: SvgPicture.asset(
          //         "assets/icons/svgs/notificationn.svg",
          //         height: 32,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 500 : double.infinity,
                  ),
                  child:
                      sendState.isLoading && sendState.channels.isEmpty
                          ? Center(
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 36,
                                ),
                          )
                          : RefreshIndicator(
                            onRefresh: () async {
                              // Dismiss keyboard when refreshing
                              FocusScope.of(context).unfocus();

                              // Force re-initialize the view model to refresh all data
                              try {
                                await ref
                                    .read(sendViewModelProvider.notifier)
                                    .forceReinitialize();
                              } catch (e) {
                                // Log error but don't crash the app
                                // print('Error refreshing SendView: $e');
                              }
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 18,
                                vertical: 4.0,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Transfer Limit Card
                                    DayfiScreenDescription(
                                      text: _enterAmountDescription(),
                                      bottomSpacing: 32,
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        final offsetAnimation = Tween<Offset>(
                                          begin: const Offset(0, 0.08),
                                          end: Offset.zero,
                                        ).animate(animation);
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Column(
                                        key: ValueKey('form-visible'),
                                        children: [
                                          // Send Amount Section
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: _buildSendAmountSection(
                                              sendState,
                                            ),
                                          ),

                                          // SizedBox(height: 20),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            transitionBuilder: (
                                              Widget child,
                                              Animation<double> animation,
                                            ) {
                                              final offsetAnimation =
                                                  Tween<Offset>(
                                                    begin: const Offset(
                                                      0,
                                                      -0.15,
                                                    ),
                                                    end: Offset.zero,
                                                  ).animate(animation);
                                              return FadeTransition(
                                                opacity: animation,
                                                child: SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child:
                                                _getSendButtonText(
                                                              sendState,
                                                              ref.watch(
                                                                sendViewModelProvider
                                                                    .notifier,
                                                              ),
                                                              ref
                                                                  .watch(
                                                                    sendViewModelProvider
                                                                        .notifier,
                                                                  )
                                                                  .isSendAmountValid,
                                                              _isCheckingWallet,
                                                            ) ==
                                                            "Fetching rates..." ||
                                                        _getSendButtonText(
                                                              sendState,
                                                              ref.watch(
                                                                sendViewModelProvider
                                                                    .notifier,
                                                              ),
                                                              ref
                                                                  .watch(
                                                                    sendViewModelProvider
                                                                        .notifier,
                                                                  )
                                                                  .isSendAmountValid,
                                                              _isCheckingWallet,
                                                            ) ==
                                                            "Loading..."
                                                    ? Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 20.0,
                                                            ),
                                                        child:
                                                            LoadingAnimationWidget.horizontalRotatingDots(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary,
                                                              size: 20,
                                                            ),
                                                      ),
                                                    )
                                                    : _getSendButtonText(
                                                              sendState,
                                                              ref.watch(
                                                                sendViewModelProvider
                                                                    .notifier,
                                                              ),
                                                              ref
                                                                  .watch(
                                                                    sendViewModelProvider
                                                                        .notifier,
                                                                  )
                                                                  .isSendAmountValid,
                                                              _isCheckingWallet,
                                                            ) ==
                                                            "Continue" ||
                                                        _getSendButtonText(
                                                              sendState,
                                                              ref.watch(
                                                                sendViewModelProvider
                                                                    .notifier,
                                                              ),
                                                              ref
                                                                  .watch(
                                                                    sendViewModelProvider
                                                                        .notifier,
                                                                  )
                                                                  .isSendAmountValid,
                                                              _isCheckingWallet,
                                                            ) ==
                                                            "Enter valid amount"
                                                    ? const SizedBox(
                                                      key: ValueKey('empty'),
                                                      height: 0,
                                                    )
                                                    : Column(
                                                      key: ValueKey(
                                                        'dynamicText',
                                                      ),
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Center(
                                                          child: Text(
                                                            _getSendButtonText(
                                                              sendState,
                                                              ref.watch(
                                                                sendViewModelProvider
                                                                    .notifier,
                                                              ),
                                                              ref
                                                                  .watch(
                                                                    sendViewModelProvider
                                                                        .notifier,
                                                                  )
                                                                  .isSendAmountValid,
                                                              _isCheckingWallet,
                                                            ),

                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Chirp',
                                                                  letterSpacing:
                                                                      -.25,
                                                                  height: 1.2,
                                                                  color:
                                                                      AppColors
                                                                          .error600,
                                                                ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                          ),

                                          if (!_isCryptoSend) ...[
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              height: 24,
                                              child: const SizedBox.shrink(),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: _buildExchangeRateSection(
                                                sendState,
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              height: 12,
                                              child: const SizedBox.shrink(),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: _buildReceiveAmountSection(
                                                sendState,
                                              ),
                                            ),
                                          ] else ...[
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              height: 24,
                                              child: const SizedBox.shrink(),
                                            ),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: _buildCryptoFeeSection(
                                                sendState,
                                              ),
                                            ),
                                          ],
                                          // AnimatedContainer(
                                          //   duration: const Duration(milliseconds: 350),
                                          //   curve: Curves.easeInOut,
                                          //   height: 18,
                                          //   child: const SizedBox.shrink(),
                                          // ),
                                          // // Recipient Delivery Method Section
                                          // AnimatedContainer(
                                          //   duration: const Duration(milliseconds: 350),
                                          //   curve: Curves.easeInOut,
                                          //   child: _buildRecipientDeliveryMethodSection(
                                          //     sendState,
                                          //   ),
                                          // ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            height: 36,
                                            child: const SizedBox.shrink(),
                                          ),
                                          // Send Button
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: _buildSendButton(sendState),
                                          ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            height: 112,
                                            child: const SizedBox.shrink(),
                                          ),
                                          SizedBox(height: 112),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSendAmountSection(SendState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You send',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -.25,
            height: 1.450,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(.75),
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppColors.neutral500.withOpacity(0.1)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.primary,
                  controller: _sendAmountController,
                  focusNode: _sendAmountFocus,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [NumberWithCommasFormatter()],
                  enableInteractiveSelection: true,
                  onChanged: (value) {
                    if (!_isUpdatingSendController) {
                      // Remove commas before sending to view model for calculations
                      String cleanValue = NumberFormatterUtils.removeCommas(
                        value,
                      );
                      ref
                          .read(sendViewModelProvider.notifier)
                          .updateSendAmount(cleanValue);
                      _selectedData?['sendAmount'] = cleanValue;
                    }
                  },
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 27,
                    letterSpacing: -.70,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 27,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(.15),
                    ),
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      right: 16,
                      top: 16,
                      bottom: 16,
                      left: -4,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            kGlobalPayCurrencyFlags[state.sendCurrency
                                    .toUpperCase()] ??
                                _getFlagPath(state.sendCountry),
                            height: 24,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.sendCurrency,
                            style: AppTypography.bodyMedium.copyWith(
                              fontFamily: 'Chirp',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 4),
              _buildQuickAmountOptions(state),
            ],
          ),
        ),
        if (_isCryptoSend) ...[
          const SizedBox(height: 6),
          Center(
            child: Consumer(
              builder: (context, ref, _) {
                final hub = ref.watch(walletHubProvider).hub;
                final currency = _cryptoDisplayCurrency();
                final available =
                    hub?.balanceInDisplayCurrency(currency) ?? 0;
                return Text(
                  'Available: ${available.toStringAsFixed(2)} $currency',
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ],

        // SizedBox(height: 8),
        // Consumer(
        //   builder: (context, ref, child) {
        //     final homeState = ref.watch(homeViewModelProvider);
        //     final balance =
        //         homeState.balance.isNotEmpty ? homeState.balance : '0.00';
        //     final currency =
        //         homeState.currency.isNotEmpty
        //             ? homeState.currency
        //             : state.sendCurrency;

        //     return Row(
        //       // mainAxisSize: MainAxisSize.min,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         Text(
        //           'Wallet balance: ',
        //           style: AppTypography.bodySmall.copyWith(
        //             fontFamily: 'Chirp',
        //             fontSize: 13,
        //             fontWeight: FontWeight.w500,
        //             color: Theme.of(
        //               context,
        //             ).colorScheme.onSurface.withOpacity(0.7),
        //             letterSpacing: -0.2,
        //           ),
        //         ),
        //         Text(
        //           () {
        //             // Format balance with commas and ensure 2 decimal places
        //             String formattedBalance = StringUtils.formatNumberWithCommas(balance);
        //             if (!formattedBalance.contains('.')) {
        //               formattedBalance += '.00';
        //             } else {
        //               List<String> parts = formattedBalance.split('.');
        //               if (parts.length == 2) {
        //                 String decimalPart = parts[1];
        //                 if (decimalPart.length == 1) {
        //                   formattedBalance += '0';
        //                 } else if (decimalPart.length > 2) {
        //                   formattedBalance = parts[0] + '.' + decimalPart.substring(0, 2);
        //                 }
        //               }
        //             }
        //             return '$formattedBalance $currency';
        //           }(),
        //           style: AppTypography.bodySmall.copyWith(
        //             fontFamily: 'Chirp',
        //             fontSize: 13,
        //             fontWeight: FontWeight.w600,
        //             color: Theme.of(
        //               context,
        //             ).colorScheme.onSurface,
        //             letterSpacing: -0.2,
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget _buildReceiveAmountSection(SendState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You receive',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -.25,
            height: 1.450,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(.75),
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppColors.neutral500.withOpacity(0.1)),
            ],
          ),
          child: TextField(
            cursorColor: Theme.of(context).colorScheme.primary,
            controller: _receiveAmountController,
            focusNode: _receiveAmountFocus,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [NumberWithCommasFormatter()],
            enableInteractiveSelection: true,
            onChanged: (value) {
              if (!_isUpdatingReceiveController) {
                // Remove commas before sending to view model for calculations
                String cleanValue = NumberFormatterUtils.removeCommas(value);
                ref
                    .read(sendViewModelProvider.notifier)
                    .updateReceiveAmount(cleanValue);
              }
            },
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Chirp',
              fontSize: 27,
              letterSpacing: -.25,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.bodyLarge.copyWith(
                fontFamily: 'Chirp',
                fontSize: 27,
                letterSpacing: -.70,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(.15),
              ),
              fillColor: Theme.of(context).colorScheme.surface,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                right: 16,
                top: 16,
                bottom: 16,
                left: -4,
              ),
              suffixIcon: GestureDetector(
                // onTap: () => _showReceiveCountryBottomSheet(state),
                child: Container(
                  // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  // margin: EdgeInsets.only(right: 0),
                  // decoration: BoxDecoration(
                  //   color: Theme.of(
                  //     context,
                  //   ).colorScheme.primaryContainer.withOpacity(.35),
                  //   borderRadius: BorderRadius.circular(40),
                  // ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // add country flag
                      SvgPicture.asset(
                        _getFlagPath(state.receiverCountry),
                        height: 24.00000,
                      ),
                      SizedBox(width: 6),
                      Text(
                        state.receiverCurrency,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      // SizedBox(width: 4),
                      // Icon(
                      //   Icons.keyboard_arrow_down,
                      //   color: AppColors.neutral400,
                      //   size: 20,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Quick amount shortcut buttons below the send amount field
  Widget _buildQuickAmountOptions(SendState state) {
    final amounts = SendAmountLimits.quickAmountsFor(state.sendCurrency);
    final symbol = _currencySymbolFor(state.sendCurrency);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 4, bottom: 12, left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            amounts.asMap().entries.map((entry) {
              final index = entry.key;
              final amt = entry.value;
              final cleanAmt = amt.toStringAsFixed(2);
              final display = StringUtils.formatNumberWithCommas(cleanAmt);
              final isSelected =
                  state.sendAmount.isNotEmpty &&
                  (double.tryParse(state.sendAmount) == amt);

              return Expanded(
                child: GestureDetector(
                      onTap: () {
                        HapticHelper.mediumImpact();
                        // Update viewmodel with clean numeric string
                        ref
                            .read(sendViewModelProvider.notifier)
                            .updateSendAmount(cleanAmt);

                        // Update controller text while preventing feedback loops
                        _isUpdatingSendController = true;
                        final formatted = StringUtils.formatNumberWithCommas(
                          cleanAmt,
                        );
                        _sendAmountController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                        _isUpdatingSendController = false;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(.22)
                                  : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            width: isSelected ? 1.5 : 1,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                        .withOpacity(0.55)
                                    : Theme.of(context).colorScheme.outline
                                        .withOpacity(0.35),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$symbol${display.split('.').first}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontFamily: 'FunnelDisplay',
                              fontSize: 15,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              letterSpacing: .2,
                              height: 1.450,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 60 * index),
                      curve: Curves.easeOut,
                    )
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 60 * index),
                      curve: Curves.easeOutBack,
                    ),
              );
            }).toList(),
      ),
    );
  }

  // Helper function to get delivery method display name
  String _getDeliveryMethodDisplayName(String? method) {
    if (method == null) return 'Unknown';
    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return UsernameCopy.label;
      case 'bank_transfer':
      case 'bank':
        return 'Bank Transfer';
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'Bank Transfer (P2P)';
      case 'eft':
        return 'Bank Transfer (EFT)';
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'Mobile Money';
      case 'spenn':
        return 'Spenn';
      case 'cash_pickup':
      case 'cash':
        return 'Cash Pickup';
      case 'wallet':
      case 'digital_wallet':
        return 'Wallet';
      case 'card':
      case 'card_payment':
        return 'Card';
      case 'crypto':
      case 'cryptocurrency':
        return 'Crypto';
      case 'digital_dollar':
      case 'stablecoins':
        return 'Digital Dollar';
      default:
        return method
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get simplified delivery method type (just the main category)
  /// Get delivery duration based on method type
  /// Fee + total for on-chain crypto sends (no FX rate row).
  Widget _buildCryptoFeeSection(SendState state) {
    final networkFee = _cryptoNetworkFeeUsd();
    final platformFee = _cryptoPlatformFeeUsd();
    final sendAmount =
        double.tryParse(state.sendAmount.replaceAll(',', '')) ?? 0;
    final total = sendAmount + networkFee + platformFee;

    Widget feeRow(String label, double value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    letterSpacing: -.25,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            Text(
              StringUtils.formatCurrency(
                value.toStringAsFixed(2),
                state.sendCurrency,
              ),
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          feeRow('Network fee', networkFee),
          feeRow('Platform fee', platformFee),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/svgs/total.svg', height: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Total to pay',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Text(
                StringUtils.formatCurrency(
                  total.toStringAsFixed(2),
                  state.sendCurrency,
                ),
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateSection(SendState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Exchange Rates',
          //   style: AppTypography.bodyMedium.copyWith(
          //     fontFamily: 'Chirp',
          //     fontSize: 16,
          //     fontWeight: FontWeight.w600,
          //     color: AppColors.neutral800,
          //   ),
          // ),

          // Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Fee',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              if (state.showRatesLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Chirp',
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.neutral800,
                //   ),
                // ),
              ] else if (state.exchangeRate.isNotEmpty &&
                  state.fee.isNotEmpty) ...[
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(sendViewModelProvider);
                    final feeInSend = ref
                        .read(sendViewModelProvider.notifier)
                        .feeInSendCurrency;
                    return Text(
                      StringUtils.formatCurrency(
                        feeInSend.toStringAsFixed(2),
                        state.sendCurrency,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/svgs/total.svg', height: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Total to pay',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              if (state.showRatesLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Chirp',
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.neutral800,
                //   ),
                // ),
              ] else ...[
                () {
                  final total =
                      double.tryParse(state.totalToPay) ??
                      double.tryParse(state.sendAmount) ??
                      0.0;
                  final formatted = StringUtils.formatCurrency(
                    total.toStringAsFixed(2),
                    state.sendCurrency,
                  );
                  return Text(
                    formatted,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }(),
              ],
            ],
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/svgs/rate.svg', height: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Rate',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              if (state.showRatesLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Chirp',
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.neutral800,
                //   ),
                // ),
              ] else if (state.exchangeRate.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    state.exchangeRate,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12),

          // // Send Currency Rates
          // if (state.sendCurrencyRates != null) ...[
          //   _buildCurrencyRateRow(
          //     '${state.sendCurrency} (Send)',
          //     state.sendCurrencyRates!,
          //   ),
          //   SizedBox(height: 8),
          // ],

          // // Receive Currency Rates
          // if (state.receiveCurrencyRates != null) ...[
          //   _buildCurrencyRateRow(
          //     '${state.receiverCurrency} (Receive)',
          //     state.receiveCurrencyRates!,
          //   ),
          //   SizedBox(height: 8),
          // ],
        ],
      ),
    );
  }

  /// Find the network that contains the given channel ID
  Network? _findNetworkForChannel(String? channelId, List<Network> networks) {
    if (channelId == null || networks.isEmpty) return null;

    for (final network in networks) {
      if (network.channelIds?.contains(channelId) == true) {
        return network;
      }
    }
    return null;
  }

  Future<void> _navigateToRecipientScreen(
    SendState state, {
    bool skipBalanceCheck = false,
  }) async {
    // Dismiss keyboard when continue button is pressed
    FocusScope.of(context).unfocus();

    AppLogger.info('🚀 _navigateToRecipientScreen called');

    if (!skipBalanceCheck) {
      // Check wallet balance first
      final shouldNavigateToPayment = await _checkWalletBalanceAndNavigate(state);
      if (shouldNavigateToPayment) {
        AppLogger.info(
          '⚠️ Navigating to payment method due to insufficient balance',
        );
        return; // Balance is insufficient, already navigated to payment method view
      }
    }

    AppLogger.info('✅ Wallet balance check passed');

    if (_isCryptoSend && _selectedData != null) {
      AppLogger.info('📍 Navigating to crypto send review');
      await appRouter.pushNamed(
        AppRoute.walletCryptoSendReviewView,
        arguments: {
          'draft': {
            'to': _selectedData!['cryptoAddress']?.toString() ?? '',
            'asset': _selectedData!['cryptoAsset']?.toString() ?? 'USDC',
            'network': _selectedData!['cryptoNetwork']?.toString() ?? 'stellar',
            'memo': _selectedData!['cryptoMemo']?.toString() ?? '',
            'amount': state.sendAmount,
            'selectedData': _selectedData,
          },
        },
      );
      return;
    }

    // If we have beneficiary data from recipients view, navigate directly to review
    if (_initialBeneficiaryWithSource != null && _openedFromRecipients) {
      AppLogger.info('📍 Navigating with beneficiary from recipients view');
      AppLogger.info(
        'Account Type: ${_initialBeneficiaryWithSource!.source.accountType}',
      );
      await _navigateToSendReviewWithBeneficiary(state);
      return;
    }

    // If we have recipient data from add recipients view, navigate directly to review
    if (_recipientData != null) {
      AppLogger.info(
        '📍 Navigating with recipient data from add recipients view',
      );
      await _navigateToSendReviewWithRecipientData(
        _recipientData!,
        _selectedData!,
        _senderData!,
      );
      return;
    }

    AppLogger.info(
      'ℹ️ No beneficiary or recipient data, proceeding with normal flow',
    );

    // Check if we have Dayfi Tag from send_dayfi_id_view - navigate to review
    if (_selectedData != null && _selectedData!['dayfiId'] != null) {
      AppLogger.info(
        '📍 Navigating to Dayfi Tag review view with existing Dayfi Tag',
      );
      // Ensure sendAmount is up to date in selectedData
      _selectedData!['sendAmount'] = state.sendAmount;
      _selectedData!['receiveAmount'] = state.receiverAmount.isNotEmpty
          ? state.receiverAmount
          : state.sendAmount;
      _selectedData!['sendCurrency'] = state.sendCurrency;
      _selectedData!['receiveCurrency'] = state.receiverCurrency;
      _selectedData!['debitCurrency'] = state.sendCurrency;
      _selectedData!['recipientDeliveryMethod'] = 'dayfi_tag';
      await _navigateToSendDayfiIdReview(_selectedData!);
      return;
    }

    // Check if delivery method is Dayfi Tag - route to Dayfi Tag view
    if (state.selectedDeliveryMethod.toLowerCase() == 'dayfi_tag') {
      final selectedData = {
        'sendAmount': state.sendAmount,
        'receiveAmount': state.receiverAmount,
        'sendCurrency': state.sendCurrency,
        'receiveCurrency': state.receiverCurrency,
        'sendCountry': state.sendCountry,
        'receiveCountry': state.receiverCountry,
        'senderDeliveryMethod': state.selectedSenderDeliveryMethod,
        'recipientDeliveryMethod': state.selectedDeliveryMethod,
        'senderChannelId': state.selectedSenderChannelId,
      };

      try {
        // Set loading state
        setState(() {
          _isCheckingWallet = true;
        });

        // Fetch wallet details to check if user has a Dayfi Tag
        AppLogger.info('Checking for Dayfi Tag...');
        final walletService = locator<WalletService>();
        final walletResponse = await walletService.fetchWalletDetails();

        // Check if any wallet has a non-empty Dayfi Tag
        final hasDayfiId = walletResponse.wallets.any(
          (wallet) => wallet.dayfiId.isNotEmpty,
        );

        // Reset loading state before navigation
        if (mounted) {
          setState(() {
            _isCheckingWallet = false;
          });
        }

        if (hasDayfiId) {
          // User has a Dayfi Tag, proceed to enter recipient's Dayfi Tag
          AppLogger.info(
            'User has Dayfi Tag, navigating to send Dayfi Tag review view',
          );
          appRouter.pushNamed(
            AppRoute.sendDayfiIdReviewView,
            arguments: {
              ...selectedData,
              'dayfiId': selectedData['dayfiId'] ?? '',
            },
          );
        } else {
          // User doesn't have a Dayfi Tag, navigate to explanation/creation view
          AppLogger.info(
            'User does not have Dayfi Tag, navigating to explanation view',
          );
          final result = await appRouter.pushNamed(
            AppRoute.dayfiTagExplanationView,
          );

          // If user created a Dayfi Tag, refresh and proceed to send Dayfi Tag view
          if (result == true || result == 'created') {
            AppLogger.info(
              'Dayfi Tag created, proceeding to send Dayfi Tag view',
            );
            appRouter.pushNamed(
              AppRoute.sendDayfiIdView,
              arguments: selectedData,
            );
          }
        }
      } catch (e) {
        AppLogger.error('Error checking Dayfi Tag: $e');

        // Reset loading state on error
        if (mounted) {
          setState(() {
            _isCheckingWallet = false;
          });
        }

        // Show error and navigate to explanation view as fallback
        TopSnackbar.show(
          context,
          message: UsernameCopy.verifyError,
          isError: true,
        );
        // Navigate to explanation view as fallback
        await appRouter.pushNamed(AppRoute.dayfiTagExplanationView);
      }
      return;
    }

    // Get the selected recipient channel to find the network
    final recipientChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == state.receiverCountry &&
                  channel.currency == state.receiverCurrency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout') &&
                  channel.channelType == state.selectedDeliveryMethod,
            )
            .toList();

    // Find the network for the selected channel
    final selectedChannel =
        recipientChannels.isNotEmpty ? recipientChannels.first : null;
    final selectedNetwork =
        selectedChannel != null
            ? _findNetworkForChannel(selectedChannel.id, state.networks)
            : null;

    // Debug logs for channel IDs
    // print('🔵 SENDER CHANNEL ID: ${state.selectedSenderChannelId}');
    // print('🟢 RECIPIENT CHANNEL ID: ${selectedChannel?.id}');

    // Use real network data with fallbacks
    final selectedData = {
      'sendAmount': state.sendAmount,
      'receiveAmount': state.receiverAmount,
      'sendCurrency': state.sendCurrency,
      'receiveCurrency': state.receiverCurrency,
      'sendCountry': state.sendCountry,
      'receiveCountry': state.receiverCountry,
      'senderDeliveryMethod': state.selectedSenderDeliveryMethod,
      'recipientDeliveryMethod': state.selectedDeliveryMethod,
      'senderChannelId': state.selectedSenderChannelId,
      'recipientChannelId': selectedChannel?.id,
      'networkId': selectedNetwork?.id,
      'networkName':
          selectedNetwork?.name ??
          selectedChannel?.channelType ??
          'Selected Network',
      'accountNumberType': selectedNetwork?.accountNumberType ?? 'phone',
      'networks': state.networks,
    };

    appRouter.pushNamed(AppRoute.sendRecipientView, arguments: selectedData);
  }

  /// Navigate to SendReviewView with beneficiary data from recipients screen
  Future<void> _navigateToSendReviewWithBeneficiary(SendState state) async {
    if (_initialBeneficiaryWithSource == null) return;

    final beneficiary = _initialBeneficiaryWithSource!;
    final source = beneficiary.source;
    final accountType = source.accountType?.toLowerCase() ?? '';

    AppLogger.info('🔍 Routing beneficiary with account type: $accountType');
    AppLogger.info('Network ID: ${source.networkId}');
    AppLogger.info('Beneficiary country: ${beneficiary.beneficiary.country}');

    // Route to Dayfi Tag review for Dayfi Tags
    if (accountType == 'dayfi') {
      AppLogger.info('✅ Routing to Dayfi Tag Review');
      final selectedData = {
        'sendAmount': state.sendAmount,
        'receiveAmount': state.receiverAmount,
        'sendCurrency': state.sendCurrency,
        'receiveCurrency': state.receiverCurrency,
        'sendCountry': state.sendCountry,
        'receiveCountry': state.receiverCountry,
        'senderDeliveryMethod': state.selectedSenderDeliveryMethod,
        'recipientDeliveryMethod': state.selectedDeliveryMethod,
        'senderChannelId': state.selectedSenderChannelId,
      };

      // Extract Dayfi Tag from beneficiary account number (without @ prefix)
      final dayfiId =
          beneficiary.beneficiary.accountNumber?.replaceFirst('@', '') ?? '';

      AppLogger.info(
        '📤 Pushing to sendDayfiIdReviewView with dayfiId: $dayfiId',
      );
      try {
        await appRouter.pushNamed(
          AppRoute.sendDayfiIdReviewView,
          arguments: {'selectedData': selectedData, 'dayfiId': dayfiId},
        );
        AppLogger.info('✅ Successfully navigated to sendDayfiIdReviewView');
      } catch (e) {
        AppLogger.error('❌ Failed to navigate to sendDayfiIdReviewView: $e');
        if (mounted) {
          TopSnackbar.show(
            context,
            message: 'Failed to navigate. Please try again.',
            isError: true,
          );
        }
      }
      return;
    }

    // Route to SendReviewView for bank/mobile money transfers
    AppLogger.info('✅ Routing to Send Review View for bank/mobile transfer');

    // Find the network object for the beneficiary's source.networkId (if any)
    final notifier = ref.read(sendViewModelProvider.notifier);
    final selectedNetwork = notifier.findNetworkById(source.networkId);

    AppLogger.info('Network found: ${selectedNetwork?.name}');

    final deliveryMethod = state.selectedDeliveryMethod.isNotEmpty
        ? state.selectedDeliveryMethod
        : (accountType == 'mobile_money' ? 'mobile_money' : 'bank');
    final resolvedRecipientChannelId =
        notifier.resolveRecipientChannelId(
          receiveCountry: state.receiverCountry,
          receiveCurrency: state.receiverCurrency,
          deliveryMethod: deliveryMethod,
          networkId: selectedNetwork?.id ?? source.networkId,
        ) ??
        '';

    final payload = <String, dynamic>{
      'selectedData': {
        'sendAmount': state.sendAmount,
        'receiveAmount': state.receiverAmount,
        'sendCurrency': state.sendCurrency,
        'receiveCurrency': state.receiverCurrency,
        'sendCountry': state.sendCountry,
        'receiveCountry': state.receiverCountry,
        'senderDeliveryMethod': state.selectedSenderDeliveryMethod,
        'recipientDeliveryMethod': state.selectedDeliveryMethod,
        'senderChannelId': state.selectedSenderChannelId,
        if (resolvedRecipientChannelId.isNotEmpty)
          'recipientChannelId': resolvedRecipientChannelId,
        'networkId': selectedNetwork?.id ?? (source.networkId ?? ''),
        'networkName':
            selectedNetwork?.name ??
            beneficiary.beneficiary.bankName ??
            'Bank Transfer',
        'accountNumberType': selectedNetwork?.accountNumberType ?? 'bank',
      },
      'recipientData': {
        'name': beneficiary.beneficiary.name,
        'country': beneficiary.beneficiary.country,
        'phone': beneficiary.beneficiary.phone,
        'address': beneficiary.beneficiary.address,
        'dob': beneficiary.beneficiary.dob,
        'email': beneficiary.beneficiary.email,
        'idNumber': beneficiary.beneficiary.idNumber,
        'idType': beneficiary.beneficiary.idType,
        'accountNumber': source.accountNumber ?? '',
        'networkId': selectedNetwork?.id ?? source.networkId ?? '',
        'bankName': beneficiary.beneficiary.bankName ?? selectedNetwork?.name,
        'networkName': selectedNetwork?.name ?? beneficiary.beneficiary.bankName,
        'accountType': source.accountType ?? '',
      },
      'senderData': null,
    };

    AppLogger.info('📤 Pushing to sendReviewView with payload');
    try {
      await appRouter.pushNamed(AppRoute.sendReviewView, arguments: payload);
      AppLogger.info('✅ Successfully navigated to sendReviewView');
    } catch (e) {
      AppLogger.error('❌ Failed to navigate to sendReviewView: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to navigate. Please try again.',
          isError: true,
        );
      }
    }
  }

  /// Navigate to SendDayfiIdReviewView with selectedData (for Dayfi Tag flow)
  Future<void> _navigateToSendDayfiIdReview(
    Map<String, dynamic> selectedData,
  ) async {
    try {
      await appRouter.pushNamed(
        AppRoute.sendDayfiIdReviewView,
        arguments: {
          'selectedData': selectedData,
          'dayfiId': selectedData['dayfiId'] ?? '',
        },
      );
    } catch (e) {
      AppLogger.error('❌ Failed to navigate to sendDayfiIdReviewView: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to navigate. Please try again.',
          isError: true,
        );
      }
    }
  }

  /// Navigate to send review view with recipient data from add recipients view
  Future<void> _navigateToSendReviewWithRecipientData(
    Map<String, dynamic> recipientData,
    Map<String, dynamic> selectedData,
    Map<String, dynamic> senderData,
  ) async {
    AppLogger.info(
      '📍 Navigating to send review with recipient data from add recipients view',
    );

    final state = ref.read(sendViewModelProvider);
    final notifier = ref.read(sendViewModelProvider.notifier);

    // Find the network object for the recipient's networkId
    final selectedNetwork = notifier.findNetworkById(
      recipientData['networkId']?.toString(),
    );

    AppLogger.info('Network found: ${selectedNetwork?.name}');

    final deliveryMethod =
        recipientData['recipientDeliveryMethod'] ??
        selectedData['recipientDeliveryMethod'] ??
        'bank';
    final resolvedChannelId = notifier.resolveRecipientChannelId(
      receiveCountry: state.receiverCountry,
      receiveCurrency: state.receiverCurrency,
      deliveryMethod: deliveryMethod.toString(),
      networkId: selectedNetwork?.id ?? recipientData['networkId']?.toString(),
      existingChannelId:
          recipientData['recipientChannelId']?.toString() ??
          selectedData['recipientChannelId']?.toString(),
    );

    // Build the payload for send review view
    final payload = <String, dynamic>{
      'selectedData': {
        'sendAmount': state.sendAmount,
        'receiveAmount': state.receiverAmount,
        'sendCurrency': state.sendCurrency,
        'receiveCurrency': state.receiverCurrency,
        'sendCountry': state.sendCountry,
        'receiveCountry': state.receiverCountry,
        'senderDeliveryMethod': state.selectedSenderDeliveryMethod,
        'recipientDeliveryMethod':
            recipientData['recipientDeliveryMethod'] ??
            selectedData['recipientDeliveryMethod'] ??
            '',
        'senderChannelId': state.selectedSenderChannelId,
        if (resolvedChannelId != null) 'recipientChannelId': resolvedChannelId,
        'networkId': selectedNetwork?.id ?? recipientData['networkId'] ?? '',
        'networkName':
            selectedNetwork?.name ??
            recipientData['networkName'] ??
            recipientData['bankName'] ??
            'Bank Transfer',
        'accountNumberType': selectedNetwork?.accountNumberType ?? 'bank',
      },
      'recipientData': recipientData,
      'senderData': senderData,
    };

    AppLogger.info(
      '📤 Pushing to sendReviewView with payload from add recipients',
    );
    try {
      await appRouter.pushNamed(AppRoute.sendReviewView, arguments: payload);
      AppLogger.info('✅ Successfully navigated to sendReviewView');
    } catch (e) {
      AppLogger.error('❌ Failed to navigate to sendReviewView: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to navigate. Please try again.',
          isError: true,
        );
      }
    }
  }

  Widget _buildSendButton(SendState state) {
    final viewModel = ref.watch(sendViewModelProvider.notifier);
    final isAmountValid = viewModel.isSendAmountValid;
    final parsedSend = double.tryParse(state.sendAmount) ?? 0.0;
    final hasValidAmount =
        isAmountValid && state.sendAmount.isNotEmpty && parsedSend > 0;
    final isLoading = _isCheckingWallet;
    final sameCurrency = viewModel.isSameFiatCurrency;
    final hasRates =
        sameCurrency || (state.hasValidRates && !state.showRatesLoading);
    final isButtonEnabled =
        _isCryptoSend
            ? hasValidAmount
            : hasValidAmount && viewModel.hasRequiredChannels && hasRates;

    final buttonText = _getSendButtonText(
      state,
      viewModel,
      isAmountValid,
      isLoading,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: PrimaryButton(
      text: buttonText == 'Continue' ? 'Review Transfer' : buttonText,
      onPressed:
          isButtonEnabled
              ? () async {
                setState(() => _isCheckingWallet = true);
                try {
                  final balanceFuture = _hasInsufficientBalance(state);
                  final kycFuture =
                      KycFlowNavigation.refreshAndCanSendMoney(ref);
                  final results = await Future.wait<bool>([
                    balanceFuture,
                    kycFuture,
                  ]);
                  if (!mounted) return;

                  final insufficient = results[0];
                  final canSend = results[1];

                  if (insufficient) {
                    _showInsufficientBalanceDialog();
                    return;
                  }
                  if (!canSend) {
                    await KycFlowNavigation.startUpgrade(
                      context,
                      ref: ref,
                      showBackButton: true,
                      showIntro: false,
                    );
                    return;
                  }

                  await _navigateToRecipientScreen(
                    state,
                    skipBalanceCheck: true,
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isCheckingWallet = false);
                  }
                }
              }
              : null,
      isLoading: isLoading,
      height: 50,
      backgroundColor:
          isButtonEnabled
              ? AppColors.purple500
              : AppColors.purple500ForTheme(context).withOpacity(0.12),
      textColor:
          isButtonEnabled
              ? AppColors.neutral0
              : AppColors.neutral0.withOpacity(.20),
      fontFamily: 'Chirp',
      letterSpacing: -.250,
      fontSize: 18,
      width: double.infinity,
      fullWidth: true,
      borderRadius: 48,
      ),
    );
  }

  String _getSendButtonText(
    SendState state,
    SendViewModel viewModel,
    bool isAmountValid,
    bool isCheckingWallet,
  ) {
    if (state.isLoading) {
      return 'Loading...';
    }

    // Show "Fetching rates..." when rates are being loaded
    if (state.showRatesLoading &&
        state.selectedDeliveryMethod.toLowerCase() != 'crypto') {
      return 'Fetching rates...';
    }

    if (!isAmountValid) {
      final message = viewModel.sendAmountValidation.message;
      if (message != null && message.isNotEmpty) return message;
      return 'Enter valid amount';
    }

    return 'Continue';
  }

  String _currencySymbolFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currency ';
    }
  }

  // Helper function to get the canonical name for sorting
}
