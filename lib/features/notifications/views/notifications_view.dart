import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/features/budget/helpers/budget_notification_helper.dart';
import 'package:dayfi/features/budget/views/budget_detail_view.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/features/notifications/vm/notifications_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour =
        local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    // Load notifications using Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationsProvider.notifier)
          .loadNotifications(isInitialLoad: true);
    });
  }

  Map<String, List<NotificationItem>> _groupNotificationsByDate(
    List<NotificationItem> notifications,
  ) {
    final Map<String, List<NotificationItem>> grouped = {};

    for (final notification in notifications) {
      final dateKey = _formatDate(notification.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    // Sort notifications within each date group by timestamp (newest first)
    grouped.forEach((key, value) {
      value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });

    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Month Day, Year" (e.g., "Dec 15, 2024")
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _markAsRead(NotificationItem notification) {
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
  }

  void _refreshNotifications() {
    ref.read(notificationsProvider.notifier).loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);
    final notifications = notificationsState.notifications;
    final isLoading = notificationsState.isLoading;
    final errorMessage = notificationsState.errorMessage;

    final groupedNotifications = _groupNotificationsByDate(notifications);
    final sortedDates =
        groupedNotifications.keys.toList()..sort((a, b) {
          // Sort dates: Today, Yesterday, then by actual date (newest first)
          if (a == 'Today') return -1;
          if (b == 'Today') return 1;
          if (a == 'Yesterday') return -1;
          if (b == 'Yesterday') return 1;

          // For other dates, parse and compare
          final dateA = _parseDateString(a);
          final dateB = _parseDateString(b);

          return dateB.compareTo(dateA);
        });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: .5,
        leadingWidth: 72,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap:
              () => {Navigator.pop(context), FocusScope.of(context).unfocus()},
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              SvgPicture.asset(
                "assets/icons/svgs/notificationn.svg",
                height: 40,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      // size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Read all',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple500ForTheme(context),
                ),
              ),
            ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          final hasData = notifications.isNotEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await ref
                      .read(notificationsProvider.notifier)
                      .loadNotifications();
                },
              ),
              if (hasData)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final date = sortedDates[index];
                      final notificationsForDate =
                          groupedNotifications[date]!;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 24 : 18,
                        ),
                        child: _buildNotificationGroup(
                          date,
                          notificationsForDate,
                        ),
                      );
                    },
                    childCount: sortedDates.length,
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 500 : double.infinity,
                      ),
                      child: isLoading
                          ? _buildLoadingState()
                          : errorMessage != null
                              ? ErrorStateWidget(
                                  message: 'Failed to load notifications',
                                  details: errorMessage,
                                  onRetry: _refreshNotifications,
                                )
                              : EmptyStateWidget(
                                  icon: Icons.notifications_none_outlined,
                                  title: 'No notifications yet',
                                  message:
                                      "You'll see important updates here",
                                ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationGroup(
    String date,
    List<NotificationItem> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        // Padding(
        //   padding: EdgeInsets.only(bottom: 8, top: 16),
        //   child: Text(
        //     date,
        //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //       fontFamily: 'Chirp',
        //       fontSize: 14,
        //       fontWeight: FontWeight.w500,
        //       letterSpacing: -.25,
        //       height: 1.450,
        //       color: Theme.of(
        //         context,
        //       ).textTheme.bodyLarge!.color!.withOpacity(.75),
        //     ),
        //   ),
        // ),

        // to be removed: date header above
        SizedBox(height: 12),

        // Notifications for this date
        SizedBox(
          // padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // decoration: BoxDecoration(
          //   color: Theme.of(context).colorScheme.surface,
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: Column(
            children: [
              for (int i = 0; i < notifications.length; i++)
                _buildNotificationCard(
                  notifications[i],
                  bottomMargin: i == notifications.length - 1 ? 8 : 24,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const DayfiLoadingCenter();
  }

  Widget _buildNotificationCard(
    NotificationItem notification, {
    double bottomMargin = 24,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (!notification.isRead) {
          _markAsRead(notification);
        }
        _openNotificationTarget(notification);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin, top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  notification.type.emoji,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(width: 16),

            // Notification Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.25,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.75),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatTime(notification.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Read status indicator
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.purple500ForTheme(context),
                  shape: BoxShape.circle,
                ),
              )
            else
              SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _openNotificationTarget(NotificationItem notification) {
    if (!isBudgetNotification(notification)) return;
    final budgetId = budgetIdFromNotification(notification);
    if (budgetId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetDetailView(budgetId: budgetId),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return AppColors.success500;
      case NotificationType.budget:
        return AppColors.primary400;
      case NotificationType.security:
        return Theme.of(context).colorScheme.primary;
      case NotificationType.promotion:
        return AppColors.warning500;
      case NotificationType.system:
        return AppColors.neutral500;
      case NotificationType.general:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getMonthNumber(String month) {
    const months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12',
    };
    return months[month] ?? '01';
  }

  DateTime _parseDateString(String dateString) {
    try {
      // Format: "Dec 15, 2024"
      final parts = dateString.split(', ');
      if (parts.length != 2) return DateTime.now();

      final year = parts[1];
      final monthDayParts = parts[0].split(' ');
      if (monthDayParts.length != 2) return DateTime.now();

      final month = monthDayParts[0];
      final day = monthDayParts[1];

      final monthNumber = _getMonthNumber(month);
      final paddedDay = day.padLeft(2, '0');

      return DateTime.parse('$year-$monthNumber-$paddedDay');
    } catch (e) {
      // If parsing fails, return current date
      return DateTime.now();
    }
  }
}
