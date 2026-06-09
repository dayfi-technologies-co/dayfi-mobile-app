import 'package:dayfi/models/payment_response.dart';

/// Yellow Card off-ramp corridors (bank / mobile money) per
/// https://docs.yellowcard.engineering/v1.0.26/docs/africa
class YellowCardCorridor {
  final String countryCode;
  final String currency;
  final bool bank;
  final bool mobileMoney;

  const YellowCardCorridor({
    required this.countryCode,
    required this.currency,
    this.bank = false,
    this.mobileMoney = false,
  });
}

/// One row per country–currency destination for the Send country list.
const List<YellowCardCorridor> kYellowCardOffRampCorridors = [
  YellowCardCorridor(countryCode: 'BJ', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'BW', currency: 'BWP', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'BF', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'CM', currency: 'XAF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'CG', currency: 'XAF', bank: true),
  YellowCardCorridor(countryCode: 'CD', currency: 'CDF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'CI', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'GA', currency: 'XAF', bank: true),
  YellowCardCorridor(countryCode: 'MW', currency: 'MWK', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'ML', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'RW', currency: 'RWF', bank: true),
  YellowCardCorridor(countryCode: 'SN', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'ZA', currency: 'ZAR', bank: true),
  YellowCardCorridor(countryCode: 'KE', currency: 'KES', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'GH', currency: 'GHS', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'TZ', currency: 'TZS', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'TG', currency: 'XOF', mobileMoney: true),
  YellowCardCorridor(countryCode: 'UG', currency: 'UGX', bank: true, mobileMoney: true),
  YellowCardCorridor(countryCode: 'ZM', currency: 'ZMW', bank: true, mobileMoney: true),
];

const String kYellowCardFallbackChannelIdPrefix = 'yc_fallback_';

const String kThirdPartyUnavailableMessage =
    'Transfers to this destination are temporarily unavailable. Please try again in a little while.';

bool isYellowCardFallbackChannel(Channel? channel) {
  final id = channel?.id;
  return id != null && id.startsWith(kYellowCardFallbackChannelIdPrefix);
}

bool _channelMatches(
  Channel channel,
  String country,
  String currency,
  String channelType,
) {
  return channel.country?.toUpperCase() == country.toUpperCase() &&
      channel.currency?.toUpperCase() == currency.toUpperCase() &&
      channel.channelType?.toLowerCase() == channelType.toLowerCase();
}

Channel _fallbackChannel(
  YellowCardCorridor corridor,
  String channelType,
) {
  return Channel(
    id: '$kYellowCardFallbackChannelIdPrefix${corridor.countryCode}_${corridor.currency}_$channelType',
    country: corridor.countryCode,
    currency: corridor.currency,
    channelType: channelType,
    rampType: 'withdrawal',
    status: 'active',
    min: 0,
    max: 999999999,
  );
}

/// Destination row for the country picker (one per corridor).
Channel destinationChannelFor(YellowCardCorridor corridor) {
  return Channel(
    id: '${kYellowCardFallbackChannelIdPrefix}dest_${corridor.countryCode}_${corridor.currency}',
    country: corridor.countryCode,
    currency: corridor.currency,
    rampType: 'withdrawal',
    status: 'active',
    min: 0,
    max: 999999999,
  );
}

/// Adds synthetic bank / momo channels when the API did not return them.
void mergeYellowCardFallbackChannels(List<Channel> channels) {
  for (final corridor in kYellowCardOffRampCorridors) {
    if (corridor.bank &&
        !channels.any(
          (c) => _channelMatches(c, corridor.countryCode, corridor.currency, 'bank'),
        )) {
      channels.add(_fallbackChannel(corridor, 'bank'));
    }
    if (corridor.mobileMoney &&
        !channels.any(
          (c) => _channelMatches(c, corridor.countryCode, corridor.currency, 'momo'),
        )) {
      channels.add(_fallbackChannel(corridor, 'momo'));
    }
  }
}

/// Delivery methods for a corridor when filtering returned nothing.
List<Channel> fallbackDeliveryChannelsFor({
  required String countryCode,
  required String currency,
}) {
  final country = countryCode.toUpperCase();
  final cur = currency.toUpperCase();
  YellowCardCorridor? corridor;
  for (final c in kYellowCardOffRampCorridors) {
    if (c.countryCode == country && c.currency == cur) {
      corridor = c;
      break;
    }
  }
  if (corridor == null) return const [];

  final out = <Channel>[];
  if (corridor.bank) out.add(_fallbackChannel(corridor, 'bank'));
  if (corridor.mobileMoney) out.add(_fallbackChannel(corridor, 'momo'));
  return out;
}
