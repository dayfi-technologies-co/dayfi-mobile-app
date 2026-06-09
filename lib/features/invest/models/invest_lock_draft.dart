import 'package:dayfi/services/remote/investment_service.dart';

class InvestLockDraft {
  InvestmentPlan plan;
  double? amount;
  String? name;
  InvestmentQuote? quote;

  InvestLockDraft({required this.plan});

  bool get hasAmount => amount != null && amount! >= 1;
  bool get hasName => name != null && name!.trim().isNotEmpty;
}
