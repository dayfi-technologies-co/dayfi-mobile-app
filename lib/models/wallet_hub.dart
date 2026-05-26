import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/models/wallet.dart';

/// Display row for one of the four PRD wallets on home / add / convert.
class WalletDisplayRow {
  final String currency;
  final String name;
  final String symbol;
  final String flagPath;
  final double balance;
  final String? walletId;
  final bool hasLedgerWallet;
  final String? accountNumber;
  final String? bankName;

  const WalletDisplayRow({
    required this.currency,
    required this.name,
    required this.symbol,
    required this.flagPath,
    required this.balance,
    this.walletId,
    this.hasLedgerWallet = false,
    this.accountNumber,
    this.bankName,
  });

  String get formattedBalance {
    final n = balance;
    final parts = n.toStringAsFixed(2).split('.');
    var integer = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buf.write(',');
      buf.write(integer[i]);
    }
    return '$symbol${buf.toString()}.${parts[1]}';
  }
}

class TotalAvailableBalance {
  final String currency;
  final double amount;
  final String formatted;

  const TotalAvailableBalance({
    required this.currency,
    required this.amount,
    required this.formatted,
  });

  factory TotalAvailableBalance.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TotalAvailableBalance(
        currency: 'USD',
        amount: 0,
        formatted: '\$0.00',
      );
    }
    return TotalAvailableBalance(
      currency: json['currency']?.toString() ?? 'USD',
      amount: _toDouble(json['amount']),
      formatted: json['formatted']?.toString() ?? '\$0.00',
    );
  }
}

class GreyOperatingAccount {
  final String currency;
  final String name;
  final String kybStatus;
  final String statusLabel;
  final String? accountNumber;
  final String? bankName;
  final String? iban;
  final bool canReceiveDeposits;
  final double balance;

  const GreyOperatingAccount({
    required this.currency,
    required this.name,
    required this.kybStatus,
    required this.statusLabel,
    this.accountNumber,
    this.bankName,
    this.iban,
    this.canReceiveDeposits = false,
    this.balance = 0,
  });

  factory GreyOperatingAccount.fromJson(Map<String, dynamic> json) {
    return GreyOperatingAccount(
      currency: json['currency']?.toString() ?? 'USD',
      name: json['name']?.toString() ?? '',
      kybStatus: json['kybStatus']?.toString() ?? 'pending',
      statusLabel: json['statusLabel']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      iban: json['iban']?.toString(),
      canReceiveDeposits: json['canReceiveDeposits'] == true,
      balance: _toDouble(json['balance']),
    );
  }

  bool get fiatReceiveReady =>
      canReceiveDeposits &&
      ((accountNumber?.isNotEmpty ?? false) || (iban?.isNotEmpty ?? false));
}

class WalletHubSnapshot {
  final TotalAvailableBalance totalAvailableBalance;
  final List<Wallet> ledgerWallets;
  final List<GreyOperatingAccount> greyAccounts;
  final List<WalletDisplayRow> displayRows;

  const WalletHubSnapshot({
    required this.totalAvailableBalance,
    this.ledgerWallets = const [],
    this.greyAccounts = const [],
    this.displayRows = const [],
  });

  WalletDisplayRow? rowFor(String currency) {
    final c = currency.toUpperCase();
    for (final r in displayRows) {
      if (r.currency.toUpperCase() == c) return r;
    }
    return null;
  }

  GreyOperatingAccount? greyFor(String currency) {
    final c = currency.toUpperCase();
    for (final g in greyAccounts) {
      if (g.currency.toUpperCase() == c) return g;
    }
    return null;
  }

  static const walletCatalog = [
    {
      'currency': 'USD',
      'name': 'United States Dollar',
      'symbol': r'$',
      'flag': 'assets/icons/svgs/world_flags/united states.svg',
    },
    {
      'currency': 'GBP',
      'name': 'Great Britain Pounds',
      'symbol': '£',
      'flag': 'assets/icons/svgs/world_flags/united kingdom.svg',
    },
    {
      'currency': 'EUR',
      'name': 'Euro',
      'symbol': '€',
      'flag': WalletFlagAssets.eur,
    },
    {
      'currency': 'NGN',
      'name': 'Nigerian Naira',
      'symbol': '₦',
      'flag': 'assets/icons/svgs/world_flags/nigeria.svg',
    },
  ];

  factory WalletHubSnapshot.fromApiData(Map<String, dynamic>? data) {
    final total = TotalAvailableBalance.fromJson(
      data?['totalAvailableBalance'] as Map<String, dynamic>?,
    );

    final wallets = <Wallet>[];
    final rawWallets = data?['wallets'];
    if (rawWallets is List) {
      for (final w in rawWallets) {
        if (w is Map<String, dynamic>) wallets.add(Wallet.fromJson(w));
      }
    }

    final balanceByCurrency = <String, double>{};
    final walletIdByCurrency = <String, String>{};
    final accountByCurrency = <String, String>{};
    final bankByCurrency = <String, String>{};

    final walletBalances = data?['walletBalances'];
    if (walletBalances is List) {
      for (final row in walletBalances) {
        if (row is! Map<String, dynamic>) continue;
        final c = row['currency']?.toString().toUpperCase() ?? '';
        balanceByCurrency[c] = _toDouble(row['balance']);
        if (row['walletId'] != null) {
          walletIdByCurrency[c] = row['walletId'].toString();
        }
        if (row['accountNumber'] != null) {
          accountByCurrency[c] = row['accountNumber'].toString();
        }
        if (row['bankName'] != null) {
          bankByCurrency[c] = row['bankName'].toString();
        }
      }
    }

    final balancesMap = data?['balances'];
    if (balancesMap is Map) {
      balancesMap.forEach((key, value) {
        final c = key.toString().toUpperCase();
        balanceByCurrency[c] = _toDouble(value);
      });
    }

    for (final w in wallets) {
      final c = w.currency.toUpperCase();
      balanceByCurrency[c] = w.balanceAsDouble;
      walletIdByCurrency[c] = w.walletId;
      if (w.accountNumber != null && w.accountNumber!.isNotEmpty) {
        accountByCurrency[c] = w.accountNumber!;
      }
      if (w.bankName != null && w.bankName!.isNotEmpty) {
        bankByCurrency[c] = w.bankName!;
      }
    }

    final rows = walletCatalog.map((meta) {
      final c = meta['currency']! as String;
      return WalletDisplayRow(
        currency: c,
        name: meta['name']! as String,
        symbol: meta['symbol']! as String,
        flagPath: meta['flag']! as String,
        balance: balanceByCurrency[c] ?? 0,
        walletId: walletIdByCurrency[c],
        hasLedgerWallet: walletIdByCurrency.containsKey(c),
        accountNumber: accountByCurrency[c],
        bankName: bankByCurrency[c],
      );
    }).toList();

    return WalletHubSnapshot(
      totalAvailableBalance: total,
      ledgerWallets: wallets,
      displayRows: rows,
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
