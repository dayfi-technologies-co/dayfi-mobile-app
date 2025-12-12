import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/views/send_fetch_crypto_channels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/features/send/widgets/delivery_methods_sheet.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';

class SelectDestinationCountryView extends ConsumerStatefulWidget {
  const SelectDestinationCountryView({super.key});

  @override
  ConsumerState<SelectDestinationCountryView> createState() =>
      _SelectDestinationCountryViewState();
}

class _SelectDestinationCountryViewState
    extends ConsumerState<SelectDestinationCountryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = ref.read(sendViewModelProvider.notifier);
      if (!viewModel.isInitialized && !viewModel.isInitializing) {
        await viewModel.initialize();
      }
      analyticsService.trackScreenView(
        screenName: 'SelectDestinationCountryView',
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Define top 7 African countries for quick send
    // final List<Map<String, String>> topAfricanCountries = [
    //   {'code': 'NG', 'name': 'Nigeria', 'currency': 'NGN'},
    //   {'code': 'GH', 'name': 'Ghana', 'currency': 'GHS'},
    //   {'code': 'KE', 'name': 'Kenya', 'currency': 'KES'},
    //   {'code': 'UG', 'name': 'Uganda', 'currency': 'UGX'},
    //   {'code': 'TZ', 'name': 'Tanzania', 'currency': 'TZS'},
    //   {'code': 'RW', 'name': 'Rwanda', 'currency': 'RWF'},
    //   {'code': 'ZA', 'name': 'South Africa', 'currency': 'ZAR'},
    // ];
    final sendState = ref.watch(sendViewModelProvider);

    // Filter withdrawal channels (where user can send TO)
    final withdrawalChannels =
        sendState.channels
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

    // Deduplicate by country-currency combination
    final uniqueWithdrawalChannels = <String, Channel>{};
    for (final channel in withdrawalChannels) {
      final key = '${channel.country} - ${channel.currency}';
      if (!uniqueWithdrawalChannels.containsKey(key) ||
          (channel.max ?? 0) > (uniqueWithdrawalChannels[key]?.max ?? 0)) {
        uniqueWithdrawalChannels[key] = channel;
      }
    }

    // Always ensure NG-NGN is available
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

    // If no withdrawal channels, add fallback
    if (finalWithdrawalChannels.isEmpty) {
      final alternativeChannels =
          sendState.channels
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

      if (alternativeChannels.isNotEmpty) {
        finalWithdrawalChannels = alternativeChannels;
      } else {
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

    return
    // DefaultTabController(
    //   length: 2,
    //   initialIndex: 0,
    //   child:
    Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap:
              () => {Navigator.pop(context), FocusScope.of(context).unfocus()},
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              SvgPicture.asset(
                "assets/icons/svgs/notificationn.svg",
                height: 40.sp,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(
                height: 40.sp,
                width: 40.sp,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      // size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          "Send Money",
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24.sp,
            // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,

        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(112.h),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Column(
        //         children: [
        //           SizedBox(height: 8.h),
        //           Text(
        //             "Select the country and currency or choose a stablecoin you want to send money to.",
        //             // 'What currency do you want to use as your payment method?',
        //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //               fontSize: 16.sp,
        //               fontWeight: FontWeight.w500,
        //               fontFamily: 'Karla',
        //               letterSpacing: -.6,
        //               height: 1.5,
        //             ),
        //             textAlign: TextAlign.center,
        //           ),

        //           SizedBox(height: 8.h),
        //           SizedBox(
        //             height: 48.h,
        //             child: TabBar(
        //               isScrollable: false,
        //               indicatorColor: AppColors.purple500,
        //               indicatorSize: TabBarIndicatorSize.tab,
        //               labelColor: AppColors.purple500,
        //               unselectedLabelColor: Theme.of(
        //                 context,
        //               ).colorScheme.onSurface.withOpacity(0.6),
        //               labelStyle: AppTypography.bodyLarge.copyWith(
        //                 fontSize: 16.sp,
        //                 fontFamily: 'Karla',
        //                 fontWeight: FontWeight.w500,
        //                 letterSpacing: -0.8,
        //                 height: 1.4,
        //               ),
        //               tabs: const [
        //                 Tab(text: 'Via Fiat'),
        //                 Tab(text: 'Via Crypto'),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ),
      body:
      // TabBarView(
      //   children: [
      Builder(
        builder: (context) {
          // Show shimmer while channels are being fetched
          if (sendState.isLoading || sendState.channels.isEmpty) {
            return ShimmerWidgets.countryListShimmer(context, itemCount: 10);
          }

          // Get all channels
          final allChannels =
              finalWithdrawalChannels.isEmpty
                  ? (() {
                    final fallbackChannels =
                        sendState.channels
                            .where(
                              (c) =>
                                  c.status == 'active' &&
                                  c.currency != null &&
                                  c.country != null &&
                                  (c.rampType == 'withdrawal' ||
                                      c.rampType == 'withdraw' ||
                                      c.rampType == 'payout' ||
                                      c.rampType == 'deposit' ||
                                      c.rampType == 'receive'),
                            )
                            .toList();

                    // Deduplicate fallback channels
                    final uniqueFallbackChannels = <String, Channel>{};
                    for (final channel in fallbackChannels) {
                      final key = '${channel.country} - ${channel.currency}';
                      if (!uniqueFallbackChannels.containsKey(key) ||
                          (channel.max ?? 0) >
                              (uniqueFallbackChannels[key]?.max ?? 0)) {
                        uniqueFallbackChannels[key] = channel;
                      }
                    }

                    return uniqueFallbackChannels.values.toList();
                  })()
                  : finalWithdrawalChannels;

          // Additional deduplication to ensure no duplicates
          final uniqueChannels = <String, Channel>{};
          for (final channel in allChannels) {
            final key = '${channel.country} - ${channel.currency}';
            if (!uniqueChannels.containsKey(key)) {
              uniqueChannels[key] = channel;
            }
          }
          final deduplicatedChannels = uniqueChannels.values.toList();

          // Sort alphabetically by country name
          deduplicatedChannels.sort((a, b) {
            final countryA = _getCountryName(a.country);
            final countryB = _getCountryName(b.country);
            return countryA.compareTo(countryB);
          });

          // Filter based on search
          final searchQuery = _searchController.text.toLowerCase();
          final filteredChannels =
              deduplicatedChannels.where((channel) {
                if (searchQuery.isEmpty) return true;

                final countryName =
                    _getCountryName(channel.country).toLowerCase();
                final currency = channel.currency?.toLowerCase() ?? '';
                final countryCode = channel.country?.toLowerCase() ?? '';

                return countryName.contains(searchQuery) ||
                    currency.contains(searchQuery) ||
                    countryCode.contains(searchQuery);
              }).toList();

          return ListView.builder(
            padding: EdgeInsets.only(top: 12.h),
            itemCount: filteredChannels.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Search Bar
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: SizedBox(
                        child: CustomTextField(
                          isSearch: true,
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
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                      ),
                      child: Text(
                        "Select a country and currency to\nsend money to",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Karla',
                          letterSpacing: -.6,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              } else if (index == 1) {
                // Spacing below search bar
                return SizedBox(height: 18.h);
              }
              final channel = filteredChannels[index - 2];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4.h,
                  horizontal: 18.w,
                ),
                onTap: () {
                  showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0.85),
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    builder: (BuildContext ctx) {
                      return DeliveryMethodsSheet(
                        selectedCountry: channel.country ?? 'NG',
                        selectedCurrency: channel.currency ?? 'NGN',
                      );
                    },
                  );
                },
                title: Row(
                  children: [
                    SvgPicture.asset(
                      _getFlagPath(channel.country),
                      height: 32.0.h,
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
      // Tab 2: Crypto - empty scaffold
      // SendFetchCryptoChannelsView(),
      // ],
      // ),
      // ),
    );
  }
}
