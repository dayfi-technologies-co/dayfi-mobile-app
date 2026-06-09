import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/constants/yellow_card_corridors.dart';
import 'package:dayfi/features/send/helpers/standard_send_destinations.dart';
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
  final bool saveRecipientOnly;

  const DeliveryMethodsSheet({
    super.key,
    required this.selectedCountry,
    required this.selectedCurrency,
    required this.debitCurrency,
    this.saveRecipientOnly = false,
  });

  @override
  ConsumerState<DeliveryMethodsSheet> createState() =>
      _DeliveryMethodsSheetState();
}

class _DeliveryMethodsSheetState extends ConsumerState<DeliveryMethodsSheet> {
  static const Set<String> _coreBankSendCurrencies = {'USD', 'EUR', 'GBP'};

  bool get _isCoreBankSendCorridor =>
      _coreBankSendCurrencies.contains(selectedCurrency.toUpperCase());

  String _bankTransferSubtitle(String receiveCurrency) {
    switch (receiveCurrency.toUpperCase()) {
      case 'EUR':
        return 'Send to a European bank account';
      case 'GBP':
        return 'Send to a UK bank account';
      default:
        return 'Send to a US bank account';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncViewModel());
  }

  Future<void> _syncViewModel() async {
    final notifier = ref.read(sendViewModelProvider.notifier);
    final debit = widget.debitCurrency.toUpperCase();
    final receive = widget.selectedCurrency.toUpperCase();

    ref.read(selectedDebitCurrencyProvider.notifier).state = debit;

    Future<void> applyCountries() async {
      await notifier.updateSendCountry(countryForCurrency(debit), debit);
      await notifier.updateReceiveCountry(
        widget.selectedCountry.toUpperCase(),
        receive,
      );
    }

    // Keep the sheet tappable immediately; sync corridor + rates in background.
    unawaited(
      () async {
        if (!notifier.isInitialized && !notifier.isInitializing) {
          await notifier.initialize();
        }
        await applyCountries();
      }().catchError((_) {}),
    );
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
        baseName = UsernameCopy.label;
        timing = 'Instant transfer';
        break;
      case 'bank_transfer':
      case 'bank':
        baseName = 'Bank Transfer';
        timing = 'Usually under 5 minutes';
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
        timing = 'Instant';
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
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/swap.svg',
              height: 40,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SvgPicture.asset(
              'assets/icons/svgs/coin.svg',
              height: 28,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
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

  String? _routeForChannelType(String channelType) {
    switch (channelType.toLowerCase()) {
      case 'dayfi_tag':
        return AppRoute.sendDayfiIdView;
      case 'crypto':
      case 'cryptocurrency':
        return AppRoute.walletCryptoSendView;
      default:
        return AppRoute.addRecipientsView;
    }
  }

  void _onMethodTap({
    required BuildContext context,
    required String channelType,
    Channel? channel,
  }) {
    if (isYellowCardFallbackChannel(channel)) {
      TopSnackbar.showSafe(
        context,
        message: kThirdPartyUnavailableMessage,
        isError: true,
      );
      return;
    }

    final type = channelType.toLowerCase();
    final isBankType =
        type == 'bank_transfer' ||
        type == 'bank' ||
        type == 'p2p' ||
        type == 'peer_to_peer' ||
        type == 'peer-to-peer' ||
        type == 'eft';
    if (_isCoreBankSendCorridor && isBankType) {
      TopSnackbar.showSafe(
        context,
        message: kThirdPartyUnavailableMessage,
        isError: true,
      );
      return;
    }

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
      if (widget.saveRecipientOnly) 'saveRecipientOnly': true,
    };

    final route = _routeForChannelType(channelType);
    if (route == null) return;

    // Close the sheet first so navigation feels instant on the root stack.
    Navigator.of(context).pop();
    appRouter.pushNamed(route, arguments: selectedData);
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              enabled
                  ? () => _onMethodTap(
                    context: context,
                    channelType: channelType,
                    channel: channel,
                  )
                  : null,
          splashColor: Colors.transparent,
          highlightColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
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
                                color:
                                    badge == 'FREE'
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
                                  color:
                                      badge == 'FREE'
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodGroup(BuildContext context, {required List<Widget> tiles}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(tiles.length, (index) {
          return Column(
            children: [
              tiles[index],
              if (index < tiles.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _cryptoSubtitle(String receiveCurrency) {
    switch (receiveCurrency.toUpperCase()) {
      case 'EUR':
        return 'Send EURC on Stellar or Ethereum';
      default:
        return 'Send USDC on Stellar or Ethereum';
    }
  }

  List<Widget> _buildCoreCurrencyMethods(
    BuildContext context,
    List<Channel> ycChannels,
  ) {
    final receive = selectedCurrency.toUpperCase();
    final bankChannel = receive == 'NGN' ? _findBankChannel(ycChannels) : null;
    // NGN bank: Flutterwave on review screen; channel list optional for UX.
    final bankEnabled = receive == 'NGN';
    final cryptoEnabled = receive == 'USD' || receive == 'EUR';

    final tiles = <Widget>[
      _methodTile(
        context: context,
        channelType: 'dayfi_tag',
        title: UsernameCopy.label,
        subtitle: UsernameCopy.sendToInstant,
        enabled: true,
        badge: 'FREE',
      ),
    ];

    if (bankEnabled) {
      tiles.add(
        _methodTile(
          context: context,
          channelType: bankChannel?.channelType ?? 'bank_transfer',
          title: 'Bank',
          subtitle: 'Transfer to a Nigerian bank account',
          enabled: true,
          channel: bankChannel,
        ),
      );
    }

    if (cryptoEnabled) {
      tiles.add(
        _methodTile(
          context: context,
          channelType: 'crypto',
          title: 'Crypto',
          subtitle: _cryptoSubtitle(receive),
          enabled: true,
        ),
      );
    }

    if (_coreBankSendCurrencies.contains(receive)) {
      tiles.add(
        _methodTile(
          context: context,
          channelType: 'bank_transfer',
          title: 'Bank Transfer',
          subtitle: _bankTransferSubtitle(receive),
          enabled: true,
        ),
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final receive = selectedCurrency.toUpperCase();
    final isCore = kCoreSendCurrencies.contains(receive);

    var ycMethods =
        isCore
            ? sendState.channels
                .where(
                  (channel) =>
                      channel.status == 'active' &&
                      (channel.country == selectedCountry ||
                          channel.currency == selectedCurrency),
                )
                .toList()
            : deliveryChannelsForCorridor(
              apiChannels: sendState.channels,
              countryCode: selectedCountry,
              currency: selectedCurrency,
            );

    final subtitleText =
        'How should the recipient in $selectedCountry receive the money?';

    final coreTiles = _buildCoreCurrencyMethods(context, ycMethods);

    Widget methodsBody;
    if (isCore) {
      methodsBody = _methodGroup(context, tiles: coreTiles);
    } else if (ycMethods.isEmpty) {
      methodsBody = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          'No delivery methods available',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      methodsBody = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: _methodGroup(
            context,
            tiles: List.generate(ycMethods.length, (index) {
              final method = ycMethods[index];
              final type = method.channelType?.toLowerCase() ?? '';
              final isDayfi = type == 'dayfi_tag';
              final isFallback = isYellowCardFallbackChannel(method);
              final name = _getDeliveryMethodName(method.channelType);
              final parts = name.split(' - ');
              return _methodTile(
                context: context,
                channelType: method.channelType ?? '',
                title: parts.first,
                subtitle: isFallback
                    ? 'Temporarily unavailable'
                    : (parts.length > 1 ? parts[1] : ''),
                // Keep fallback methods tappable so we can show a friendly
                // TopSnackbar error instead of silently disabling the row.
                enabled: true,
                badge: isDayfi ? 'FREE' : null,
                channel: method,
              );
            }),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Choose delivery method',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/svgs/notificationn.svg',
                          height: 40,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/pngs/cancelicon.png',
                              height: 20,
                              width: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                subtitleText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  height: 1.45,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.55),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: methodsBody,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
