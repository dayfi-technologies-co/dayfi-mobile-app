import 'package:dayfi/features/dayx/models/dayx_flow.dart';

/// Maps spoken phrases to flow option chips (bank, method, wallet, etc.).
abstract final class DayxFlowVoiceMatch {
  static const _bankHints = <String, List<String>>{
    'opay': ['opay', 'paycom'],
    'palmpay': ['palmpay', 'palm pay', 'palm'],
    'gtb': ['gtb', 'gtbank', 'guaranty'],
    'access': ['access'],
    'uba': ['uba', 'united bank'],
    'zenith': ['zenith'],
    'kuda': ['kuda'],
    'moniepoint': ['moniepoint', 'monie'],
    'first': ['first bank', 'firstbank', 'fbn'],
    'fcmb': ['fcmb'],
    'sterling': ['sterling'],
    'wema': ['wema', 'alat'],
    'fidelity': ['fidelity'],
    'union': ['union'],
    'ecobank': ['ecobank'],
  };

  static const _methodHints = <String, String>{
    'bank': 'bank',
    'username': 'dayfi_tag',
    'dayfi': 'dayfi_tag',
    'tag': 'dayfi_tag',
    'crypto': 'crypto',
    'on-chain': 'crypto',
    'onchain': 'crypto',
  };

  /// Best matching option for spoken text, or null → send [utterance] to backend.
  static DayxFlowOption? matchOption(
    List<DayxFlowOption> options,
    String text,
  ) {
    if (options.isEmpty) return null;
    final q = text.toLowerCase().trim();

    for (final opt in options) {
      final label = opt.label.toLowerCase();
      final id = opt.id.toLowerCase();
      if (q.contains(label) || q.contains(id)) return opt;
      final words = label.split(RegExp(r'\s+'));
      for (final w in words) {
        if (w.length >= 4 && q.contains(w)) return opt;
      }
    }

    for (final entry in _bankHints.entries) {
      if (!q.contains(entry.key)) continue;
      for (final opt in options) {
        final label = opt.label.toLowerCase();
        if (entry.value.any((h) => label.contains(h))) return opt;
      }
    }

    for (final entry in _methodHints.entries) {
      if (!q.contains(entry.key)) continue;
      for (final opt in options) {
        if (opt.id == entry.value) return opt;
      }
    }

    for (final opt in options) {
      if (q.contains(opt.id.toLowerCase())) return opt;
    }

    return null;
  }

  static String listenHintForStep(String step) {
    switch (step) {
      case 'select_bank':
        return 'Listening… say a bank, e.g. Opay or GTBank.';
      case 'select_method':
        return 'Listening… say username, bank, or crypto.';
      case 'select_spend_wallet':
      case 'select_wallet':
      case 'select_from':
        return 'Listening… say NGN, USD, EUR, or GBP.';
      case 'select_country':
        return 'Listening… say Nigeria, US, UK, or Euro.';
      default:
        return 'Listening… say your choice or tap an option.';
    }
  }

  static String shortVoiceCue(String step) {
    switch (step) {
      case 'select_bank':
        return 'Say the bank name, like Opay.';
      case 'select_method':
        return 'How should they receive it?';
      case 'input_amount':
        return 'How much?';
      default:
        return '';
    }
  }
}
