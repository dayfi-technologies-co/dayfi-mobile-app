import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

class DayFlowScheduleDateGroup {
  final String dateLabel;
  final DateTime sortKey;
  final List<DayBudgetScheduleInstance> items;

  const DayFlowScheduleDateGroup({
    required this.dateLabel,
    required this.sortKey,
    required this.items,
  });
}

class DayFlowScheduleListData {
  final List<DayFlowScheduleDateGroup> upcomingGroups;
  final List<DayFlowScheduleDateGroup> pastGroups;

  const DayFlowScheduleListData({
    this.upcomingGroups = const [],
    this.pastGroups = const [],
  });

  bool get isEmpty => upcomingGroups.isEmpty && pastGroups.isEmpty;
}

String formatScheduleDateHeader(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);

  if (dueDay == today) return 'Today';
  final tomorrow = today.add(const Duration(days: 1));
  if (dueDay == tomorrow) return 'Tomorrow';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[due.month - 1]} ${due.day}';
}

bool _matchesSearch(DayBudgetScheduleInstance item, String query) {
  if (query.isEmpty) return true;
  final haystack = [
    item.title,
    item.recipientHint,
    item.flowTitle,
    item.dueLabel,
    item.paymentType,
  ].whereType<String>().join(' ').toLowerCase();
  return haystack.contains(query);
}

List<DayFlowScheduleDateGroup> _groupByDate(
  List<DayBudgetScheduleInstance> items, {
  required bool ascending,
}) {
  final grouped = <String, List<DayBudgetScheduleInstance>>{};
  final sortKeys = <String, DateTime>{};

  for (final item in items) {
    final label = formatScheduleDateHeader(item.dueAt);
    grouped.putIfAbsent(label, () => []).add(item);
    final dueDay = DateTime(
      item.dueAt.year,
      item.dueAt.month,
      item.dueAt.day,
    );
    sortKeys.putIfAbsent(label, () => dueDay);
  }

  final groups =
      grouped.entries
          .map(
            (e) => DayFlowScheduleDateGroup(
              dateLabel: e.key,
              sortKey: sortKeys[e.key]!,
              items: e.value,
            ),
          )
          .toList()
        ..sort(
          (a, b) =>
              ascending
                  ? a.sortKey.compareTo(b.sortKey)
                  : b.sortKey.compareTo(a.sortKey),
        );

  for (final group in groups) {
    group.items.sort(
      (a, b) =>
          ascending
              ? a.dueAt.compareTo(b.dueAt)
              : b.dueAt.compareTo(a.dueAt),
    );
  }
  return groups;
}

DayFlowScheduleListData buildScheduleListData(
  DayBudgetScheduleInstances instances, {
  String searchQuery = '',
}) {
  final query = searchQuery.trim().toLowerCase();

  final upcoming =
      instances.upcoming
          .where((i) => _matchesSearch(i, query))
          .toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  final past =
      instances.past
          .where((i) => _matchesSearch(i, query))
          .toList()
        ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

  return DayFlowScheduleListData(
    upcomingGroups: _groupByDate(upcoming, ascending: true),
    pastGroups: _groupByDate(past, ascending: false),
  );
}
