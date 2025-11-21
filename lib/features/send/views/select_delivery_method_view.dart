import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';

class SelectDeliveryMethodView extends ConsumerStatefulWidget {
  const SelectDeliveryMethodView({super.key});

  @override
  ConsumerState<SelectDeliveryMethodView> createState() =>
      _SelectDeliveryMethodViewState();
}

class _SelectDeliveryMethodViewState
    extends ConsumerState<SelectDeliveryMethodView> {
  String? _selectedCountry;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.trackScreenView(screenName: 'SelectDeliveryMethodView');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedCountry = args['country'] as String?;
      _selectedCurrency = args['currency'] as String?;
    }
  }

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

  String _getCurrencyCountryCode(String? currency) {
    switch (currency?.toUpperCase()) {
      case 'NGN':
        return 'NG';
      case 'GHS':
        return 'GH';
      case 'RWF':
        return 'RW';
      case 'KES':
        return 'KE';
      case 'UGX':
        return 'UG';
      case 'TZS':
        return 'TZ';
      case 'ZAR':
        return 'ZA';
      case 'XOF':
        // XOF is used by multiple countries, default to Senegal
        return 'SN';
      case 'XAF':
        // XAF is used by multiple countries, default to Cameroon
        return 'CM';
      case 'USD':
        return 'US';
      case 'GBP':
        return 'GB';
      case 'CAD':
        return 'CA';
      case 'EUR':
        // EUR is used by multiple countries, could default to a specific one
        return 'EU';
      case 'BWP':
        return 'BW';
      case 'MWK':
        return 'MW';
      case 'ZMW':
        return 'ZM';
      default:
        return 'NG';
    }
  }

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
        return 'assets/icons/svgs/world_flags/nigeria.svg';
    }
  }

  String _getDeliveryMethodName(String? channelType) {
    if (channelType == null) return 'Unknown';

    switch (channelType.toLowerCase()) {
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
        return channelType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _getDeliveryMethodDescription(String? channelType, String? currency) {
    if (channelType == null) return '';

    final methodLower = channelType.toLowerCase();

    // For NGN to NGN bank transfers (peer-to-peer), show "Arrives immediately"
    final isNgnToNgn = _selectedCurrency == 'NGN' && currency == 'NGN';
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

  // Helper function to get canonical name for sorting (same as send_view.dart)
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

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);

    // Filter channels by status, rampType, and country/currency (same as send_view.dart)
    final filteredChannels =
        sendState.channels
            .where(
              (channel) =>
                  channel.status == 'active' &&
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout' ||
                      channel.rampType == 'deposit' ||
                      channel.rampType == 'receive') &&
                  (channel.country == _selectedCountry ||
                      channel.currency == _selectedCurrency),
            )
            .toList();

    // Check if this is NGN to NGN transfer
    final isNgnToNgn =
        sendState.sendCurrency == 'NGN' && _selectedCurrency == 'NGN';

    // For NGN to NGN transfers, add DayFi Tag as an option if not already present
    if (isNgnToNgn) {
      final hasDayfiTag = filteredChannels.any(
        (channel) => channel.channelType?.toLowerCase() == 'dayfi_tag',
      );

      if (!hasDayfiTag) {
        // Create a synthetic DayFi Tag channel
        final dayfiTagChannel = Channel(
          channelType: 'dayfi_tag',
          country: _selectedCountry,
          currency: _selectedCurrency,
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
      // Get canonical type for merging
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
    final deliveryMethods =
        uniqueChannels.values.toList()..sort(
          (a, b) => _getCanonicalChannelName(
            a.channelType,
          ).compareTo(_getCanonicalChannelName(b.channelType)),
        );

    return Scaffold(
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
          "Choose delivery method",
          style: AppTypography.titleLarge.copyWith(
            fontSize: 19.sp,
            // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Country Info
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sending to ${_selectedCurrency ?? 'NGN'}",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 12.sp,
                      color: const Color(0xff2A0079),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.04,
                      height: 1.450,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    _getFlagPath(_getCurrencyCountryCode(_selectedCurrency)),
                    height: 18.h,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Text(
              'Available delivery methods',
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),

          // Delivery Methods List
          Expanded(
            child:
                sendState.isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.purple500,
                      ),
                    )
                    : deliveryMethods.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No delivery methods available',
                            style: TextStyle(
                              fontFamily: 'Karla',
                              fontSize: 16.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 8.h,
                      ),
                      itemCount: deliveryMethods.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final method = deliveryMethods[index];
                        return _buildDeliveryMethodCard(method);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodCard(Channel method) {
    final isDayfiTag = method.channelType?.toLowerCase() == 'dayfi_tag';

    return GestureDetector(
      onTap: () {
        // Update send state with selected delivery method
        ref
            .read(sendViewModelProvider.notifier)
            .updateDeliveryMethod(method.channelType ?? '');

        // Navigate to send view
        Navigator.pushNamed(context, AppRoute.sendView);
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
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: _getDeliveryMethodIcon(method.channelType),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _getDeliveryMethodName(
                                          method.channelType,
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontFamily: 'Karla',
                                          fontSize: 18.sp,
                                          letterSpacing: -.5,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
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
                                            color: AppColors.warning400
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Free',
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                      fontFamily: 'Karla',
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.warning600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _getDeliveryMethodDescription(
                                      method.channelType,
                                      method.currency,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontSize: 12.5.sp,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.4,
                                      height: 1.3,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
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
                ],
              ),
            ),
            SizedBox(width: 24.w),
            SizedBox(width: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _getDeliveryMethodIcon(String? method) {
    if (method == null || method.isEmpty) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 34,
            color: AppColors.neutral700.withOpacity(.35),
          ),
          SvgPicture.asset(
            "assets/icons/svgs/payymentt.svg",
            height: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
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
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
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
}
