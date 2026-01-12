import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryMethodsSheet extends ConsumerWidget {
  final String selectedCountry;
  final String selectedCurrency;

  const DeliveryMethodsSheet({
    super.key,
    required this.selectedCountry,
    required this.selectedCurrency,
  });

  String _getDeliveryMethodName(String? channelType) {
    if (channelType == null) return 'Unknown';
    String baseName;
    String timing;

    switch (channelType.toLowerCase()) {
      case 'dayfi_tag':
        baseName = 'Dayfi Tag';
        timing = 'Instant transfer';
        break;
      case 'bank_transfer':
      case 'bank':
        baseName = 'Bank Transfer';
        timing = '24-48 hours';
        break;
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        baseName = 'Bank Transfer (P2P)';
        timing = 'Instant';
        break;
      case 'eft':
        baseName = 'Bank Transfer (EFT)';
        timing = 'Instant';
        break;
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        baseName = 'Mobile Money';
        timing = 'Instant';
        break;
      case 'spenn':
        baseName = 'Spenn';
        timing = 'Instant';
        break;
      case 'cash_pickup':
      case 'cash':
        baseName = 'Cash Pickup';
        timing = '1-24 hours';
        break;
      case 'wallet':
      case 'digital_wallet':
        baseName = 'Wallet';
        timing = 'Instant';
        break;
      case 'card':
      case 'card_payment':
        baseName = 'Card';
        timing = 'Instant';
        break;
      case 'crypto':
      case 'cryptocurrency':
        baseName = 'Crypto';
        timing = '10-30 minutes';
        break;
      case 'digital_dollar':
      case 'stablecoins':
        baseName = 'Digital Dollar';
        timing = 'Instant';
        break;
      default:
        baseName = channelType
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
        timing = '1-24 hours';
    }

    return '$baseName - $timing';
  }

  String _getCountryCurrency(String country) {
    switch (country.toUpperCase()) {
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
        return 'NGN';
    }
  }

  Widget _getDeliveryMethodIcon(String? method, BuildContext context) {
    if (method == null || method.isEmpty) {
      return SvgPicture.asset('assets/icons/svgs/swap.svg', height: 34);
    }
    switch (method.toLowerCase()) {
      case 'dayfi_tag':
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 40,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SvgPicture.asset(
              'assets/icons/svgs/at.svg',
              height: 28,
              color: Theme.of(context).colorScheme.surface,
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
              height: 40,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SvgPicture.asset(
              'assets/icons/svgs/building-bank.svg',
              height: 28,
              color: Theme.of(context).colorScheme.surface,
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
              height: 40,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SvgPicture.asset(
              'assets/icons/svgs/device-mobile.svg',
              height: 28,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        );
      case 'spenn':
        return SvgPicture.asset(
          'assets/icons/svgs/wallett.svg',
          height: 32,
          width: 32,
        );
      case 'cash_pickup':
      case 'cash':
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 32,
          width: 32,
        );
      case 'wallet':
      case 'digital_wallet':
        return SvgPicture.asset(
          'assets/icons/svgs/wallett.svg',
          height: 32,
          width: 32,
        );
      case 'card':
      case 'card_payment':
        return SvgPicture.asset(
          'assets/icons/svgs/cardd.svg',
          height: 32,
          width: 32,
        );
      case 'crypto':
      case 'cryptocurrency':
        return SvgPicture.asset(
          'assets/icons/svgs/cryptoo.svg',
          height: 32,
          width: 32,
        );
      default:
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 40,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SvgPicture.asset(
              'assets/icons/svgs/building-bank.svg',
              height: 28,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendState = ref.watch(sendViewModelProvider);

    // Filter channels for the selected country/currency
    final filteredChannels =
        sendState.channels.where((channel) {
          return channel.status == 'active' &&
              (channel.rampType == 'withdrawal' ||
                  channel.rampType == 'withdraw' ||
                  channel.rampType == 'payout' ||
                  channel.rampType == 'deposit' ||
                  channel.rampType == 'receive') &&
              (channel.country == selectedCountry ||
                  channel.currency == selectedCurrency);
        }).toList();

    // Add synthetic Dayfi Tag for all countries
    final hasDayfiTag = filteredChannels.any(
      (c) => c.channelType?.toLowerCase() == 'dayfi_tag',
    );
    if (!hasDayfiTag) {
      filteredChannels.add(
        Channel(
          channelType: 'dayfi_tag',
          country: selectedCountry,
          currency: selectedCurrency,
          status: 'active',
          rampType: 'withdrawal',
          min: 0,
          max: 999999999,
          id: 'dayfi_tag_synthetic',
        ),
      );
    }

    // Deduplicate by canonical name
    Map<String, Channel> unique = {};
    for (final channel in filteredChannels) {
      final key = channel.channelType?.toLowerCase() ?? 'unknown';
      if (!unique.containsKey(key) ||
          (channel.max ?? 0) > (unique[key]!.max ?? 0)) {
        unique[key] = channel;
      }
    }

    final deliveryMethods =
        unique.values.toList()..sort(
          (a, b) => (a.channelType ?? '').compareTo(b.channelType ?? ''),
        );

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 40, width: 40),
                Text(
                  'Choose delivery method',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20,
                    // height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                InkWell(
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
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 20,
                            width: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'How would you like the recipient in $selectedCountry to receive the money?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24),

          Expanded(
            child:
                deliveryMethods.isEmpty
                    ? Center(
                      child: Text(
                        'No delivery methods available',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 20,
                          // height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      itemCount: deliveryMethods.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final method = deliveryMethods[index];
                        final isDayfi =
                            method.channelType?.toLowerCase() == 'dayfi_tag';
                        return GestureDetector(
                          onTap: () {
                            // Update delivery method in the view model
                            ref
                                .read(sendViewModelProvider.notifier)
                                .updateDeliveryMethod(method.channelType ?? '');

                            // Build selectedData map expected by AddRecipientsView
                            final selectedData = <String, dynamic>{
                              'receiveCountry': selectedCountry,
                              'receiveCurrency': _getCountryCurrency(
                                selectedCountry,
                              ),
                              'sendCountry': 'NG', // User's country
                              'sendCurrency':
                                  ref.read(sendViewModelProvider).sendCurrency,
                              'recipientDeliveryMethod':
                                  method.channelType ?? '',
                              'recipientChannelId': method.id ?? '',
                            };

                            // Check if networks are available for this country/currency
                            final allNetworks =
                                ref.read(sendViewModelProvider).networks;
                            final availableNetworks = allNetworks.where(
                              (network) =>
                                  network.status == 'active' &&
                                  network.country == selectedCountry,
                            );
                            if (availableNetworks.isEmpty) {
                              TopSnackbar.show(
                                context,
                                message:
                                    'No networks available for $selectedCountry',
                                isError: true,
                              );
                              return;
                            }

                            // Navigator.pop(context);

                            // Special handling for Dayfi Tag (NGN to NGN only)
                            if (method.channelType?.toLowerCase() ==
                                'dayfi_tag') {
                              // Navigate to Dayfi Tag view for NGN-NGN Dayfi Tag transfers
                              Navigator.pushNamed(
                                context,
                                AppRoute.sendDayfiIdView,
                                arguments: selectedData,
                              );
                            } else {
                              // Navigate to Add Recipients view with selectedData
                              Navigator.pushNamed(
                                context,
                                AppRoute.addRecipientsView,
                                arguments: selectedData,
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: _getDeliveryMethodIcon(
                                    method.channelType,
                                    context,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _getDeliveryMethodName(
                                              method.channelType,
                                            ).split(' -')[0],
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge?.copyWith(
                                              fontFamily: 'Chirp',
                                              fontSize: 18,
                                              letterSpacing: -.25,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          if (isDayfi)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.warning400
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'FREE',
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                      fontFamily: 'Chirp',
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: .3,
                                                      height: 1.2,
                                                      color:
                                                          AppColors.warning600,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _getDeliveryMethodName(
                                          method.channelType,
                                        ).split('- ')[1],
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                          fontFamily: 'Chirp',
                                          letterSpacing: -.25,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 32),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.neutral400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
