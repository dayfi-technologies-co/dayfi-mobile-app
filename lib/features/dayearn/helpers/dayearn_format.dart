import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:intl/intl.dart';

/// DayEarn pots are funded from the global USD wallet only.
const String kDayEarnCurrency = 'USD';
const double kDayEarnApyPercent = 7.0;

String dayEarnEffectiveCurrency([String? currency]) => kDayEarnCurrency;

class DayEarnInterestPreview {
  final String currency;
  final double apyPercent;
  final double amount;
  final double daily;
  final double monthly;
  final double yearly;

  const DayEarnInterestPreview({
    required this.currency,
    required this.apyPercent,
    required this.amount,
    required this.daily,
    required this.monthly,
    required this.yearly,
  });

  factory DayEarnInterestPreview.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    return DayEarnInterestPreview(
      currency: json['currency']?.toString().toUpperCase() ?? kDayEarnCurrency,
      apyPercent: n(json['apyPercent']),
      amount: n(json['amount']),
      daily: n(json['daily']),
      monthly: n(json['monthly']),
      yearly: n(json['yearly']),
    );
  }

  static DayEarnInterestPreview compute({
    required double amount,
    required String currency,
  }) {
    final c = dayEarnEffectiveCurrency(currency);
    final apy = kDayEarnApyPercent;
    final daily = _round(amount * apy / 100 / 365, 4);
    return DayEarnInterestPreview(
      currency: c,
      apyPercent: apy,
      amount: amount,
      daily: daily,
      monthly: _round(daily * 30),
      yearly: _round(amount * apy / 100),
    );
  }

  static double _round(double v, [int d = 2]) {
    final f = _pow10(d);
    return (v * f).round() / f;
  }

  static double _pow10(int d) {
    var r = 1.0;
    for (var i = 0; i < d; i++) {
      r *= 10;
    }
    return r;
  }
}

String dayEarnCurrencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'NGN':
      return '₦';
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    default:
      return currency.toUpperCase();
  }
}

/// NGN — whole amounts; USD/EUR/GBP — cents (2 dp).
int amountDisplayDecimals(String currency) {
  switch (currency.toUpperCase()) {
    case 'NGN':
      return 0;
    case 'USD':
    case 'EUR':
    case 'GBP':
      return 2;
    default:
      return 2;
  }
}

String formatDayEarnAmount(double amount, String currency, {int? decimals}) {
  final d = decimals ?? amountDisplayDecimals(currency);
  final sym = dayEarnCurrencySymbol(currency);
  final formatted = amount.toStringAsFixed(d);
  final parts = formatted.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  if (d <= 0) return '$sym${buffer.toString()}';
  final dec = parts.length > 1 ? '.${parts[1]}' : '';
  return '$sym${buffer.toString()}$dec';
}

/// Interest accrual can be sub-cent on small USD pots — avoid showing \$0.00 when earning.
String formatDayEarnInterestAmount(double amount, String currency) {
  if (amount == 0) return formatDayEarnAmount(0, currency);

  if (currency.toUpperCase() == 'NGN') {
    return formatDayEarnAmount(amount.roundToDouble(), currency, decimals: 0);
  }

  final abs = amount.abs();
  // Below one cent: show up to 4 decimal places (matches backend accrual precision).
  final decimals = abs < 0.01 ? 4 : 2;
  final fixed = amount.toStringAsFixed(decimals);
  final trimmed = _trimTrailingDecimalZeros(fixed);
  final parts = trimmed.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  final sym = dayEarnCurrencySymbol(currency);
  if (parts.length <= 1) return '$sym${buffer.toString()}';
  return '$sym${buffer.toString()}.${parts[1]}';
}

String _trimTrailingDecimalZeros(String value) {
  if (!value.contains('.')) return value;
  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Before [DayEarnPot.firstCreditAt] — today's earned interest is always zero.
bool dayEarnPotAwaitingFirstCredit(DayEarnPot pot) {
  if (pot.awaitingFirstCredit) return true;
  final firstCredit = pot.firstCreditAt;
  if (firstCredit != null && DateTime.now().isBefore(firstCredit.toLocal())) {
    return true;
  }
  return pot.interestEarned <= 0 && pot.todaysInterest <= 0;
}

String formatDayEarnFirstCreditLabel(DayEarnPot pot) {
  final at = pot.firstCreditAt ?? pot.nextInterestAt;
  if (at == null) return 'First interest soon';
  final local = at.toLocal();
  if (local.isBefore(DateTime.now())) return 'First interest soon';
  return 'First interest ${DateFormat('MMM d').format(local)} · ${DateFormat.jm().format(local)}';
}

String _formatDayEarnInterestTiming(DayEarnPot pot) {
  final at = pot.firstCreditAt ?? pot.nextInterestAt;
  if (at == null) return 'after your first full day in the pot';
  final local = at.toLocal();
  if (local.isBefore(DateTime.now())) {
    return DateFormat('MMM d · h:mm a').format(local);
  }
  return '${DateFormat('MMM d').format(local)} at ${DateFormat.jm().format(local)}';
}

/// Single friendly summary for pot detail balance card (interest + timing).
String formatDayEarnPotDetailInterestSummary(DayEarnPot pot) {
  final zero = formatDayEarnAmount(0, kDayEarnCurrency);
  final todayEarned =
      dayEarnPotAwaitingFirstCredit(pot) || pot.todaysInterest <= 0
          ? zero
          : '+${formatDayEarnInterestAmount(pot.todaysInterest, kDayEarnCurrency)}';

  if (dayEarnPotAwaitingFirstCredit(pot)) {
    final when = _formatDayEarnInterestTiming(pot);
    return
        "Today's interest is $todayEarned. Your first interest lands on $when — "
        'keep your money in this pot through that full day. '
        'Withdraw before then and you earn nothing.';
  }

  final nextWhen = _formatDayEarnInterestTiming(pot);
  return
      "Today's interest is $todayEarned. "
      'Your next interest payment is scheduled for $nextWhen.';
}

String formatDayEarnProjectedDailyRate(DayEarnPot pot) {
  return '~${formatDayEarnInterestAmount(pot.dailyInterest, kDayEarnCurrency)}/day';
}

String formatDayEarnTodaysInterestLabel(DayEarnPot pot) {
  if (dayEarnPotAwaitingFirstCredit(pot)) {
    return formatDayEarnAmount(0, kDayEarnCurrency);
  }
  if (pot.todaysInterest <= 0) {
    return formatDayEarnAmount(0, kDayEarnCurrency);
  }
  return '+${formatDayEarnInterestAmount(pot.todaysInterest, kDayEarnCurrency)}';
}

String formatDayEarnCombinedTodaysInterest(List<DayEarnPot> pots) {
  final total = pots.fold<double>(0, (sum, p) => sum + p.todaysInterest);
  if (total <= 0) {
    final currency = pots.isNotEmpty
        ? dayEarnEffectiveCurrency(pots.first.currency)
        : kDayEarnCurrency;
    return formatDayEarnInterestAmount(0, currency);
  }
  // Mixed currencies — show raw sum with USD (DayEarn is USD-only).
  return '+${formatDayEarnInterestAmount(total, kDayEarnCurrency)}';
}

String dayEarnWalletLabel([String? currency]) => 'USD balance';

String dayEarnFlagAsset([String? currency]) =>
    'assets/icons/svgs/world_flags/united states.svg';
