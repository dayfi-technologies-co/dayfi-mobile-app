import 'package:dayfi/features/pay/constants/bill_display_labels.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';

export 'package:dayfi/features/pay/constants/bill_display_labels.dart';

/// Preview billers when Flutterwave / bills API is unavailable (IP whitelist, etc.).
const String kFlutterwavePreviewBillerPrefix = 'fw_preview_';

const String kBillPaymentThirdPartyMessage =
    'Bill payments are temporarily unavailable. Our payment partners are having network issues — please try again shortly.';

bool isFlutterwavePreviewBiller(BillBiller biller) =>
    biller.billerCode.startsWith(kFlutterwavePreviewBillerPrefix);

String resolveFlutterwaveBillerCode(BillBiller biller) =>
    biller.flutterwaveBillerCode ?? biller.billerCode;

bool isMtnNigeriaAirtimeBill(BillCategory category, BillBiller biller) {
  if (category.code.toUpperCase() != 'AIRTIME') return false;
  final name = '${biller.shortName ?? ''} ${biller.name}'.toLowerCase();
  return name.contains('mtn');
}

String billBillerTitle(BillBiller biller) => biller.displayName;

bool billerMatchesTelcoNetwork(BillBiller biller, String network) {
  final hay = formatBillBillerLabel(
    '${biller.shortName ?? ''} ${biller.name}',
  ).toLowerCase();
  final needle = formatBillBillerLabel(network).toLowerCase();
  if (needle.isEmpty) return false;
  return hay.contains(needle);
}

String _billItemLabel(BillItem item) =>
    (item.shortName.isNotEmpty ? item.shortName : item.name).toLowerCase();

/// Picks the default bill item — MTN Nigeria airtime always uses MTN VTU.
BillItem? defaultBillItemFor({
  required BillCategory category,
  required BillBiller biller,
  required List<BillItem> items,
}) {
  if (items.isEmpty) return null;
  if (isMtnNigeriaAirtimeBill(category, biller)) {
    for (final item in items) {
      final label = _billItemLabel(item);
      if (label.contains('mtn') && label.contains('vtu')) return item;
    }
  }
  return items.first;
}

bool shouldShowBillPackagePicker({
  required BillCategory category,
  required BillBiller biller,
  required List<BillItem> items,
}) {
  if (isMtnNigeriaAirtimeBill(category, biller)) return false;
  return items.length > 1;
}

/// Category tile icons — monochrome inner glyph (outer ring from [PayBillIconBadge]).
String categoryInnerIconAsset(String categoryCode) {
  switch (categoryCode.toUpperCase()) {
    case 'AIRTIME':
      return 'assets/icons/svgs/phone-call.svg';
    case 'MOBILEDATA':
      return 'assets/icons/svgs/wifi.svg';
    case 'CABLEBILLS':
      return 'assets/icons/svgs/device-tv.svg';
    case 'INTSERVICE':
      return 'assets/icons/svgs/router.svg';
    case 'UTILITYBILLS':
      return 'assets/icons/svgs/bolt.svg';
    default:
      return 'assets/icons/svgs/receipt-long.svg';
  }
}

const _billBrandImageRules = <(List<String> keys, String asset)>[
  (['t2mobile', 't2 mobile', '9mobile', 'etisalat'], 'assets/images/bills/t2mobile.png'),
  (['abuja', 'aedc'], 'assets/images/bills/abuja.jpg'),
  (['airtel'], 'assets/images/bills/airtel.jpeg'),
  (['benin', 'bedc'], 'assets/images/bills/benin.jpeg'),
  (['dstv'], 'assets/images/bills/dstv.png'),
  (['eko', 'ekedc'], 'assets/images/bills/eko.jpg'),
  (['enugu', 'eedc'], 'assets/images/bills/enugu.png'),
  (['glo', 'globacom'], 'assets/images/bills/glo.png'),
  (['gotv'], 'assets/images/bills/gotv.webp'),
  (['ibadan', 'ibedc'], 'assets/images/bills/ibadan.png'),
  (['ikeja', 'ikedc'], 'assets/images/bills/ikeja.jpeg'),
  (['ipnx'], 'assets/images/bills/ipnx.png'),
  (['jos', 'jedc'], 'assets/images/bills/jos.jpeg'),
  (['kaduna', 'kaedco'], 'assets/images/bills/kaduna.jpeg'),
  (['kano', 'kedco'], 'assets/images/bills/kano.jpeg'),
  (['lekki', 'lcc', 'concession'], 'assets/images/bills/lekki.jpeg'),
  (['port harcourt', 'portharcourt', 'phed'], 'assets/images/bills/port_harcount.jpeg'),
  (['smile'], 'assets/images/bills/smile.webp'),
  (['spectranet'], 'assets/images/bills/spectranet.png'),
  (['startimes', 'star times'], 'assets/images/bills/startimes.png'),
  (['swift'], 'assets/images/bills/swift4g.jpg'),
  (['yola', 'yedc'], 'assets/images/bills/yola.jpeg'),
  (['mtn'], 'assets/images/bills/mtn.jpeg'),
];

