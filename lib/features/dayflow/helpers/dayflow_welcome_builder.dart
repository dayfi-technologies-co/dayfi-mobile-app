import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/models/wallet_hub.dart';

/// Friendly DayFlow budget-chat opener with wallet context.
abstract final class DayFlowWelcomeBuilder {
  DayFlowWelcomeBuilder._();

  static String build({
    required String firstName,
    WalletHubSnapshot? hub,
    int transactionCount = 0,
    int? accountAgeDays,
  }) {
    final name = firstName.trim().isEmpty
        ? 'there'
        : firstName.trim()[0].toUpperCase() +
            firstName.trim().substring(1).toLowerCase();
    final balance = dayFlowWalletBalance(hub);
    final balanceLabel = formatDayFlowAmount(balance, kDayFlowWalletCurrency);

    final buffer = StringBuffer()
      ..writeln('Hey $name! 👋')
      ..writeln('')
      ..writeln(
        'Great that you want to plan your money. Let me be upfront about '
        'what I see, then we can build something that actually fits your life.',
      )
      ..writeln('')
      ..writeln('Your financial snapshot:');

    if (balance > 0) {
      buffer.writeln(
        '• Wallet available: $balanceLabel ${DayFlowCopy.globalWalletAvailableSuffix}',
      );
    } else {
      buffer.writeln('• Wallet available: $balanceLabel');
    }

    if (transactionCount == 0 &&
        accountAgeDays != null &&
        accountAgeDays <= 14) {
      buffer.writeln(
        '• Your account is only $accountAgeDays days old — I do not have '
        'real income or spending patterns yet. Perfect timing to set a budget '
        'before money starts flowing.',
      );
    } else if (transactionCount == 0) {
      buffer.writeln(
        '• I do not have much transaction history yet — we will shape your '
        'budget from what you tell me.',
      );
    } else {
      buffer.writeln(
        '• $transactionCount transactions so far — as you use DayFi more, '
        'we can tune your budget from real spending.',
      );
    }

    buffer
      ..writeln('')
      ..writeln('To build a solid plan, tell me:')
      ..writeln('1. Your monthly income (salary, business, side hustle)')
      ..writeln('2. Main expenses (rent, food, transport, bills, subscriptions)')
      ..writeln('3. Any goals (emergency fund, savings, debt payoff)')
      ..writeln('')
      ..writeln(
        'Or jump in with something like "I have ₦200k this month — rent is '
        '₦80k, send mom ₦20k weekly, and keep ₦30k for data and airtime."',
      )
      ..writeln('')
      ..writeln('What is your approximate monthly income? 💰');

    return buffer.toString().trim();
  }

  static bool isWelcomeMessage(String text) {
    final t = text.trim();
    return t.startsWith('Hey ') && t.contains('financial snapshot');
  }
}
