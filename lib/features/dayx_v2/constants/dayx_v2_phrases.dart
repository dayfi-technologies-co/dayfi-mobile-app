/// Fixed phrases DayX v2 says verbatim. These are pre-warmed (synthesized +
/// cached) so they play instantly in the real YarnGPT voice instead of paying
/// the slow per-utterance synthesis cost every time.
abstract final class DayxV2Phrases {
  DayxV2Phrases._();

  /// Returning-session greeting — spoken on every open after the first.
  static const returningGreeting = 'Wetin you wan do today?';

  /// Common confirmations / fallbacks spoken verbatim by the overlay flow.
  static const _fixed = <String>[
    returningGreeting,
    'Done! Transaction successful.',
    'Wrong PIN. Try again.',
    'Something no work. Try again.',
    'I no catch am. Say am again.',
    'Try again.',
  ];

  /// Phrase set to pre-bake. The first-run intro greeting is not included —
  /// it self-caches the first time it is spoken.
  static List<String> get prewarmSet => List.unmodifiable(_fixed);
}
