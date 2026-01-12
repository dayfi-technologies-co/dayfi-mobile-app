import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/common/utils/number_formatter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
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

  // Track last fetched country/currency to avoid duplicate rate API calls
  String? _lastFetchedSendCountry;
  String? _lastFetchedSendCurrency;

  // Track last wallet fetch to avoid duplicate API calls
  DateTime? _lastWalletFetchTime;

  // Route argument helpers (populated when opened via named route)
  BeneficiaryWithSource? _initialBeneficiaryWithSource;
  bool _openedFromRecipients = false;
  bool _didLoadRouteArgs = false;

  // Stored data from send_add_recipients_view
  Map<String, dynamic>? _recipientData;
  Map<String, dynamic>? _selectedData;
  Map<String, dynamic>? _senderData;

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

      // Set receiver country and currency from route arguments BEFORE initialization
      // This ensures that when navigating from select_delivery_method_view or
      // send_add_recipients_view, the selected country/currency is preserved
      if (_selectedData != null) {
        // Update receiver country and currency from selected data BEFORE initialize
        final receiveCountry = _selectedData!['receiveCountry'] as String?;
        final receiveCurrency = _selectedData!['receiveCurrency'] as String?;
        if (receiveCountry != null &&
            receiveCountry.isNotEmpty &&
            receiveCurrency != null &&
            receiveCurrency.isNotEmpty) {
          viewModel.updateReceiveCountry(receiveCountry, receiveCurrency);
        }

        final recipientDeliveryMethod =
            _selectedData!['recipientDeliveryMethod'] as String?;
        if (recipientDeliveryMethod != null &&
            recipientDeliveryMethod.isNotEmpty) {
          viewModel.updateDeliveryMethod(recipientDeliveryMethod);
        }
      }

      // Initialize viewmodel if needed (will preserve receiver country/currency set above)
      if (!viewModel.isInitialized && !viewModel.isInitializing) {
        try {
          await viewModel.initialize();
        } catch (e) {
          // Log error but don't crash the app
        }
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
        try {
          await ref.read(homeViewModelProvider.notifier).fetchWalletDetails();
          _lastWalletFetchTime = now;
        } catch (e) {
          AppLogger.error('Error fetching wallet balance: $e');
        }
      }

      analyticsService.trackScreenView(screenName: 'SendView');
    });
  }

  Future<bool> _checkWalletBalanceAndNavigate(SendState state) async {
    try {
      // Set loading state
      if (mounted) {
        setState(() {
          _isCheckingWallet = true;
        });
      }

      // Fetch wallet details and transactions in parallel
      final homeViewModel = ref.read(homeViewModelProvider.notifier);
      final transactionsNotifier = ref.read(transactionsProvider.notifier);

      await Future.wait([
        homeViewModel.fetchWalletDetails(),
        transactionsNotifier.loadTransactions(),
      ]);

      // Check balance after a short delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        final homeState = ref.read(homeViewModelProvider);
        final transactionsState = ref.read(transactionsProvider);

        // Check if wallets list is empty
        if (homeState.wallets.isEmpty) {
          // Reset loading state before showing dialog
          setState(() {
            _isCheckingWallet = false;
          });

          // Show dialog before navigating
          _showInsufficientBalanceDialog();
          return true;
        }

        final balance = homeState.balance;

        // Calculate available balance (current balance - pending transactions)
        final availableBalance =
            AvailableBalanceCalculator.calculateAvailableBalance(
              balance,
              transactionsState.transactions,
              currency: homeState.currency,
            );

        // Get send amount
        final sendAmount =
            double.tryParse(state.sendAmount.replaceAll(',', '')) ?? 0.0;
        final fee = double.tryParse(state.fee.replaceAll(',', '')) ?? 0.0;
        final totalAmount = sendAmount + fee;

        // Check if available balance is insufficient
        if (balance.isEmpty ||
            balance == '0.00' ||
            availableBalance <= 0 ||
            availableBalance < totalAmount) {
          // Reset loading state before showing dialog
          setState(() {
            _isCheckingWallet = false;
          });

          // Show dialog with pending transaction info if applicable
          final pendingCount =
              AvailableBalanceCalculator.getPendingTransactionCount(
                transactionsState.transactions,
              );
          _showInsufficientBalanceDialog(pendingTransactionCount: pendingCount);
          return true;
        }
      }

      // Reset loading state if balance is sufficient
      if (mounted) {
        setState(() {
          _isCheckingWallet = false;
        });
      }

      return false;
    } catch (e) {
      // Reset loading state on error
      if (mounted) {
        setState(() {
          _isCheckingWallet = false;
        });
      }
      // Log error but don't crash the app
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
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SendPaymentMethodView(
                  selectedData: {},
                  recipientData: {},
                  senderData: {},
                  paymentData: {},
                ),
          ),
        );
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
            ref.read(homeViewModelProvider.notifier).fetchWalletDetails();
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
    String receiveCountry =
        beneficiary.country.isNotEmpty ? beneficiary.country : 'NG';
    // Derive currency from country code
    String receiveCurrency = _getCurrencyFromCountry(receiveCountry);

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
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);

    // Listen to state changes and update controllers safely
    ref.listen(sendViewModelProvider, (previous, next) async {
      // --- Detect delivery method change and trigger re-initialization ---
      if (_lastDeliveryMethod != null &&
          next.selectedDeliveryMethod != _lastDeliveryMethod) {
        // Only re-initialize if the delivery method actually changed
        _lastDeliveryMethod = next.selectedDeliveryMethod;
        try {
          await ref.read(sendViewModelProvider.notifier).forceReinitialize();
        } catch (e) {
          // Log error but don't crash the app
          // print('Error re-initializing on delivery method change: $e');
        }
      } else {
        _lastDeliveryMethod = next.selectedDeliveryMethod;
      }

      // ---- Handle SEND amount ----
      if (previous?.sendAmount != next.sendAmount &&
          !_isUpdatingSendController) {
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
    });

    // Ensure keyboard is dismissed when building the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !_sendAmountFocus.hasFocus &&
          !_receiveAmountFocus.hasFocus) {
        FocusScope.of(context).unfocus();
      }

      // Restore controller text when state has values but controller is empty
      if (mounted && !_sendAmountFocus.hasFocus) {
        if (sendState.sendAmount.isNotEmpty &&
            _sendAmountController.text.isEmpty) {
          _isUpdatingSendController = true;
          final formattedSend = StringUtils.formatNumberWithCommas(
            sendState.sendAmount,
          );
          _sendAmountController.value = TextEditingValue(
            text: formattedSend,
            selection: TextSelection.collapsed(offset: formattedSend.length),
          );
          _isUpdatingSendController = false;
        } else if (sendState.sendAmount.isEmpty &&
            _sendAmountController.text.isNotEmpty) {
          // Clear stale controller text when state values are empty
          _isUpdatingSendController = true;
          _sendAmountController.clear();
          _isUpdatingSendController = false;
        }
      }

      if (mounted && !_receiveAmountFocus.hasFocus) {
        if (sendState.receiverAmount.isNotEmpty &&
            _receiveAmountController.text.isEmpty) {
          _isUpdatingReceiveController = true;
          final formattedReceive = StringUtils.formatNumberWithCommas(
            sendState.receiverAmount,
          );
          _receiveAmountController.value = TextEditingValue(
            text: formattedReceive,
            selection: TextSelection.collapsed(offset: formattedReceive.length),
          );
          _isUpdatingReceiveController = false;
        } else if (sendState.receiverAmount.isEmpty &&
            _receiveAmountController.text.isNotEmpty) {
          // Clear stale controller text when state values are empty
          _isUpdatingReceiveController = true;
          _receiveAmountController.clear();
          _isUpdatingReceiveController = false;
        }
      }
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
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isWide ? 24 : 18,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        "Enter the amount you want to send to ${_getCountryName(sendState.receiverCountry)} (${sendState.receiverCurrency}) via ${_getDeliveryMethodDisplayName(sendState.selectedDeliveryMethod)}${_getNetworkName().isNotEmpty ? ' (${_getNetworkName()})' : ''}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Chirp',
                                          letterSpacing: -.25,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: 32),
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
                                          // Sender Delivery Method Section (commented out)
                                          // AnimatedContainer(
                                          //   duration: const Duration(milliseconds: 350),
                                          //   curve: Curves.easeInOut,
                                          //   child: _buildSenderDeliveryMethodSection(sendState),
                                          // ),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            height: 12,
                                            child: const SizedBox.shrink(),
                                          ),
                                          // Receive Amount Section
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: _buildReceiveAmountSection(
                                              sendState,
                                            ),
                                          ),
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
                    suffixIcon: GestureDetector(
                      // onTap: () => _showSendCountryBottomSheet(state),
                      child: SizedBox(
                        // padding: EdgeInsets.symmetric(
                        //   horizontal: 8,
                        //   vertical: 8,
                        // ),
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
                              _getFlagPath(state.sendCountry),
                              height: 24.00000,
                            ),
                            SizedBox(width: 6),
                            Text(
                              state.sendCurrency,
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
              // SizedBox(height: 4),
              _buildQuickAmountOptions(state),
            ],
          ),
        ),

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
          'Recipient gets',
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
    // Common quick amounts (NGN-centric). Adjust as needed per currency.
    final amounts = [2000.0, 5000.0, 10000.0];

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
                                      .withOpacity(.15)
                                  : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            width: 1,
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(.05)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '₦${display.split('.').first}',
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

  // Helper function to get recipient info text
  String _getRecipientInfoText() {
    // Try beneficiary data first (from recipients screen)
    if (_initialBeneficiaryWithSource != null) {
      final name = _initialBeneficiaryWithSource!.beneficiary.name;
      if (name.isNotEmpty) {
        return 'to $name';
      }
    }

    // Try recipient data (from add recipients view)
    if (_recipientData != null && _recipientData!['name'] != null) {
      final name = _recipientData!['name'] as String;
      if (name.isNotEmpty) {
        return 'to $name';
      }
    }

    // No recipient info available
    return '';
  }

  // Helper function to get delivery method display name
  String _getDeliveryMethodDisplayName(String? method) {
    if (method == null) return 'Unknown';
    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return 'Dayfi Tag';
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
                    final sendState = ref.watch(sendViewModelProvider);

                    return Text(
                      '₦${sendState.fee}',
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
                  final fee = double.tryParse(state.fee) ?? 0.0;
                  final sendAmount = double.tryParse(state.sendAmount) ?? 0.0;
                  final total = fee + sendAmount;
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
                    state.receiverCurrency == 'NGN'
                        ? '₦1 = ₦1'
                        : state.exchangeRate,
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

  Future<void> _navigateToRecipientScreen(SendState state) async {
    // Dismiss keyboard when continue button is pressed
    FocusScope.of(context).unfocus();

    AppLogger.info('🚀 _navigateToRecipientScreen called');

    // Check wallet balance first
    final shouldNavigateToPayment = await _checkWalletBalanceAndNavigate(state);
    if (shouldNavigateToPayment) {
      AppLogger.info(
        '⚠️ Navigating to payment method due to insufficient balance',
      );
      return; // Balance is insufficient, already navigated to payment method view
    }

    AppLogger.info('✅ Wallet balance check passed');

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
          message: 'Failed to verify Dayfi Tag. Please try again.',
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
    final selectedNetwork =
        source.networkId != null
            ? state.networks.firstWhere(
              (n) => n.id == source.networkId,
              orElse: () => Network(id: null, name: null),
            )
            : null;

    AppLogger.info('Network found: ${selectedNetwork?.name}');

    // Attempt to resolve a channel ID from the network's channelIds
    String resolvedRecipientChannelId = '';
    if (selectedNetwork?.channelIds != null &&
        selectedNetwork!.channelIds!.isNotEmpty) {
      // Prefer a channel that exists in state.channels and matches criteria
      final candidate = state.channels.firstWhere(
        (ch) => selectedNetwork.channelIds!.contains(ch.id ?? ''),
        orElse: () => Channel(id: null),
      );

      if (candidate.id != null) {
        resolvedRecipientChannelId = candidate.id!;
      } else {
        // Fallback to first channel id string from the network
        resolvedRecipientChannelId = selectedNetwork.channelIds!.first;
      }
    }

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
        // Use resolved channel id if we could find one from the network, else empty
        'recipientChannelId':
            resolvedRecipientChannelId.isNotEmpty
                ? resolvedRecipientChannelId
                : (source.networkId ?? ''),
        // networkId should be the network's id (not a channel id)
        'networkId': selectedNetwork?.id ?? (source.networkId ?? ''),
        'networkName': selectedNetwork?.name ?? 'Bank Transfer',
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
        'networkId': source.networkId ?? '',
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

    // Find the network object for the recipient's networkId
    final selectedNetwork =
        recipientData['networkId'] != null
            ? state.networks.firstWhere(
              (n) => n.id == recipientData['networkId'],
              orElse: () => Network(id: null, name: null),
            )
            : null;

    AppLogger.info('Network found: ${selectedNetwork?.name}');

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
        'recipientChannelId':
            recipientData['recipientChannelId'] ??
            selectedData['recipientChannelId'] ??
            '',
        'networkId': selectedNetwork?.id ?? recipientData['networkId'] ?? '',
        'networkName': selectedNetwork?.name ?? 'Bank Transfer',
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
    final hasRates = state.hasValidRates && !state.showRatesLoading;
    final isButtonEnabled =
        hasValidAmount && state.channels.isNotEmpty && hasRates;

    return PrimaryButton(
      text: 'Review Transfer',
      onPressed:
          isButtonEnabled
              ? () async {
                // 1. Check for insufficient funds
                final homeState = ref.read(homeViewModelProvider);
                final balance = homeState.balance;
                final balanceValue =
                    double.tryParse(balance.replaceAll(',', '')) ?? 0.0;
                if (balance.isEmpty ||
                    balance == '0.00' ||
                    balanceValue <= 0 ||
                    balanceValue < parsedSend) {
                  _showInsufficientBalanceDialog();
                  return;
                }
                // 2. Check user tier
                final profileState = ref.read(profileViewModelProvider);
                final user = profileState.user;
                final userTierLevel = TierUtils.getCurrentTierLevel(user);
                if (userTierLevel == 1) {
                  Navigator.pushNamed(
                    context,
                    AppRoute.uploadDocumentsView,
                    arguments: {'showBackButton': true},
                  );
                  return;
                }
                // 3. Proceed as normal
                _navigateToRecipientScreen(state);
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
    if (state.showRatesLoading) {
      return 'Fetching rates...';
    }

    if (!isAmountValid) {
      // if (state.sendAmount.isEmpty) {
      //   return 'Enter amount to continue';
      // }

      final cleanAmount = state.sendAmount.replaceAll(RegExp(r'[,\s]'), '');
      final sendAmount = double.tryParse(cleanAmount);

      if (sendAmount == null || sendAmount <= 0) {
        return 'Enter valid amount';
      }

      // Hard limits - 1000 minimum for dayfi_tag, 2000 for others
      const hardMaximumLimit = 5000000.0;

      if (state.selectedDeliveryMethod.toLowerCase() == 'dayfi_tag') {
        const dayfiTagMinimum = 1000.0;
        if (sendAmount < dayfiTagMinimum) {
          final minAmount =
              StringUtils.formatCurrency(
                dayfiTagMinimum.toStringAsFixed(2),
                state.sendCurrency,
              ).split('.')[0];
          return 'Minimum amount is $minAmount';
        }
      } else {
        const otherMethodsMinimum = 2000.0;
        if (sendAmount < otherMethodsMinimum) {
          final minAmount =
              StringUtils.formatCurrency(
                otherMethodsMinimum.toStringAsFixed(2),
                state.sendCurrency,
              ).split('.')[0];
          return 'Minimum amount is $minAmount';
        }
      }

      if (sendAmount > hardMaximumLimit) {
        final maxAmount =
            StringUtils.formatCurrency(
              hardMaximumLimit.toStringAsFixed(2),
              state.sendCurrency,
            ).split('.')[0];
        return 'Maximum amount is $maxAmount';
      }

      return 'Enter valid amount';
    }

    return 'Continue';
  }

  // Helper function to get the canonical name for sorting
}
