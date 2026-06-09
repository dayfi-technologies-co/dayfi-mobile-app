import 'package:dayfi/common/utils/string_utils.dart';

String formatBudgetAmount(double amount, String currency) {
  return StringUtils.formatCurrency(
    amount.toStringAsFixed(2),
    currency,
  );
}
