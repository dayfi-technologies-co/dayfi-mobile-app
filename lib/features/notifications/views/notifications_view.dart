import 'package:dayfi/common/widgets/buttons/help_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/core/theme/app_colors.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // Only show welcome notification for now
    final now = DateTime.now();
    _notifications.addAll([
      NotificationItem(
        id: 'welcome_1',
        title: 'Welcome to DayFi! 🎉',
        message: 'Your account is ready. Send money to those who matter.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: NotificationType.general,
        isRead: false,
      ),
    ]);
  }

  Map<String, List<NotificationItem>> _groupNotificationsByDate() {
    final Map<String, List<NotificationItem>> grouped = {};

    for (final notification in _notifications) {
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

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();
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
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Alerts",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: HelpButton(
                onTap: _markAllAsRead,
                text: "Read All",
                svgIcon: const SizedBox.shrink(),
              ),
            ),
        ],
      ),

      body:
          _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: () async {
                  // Simulate refresh
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() {});
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final notifications = groupedNotifications[date]!;

                    return _buildNotificationGroup(date, notifications);
                  },
                ),
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
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
          child: Text(
            date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Karla',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -.6,
              height: 1.450,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(.75),
            ),
          ),
        ),

        // Notifications for this date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'ll see important updates here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Karla',
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification, {
    double bottomMargin = 24,
  }) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          _markAsRead(notification);
        }
        // Handle notification tap (e.g., navigate to relevant screen)
      },
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin.h, top: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notification.type,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  notification.type.emoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Notification Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 18.sp,
                      letterSpacing: -.6,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.6,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.75),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatTime(notification.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Read status indicator
            if (!notification.isRead)
              Container(
                width: 8.w,
                height: 8.w,
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

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return AppColors.success500;
      case NotificationType.security:
        return AppColors.primary500;
      case NotificationType.promotion:
        return AppColors.warning500;
      case NotificationType.system:
        return AppColors.neutral500;
      case NotificationType.general:
        return AppColors.primary500;
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
