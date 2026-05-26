import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryMethodsSheet extends ConsumerStatefulWidget {
  final String selectedCountry;
  final String selectedCurrency;
  final String debitCurrency;

  const DeliveryMethodsSheet({
    super.key,
    required this.selectedCountry,
    required this.selectedCurrency,
    required this.debitCurrency,
  });

  @override
  ConsumerState<DeliveryMethodsSheet> createState() =>
      _DeliveryMethodsSheetState();
}

class _DeliveryMethodsSheetState extends ConsumerState<DeliveryMethodsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncViewModel());
  }

  Future<void> _syncViewModel() async {
    final notifier = ref.read(sendViewModelProvider.notifier);
    if (!notifier.isInitialized && !notifier.isInitializing) {
      await notifier.initialize();
    }
    final debit = widget.debitCurrency.toUpperCase();
    final receive = widget.selectedCurrency.toUpperCase();
    await notifier.updateSendCountry(countryForCurrency(debit), debit);
    await notifier.updateReceiveCountry(
      widget.selectedCountry.toUpperCase(),
      receive,
    );
    ref.read(selectedDebitCurrencyProvider.notifier).state = debit;
  }

  String get selectedCountry => widget.selectedCountry;
  String get selectedCurrency => widget.selectedCurrency;
  String get debitCurrency => widget.debitCurrency;

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

  Channel? _findBankChannel(List<Channel> channels) {
    for (final c in channels) {
      final t = c.channelType?.toLowerCase() ?? '';
      if (t == 'bank_transfer' ||
          t == 'bank' ||
          t == 'p2p' ||
          t == 'peer_to_peer' ||
          t == 'peer-to-peer' ||
          t == 'eft') {
        return c;
      }
    }
    return null;
  }

  void _onMethodTap({
    required BuildContext context,
    required String channelType,
    Channel? channel,
  }) {
    final sendNotifier = ref.read(sendViewModelProvider.notifier);
    sendNotifier.updateDeliveryMethod(channelType);

    final receive = selectedCurrency.toUpperCase();
    final selectedData = <String, dynamic>{
      'receiveCountry': selectedCountry.toUpperCase(),
      'receiveCurrency': receive,
      'sendCountry': countryForCurrency(debitCurrency),
      'sendCurrency': debitCurrency.toUpperCase(),
      'recipientDeliveryMethod': channelType,
      'recipientChannelId': channel?.id ?? '',
      'debitCurrency': debitCurrency.toUpperCase(),
    };

    if (channelType.toLowerCase() == 'dayfi_tag') {
      Navigator.pushNamed(
        context,
        AppRoute.sendDayfiIdView,
        arguments: selectedData,
      );
      return;
    }

    if (channelType.toLowerCase() == 'crypto' ||
        channelType.toLowerCase() == 'cryptocurrency') {
      Navigator.pushNamed(
        context,
        AppRoute.walletCryptoSendView,
        arguments: selectedData,
      );
      return;
    }

    final sendState = ref.read(sendViewModelProvider);
    final availableNetworks = sendState.networks.where(
      (network) =>
          network.status == 'active' && network.country == selectedCountry,
    );
    if (availableNetworks.isEmpty && selectedCountry != 'US') {
      TopSnackbar.show(
        context,
        message: 'No networks available for $selectedCountry',
        isError: true,
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoute.addRecipientsView,
      arguments: selectedData,
    );
  }

  Widget _methodTile({
    required BuildContext context,
    required String channelType,
    required String title,
    required String subtitle,
    required bool enabled,
    String? badge,
    Channel? channel,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled
            ? () => _onMethodTap(
                  context: context,
                  channelType: channelType,
                  channel: channel,
                )
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: _getDeliveryMethodIcon(channelType, context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 18,
                            letterSpacing: -.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badge == 'FREE'
                                  ? AppColors.warning400.withOpacity(0.15)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: AppTypography.labelSmall.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: badge == 'FREE'
                                    ? AppColors.warning600
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        fontFamily: 'Chirp',
                        letterSpacing: -.25,
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.neutral400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCoreCurrencyMethods(
    BuildContext context,
    List<Channel> ycChannels,
  ) {
    final receive = selectedCurrency.toUpperCase();
    final bankChannel = receive == 'NGN' ? _findBankChannel(ycChannels) : null;
    // NGN bank: Flutterwave on review screen; channel list optional for UX.
    final bankEnabled = receive == 'NGN';
    final cryptoEnabled =
        receive == 'USD' || receive == 'EUR' || receive == 'NGN';

    return [
      _methodTile(
        context: context,
        channelType: 'dayfi_tag',
        title: 'Dayfi user',
        subtitle: 'Send to a Dayfi Tag — instant',
        enabled: true,
        badge: 'FREE',
      ),
      const SizedBox(height: 12),
      _methodTile(
        context: context,
        channelType: bankChannel?.channelType ?? 'bank_transfer',
        title: 'Bank',
        subtitle: receive == 'NGN'
            ? 'Transfer to a Nigerian bank account'
            : 'Bank transfers — coming soon',
        enabled: bankEnabled,
        badge: bankEnabled ? null : 'SOON',
        channel: bankChannel,
      ),
      const SizedBox(height: 12),
      _methodTile(
        context: context,
        channelType: 'mobile_money',
        title: 'Mobile money',
        subtitle: 'Coming soon',
        enabled: false,
        badge: 'SOON',
      ),
      const SizedBox(height: 12),
      _methodTile(
        context: context,
        channelType: 'crypto',
        title: 'Crypto',
        subtitle: 'Send USDC/EURC on Stellar or Ethereum',
        enabled: cryptoEnabled,
        badge: cryptoEnabled ? null : 'SOON',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final receive = selectedCurrency.toUpperCase();
    final isCore = kCoreSendCurrencies.contains(receive);

    final filteredChannels = sendState.channels.where((channel) {
      return channel.status == 'active' &&
          (channel.rampType == 'withdrawal' ||
              channel.rampType == 'withdraw' ||
              channel.rampType == 'payout' ||
              channel.rampType == 'deposit' ||
              channel.rampType == 'receive') &&
          (channel.country == selectedCountry ||
              channel.currency == selectedCurrency);
    }).toList();

    Map<String, Channel> unique = {};
    for (final channel in filteredChannels) {
      final key = channel.channelType?.toLowerCase() ?? 'unknown';
      if (!unique.containsKey(key) ||
          (channel.max ?? 0) > (unique[key]!.max ?? 0)) {
        unique[key] = channel;
      }
    }

    final ycMethods = unique.values.toList()
      ..sort((a, b) => (a.channelType ?? '').compareTo(b.channelType ?? ''));

    final subtitleText = isCore
        ? 'Send $receive from your $debitCurrency wallet'
        : 'How should the recipient in $selectedCountry receive the money?';

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
                subtitleText,
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
          const SizedBox(height: 24),
          Expanded(
            child: isCore
                ? ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    children: _buildCoreCurrencyMethods(context, ycMethods),
                  )
                : ycMethods.isEmpty
                    ? Center(
                        child: Text(
                          'No delivery methods available',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        itemCount: ycMethods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final method = ycMethods[index];
                          final type =
                              method.channelType?.toLowerCase() ?? '';
                          final isDayfi = type == 'dayfi_tag';
                          final name =
                              _getDeliveryMethodName(method.channelType);
                          final parts = name.split(' - ');
                          return _methodTile(
                            context: context,
                            channelType: method.channelType ?? '',
                            title: parts.first,
                            subtitle: parts.length > 1 ? parts[1] : '',
                            enabled: true,
                            badge: isDayfi ? 'FREE' : null,
                            channel: method,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
