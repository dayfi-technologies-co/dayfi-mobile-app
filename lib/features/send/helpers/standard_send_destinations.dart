import 'package:dayfi/features/send/constants/yellow_card_corridors.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/models/payment_response.dart';

const Set<String> _withdrawRampTypes = {
  'withdrawal',
  'withdraw',
  'payout',
};

bool isWithdrawRamp(String? rampType) {
  final r = rampType?.toLowerCase() ?? '';
  return _withdrawRampTypes.contains(r);
}

/// Allowed standard (Yellow Card) destinations — no LATAM/other deposit-only rows.
Set<String> get kStandardDestinationKeys => {
  for (final c in kYellowCardOffRampCorridors) '${c.countryCode}-${c.currency}',
};

bool isAllowedStandardDestination(String? country, String? currency) {
  final key = '${country?.toUpperCase() ?? ''}-${currency?.toUpperCase() ?? ''}';
  return kStandardDestinationKeys.contains(key);
}

/// One row per Yellow Card corridor, preferring live API channel metadata.
List<Channel> buildStandardSendDestinations(List<Channel> apiChannels) {
  final withdraw =
      apiChannels.where((c) {
        return c.status == 'active' &&
            c.country != null &&
            c.currency != null &&
            isWithdrawRamp(c.rampType) &&
            isAllowedStandardDestination(c.country, c.currency);
      }).toList();

  final out = <Channel>[];

  for (final corridor in kYellowCardOffRampCorridors) {
    final cc = corridor.countryCode.toUpperCase();
    final cur = corridor.currency.toUpperCase();

    final matches =
        withdraw
            .where(
              (c) =>
                  c.country?.toUpperCase() == cc && c.currency?.toUpperCase() == cur,
            )
            .toList();

    if (matches.isNotEmpty) {
      Channel? pick;
      for (final type in ['bank', 'momo', 'mobile_money']) {
        for (final c in matches) {
          if (c.channelType?.toLowerCase() == type) {
            pick = c;
            break;
          }
        }
        if (pick != null) break;
      }
      pick ??= matches.first;
      out.add(
        Channel(
          id: pick.id,
          country: cc,
          currency: cur,
          channelType: pick.channelType,
          rampType: pick.rampType ?? 'withdrawal',
          status: 'active',
          min: pick.min,
          max: pick.max,
        ),
      );
    } else {
      out.add(destinationChannelFor(corridor));
    }
  }

  sortStandardSendDestinations(out);
  return out;
}

/// Delivery methods (bank / momo) for a corridor from live Yellow Card channels.
List<Channel> deliveryChannelsForCorridor({
  required List<Channel> apiChannels,
  required String countryCode,
  required String currency,
}) {
  final cc = countryCode.toUpperCase();
  final cur = currency.toUpperCase();

  final live =
      apiChannels
          .where(
            (c) =>
                c.status == 'active' &&
                isWithdrawRamp(c.rampType) &&
                c.country?.toUpperCase() == cc &&
                c.currency?.toUpperCase() == cur &&
                c.channelType != null &&
                !isYellowCardFallbackChannel(c),
          )
          .toList();

  if (live.isNotEmpty) {
    final byType = <String, Channel>{};
    for (final c in live) {
      final t = c.channelType!.toLowerCase();
      byType.putIfAbsent(t, () => c);
    }
    return byType.values.toList()
      ..sort((a, b) => (a.channelType ?? '').compareTo(b.channelType ?? ''));
  }

  return fallbackDeliveryChannelsFor(countryCode: cc, currency: cur);
}
