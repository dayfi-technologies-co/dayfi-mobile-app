import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Personalized, friendly DayX opener (chat + voice hints).
abstract final class DayxWelcomeBuilder {
  DayxWelcomeBuilder._();

  static Future<String> buildChatWelcome(WidgetRef ref) async {
    final profile = ref.read(profileViewModelProvider).user;
    final firstName = _firstName(profile?.firstName);
    WalletHubSnapshot? hub;
    try {
      hub = await walletService.fetchWalletHub();
    } catch (_) {}

    var txCount = ref.read(transactionsProvider).transactions.length;
    if (txCount == 0) {
      try {
        await ref.read(transactionsProvider.notifier).loadTransactions();
        txCount = ref.read(transactionsProvider).transactions.length;
      } catch (_) {}
    }

    final accountAgeDays = _accountAgeDays(profile?.createdAt);
    return _compose(
      firstName: firstName,
      balanceLabel: hub?.totalAvailableBalance.formatted ?? '\$0.00',
      transactionCount: txCount,
      accountAgeDays: accountAgeDays,
    );
  }

  static String _firstName(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return 'there';
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  static int? _accountAgeDays(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return null;
    final created = DateTime.tryParse(createdAt);
    if (created == null) return null;
    return DateTime.now().difference(created.toLocal()).inDays;
  }

  static String _compose({
    required String firstName,
    required String balanceLabel,
    required int transactionCount,
    int? accountAgeDays,
  }) {
    final buffer = StringBuffer()
      ..writeln('Hey $firstName! 👋')
      ..writeln('')
      ..writeln(
        "I'm DayX — your guide inside DayFi. I can help you send money, "
        'pay bills, check your balance, open DayEarn savings, or build a '
        'budget with DayFlow.',
      )
      ..writeln('')
      ..writeln('Your snapshot right now:')
      ..writeln('• Available balance: $balanceLabel');

    if (transactionCount == 0) {
      if (accountAgeDays != null && accountAgeDays <= 14) {
        buffer.writeln(
          '• Your account is pretty new — I do not have real spending '
          'patterns yet. Great time to set a budget before money starts moving.',
        );
      } else {
        buffer.writeln(
          '• No transactions yet — once you send or pay bills, I can '
          'help you track and budget from real activity.',
        );
      }
    } else {
      buffer.writeln('• $transactionCount transactions on your account so far');
    }

    buffer
      ..writeln('')
      ..writeln('Try saying:')
      ..writeln('• "Send ₦5,000 to mom"')
      ..writeln('• "Pay airtime"')
      ..writeln('• "Help me budget this month"')
      ..writeln('• "What is DayFi?"')
      ..writeln('')
      ..writeln('What would you like to do?');

    return buffer.toString().trim();
  }

  static bool isWelcomeMessage(String text) {
    final t = text.trim();
    return t.startsWith('Hey ') && t.contains("I'm DayX");
  }
}
