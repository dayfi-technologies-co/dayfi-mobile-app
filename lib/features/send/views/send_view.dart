import 'package:dayfi/common/widgets/buttons/primary_button.dart';
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
import 'send_recipient_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

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
      }

      analyticsService.trackScreenView(screenName: 'SendView');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    });

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere on the screen
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          title: Text(
            "Send Money",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 20.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transfer Limit Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4.r),
                    // border: Border.all(
                    //   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    //   width: 1.0,
                    // ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 4.w),
                      Image.asset(
                        "assets/images/idea.png",
                        height: 18.h,
                        // color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Please prepare your KYC documents in case we require verification to complete this transaction.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 12.5.sp,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                            height: 1.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

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

                    SizedBox(height: 16.h),

                    // Recipient Delivery Method Section
                    _buildRecipientDeliveryMethodSection(sendState),
                  ],
                ),
                SizedBox(height: 32.h),

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

  Widget _buildUpgradeCard() {
    final profileState = ref.watch(profileViewModelProvider);
    final user = profileState.user;

    // Only show upgrade card if user can upgrade
    if (!TierUtils.canUpgrade(user)) {
      return const SizedBox.shrink();
    }

    final tierDescription = TierUtils.getTierDescription(user);
    final nextTierInfo = TierUtils.getNextTierInfo(user);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: AppColors.warning400.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 4),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset("assets/icons/pngs/account_4.png", height: 40.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Increase transfer limit',
                  style: AppTypography.titleMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 19.00,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    text: tierDescription,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Karla',
                      letterSpacing: -.3,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: ' $nextTierInfo.',
                        style: TextStyle(
                          color: Color(0xFF2787A1),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Karla',
                          letterSpacing: -.4,
                          height: 1.2,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
            letterSpacing: -.6,
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
            controller: _sendAmountController,
            focusNode: _sendAmountFocus,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [NumberWithCommasFormatter()],
            enableInteractiveSelection: true,
            onChanged: (value) {
              if (!_isUpdatingSendController) {
                // Remove commas before sending to view model for calculations
                String cleanValue = NumberFormatterUtils.removeCommas(value);
                ref
                    .read(sendViewModelProvider.notifier)
                    .updateSendAmount(cleanValue);
              }
            },
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Karla',
              fontSize: 27.sp,
              letterSpacing: -.6,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.bodyLarge.copyWith(
                fontFamily: 'Karla',
                fontSize: 27.sp,
                letterSpacing: -.6,
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  margin: EdgeInsets.only(right: 0.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // add country flag
                      SvgPicture.asset(
                        _getFlagPath(state.sendCountry),
                        height: 24.000.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        state.sendCurrency,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          // color: AppColors.primary600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary600,
                        size: 16.sp,
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
            letterSpacing: -.6,
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
              letterSpacing: -.6,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.bodyLarge.copyWith(
                fontFamily: 'Karla',
                fontSize: 27.sp,
                letterSpacing: -.6,
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // add country flag
                      SvgPicture.asset(
                        _getFlagPath(state.receiverCountry),
                        height: 24.000.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        state.receiverCurrency,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          // color: AppColors.primary600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary600,
                        size: 16.sp,
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
  String _getDeliveryDuration(String? method) {
    if (method == null || method.isEmpty) {
      return 'Select method';
    }

    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return 'Completely free';
      case 'bank_transfer':
      case 'bank':
        return 'Arrives in 1-2 hours';
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'Arrives in minutes';
      case 'spenn':
        return 'Arrives in minutes';
      case 'cash_pickup':
      case 'cash':
        return 'Arrives in 24 hours';
      case 'wallet':
      case 'digital_wallet':
        return 'Arrives in minutes';
      case 'card':
      case 'card_payment':
        return 'Arrives in 1-3 hours';
      case 'crypto':
      case 'cryptocurrency':
        return 'Arrives in 10-30 minutes';
      case 'digital_dollar':
      case 'stablecoins':
        return 'Arrives in minutes';
      default:
        return 'Arrives in 1-2 hours';
    }
  }

  Widget _getDeliveryMethodIcon(String? method) {
    if (method == null || method.isEmpty) {
      return SvgPicture.asset(
        'assets/icons/svgs/paymentt.svg',
        height: 32.sp,
        width: 32.sp,
      );
    }

    // Return specific icons for different delivery methods
    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return SvgPicture.asset(
          'assets/icons/svgs/wallett.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'bank_transfer':
      case 'bank':
        return SvgPicture.asset(
          'assets/icons/svgs/bankk.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return SvgPicture.asset(
          'assets/icons/svgs/mobilee.svg',
          height: 32.sp,
          width: 32.sp,
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
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 32.sp,
          width: 32.sp,
        );
    }
  }

  Widget _buildRecipientDeliveryMethodSection(SendState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Method',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -.6,
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
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.neutral500.withOpacity(0.1),
            //     blurRadius: 2.0,
            //     offset: const Offset(0, 2),
            //     spreadRadius: 0.5,
            //   ),
            // ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(
              top: 8.h,
              bottom: 8.h,
              left: 18.w,
              right: 0.w,
            ),
            onTap:
                () => _showChannelTypesBottomSheet(
                  context,
                  state.receiverCountry,
                  state.receiverCurrency,
                  state,
                ),
            title: Row(
              children: [
                _getDeliveryMethodIcon(state.selectedDeliveryMethod),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDeliveryMethodType(state.selectedDeliveryMethod) ==
                              "P2p"
                          ? "Peer-to-Peer"
                          : _getDeliveryMethodType(
                            state.selectedDeliveryMethod,
                          ),
                      style: AppTypography.bodyLarge.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            state.selectedDeliveryMethod.isEmpty
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.4)
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _getDeliveryDuration(state.selectedDeliveryMethod),
                      style: AppTypography.bodyLarge.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Karla',
                        letterSpacing: -.3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
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
              ] else if (state.exchangeRate.isNotEmpty) ...[
                Text(
                  StringUtils.formatCurrency(state.fee, state.sendCurrency),
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
              ] else if (state.exchangeRate.isNotEmpty) ...[
                Text(
                  () {
                    final fee = double.tryParse(state.fee) ?? 0.0;
                    final sendAmount = double.tryParse(state.sendAmount) ?? 0.0;
                    final total = fee + sendAmount;
                    return StringUtils.formatCurrency(
                      total.toStringAsFixed(2),
                      state.sendCurrency,
                    );
                  }(),
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
                Text(
                  state.receiverCurrency == 'NGN'
                      ? '₦1 = ₦1'
                      : state.exchangeRate,
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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

  void _navigateToRecipientScreen(SendState state) {
    // Dismiss keyboard when continue button is pressed
    FocusScope.of(context).unfocus();

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendRecipientView(selectedData: selectedData),
      ),
    );
  }

  Widget _buildSendButton(SendState state) {
    final viewModel = ref.watch(sendViewModelProvider.notifier);
    final isAmountValid = viewModel.isSendAmountValid;

    return PrimaryButton(
      text: _getSendButtonText(state, viewModel, isAmountValid),
      onPressed:
          state.isLoading || !isAmountValid
              ? null
              : () {
                _navigateToRecipientScreen(state);
              },
      isLoading: state.isLoading,
      height: 60.h,
      backgroundColor:
          !isAmountValid
              ? AppColors.purple500.withOpacity(.25)
              : AppColors.purple500,
      textColor:
          !isAmountValid
              ? AppColors.neutral0.withOpacity(.25)
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
  ) {
    if (state.isLoading) {
      return 'Loading...';
    }

    if (!isAmountValid) {
      if (state.sendAmount.isEmpty) {
        return 'Enter amount to continue';
      }

      final sendAmount = double.tryParse(state.sendAmount);
      if (sendAmount == null || sendAmount <= 0) {
        return 'Enter valid amount';
      }

      if (viewModel.sendMinimumLimit != null &&
          sendAmount < viewModel.sendMinimumLimit!) {
        final minAmount =
            StringUtils.formatCurrency(
              viewModel.sendMinimumLimit!.toStringAsFixed(2),
              state.sendCurrency,
            ).split('.')[0];
        return 'Minimum amount is $minAmount';
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
                //     color: AppColors.neutral300,
                //     borderRadius: BorderRadius.circular(2.r),
                //   ),
                // ),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 22.h, width: 22.w),
                      Text(
                        'Sending currency',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 18.sp,
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
                          height: 22.h,
                          width: 22.w,
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
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                                      height: 24.000.h,
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
                                //         color: AppColors.neutral500,
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

      // Use alternative channels if available
      if (alternativeChannels.isNotEmpty) {
        finalWithdrawalChannels = alternativeChannels;
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
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 22.h, width: 22.w),
                          Text(
                            'Receiving currency',
                            style: AppTypography.titleLarge.copyWith(
                              fontFamily: 'CabinetGrotesk',
                              fontSize: 18.sp,
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
                              height: 22.h,
                              width: 22.w,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Search field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomTextField(
                        controller: _searchController,
                        label: '',
                        hintText: 'Search countries',
                        borderRadius: 40,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          size: 20.sp,
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
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                                //         color: AppColors.neutral500,
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
                                      height: 24.000.h,
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

  // Helper function to check if a channel type is allowed
  bool _isAllowedDeliveryMethod(String? channelType) {
    if (channelType == null) return false;
    final lower = channelType.toLowerCase();
    
    // Only allow these methods for now
    return lower == 'dayfi_tag' ||
        lower == 'bank_transfer' ||
        lower == 'bank' ||
        lower == 'mobile_money' ||
        lower == 'momo' ||
        lower == 'mobilemoney' ||
        lower == 'digital_dollar' ||
        lower == 'stablecoins';
  }

  // Helper function to get the canonical name for sorting
  String _getCanonicalChannelName(String? channelType) {
    if (channelType == null) return 'zzz';
    final lower = channelType.toLowerCase();
    
    // DayFi Tag should always be first
    if (lower == 'dayfi_tag') return '000_dayfi_tag';
    if (lower == 'bank_transfer' || lower == 'bank') return '001_bank_transfer';
    if (lower == 'mobile_money' || lower == 'momo' || lower == 'mobilemoney') return '002_mobile_money';
    if (lower == 'digital_dollar' || lower == 'stablecoins') return '003_digital_dollar';
    
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
    final filteredChannels = state.channels
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

    // Deduplicate channels by channelType to merge similar options
    final Map<String, Channel> uniqueChannels = {};
    for (final channel in filteredChannels) {
      // Use a canonical key based on the channel type for merging
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
    final allChannels = uniqueChannels.values.toList()
      ..sort(
        (a, b) => _getCanonicalChannelName(a.channelType).compareTo(
          _getCanonicalChannelName(b.channelType),
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
                //     color: AppColors.neutral300,
                //     borderRadius: BorderRadius.circular(2.r),
                //   ),
                // ),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 22.h, width: 22.w),
                      Text(
                        'Delivery methods for $currency',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 18.sp,
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
                          height: 22.h,
                          width: 22.w,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: currency == 'NGN' ? allChannels.length + 1 : allChannels.length,
                    itemBuilder: (context, index) {
                      // If currency is NGN, show DayFi Tag as first option
                      if (currency == 'NGN' && index == 0) {
                        // Auto-select DayFi Tag if no delivery method is selected
                        final isSelected = state.selectedDeliveryMethod.isEmpty || 
                                          state.selectedDeliveryMethod == 'dayfi_tag';
                        
                        // Auto-select on first render if nothing is selected
                        if (state.selectedDeliveryMethod.isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(sendViewModelProvider.notifier)
                                .updateDeliveryMethod('dayfi_tag');
                          });
                        }
                        
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          onTap: () {
                            ref
                                .read(sendViewModelProvider.notifier)
                                .updateDeliveryMethod('dayfi_tag');

                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          leading: _getDeliveryMethodIcon('dayfi_tag'),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DayFi Tag',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontFamily: 'CabinetGrotesk',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Instant • [Free]',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.3,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? SvgPicture.asset(
                                  'assets/icons/svgs/circle-check.svg',
                                  color: AppColors.purple500,
                                )
                              : null,
                        );
                      }

                      // Adjust index for API channels if DayFi Tag was added
                      final channelIndex = currency == 'NGN' ? index - 1 : index;
                      final channel = allChannels[channelIndex];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        onTap: () {
                          ref
                              .read(sendViewModelProvider.notifier)
                              .updateDeliveryMethod(
                                channel.channelType ?? 'Unknown',
                              );

                          // print('channel.id: ${channel.id}');
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                        },
                        leading: _getDeliveryMethodIcon(channel.channelType),
                        // SizedBox(width: 12.w),,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDeliveryMethodType(channel.channelType) == "P2p" ? "Peer-to-Peer" : _getDeliveryMethodType(channel.channelType),
                              // [${channel.channelType.toString().toUpperCase()}]
                              style: AppTypography.bodyLarge.copyWith(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _getDeliveryDuration(channel.channelType),
                              style: AppTypography.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Karla',
                                letterSpacing: -.3,
                                height: 1.2,
                              ),
                            ),
                            // SizedBox(height: 2.h),
                            // Text(
                            //   '${channel.vendorId ?? 'Unknown'} - ${channel.channelType ?? 'Unknown'} - ${channel.settlementType ?? 'Unknown'}',
                            //   style: AppTypography.bodySmall.copyWith(
                            //     fontFamily: 'Karla',
                            //     fontSize: 12.sp,
                            //     color: AppColors.primary600,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // SizedBox(height: 1.h),
                            // Text(
                            //   '${channel.rampType ?? 'Unknown'} - ${channel.status ?? 'Unknown'}',
                            //   style: AppTypography.bodySmall.copyWith(
                            //     fontFamily: 'Karla',
                            //     fontSize: 11.sp,
                            //     color: AppColors.neutral600,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            // SizedBox(height: 2.h),
                            // Text(
                            //   'Min: ${channel.min} ${channel.currency} | Max: ${channel.max} ${channel.currency}',
                            //   style: AppTypography.bodySmall.copyWith(
                            //     fontFamily: 'Karla',
                            //     fontSize: 12.sp,
                            //     color: AppColors.neutral500,
                            //   ),
                            // ),
                          ],
                        ),
                        trailing:
                            state.selectedDeliveryMethod == channel.channelType
                                ? SvgPicture.asset(
                                  'assets/icons/svgs/circle-check.svg',
                                  color: AppColors.purple500,
                                )
                                : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
