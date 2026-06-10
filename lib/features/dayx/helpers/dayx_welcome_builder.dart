import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/constants/dayx_copy.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Personalized, friendly DayX opener — always two bubbles: greeting, then intro.
abstract final class DayxWelcomeBuilder {
  DayxWelcomeBuilder._();

  /// Short opener: `Hey Kolawole! 👋` — never "Hey there!".
  static String greetingLine(String? rawFirstName) {
    final firstName = _firstName(rawFirstName);
    if (firstName.isEmpty) return 'Hey! 👋';
    return 'Hey $firstName! 👋';
  }

  /// Placeholder intro while profile/wallet loads.
  static String introPlaceholder() => DayxCopy.chatWelcomeIntroLead;

  static Future<List<String>> buildChatWelcomeMessages(WidgetRef ref) async {
    await ref.read(profileViewModelProvider.notifier).loadUserProfile();
    final profile = ref.read(profileViewModelProvider).user;
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
    return [
      greetingLine(profile?.firstName),
      _composeIntroBody(
        balanceLabel: hub?.totalAvailableBalance.formatted ?? '\$0.00',
        transactionCount: txCount,
        accountAgeDays: accountAgeDays,
      ),
    ];
  }

  @Deprecated('Use buildChatWelcomeMessages')
  static Future<String> buildChatWelcome(WidgetRef ref) async {
    final parts = await buildChatWelcomeMessages(ref);
    return '${parts[0]}\n\n${parts[1]}';
  }

  static String _firstName(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  static int? _accountAgeDays(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return null;
    final created = DateTime.tryParse(createdAt);
    if (created == null) return null;
    return DateTime.now().difference(created.toLocal()).inDays;
  }

  static String _composeIntroBody({
    required String balanceLabel,
    required int transactionCount,
    int? accountAgeDays,
  }) {
    final buffer = StringBuffer()
      ..writeln(DayxCopy.chatWelcomeIntroLead)
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

    return buffer.toString().trim();
  }

  static bool isWelcomeGreeting(String text) {
    final t = text.trim();
    if (!t.startsWith('Hey')) return false;
    return t.contains('👋') && !t.contains("I'm DayX");
  }

  static bool isWelcomeIntro(String text) {
    return text.trim().startsWith("I'm DayX");
  }

  static bool isWelcomeMessage(String text) {
    return isWelcomeGreeting(text) || isWelcomeIntro(text);
  }
}
