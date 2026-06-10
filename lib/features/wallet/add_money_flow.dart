import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/views/wallet_receive_view.dart';
import 'package:dayfi/features/wallet/widgets/add_money_option_list.dart';
import 'package:flutter/material.dart';

/// Add-money entry methods (method-first UX).
abstract final class AddMoneyMethod {
  static const username = 'username';
  static const bankTransfer = 'bank_transfer';
  static const onChain = 'on_chain';
  static const nfc = 'nfc';
  static const card = 'card';
}

String addMoneyViaTitle(String type) => 'Add via $type';

/// User-facing label for USDC/EURC deposit addresses.
const String kAddMoneyCryptoLabel = 'Crypto';

const String kAddMoneyHubDescription = 'How would you like to add money?';

const List<AddMoneyOption> kAddMoneyMethodOptions = [
  AddMoneyOption(
    id: AddMoneyMethod.username,
    title: 'Via Username',
    subtitle: UsernameCopy.shareInstant,
    iconAsset: 'assets/icons/svgs/at.svg',
  ),
  AddMoneyOption(
    id: AddMoneyMethod.bankTransfer,
    title: 'Via Bank transfer',
    subtitle: 'NGN, USD, GBP or EUR bank details',
    iconAsset: 'assets/icons/svgs/building-bank.svg',
  ),
  AddMoneyOption(
    id: AddMoneyMethod.onChain,
    title: 'Via $kAddMoneyCryptoLabel',
    subtitle: 'Deposit USD or EUR on-chain',
    iconAsset: 'assets/icons/svgs/coin.svg',
    enabled: ProductFeatures.cryptoAddMoney,
  ),
];

void showAddMoneyComingSoon(BuildContext context, String label) {
  TopSnackbar.show(context, message: '$label is coming soon.');
}

Future<void> handleAddMoneyMethodTap(
  BuildContext context,
  AddMoneyOption option,
) async {
  if (!option.enabled) {
    showAddMoneyComingSoon(context, option.title);
    return;
  }

  switch (option.id) {
    case AddMoneyMethod.username:
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddMoneyUsernameView()),
      );
      return;
    case AddMoneyMethod.bankTransfer:
      await _runAddMoneyBankTransferFlow(context);
      return;
    case AddMoneyMethod.onChain:
      final coin = await showAddMoneyCryptoCoinSheet(context);
      if (coin == null || !context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddMoneyCryptoView(coin: coin)),
      );
      return;
    default:
      showAddMoneyComingSoon(context, option.title);
  }
}

/// Bank transfer: back from detail re-opens currency sheet; Close exits to Add money.
Future<void> _runAddMoneyBankTransferFlow(BuildContext context) async {
  while (context.mounted) {
    final currency = await showAddMoneyBankCurrencySheet(context);
    if (currency == null || !context.mounted) return;

    final exitFlow = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddMoneyBankView(
              currency: currency,
              retainCurrencySheetOnBack: true,
            ),
      ),
    );

    if (!context.mounted) return;
    if (exitFlow == true) return;
  }
}

Future<String?> showAddMoneyBankCurrencySheet(BuildContext context) {
  const bankCurrencies = ['NGN', 'USD', 'EUR', 'GBP'];
  final options =
      bankCurrencies.map((c) {
        return AddMoneyOption(
          id: c,
          title: kGlobalPayCurrencyNames[c] ?? c,
          iconAsset: kGlobalPayCurrencyFlags[c]!,
          iconStyle: AddMoneyOptionIconStyle.flag,
        );
      }).toList();

  return showAddMoneyPickerSheet<String>(
    context: context,
    title: addMoneyViaTitle('Bank transfer'),
    options: options,
  );
}

Future<String?> showAddMoneyCryptoCoinSheet(BuildContext context) {
  const options = [
    AddMoneyOption(
      id: 'USDC',
      title: 'USDC',
      iconAsset: 'assets/icons/svgs/brand-stellar.svg',
    ),
    AddMoneyOption(
      id: 'EURC',
      title: 'EURC',
      iconAsset: 'assets/icons/svgs/currency-ethereum.svg',
    ),
  ];

  return showAddMoneyPickerSheet<String>(
    context: context,
    title: addMoneyViaTitle(kAddMoneyCryptoLabel),
    options: options,
  );
}
