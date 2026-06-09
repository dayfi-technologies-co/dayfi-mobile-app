import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/models/wallet.dart';

/// Global wallet — one USD ledger; display rows are pay-with / view currencies.
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
  final String? routingNumber;
  final bool isDemoAccount;
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
    this.routingNumber,
    this.isDemoAccount = false,
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
      routingNumber: json['routingNumber']?.toString(),
      isDemoAccount: json['isDemoAccount'] == true,
      canReceiveDeposits: json['canReceiveDeposits'] == true,
      balance: _toDouble(json['balance']),
    );
  }

  bool get hasBankDisplayDetails =>
      (accountNumber?.isNotEmpty ?? false) || (iban?.isNotEmpty ?? false);

  bool get fiatReceiveReady =>
      canReceiveDeposits && hasBankDisplayDetails;
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

  /// Available balance shown in [currency] (same global pool, FX display).
  double balanceInDisplayCurrency(String currency) {
    return rowFor(currency)?.balance ?? totalAvailableBalance.amount;
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
    final hasWalletBalanceRows =
        walletBalances is List && walletBalances.isNotEmpty;
    if (hasWalletBalanceRows) {
      for (final row in walletBalances) {
        if (row is! Map<String, dynamic>) continue;
        final c = row['currency']?.toString().toUpperCase() ?? '';
        balanceByCurrency[c] = _toDouble(row['balance']);

        // Backend compatibility: some deployments may use snake_case keys.
        final walletIdRaw = row['walletId'] ??
            row['wallet_id'] ??
            row['walletID'] ??
            row['walletid'];
        final walletIdStr = walletIdRaw?.toString();
        if (walletIdStr != null && walletIdStr.isNotEmpty) {
          walletIdByCurrency[c] = walletIdStr;
        }

        final accountNumberRaw =
            row['accountNumber'] ?? row['account_number'];
        final accountNumberStr = accountNumberRaw?.toString();
        if (accountNumberStr != null && accountNumberStr.isNotEmpty) {
          accountByCurrency[c] = accountNumberStr;
        }

        final bankNameRaw = row['bankName'] ?? row['bank_name'];
        final bankNameStr = bankNameRaw?.toString();
        if (bankNameStr != null && bankNameStr.isNotEmpty) {
          bankByCurrency[c] = bankNameStr;
        }
      }
    }

    final balancesMap = data?['balances'];
    if (balancesMap is Map && !hasWalletBalanceRows) {
      balancesMap.forEach((key, value) {
        final c = key.toString().toUpperCase();
        balanceByCurrency[c] = _toDouble(value);
      });
    }

    for (final w in wallets) {
      final c = w.currency.toUpperCase();
      // PRD `walletBalances` is authoritative; legacy `wallets` may lag behind sync.
      if (!hasWalletBalanceRows) {
        balanceByCurrency[c] = w.balanceAsDouble;
      }
      if (w.walletId.isNotEmpty) {
        walletIdByCurrency[c] = w.walletId;
      }
      if (w.accountNumber != null && w.accountNumber!.isNotEmpty) {
        accountByCurrency[c] = w.accountNumber!;
      }
      if (w.bankName != null && w.bankName!.isNotEmpty) {
        bankByCurrency[c] = w.bankName!;
      }
    }

    final rows = walletCatalog.map((meta) {
      final c = meta['currency']!;
      return WalletDisplayRow(
        currency: c,
        name: meta['name']!,
        symbol: meta['symbol']!,
        flagPath: meta['flag']!,
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