/// Branded logo from [assets/images/bills/], when available.
String? billerBrandImageAsset(BillBiller biller) {
  final name = '${biller.shortName ?? ''} ${biller.name}'.toLowerCase();
  for (final rule in _billBrandImageRules) {
    if (rule.$1.any(name.contains)) return rule.$2;
  }
  return null;
}

List<BillCategory> billCategoriesFromRows(List<dynamic> rows) {
  return rows
      .map((e) => BillCategory.fromJson(Map<String, dynamic>.from(e as Map)))
      .where((c) => c.code.isNotEmpty)
      .toList();
}

List<BillBiller> billBillersFromRows(List<dynamic> rows) {
  return rows
      .map((e) => BillBiller.fromJson(Map<String, dynamic>.from(e as Map)))
      .where((b) => b.billerCode.isNotEmpty)
      .toList();
}

List<BillItem> billItemsFromRows(List<dynamic> rows) {
  return rows
      .map((e) => BillItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .where((i) => i.itemCode.isNotEmpty)
      .toList();
}

String billerInnerIconAsset(BillBiller biller, String categoryCode) {
  final name = '${biller.shortName ?? ''} ${biller.name}'.toLowerCase();
  if (name.contains('mtn') ||
      name.contains('glo') ||
      name.contains('airtel') ||
      name.contains('t2mobile') ||
      name.contains('9mobile') ||
      name.contains('etisalat')) {
    return categoryCode.toUpperCase() == 'MOBILEDATA'
        ? 'assets/icons/svgs/wifi.svg'
        : 'assets/icons/svgs/phone-call.svg';
  }
  if (name.contains('dstv') ||
      name.contains('gotv') ||
      name.contains('startime') ||
      name.contains('showmax') ||
      name.contains('cable') ||
      name.contains('tv')) {
    return 'assets/icons/svgs/device-tv.svg';
  }
  if (name.contains('ikedc') ||
      name.contains('ekedc') ||
      name.contains('aedc') ||
      name.contains('phed') ||
      name.contains('electric') ||
      name.contains('prepaid') ||
      name.contains('postpaid')) {
    return 'assets/icons/svgs/bolt.svg';
  }
  if (name.contains('spectranet') ||
      name.contains('smile') ||
      name.contains('internet')) {
    return 'assets/icons/svgs/router.svg';
  }
  return categoryInnerIconAsset(categoryCode);
}

BillBiller _previewBiller({
  required String slug,
  required String name,
  required String flutterwaveCode,
  String? shortName,
}) {
  return BillBiller(
    billerCode: '$kFlutterwavePreviewBillerPrefix$slug',
    flutterwaveBillerCode: flutterwaveCode,
    name: name,
    shortName: shortName ?? name,
  );
}

BillItem _flexibleItem({
  required BillBiller biller,
  required String itemCode,
  required String labelName,
  bool isAirtime = false,
}) {
  return BillItem(
    itemCode: itemCode,
    billerCode: resolveFlutterwaveBillerCode(biller),
    name: 'Custom amount',
    shortName: 'Custom amount',
    labelName: labelName,
    amount: 0,
    fee: 0,
    isAirtime: isAirtime,
    isResolvable: !isAirtime,
  );
}

/// Nigerian billers per Flutterwave category (v3 reference codes).
List<BillBiller> flutterwavePreviewBillersFor(String categoryCode) {
  switch (categoryCode.toUpperCase()) {
    case 'AIRTIME':
      return [
        _previewBiller(slug: 'AIRTIME_MTN', name: 'MTN', flutterwaveCode: 'BIL099'),
        _previewBiller(slug: 'AIRTIME_GLO', name: 'Glo', flutterwaveCode: 'BIL099'),
        _previewBiller(
          slug: 'AIRTIME_AIRTEL',
          name: 'Airtel',
          flutterwaveCode: 'BIL099',
        ),
        _previewBiller(
          slug: 'AIRTIME_9MOBILE',
          name: 'T2mobile',
          flutterwaveCode: 'BIL099',
        ),
      ];
    case 'MOBILEDATA':
      return [
        _previewBiller(slug: 'DATA_MTN', name: 'MTN', flutterwaveCode: 'BIL108'),
        _previewBiller(slug: 'DATA_GLO', name: 'Glo', flutterwaveCode: 'BIL109'),
        _previewBiller(
          slug: 'DATA_AIRTEL',
          name: 'Airtel',
          flutterwaveCode: 'BIL107',
        ),
        _previewBiller(
          slug: 'DATA_9MOBILE',
          name: 'T2mobile',
          flutterwaveCode: 'BIL111',
        ),
      ];
    case 'CABLEBILLS':
      return [
        _previewBiller(slug: 'CABLE_DSTV', name: 'DSTV', flutterwaveCode: 'BIL119'),
        _previewBiller(slug: 'CABLE_GOTV', name: 'GOtv', flutterwaveCode: 'BIL120'),
        _previewBiller(
          slug: 'CABLE_STARTIMES',
          name: 'Startimes',
          flutterwaveCode: 'BIL123',
        ),
        _previewBiller(
          slug: 'CABLE_SHOWMAX',
          name: 'Showmax',
          flutterwaveCode: 'BIL125',
        ),
      ];
    case 'UTILITYBILLS':
      return [
        _previewBiller(
          slug: 'UTIL_EKEDC',
          name: 'EKEDC',
          flutterwaveCode: 'BIL110',
        ),
        _previewBiller(
          slug: 'UTIL_IKEDC',
          name: 'IKEDC',
          flutterwaveCode: 'BIL113',
        ),
        _previewBiller(
          slug: 'UTIL_AEDC',
          name: 'AEDC',
          flutterwaveCode: 'BIL114',
        ),
        _previewBiller(
          slug: 'UTIL_PHED',
          name: 'PHED',
          flutterwaveCode: 'BIL115',
        ),
      ];
    case 'INTSERVICE':
      return [
        _previewBiller(
          slug: 'INT_SPECTRANET',
          name: 'Spectranet',
          flutterwaveCode: 'BIL121',
        ),
        _previewBiller(slug: 'INT_SMILE', name: 'Smile', flutterwaveCode: 'BIL122'),
      ];
    default:
      return [];
  }
}

List<BillItem> flutterwavePreviewItemsFor({
  required BillCategory category,
  required BillBiller biller,
}) {
  final code = category.code.toUpperCase();
  final fwCode = resolveFlutterwaveBillerCode(biller);

  if (code == 'AIRTIME') {
    return [
      _flexibleItem(
        biller: biller,
        itemCode: 'AT099',
        labelName: 'Mobile number',
        isAirtime: true,
      ),
    ];
  }

  if (code == 'MOBILEDATA') {
    return [
      _flexibleItem(
        biller: biller,
        itemCode: _dataItemCodeFor(biller),
        labelName: 'Mobile number',
      ),
    ];
  }

  if (code == 'CABLEBILLS') {
    return [
      BillItem(
        itemCode: _cableItemCodeFor(fwCode),
        billerCode: fwCode,
        name: 'Subscription',
        shortName: 'Pay subscription',
        labelName: 'Smartcard / IUC number',
        amount: 0,
        fee: 0,
        isResolvable: true,
      ),
    ];
  }

  if (code == 'UTILITYBILLS') {
    return [
      BillItem(
        itemCode: _utilityItemCodeFor(fwCode),
        billerCode: fwCode,
        name: 'Meter payment',
        shortName: 'Top up meter',
        labelName: 'Meter number',
        amount: 0,
        fee: 0,
        isResolvable: true,
      ),
    ];
  }

  if (code == 'INTSERVICE') {
    return [
      _flexibleItem(
        biller: biller,
        itemCode: 'IS001',
        labelName: 'Account / customer ID',
      ),
    ];
  }

  return [
    _flexibleItem(
      biller: biller,
      itemCode: 'ITEM001',
      labelName: 'Customer ID',
    ),
  ];
}

String _dataItemCodeFor(BillBiller biller) {
  final slug = biller.billerCode.toUpperCase();
  if (slug.contains('MTN')) return 'MD108';
  if (slug.contains('GLO')) return 'MD109';
  if (slug.contains('AIRTEL')) return 'MD107';
  if (slug.contains('9MOBILE')) return 'MD111';
  return 'MD108';
}

String _cableItemCodeFor(String fwCode) {
  switch (fwCode) {
    case 'BIL119':
      return 'CB119';
    case 'BIL120':
      return 'CB120';
    case 'BIL123':
      return 'CB123';
    default:
      return 'CB119';
  }
}

String _utilityItemCodeFor(String fwCode) {
  switch (fwCode) {
    case 'BIL110':
      return 'UB134';
    case 'BIL113':
      return 'UB136';
    case 'BIL114':
      return 'UB137';
    default:
      return 'UB134';
  }
}
