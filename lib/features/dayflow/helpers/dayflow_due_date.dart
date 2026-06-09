/// Resolve human schedule labels (tomorrow, every Saturday, ISO dates) to timestamps.
DateTime? dayflowParseDueLabelToNextRunAt(
  String? dueLabel, {
  DateTime? now,
}) {
  if (dueLabel == null || dueLabel.trim().isEmpty) return null;
  final ref = now ?? DateTime.now();
  final lower = dueLabel.toLowerCase().trim();

  final iso = DateTime.tryParse(dueLabel.trim());
  if (iso != null) return iso;

  if (lower.contains('today')) {
    return DateTime(ref.year, ref.month, ref.day, 9);
  }
  if (lower.contains('tomorrow')) {
    final t = ref.add(const Duration(days: 1));
    return DateTime(t.year, t.month, t.day, 9);
  }

  const weekdays = {
    'sunday': DateTime.sunday,
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
  };
  for (final e in weekdays.entries) {
    if (!lower.contains(e.key)) continue;
    var cursor = DateTime(ref.year, ref.month, ref.day, 9);
    for (var i = 0; i < 14; i++) {
      if (cursor.weekday == e.value && !cursor.isBefore(DateTime(ref.year, ref.month, ref.day))) {
        return cursor;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  final monthDay = RegExp(
    r'\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})\b',
    caseSensitive: false,
  ).firstMatch(lower);
  if (monthDay != null) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final monthKey = monthDay.group(1)!.toLowerCase().substring(0, 3);
    final day = int.tryParse(monthDay.group(2)!);
    final month = months[monthKey];
    if (month != null && day != null) {
      var year = ref.year;
      final candidate = DateTime(year, month, day, 9);
      if (candidate.isBefore(DateTime(ref.year, ref.month, ref.day))) {
        year += 1;
      }
      return DateTime(year, month, day, 9);
    }
  }

  return null;
}

String? dayflowResolveNextRunAtIso({
  String? dueLabel,
  String? nextRunAt,
  String frequency = 'monthly',
  DateTime? now,
}) {
  final explicit = nextRunAt?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    final parsed = DateTime.tryParse(explicit);
    if (parsed != null) return parsed.toIso8601String();
  }

  if (frequency == 'once' ||
      (dueLabel ?? '').toLowerCase().contains('tomorrow') ||
      (dueLabel ?? '').toLowerCase().contains('today')) {
    final parsed = dayflowParseDueLabelToNextRunAt(dueLabel, now: now);
    return parsed?.toIso8601String();
  }

  if (frequency == 'weekly' || frequency == 'biweekly') {
    final parsed = dayflowParseDueLabelToNextRunAt(dueLabel, now: now);
    if (parsed != null) return parsed.toIso8601String();
  }

  return null;
}

bool dayflowHasResolvableSchedule({
  String? dueLabel,
  String? nextRunAt,
  String frequency = 'monthly',
}) {
  if (nextRunAt != null && DateTime.tryParse(nextRunAt) != null) return true;
  if (frequency == 'monthly' ||
      frequency == 'weekly' ||
      frequency == 'biweekly' ||
      frequency == 'daily') {
    return (dueLabel ?? '').trim().isNotEmpty ||
        dayflowParseDueLabelToNextRunAt(dueLabel) != null;
  }
  return dayflowParseDueLabelToNextRunAt(dueLabel) != null;
}
