/// Display names and flag assets for Send destination countries (Yellow Card corridors).
library;

const String _flagsBase = 'assets/icons/svgs/world_flags';

/// ISO 3166-1 alpha-2 → English display name.
const Map<String, String> kSendCountryNames = {
  'NG': 'Nigeria',
  'US': 'United States',
  'GB': 'United Kingdom',
  'DE': 'Euro',
  'ZA': 'South Africa',
  'UG': 'Uganda',
  'TZ': 'Tanzania',
  'RW': 'Rwanda',
  'ZM': 'Zambia',
  'BW': 'Botswana',
  'MW': 'Malawi',
  'SN': 'Senegal',
  'CM': 'Cameroon',
  'CI': "Côte d'Ivoire",
  'CD': 'Democratic Republic of Congo',
  'CG': 'Republic of Congo',
  'GA': 'Gabon',
  'BJ': 'Benin',
  'BF': 'Burkina Faso',
  'ML': 'Mali',
  'TG': 'Togo',
  'KE': 'Kenya',
  'GH': 'Ghana',
};

/// ISO2 → flag SVG under [world_flags] (lowercase file names).
const Map<String, String> kSendCountryFlagAssets = {
  'NG': '$_flagsBase/nigeria.svg',
  'US': '$_flagsBase/united states.svg',
  'GB': '$_flagsBase/united kingdom.svg',
  'DE': '$_flagsBase/european-union.svg',
  'ZA': '$_flagsBase/south africa.svg',
  'UG': '$_flagsBase/uganda.svg',
  'TZ': '$_flagsBase/tanzania.svg',
  'RW': '$_flagsBase/rwanda.svg',
  'ZM': '$_flagsBase/zambia.svg',
  'BW': '$_flagsBase/botswana.svg',
  'MW': '$_flagsBase/malawi.svg',
  'SN': '$_flagsBase/senegal.svg',
  'CM': '$_flagsBase/cameroon.svg',
  'CI': '$_flagsBase/ivory coast.svg',
  'CD': '$_flagsBase/democratic republic of congo.svg',
  'CG': '$_flagsBase/republic of the congo.svg',
  'GA': '$_flagsBase/gabon.svg',
  'BJ': '$_flagsBase/benin.svg',
  'BF': '$_flagsBase/burkina faso.svg',
  'ML': '$_flagsBase/mali.svg',
  'TG': '$_flagsBase/togo.svg',
  'KE': '$_flagsBase/kenya.svg',
  'GH': '$_flagsBase/ghana.svg',
};

String sendCountryDisplayName(String? countryCode) {
  final code = countryCode?.toUpperCase() ?? '';
  return kSendCountryNames[code] ?? code;
}

String sendCountryFlagAsset(String? countryCode) {
  final code = countryCode?.toUpperCase() ?? '';
  return kSendCountryFlagAssets[code] ?? '$_flagsBase/nigeria.svg';
}
