import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
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
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView>
    with WidgetsBindingObserver {
  final TextEditingController _sendAmountController = TextEditingController();
  final TextEditingController _receiveAmountController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _sendAmountFocus = FocusNode();
  final FocusNode _receiveAmountFocus = FocusNode();
  bool _isCheckingWallet = false;

  // Route argument helpers (populated when opened via named route)
  BeneficiaryWithSource? _initialBeneficiaryWithSource;
  bool _openedFromRecipients = false;
  bool _didLoadRouteArgs = false;

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

      // Only initialize if not already initialized or initializing
      final viewModel = ref.read(sendViewModelProvider.notifier);
      if (!viewModel.isInitialized && !viewModel.isInitializing) {
        try {
          await viewModel.initialize();
        } catch (e) {
          // Log error but don't crash the app
          print('Error initializing SendView: $e');
        }
      } else {
        // If already initialized, restore controller values from state
        final state = ref.read(sendViewModelProvider);
        if (state.sendAmount.isNotEmpty) {
          _isUpdatingSendController = true;
          final formattedSend = StringUtils.formatNumberWithCommas(
            state.sendAmount,
          );
          _sendAmountController.value = TextEditingValue(
            text: formattedSend,
            selection: TextSelection.collapsed(offset: formattedSend.length),
          );
          _isUpdatingSendController = false;
        }
        if (state.receiverAmount.isNotEmpty) {
          _isUpdatingReceiveController = true;
          final formattedReceive = StringUtils.formatNumberWithCommas(
            state.receiverAmount,
          );
          _receiveAmountController.value = TextEditingValue(
            text: formattedReceive,
            selection: TextSelection.collapsed(offset: formattedReceive.length),
          );
          _isUpdatingReceiveController = false;
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

      // Fetch wallet details
      final homeViewModel = ref.read(homeViewModelProvider.notifier);
      await homeViewModel.fetchWalletDetails();

      // Check balance after a short delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        final homeState = ref.read(homeViewModelProvider);

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

        // Check if balance is empty or zero
        final balanceValue =
            double.tryParse(balance.replaceAll(',', '')) ?? 0.0;

        // Get send amount
        final sendAmount =
            double.tryParse(state.sendAmount.replaceAll(',', '')) ?? 0.0;
        final fee = double.tryParse(state.fee.replaceAll(',', '')) ?? 0.0;
        final totalAmount = sendAmount + fee;

        // Check if balance is insufficient
        if (balance.isEmpty ||
            balance == '0.00' ||
            balanceValue <= 0 ||
            balanceValue < totalAmount) {
          // Reset loading state before showing dialog
          setState(() {
            _isCheckingWallet = false;
          });

          // Show dialog before navigating
          _showInsufficientBalanceDialog();
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
  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildInsufficientBalanceDialog(),
    );
  }

  // Insufficient Balance Dialog Widget
  Widget _buildInsufficientBalanceDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBalanceDialogIcon(),
            SizedBox(height: 24.h),
            _buildBalanceDialogTitle(),
            SizedBox(height: 16.h),
            _buildBalanceDialogButtons(),
          ],
        ),
      ),
    );
  }

  // Dialog Icon
  Widget _buildBalanceDialogIcon() {
    return Container(
      width: 80.w,
      height: 80.w,
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
      //   size: 40.sp,
      // ),
    );
  }

  // Dialog Title
  Widget _buildBalanceDialogTitle() {
    return Text(
      "Your wallet balance is too low to send this amount. Please add funds and try again.",
      style: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 20.sp,
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
        SizedBox(height: 12.h),
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
      borderRadius: 38.r,
      height: 48.000.h,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Karla',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
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
      height: 48.000.h,
      borderRadius: 38.r,
      fontFamily: 'Karla',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
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
        }
      }
      _didLoadRouteArgs = true;
    }
  }

  /// Configure send state based on beneficiary data
  void _configureSendStateForBeneficiary() {
    if (_initialBeneficiaryWithSource == null) return;

    final beneficiary = _initialBeneficiaryWithSource!.beneficiary;
    final source = _initialBeneficiaryWithSource!.source;
    final viewModel = ref.read(sendViewModelProvider.notifier);

    // Determine delivery method based on account type
    String deliveryMethod = '';
    String receiveCurrency = 'NGN';
    String receiveCountry =
        beneficiary.country.isNotEmpty ? beneficiary.country : 'NG';

    if (source.accountType?.toLowerCase() == 'dayfi') {
      deliveryMethod = 'dayfi_tag';
    } else if (source.accountType?.toLowerCase() == 'bank') {
      deliveryMethod = 'bank_transfer';
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
    ref.listen(sendViewModelProvider, (previous, next) {
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
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "Send Money",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 19.sp,
              // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   Padding(
          //     padding: EdgeInsets.only(right: 18.w),
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
          //         height: 32.sp,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: RefreshIndicator(
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
              print('Error refreshing SendView: $e');
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transfer Limit Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color:
                        sendState.channels.isEmpty
                            ? AppColors.warning500.withOpacity(0.1)
                            : Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8.r),
                    border:
                        sendState.channels.isEmpty
                            ? Border.all(
                              color: AppColors.warning500.withOpacity(0.3),
                              width: 1.0,
                            )
                            : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 4.w),
                      Image.asset("assets/images/idea.png", height: 20.h),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          sendState.channels.isEmpty
                              ? "Channels not available. Only Dayfi tag transfer available (NGN only)."
                              : "Send funds via dayfi tag (NGN only), bank transfer, mobile money or wallet address.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 14.sp,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                            height: 1.5,
                            color:
                                sendState.channels.isEmpty
                                    ? AppColors.warning500
                                    : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Column(
                  children: [
                    // Send Amount Section
                    _buildSendAmountSection(sendState),

                    SizedBox(height: 24.h),
                    _buildExchangeRateSection(sendState),

                    // Sender Delivery Method Section
                    // _buildSenderDeliveryMethodSection(sendState),
                    SizedBox(height: 12.h),

                    // Receive Amount Section
                    _buildReceiveAmountSection(sendState),

                    SizedBox(height: 18.h),

                    // Recipient Delivery Method Section
                    _buildRecipientDeliveryMethodSection(sendState),
                  ],
                ),
                SizedBox(height: 36.h),

                // Send Button
                _buildSendButton(sendState),
                SizedBox(height: 112.h),
              ],
            ),
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
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -.3,
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
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: AppColors.neutral500.withOpacity(0.1)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: TextField(
                  cursorColor: AppColors.primary600,
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
                    }
                  },
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 27.sp,
                    letterSpacing: -.3,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 27.sp,
                      letterSpacing: -.3,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(.25),
                    ),
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      right: 16.w,
                      top: 16.h,
                      bottom: 16.h,
                      left: -4.w,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => _showSendCountryBottomSheet(state),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        margin: EdgeInsets.only(right: 0.w),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(.5),
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // add country flag
                            SvgPicture.asset(
                              _getFlagPath(state.sendCountry),
                              height: 24.00000.h,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              state.sendCurrency,
                              style: AppTypography.bodyMedium.copyWith(
                                fontFamily: 'Karla',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                // color: AppColors.primary600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 4.h),
              // _buildQuickAmountOptions(state),
            ],
          ),
        ),

        // SizedBox(height: 8.h),
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
        //             fontFamily: 'Karla',
        //             fontSize: 12.5.sp,
        //             fontWeight: FontWeight.w400,
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
        //             fontFamily: 'Karla',
        //             fontSize: 13.sp,
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
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -.3,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: AppColors.neutral500.withOpacity(0.1)),
            ],
          ),
          child: TextField(
            cursorColor: AppColors.primary600,
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
              fontFamily: 'Karla',
              fontSize: 27.sp,
              letterSpacing: -.3,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.bodyLarge.copyWith(
                fontFamily: 'Karla',
                fontSize: 27.sp,
                letterSpacing: -.3,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(.25),
              ),
              fillColor: Theme.of(context).colorScheme.surface,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                right: 16.w,
                top: 16.h,
                bottom: 16.h,
                left: -4.w,
              ),
              suffixIcon: GestureDetector(
                onTap: () => _showReceiveCountryBottomSheet(state),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  margin: EdgeInsets.only(right: 0.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(.5),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // add country flag
                      SvgPicture.asset(
                        _getFlagPath(state.receiverCountry),
                        height: 24.00000.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        state.receiverCurrency,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          // color: AppColors.primary600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
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

  /// Get simplified delivery method type (just the main category)
  String _getDeliveryMethodType(String? method) {
    if (method == null || method.isEmpty) {
      return 'Select method';
    }

    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return 'DayFi Tag';
      case 'bank_transfer':
      case 'bank':
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'Bank Transfer';
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

  /// Get delivery duration based on method type
  String _getDeliveryDuration(
    String? method, {
    String? sendCurrency,
    String? receiverCurrency,
  }) {
    if (method == null || method.isEmpty) {
      return 'Select method';
    }

    final methodLower = method.toLowerCase();

    // For NGN to NGN bank transfers (peer-to-peer), show "Arrives immediately"
    final isNgnToNgn = sendCurrency == 'NGN' && receiverCurrency == 'NGN';
    final isBankTransfer =
        methodLower == 'bank_transfer' ||
        methodLower == 'bank' ||
        methodLower == 'p2p' ||
        methodLower == 'peer_to_peer' ||
        methodLower == 'peer-to-peer';

    if (isNgnToNgn && isBankTransfer) {
      return 'Instant delivery';
    }

    switch (methodLower) {
      case 'dayfi_tag':
        return 'Completely free — Instant delivery';
      case 'bank_transfer':
      case 'bank':
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'Fast delivery';
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'Instant delivery';
      case 'spenn':
        return 'Instant delivery';
      case 'cash_pickup':
      case 'cash':
        return 'Same day delivery';
      case 'wallet':
      case 'digital_wallet':
        return 'Instant delivery';
      case 'card':
      case 'card_payment':
        return 'Fast delivery';
      case 'crypto':
      case 'cryptocurrency':
        return 'Quick delivery';
      case 'digital_dollar':
      case 'stablecoins':
        return 'Instant delivery';
      default:
        return 'Fast delivery';
    }
  }

  Widget _getDeliveryMethodIcon(String? method) {
    if (method == null || method.isEmpty) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 34,
            color: AppColors.primary500,
          ),
          SvgPicture.asset(
            "assets/icons/svgs/payymentt.svg",
            height: 18,
            color: Colors.white,
          ),
        ],
      );
    }

    // Return specific icons for different delivery methods
    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 34,
                        color: AppColors.neutral700.withOpacity(.35),
            ),
            SvgPicture.asset(
              "assets/icons/svgs/at.svg",
              height: 26,
               color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
            ),
          ],
        );
      case 'bank_transfer':
      case 'bank':
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 34,
                      color: AppColors.neutral700.withOpacity(.35),
            ),
            SvgPicture.asset(
              "assets/icons/svgs/building-bank.svg",
              height: 26,
               color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
            ),
          ],
        );
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 34,
                       color: AppColors.neutral700.withOpacity(.35),
            ),
            SvgPicture.asset(
              "assets/icons/svgs/device-mobile.svg",
              height: 26,
             color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
            ),
          ],
        );
      case 'spenn':
        return SvgPicture.asset(
          'assets/icons/svgs/wallett.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'cash_pickup':
      case 'cash':
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'wallet':
      case 'digital_wallet':
        return SvgPicture.asset(
          'assets/icons/svgs/wallett.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'card':
      case 'card_payment':
        return SvgPicture.asset(
          'assets/icons/svgs/cardd.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'crypto':
      case 'cryptocurrency':
        return SvgPicture.asset(
          'assets/icons/svgs/cryptoo.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'digital_dollar':
      case 'stablecoins':
        return SvgPicture.asset(
          'assets/icons/svgs/cryptoo.svg',
          height: 32.sp,
          width: 32.sp,
        );
      default:
        // Default icon for unknown delivery methods
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 34,
                 color: AppColors.neutral700.withOpacity(.35),
            ),
            SvgPicture.asset(
              "assets/icons/svgs/building-bank.svg",
              height: 26,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
            ),
          ],
        );
    }
  }

  Widget _buildRecipientDeliveryMethodSection(SendState state) {
    final isDayfiTag = state.selectedDeliveryMethod.toLowerCase() == 'dayfi_tag';

    return GestureDetector(
      onTap:
          () => _showChannelTypesBottomSheet(
            context,
            state.receiverCountry,
            state.receiverCurrency,
            state,
          ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16.w,
          top: 16.h,
          bottom: 16.h,
          right: 12.w,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.purple500ForTheme(context).withOpacity(0),
            width: .75,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.0375),
              blurRadius: 8.0,
              offset: const Offset(0, 8),
              spreadRadius: .8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: _getDeliveryMethodIcon(state.selectedDeliveryMethod),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getDeliveryMethodType(state.selectedDeliveryMethod),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 18.sp,
                          letterSpacing: -.5,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (isDayfiTag)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning400.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Free',
                            style: AppTypography.labelSmall.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getDeliveryDuration(
                      state.selectedDeliveryMethod,
                      sendCurrency: state.sendCurrency,
                      receiverCurrency: state.receiverCurrency,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5.sp,
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4,
                      height: 1.3,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  // SizedBox(height: 2.h),
                  //     Text(
                  //       _getDeliveryDuration(
                  //         state.selectedDeliveryMethod,
                  //         sendCurrency: state.sendCurrency,
                  //         receiverCurrency: state.receiverCurrency,
                  //       ),
                  //       style: AppTypography.bodyLarge.copyWith(
                  //  color: AppColors.outlineDark,
                  //         fontSize: 12.sp,
                  //         fontWeight: FontWeight.w400,
                  //         fontFamily: 'Karla',
                  //         letterSpacing: -.3,
                  //         height: 1.2,
                  //       ),
                  //     ),
                ],
              ),
            ),
            SizedBox(width: 24.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateSection(SendState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Exchange Rates',
          //   style: AppTypography.bodyMedium.copyWith(
          //     fontFamily: 'Karla',
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.w600,
          //     color: AppColors.neutral800,
          //   ),
          // ),

          // Fee

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
                      fontFamily: 'Karla',
                      letterSpacing: -.3,
                      fontSize: 14.sp,
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
                  width: 20.w,
                  height: 20.w,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.primary600,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8.w),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Karla',
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.neutral800,
                //   ),
                // ),
              ] else if (state.exchangeRate.isNotEmpty &&
                  state.fee.isNotEmpty) ...[
                Text(
                  StringUtils.formatCurrency(state.fee, state.sendCurrency),
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 12.h),

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
                      fontFamily: 'Karla',
                      letterSpacing: -.3,
                      fontSize: 14.sp,
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
                  width: 20.w,
                  height: 20.w,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.primary600,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8.w),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Karla',
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.neutral800,
                //   ),
                // ),
              ] else if (state.exchangeRate.isNotEmpty &&
                  state.sendAmount.isNotEmpty) ...[
                () {
                  final fee = double.tryParse(state.fee) ?? 0.0;
                  final sendAmount = double.tryParse(state.sendAmount) ?? 0.0;
                  if (sendAmount <= 0 && fee <= 0) {
                    return const SizedBox.shrink();
                  }
                  final total = fee + sendAmount;
                  final formatted = StringUtils.formatCurrency(
                    total.toStringAsFixed(2),
                    state.sendCurrency,
                  );
                  return Text(
                    formatted,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }(),
              ],
            ],
          ),
          SizedBox(height: 12.h),

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
                      fontFamily: 'Karla',
                      letterSpacing: -.3,
                      fontSize: 14.sp,
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
                  width: 20.w,
                  height: 20.w,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.primary600,
                    size: 20,
                  ),
                ),
                // SizedBox(width: 8.w),
                // Text(
                //   'Calculating rates...',
                //   style: AppTypography.bodyLarge.copyWith(
                //     fontFamily: 'Karla',
                //     fontSize: 14.sp,
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
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
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
                  width: 20.w,
                  height: 20.w,
                  child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.primary600,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 12.h),

          // // Send Currency Rates
          // if (state.sendCurrencyRates != null) ...[
          //   _buildCurrencyRateRow(
          //     '${state.sendCurrency} (Send)',
          //     state.sendCurrencyRates!,
          //   ),
          //   SizedBox(height: 8.h),
          // ],

          // // Receive Currency Rates
          // if (state.receiveCurrencyRates != null) ...[
          //   _buildCurrencyRateRow(
          //     '${state.receiverCurrency} (Receive)',
          //     state.receiveCurrencyRates!,
          //   ),
          //   SizedBox(height: 8.h),
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

    AppLogger.info(
      'ℹ️ No beneficiary from recipients, proceeding with normal flow',
    );

    // Check if delivery method is Dayfi Tag - route to Dayfi ID view
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

        // Fetch wallet details to check if user has a Dayfi ID
        AppLogger.info('Checking for Dayfi ID...');
        final walletService = locator<WalletService>();
        final walletResponse = await walletService.fetchWalletDetails();

        // Check if any wallet has a non-empty Dayfi ID
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
          // User has a Dayfi ID, proceed to enter recipient's Dayfi ID
          AppLogger.info('User has Dayfi ID, navigating to send Dayfi ID view');
          appRouter.pushNamed(
            AppRoute.sendDayfiIdView,
            arguments: selectedData,
          );
        } else {
          // User doesn't have a Dayfi ID, navigate to explanation/creation view
          AppLogger.info(
            'User does not have Dayfi ID, navigating to explanation view',
          );
          final result = await appRouter.pushNamed(
            AppRoute.dayfiTagExplanationView,
          );

          // If user created a Dayfi Tag, refresh and proceed to send Dayfi ID view
          if (result == true || result == 'created') {
            AppLogger.info(
              'Dayfi Tag created, proceeding to send Dayfi ID view',
            );
            appRouter.pushNamed(
              AppRoute.sendDayfiIdView,
              arguments: selectedData,
            );
          }
        }
      } catch (e) {
        AppLogger.error('Error checking Dayfi ID: $e');

        // Reset loading state on error
        if (mounted) {
          setState(() {
            _isCheckingWallet = false;
          });
        }

        // Show error and navigate to explanation view as fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify Dayfi ID. Please try again.'),
            backgroundColor: AppColors.error500,
          ),
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
    print('🔵 SENDER CHANNEL ID: ${state.selectedSenderChannelId}');
    print('🟢 RECIPIENT CHANNEL ID: ${selectedChannel?.id}');

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
      'networkId': selectedChannel?.id,
      'networkName':
          selectedNetwork?.name ??
          selectedChannel?.channelType ??
          'Selected Network',
      'accountNumberType': selectedNetwork?.accountNumberType ?? 'phone',
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

    // Route to DayFi ID review for DayFi tags
    if (accountType == 'dayfi') {
      AppLogger.info('✅ Routing to DayFi ID Review');
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

      // Extract DayFi ID from beneficiary account number (without @ prefix)
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to navigate. Please try again.'),
              backgroundColor: AppColors.error500,
            ),
          );
        }
      }
      return;
    }

    // Route to SendReviewView for bank/mobile money transfers
    AppLogger.info('✅ Routing to Send Review View for bank/mobile transfer');

    final selectedNetwork =
        source.networkId != null
            ? state.networks.firstWhere(
              (n) => n.id == source.networkId,
              orElse: () => Network(id: null, name: null),
            )
            : null;

    AppLogger.info('Network found: ${selectedNetwork?.name}');

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
        'recipientChannelId': source.networkId ?? '',
        'networkId': source.networkId ?? '',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to navigate. Please try again.'),
            backgroundColor: AppColors.error500,
          ),
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
    final isLoading = state.isLoading || _isCheckingWallet;

    // Enable button if amount is valid (exchange rate will be calculated on next screen)
    final isButtonEnabled = hasValidAmount;

    return PrimaryButton(
      text: _getSendButtonText(
        state,
        viewModel,
        isButtonEnabled,
        _isCheckingWallet,
      ),
      onPressed:
          isLoading || !isButtonEnabled
              ? null
              : () {
                _navigateToRecipientScreen(state);
              },
      isLoading: isLoading,
      backgroundColor:
          !isButtonEnabled
              ? AppColors.purple500.withOpacity(.25)
              : AppColors.purple500,
      height: 48.000.h,
      textColor:
          !isButtonEnabled
              ? AppColors.neutral0.withOpacity(.65)
              : AppColors.neutral0,
      fontFamily: 'Karla',
      letterSpacing: -.8,
      fontSize: 18,
      width: 375.w,
      fullWidth: true,
      borderRadius: 40.r,
    );
  }

  String _getSendButtonText(
    SendState state,
    SendViewModel viewModel,
    bool isAmountValid,
    bool isCheckingWallet,
  ) {
    if (isCheckingWallet) {
      return 'Checking balance...';
    }

    if (state.isLoading) {
      return 'Loading...';
    }

    if (!isAmountValid) {
      if (state.sendAmount.isEmpty) {
        return 'Enter amount to continue';
      }

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

  void _showSendCountryBottomSheet(SendState state) {
    // Dismiss keyboard when opening bottom sheet
    FocusScope.of(context).unfocus();

    // Filter channels for deposit (send) countries - where user can send FROM
    final depositChannels =
        state.channels
            .where(
              (channel) =>
                  channel.rampType == 'deposit' &&
                  channel.status == 'active' &&
                  channel.currency != null &&
                  channel.country != null,
            )
            .toList();

    // Deduplicate by country-currency combination, keeping the one with highest max limit
    final uniqueDepositChannels = <String, Channel>{};
    for (final channel in depositChannels) {
      final key = '${channel.country} - ${channel.currency}';
      if (!uniqueDepositChannels.containsKey(key) ||
          (channel.max ?? 0) > (uniqueDepositChannels[key]?.max ?? 0)) {
        uniqueDepositChannels[key] = channel;
      }
    }

    // Always ensure NG-NGN is available for Dayfi tag transfers
    final ngnKey = 'NG - NGN';
    if (!uniqueDepositChannels.containsKey(ngnKey)) {
      uniqueDepositChannels[ngnKey] = Channel(
        country: 'NG',
        currency: 'NGN',
        rampType: 'deposit',
        status: 'active',
        min: 1000.0,
        max: 5000000.0,
      );
    }

    final finalDepositChannels =
        uniqueDepositChannels.values.toList()..sort(
          (a, b) => '${a.country ?? ''} - ${a.currency ?? ''}'.compareTo(
            '${b.country ?? ''} - ${b.currency ?? ''}',
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // Container(
                //   width: 40.w,
                //   height: 4.h,
                //   margin: EdgeInsets.symmetric(vertical: 12.h),
                //   decoration: BoxDecoration(
                //     color: AppColors.neutral400,
                //     borderRadius: BorderRadius.circular(2.r),
                //   ),
                // ),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 24.h, width: 22.w),
                      Text(
                        'Sending currency',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                        },
                        child: Image.asset(
                          "assets/icons/pngs/cancelicon.png",
                          height: 24.h,
                          width: 24.w,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final channelsToShow =
                          finalDepositChannels.isEmpty
                              ? (() {
                                final fallbackChannels =
                                    state.channels
                                        .where(
                                          (c) =>
                                              c.status == 'active' &&
                                              c.currency != null &&
                                              c.country != null &&
                                              (c.rampType == 'deposit' ||
                                                  c.rampType == 'receive' ||
                                                  c.rampType == 'funding'),
                                        )
                                        .toList();

                                // Deduplicate fallback channels too
                                final uniqueFallbackChannels =
                                    <String, Channel>{};
                                for (final channel in fallbackChannels) {
                                  final key =
                                      '${channel.country} - ${channel.currency}';
                                  if (!uniqueFallbackChannels.containsKey(
                                        key,
                                      ) ||
                                      (channel.max ?? 0) >
                                          (uniqueFallbackChannels[key]?.max ??
                                              0)) {
                                    uniqueFallbackChannels[key] = channel;
                                  }
                                }

                                final deduplicatedFallback =
                                    uniqueFallbackChannels.values.toList()..sort(
                                      (
                                        a,
                                        b,
                                      ) => '${a.country ?? ''} - ${a.currency ?? ''}'
                                          .compareTo(
                                            '${b.country ?? ''} - ${b.currency ?? ''}',
                                          ),
                                    );
                                return deduplicatedFallback;
                              })()
                              : finalDepositChannels;

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        itemCount: channelsToShow.length,
                        itemBuilder: (context, index) {
                          final channel = channelsToShow[index];
                          return channel.country == "NG"
                              ? ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.h,
                                ),
                                onTap: () {
                                  ref
                                      .read(sendViewModelProvider.notifier)
                                      .updateSendCountry(
                                        channel.country!,
                                        channel.currency!,
                                      );
                                  // print(channel.id);
                                  Navigator.pop(context);
                                  FocusScope.of(context).unfocus();
                                },
                                title: Row(
                                  children: [
                                    SvgPicture.asset(
                                      _getFlagPath(channel.country),
                                      height: 32.00000.h,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      _getCountryName(channel.country),
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontFamily: 'Karla',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                // subtitle: Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Text(
                                //       '${channel.vendorId ?? 'Unknown'} - ${channel.channelType ?? 'Unknown'} - ${channel.settlementType ?? 'Unknown'}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 12.sp,
                                //         color: AppColors.primary600,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     SizedBox(height: 1.h),
                                //     Text(
                                //       '${channel.rampType ?? 'Unknown'} - ${channel.status ?? 'Unknown'}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 11.sp,
                                //         color: AppColors.neutral600,
                                //         fontWeight: FontWeight.w400,
                                //       ),
                                //     ),
                                //     SizedBox(height: 2.h),
                                //     Text(
                                //       'Min: ${channel.min} ${channel.currency} | Max: ${channel.max} ${channel.currency}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 12.sp,
                                //         color: AppColors.neutral400,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                trailing: Text(
                                  '${channel.currency}',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontFamily: 'Karla',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // state.sendCountry == channel.country &&
                                //         state.sendCurrency == channel.currency
                                //     ? Icon(
                                //       Icons.check_circle,
                                //       color: AppColors.primary600,
                                //     )
                                //     : null,
                              )
                              : const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showReceiveCountryBottomSheet(SendState state) {
    // Dismiss keyboard when opening bottom sheet
    FocusScope.of(context).unfocus();

    // Filter channels for withdrawal (receive) countries - where user can send TO
    final withdrawalChannels =
        state.channels
            .where(
              (channel) =>
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout' ||
                      channel.rampType == 'deposit' ||
                      channel.rampType == 'receive') &&
                  channel.status == 'active' &&
                  channel.currency != null &&
                  channel.country != null,
            )
            .toList();

    // Deduplicate by country-currency combination, keeping the one with highest max limit
    final uniqueWithdrawalChannels = <String, Channel>{};
    for (final channel in withdrawalChannels) {
      final key = '${channel.country} - ${channel.currency}';
      if (!uniqueWithdrawalChannels.containsKey(key) ||
          (channel.max ?? 0) > (uniqueWithdrawalChannels[key]?.max ?? 0)) {
        uniqueWithdrawalChannels[key] = channel;
      }
    }

    // Always ensure NG-NGN is available for Dayfi tag transfers
    final ngnKey = 'NG - NGN';
    if (!uniqueWithdrawalChannels.containsKey(ngnKey)) {
      uniqueWithdrawalChannels[ngnKey] = Channel(
        country: 'NG',
        currency: 'NGN',
        rampType: 'withdrawal',
        status: 'active',
        min: 1000.0,
        max: 5000000.0,
      );
    }

    List<Channel> finalWithdrawalChannels =
        uniqueWithdrawalChannels.values.toList()..sort(
          (a, b) => '${a.country ?? ''} - ${a.currency ?? ''}'.compareTo(
            '${b.country ?? ''} - ${b.currency ?? ''}',
          ),
        );

    // If no withdrawal channels, let's try a different approach
    if (finalWithdrawalChannels.isEmpty) {
      // Try filtering by different criteria but still only withdrawal-related channels
      final alternativeChannels =
          state.channels
              .where(
                (channel) =>
                    channel.status == 'active' &&
                    channel.currency != null &&
                    channel.country != null &&
                    (channel.rampType == 'withdrawal' ||
                        channel.rampType == 'withdraw' ||
                        channel.rampType == 'payout' ||
                        channel.rampType == 'deposit' ||
                        channel.rampType == 'receive'),
              )
              .toList();

      // Use alternative channels if available, otherwise ensure NGN is there
      if (alternativeChannels.isNotEmpty) {
        finalWithdrawalChannels = alternativeChannels;
      } else {
        // Fallback: add NGN for Dayfi transfers
        finalWithdrawalChannels = [
          Channel(
            country: 'NG',
            currency: 'NGN',
            rampType: 'withdrawal',
            status: 'active',
            min: 1000.0,
            max: 5000000.0,
          ),
        ];
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.92,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 24.h, width: 22.w),
                          Text(
                            'Receiving currency',
                            style: AppTypography.titleLarge.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                            },
                            child: Image.asset(
                              "assets/icons/pngs/cancelicon.png",
                              height: 24.h,
                              width: 24.w,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Search field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: CustomTextField(
                        controller: _searchController,
                        label: '',
                        hintText: 'Search countries',
                        borderRadius: 40,
                        prefixIcon: Container(
                          width: 40.w,
                          alignment: Alignment.centerRight,
                          constraints: BoxConstraints.tightForFinite(),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/svgs/search-normal.svg',
                              height: 22.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // Get all channels
                          final allChannels =
                              finalWithdrawalChannels.isEmpty
                                  ? (() {
                                    final fallbackChannels =
                                        state.channels
                                            .where(
                                              (c) =>
                                                  c.status == 'active' &&
                                                  c.currency != null &&
                                                  c.country != null &&
                                                  (c.rampType == 'withdrawal' ||
                                                      c.rampType ==
                                                          'withdraw' ||
                                                      c.rampType == 'payout' ||
                                                      c.rampType == 'deposit' ||
                                                      c.rampType == 'receive'),
                                            )
                                            .toList();

                                    // Deduplicate fallback channels
                                    final uniqueFallbackChannels =
                                        <String, Channel>{};
                                    for (final channel in fallbackChannels) {
                                      final key =
                                          '${channel.country} - ${channel.currency}';
                                      if (!uniqueFallbackChannels.containsKey(
                                            key,
                                          ) ||
                                          (channel.max ?? 0) >
                                              (uniqueFallbackChannels[key]
                                                      ?.max ??
                                                  0)) {
                                        uniqueFallbackChannels[key] = channel;
                                      }
                                    }

                                    return uniqueFallbackChannels.values
                                        .toList();
                                  })()
                                  : finalWithdrawalChannels;

                          // Additional deduplication to ensure no duplicates
                          final uniqueChannels = <String, Channel>{};
                          for (final channel in allChannels) {
                            final key =
                                '${channel.country} - ${channel.currency}';
                            if (!uniqueChannels.containsKey(key)) {
                              uniqueChannels[key] = channel;
                            }
                          }
                          final deduplicatedChannels =
                              uniqueChannels.values.toList();

                          // Sort alphabetically by country name
                          deduplicatedChannels.sort((a, b) {
                            final countryA = _getCountryName(a.country);
                            final countryB = _getCountryName(b.country);
                            return countryA.compareTo(countryB);
                          });

                          // Filter based on search
                          final searchQuery =
                              _searchController.text.toLowerCase();
                          final filteredChannels =
                              deduplicatedChannels.where((channel) {
                                if (searchQuery.isEmpty) return true;

                                final countryName =
                                    _getCountryName(
                                      channel.country,
                                    ).toLowerCase();
                                final currency =
                                    channel.currency?.toLowerCase() ?? '';
                                final countryCode =
                                    channel.country?.toLowerCase() ?? '';

                                return countryName.contains(searchQuery) ||
                                    currency.contains(searchQuery) ||
                                    countryCode.contains(searchQuery);
                              }).toList();

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            itemCount: filteredChannels.length,
                            itemBuilder: (context, index) {
                              final channel = filteredChannels[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.h,
                                ),
                                onTap: () {
                                  ref
                                      .read(sendViewModelProvider.notifier)
                                      .updateReceiveCountry(
                                        channel.country!,
                                        channel.currency!,
                                      );
                                  Navigator.pop(context);
                                  FocusScope.of(context).unfocus();
                                },
                                // subtitle: Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Text(
                                //       '${channel.vendorId ?? 'Unknown'} - ${channel.channelType ?? 'Unknown'} - ${channel.settlementType ?? 'Unknown'}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 12.sp,
                                //         color: AppColors.primary600,
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     SizedBox(height: 1.h),
                                //     Text(
                                //       '${channel.rampType ?? 'Unknown'} - ${channel.status ?? 'Unknown'}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 11.sp,
                                //         color: AppColors.neutral600,
                                //         fontWeight: FontWeight.w400,
                                //       ),
                                //     ),
                                //     SizedBox(height: 2.h),
                                //     Text(
                                //       'Min: ${channel.min} ${channel.currency} | Max: ${channel.max} ${channel.currency}',
                                //       style: AppTypography.bodySmall.copyWith(
                                //         fontFamily: 'Karla',
                                //         fontSize: 12.sp,
                                //         color: AppColors.neutral400,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // state.receiverCountry == channel.country &&
                                //         state.receiverCurrency ==
                                //             channel.currency
                                //     ? Icon(
                                //       Icons.check_circle,
                                //       color: AppColors.primary600,
                                //     )
                                //     : null,
                                title: Row(
                                  children: [
                                    SvgPicture.asset(
                                      _getFlagPath(channel.country),
                                      height: 32.00000.h,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      _getCountryName(channel.country),
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontFamily: 'Karla',
                                        fontSize: 16.sp,
                                        letterSpacing: -.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '${channel.currency}',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontFamily: 'Karla',
                                    fontSize: 14.sp,
                                    letterSpacing: -.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  // Helper function to get the canonical name for sorting
  String _getCanonicalChannelName(String? channelType) {
    if (channelType == null) return 'zzz';
    final lower = channelType.toLowerCase();

    // DayFi Tag should always be first
    if (lower == 'dayfi_tag') return '000_dayfi_tag';
    if (lower == 'bank_transfer' || lower == 'bank') return '001_bank_transfer';
    if (lower == 'mobile_money' || lower == 'momo' || lower == 'mobilemoney') {
      return '002_mobile_money';
    }

    // Other allowed methods fall here
    return '999_$channelType';
  }

  void _showChannelTypesBottomSheet(
    BuildContext context,
    String country,
    String currency,
    SendState state,
  ) {
    // Dismiss keyboard when opening bottom sheet
    FocusScope.of(context).unfocus();
    // Filter channels by status, rampType, and country/currency
    final filteredChannels =
        state.channels
            .where(
              (channel) =>
                  channel.status == 'active' &&
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout' ||
                      channel.rampType == 'deposit' ||
                      channel.rampType == 'receive') &&
                  (channel.country == country || channel.currency == currency),
            )
            .toList();

    // Check if this is NGN to NGN transfer
    final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';

    // For NGN to NGN transfers, add DayFi Tag as an option if not already present
    if (isNgnToNgn) {
      final hasDayfiTag = filteredChannels.any(
        (channel) => channel.channelType?.toLowerCase() == 'dayfi_tag',
      );

      if (!hasDayfiTag) {
        // Create a synthetic DayFi Tag channel
        final dayfiTagChannel = Channel(
          channelType: 'dayfi_tag',
          country: country,
          currency: currency,
          status: 'active',
          rampType: 'withdrawal',
          min: 0,
          max: 999999999,
          id: 'dayfi_tag_synthetic',
        );
        filteredChannels.add(dayfiTagChannel);
      }
    }

    // Deduplicate channels by channelType to merge similar options
    final Map<String, Channel> uniqueChannels = {};
    for (final channel in filteredChannels) {
      // ...existing code...l type for merging
      final canonicalType = _getCanonicalChannelName(channel.channelType);

      // Keep the channel with the highest max limit if duplicates exist
      if (!uniqueChannels.containsKey(canonicalType)) {
        uniqueChannels[canonicalType] = channel;
      } else {
        final existing = uniqueChannels[canonicalType]!;
        if ((channel.max ?? 0) > (existing.max ?? 0)) {
          uniqueChannels[canonicalType] = channel;
        }
      }
    }

    // Sort channels by canonical channel name
    final allChannels =
        uniqueChannels.values.toList()..sort(
          (a, b) => _getCanonicalChannelName(
            a.channelType,
          ).compareTo(_getCanonicalChannelName(b.channelType)),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 24.h, width: 22.w),
                    Text(
                      'Delivery methods for $currency',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      },
                      child: Image.asset(
                        "assets/icons/pngs/cancelicon.png",
                        height: 24.h,
                        width: 24.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Auto-select DayFi Tag for NGN to NGN if no delivery method is selected
                    if (isNgnToNgn &&
                        state.selectedDeliveryMethod.isEmpty &&
                        allChannels.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // Find DayFi Tag channel
                        final dayfiTagChannel = allChannels.firstWhere(
                          (ch) => ch.channelType?.toLowerCase() == 'dayfi_tag',
                          orElse: () => allChannels[0],
                        );
                        ref
                            .read(sendViewModelProvider.notifier)
                            .updateDeliveryMethod(
                              dayfiTagChannel.channelType ?? 'Unknown',
                            );
                      });
                    } else if (!isNgnToNgn &&
                        state.selectedDeliveryMethod.isEmpty &&
                        allChannels.isNotEmpty) {
                      // For non-NGN to NGN, auto-select first channel
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(sendViewModelProvider.notifier)
                            .updateDeliveryMethod(
                              allChannels[0].channelType ?? 'Unknown',
                            );
                      });
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      itemCount: allChannels.length,
                      itemBuilder: (context, index) {
                        final channel = allChannels[index];
                        final isDayfiTag = channel.channelType?.toLowerCase() == 'dayfi_tag';

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(sendViewModelProvider.notifier)
                                  .updateDeliveryMethod(
                                    channel.channelType ?? 'Unknown',
                                  );

                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: 16.w,
                                top: 16.h,
                                bottom: 16.h,
                                right: 12.w,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: state.selectedDeliveryMethod == channel.channelType
                                      ? AppColors.purple500ForTheme(context).withOpacity(0.5)
                                      : AppColors.purple500ForTheme(context).withOpacity(0),
                                  width: .75,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neutral500.withOpacity(0.0375),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 8),
                                    spreadRadius: .8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.w,
                                    height: 32.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                    child: _getDeliveryMethodIcon(channel.channelType),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _getDeliveryMethodType(channel.channelType),
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontFamily: 'Karla',
                                                fontSize: 18.sp,
                                                letterSpacing: -.5,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            if (isDayfiTag)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 3.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warning400.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  'Free',
                                                  style: AppTypography.labelSmall.copyWith(
                                                    fontFamily: 'Karla',
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.warning600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          _getDeliveryDuration(
                                            channel.channelType,
                                            sendCurrency: state.sendCurrency,
                                            receiverCurrency: state.receiverCurrency,
                                          ),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 12.5.sp,
                                            fontFamily: 'Karla',
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.4,
                                            height: 1.3,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  if (state.selectedDeliveryMethod == channel.channelType)
                                    SvgPicture.asset(
                                      'assets/icons/svgs/circle-check.svg',
                                      color: AppColors.purple500ForTheme(context),
                                      width: 24.sp,
                                      height: 24.sp,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
