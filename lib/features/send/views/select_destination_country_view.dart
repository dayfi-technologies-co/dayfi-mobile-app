import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/routes/route.dart';
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
          "Where are you sending to?",
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          // Search Bar
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
                setState(() {});
              },
            ),
          ),
          SizedBox(height: 8.h),

          // Country List
          Expanded(
            child: Builder(
              builder: (context) {
                // Show shimmer while channels are being fetched
                if (sendState.isLoading || sendState.channels.isEmpty) {
                  return ShimmerWidgets.countryListShimmer(
                    context,
                    itemCount: 10,
                  );
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
                            final key =
                                '${channel.country} - ${channel.currency}';
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

                if (filteredChannels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/svgs/search-normal.svg',
                          height: 64.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),

                        SizedBox(height: 16.h),
                        Text(
                          'No countries found',
                          style: TextStyle(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 16.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  itemCount: filteredChannels.length,
                  itemBuilder: (context, index) {
                    final channel = filteredChannels[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      onTap: () {
                        ref
                            .read(sendViewModelProvider.notifier)
                            .updateReceiveCountry(
                              channel.country ?? 'NG',
                              channel.currency ?? 'NGN',
                            );
                        Navigator.pushNamed(
                          context,
                          AppRoute.selectDeliveryMethodView,
                          arguments: {
                            'country': channel.country ?? 'NG',
                            'currency': channel.currency ?? 'NGN',
                          },
                        );
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
  }
}
