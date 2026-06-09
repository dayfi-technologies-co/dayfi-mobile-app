class BillCategory {
  final int? id;
  final String name;
  final String code;
  final String description;
  final String countryCode;

  const BillCategory({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    this.countryCode = 'NG',
  });

  factory BillCategory.fromJson(Map<String, dynamic> json) {
    return BillCategory(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? 'NG',
    );
  }
}

class BillBiller {
  final String billerCode;
  final String name;
  final String? shortName;
  final String? logo;
  /// Live Flutterwave `biller_code` when [billerCode] is a preview slug.
  final String? flutterwaveBillerCode;

  const BillBiller({
    required this.billerCode,
    required this.name,
    this.shortName,
    this.logo,
    this.flutterwaveBillerCode,
  });

  factory BillBiller.fromJson(Map<String, dynamic> json) {
    return BillBiller(
      billerCode: json['biller_code']?.toString() ?? json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['biller_name']?.toString() ?? '',
      shortName: json['short_name']?.toString(),
      logo: json['logo']?.toString(),
      flutterwaveBillerCode: json['flutterwave_biller_code']?.toString(),
    );
  }
}

class BillItem {
  final String itemCode;
  final String billerCode;
  final String name;
  final String shortName;
  final String labelName;
  final double amount;
  final double fee;
  final bool isAirtime;
  final bool isResolvable;
  final String? validityPeriod;

  const BillItem({
    required this.itemCode,
    required this.billerCode,
    required this.name,
    required this.shortName,
    required this.labelName,
    required this.amount,
    required this.fee,
    this.isAirtime = false,
    this.isResolvable = true,
    this.validityPeriod,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      itemCode: json['item_code']?.toString() ?? '',
      billerCode: json['biller_code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['biller_name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
      labelName: json['label_name']?.toString() ?? 'Customer ID',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      fee: double.tryParse(json['fee']?.toString() ?? '') ?? 0,
      isAirtime: json['is_airtime'] == true,
      isResolvable: json['is_resolvable'] != false,
      validityPeriod: json['validity_period']?.toString(),
    );
  }

  String get displayLabel =>
      shortName.isNotEmpty ? shortName : name;
}

/// Smallest priced packages first; flexible / custom (amount 0) last.
int compareBillItemsByAmount(BillItem a, BillItem b) {
  final aAmt = a.amount;
  final bAmt = b.amount;
  if (aAmt <= 0 && bAmt <= 0) {
    return a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase());
  }
  if (aAmt <= 0) return 1;
  if (bAmt <= 0) return -1;
  final byAmount = aAmt.compareTo(bAmt);
  if (byAmount != 0) return byAmount;
  return a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase());
}

List<BillItem> sortBillItemsByAmount(List<BillItem> items) {
  return List<BillItem>.from(items)..sort(compareBillItemsByAmount);
}
