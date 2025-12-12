import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';

/// Platform-specific date picker utility
///
/// This utility provides a consistent interface for showing date pickers
/// while using the native platform UI:
/// - iOS: CupertinoDatePicker in a bottom sheet
/// - Android: Material showDatePicker
class PlatformDatePicker {
  /// Shows a platform-appropriate date picker
  ///
  /// [context] - The build context
  /// [initialDate] - The initial date to show
  /// [firstDate] - The earliest selectable date
  /// [lastDate] - The latest selectable date
  /// [onDateSelected] - Callback when a date is selected
  /// [title] - Optional title for the picker
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onDateSelected,
    String? title,
  }) async {
    if (Platform.isIOS) {
      return _showIOSDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        onDateSelected: onDateSelected,
        title: title,
      );
    } else {
      return _showAndroidDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        onDateSelected: onDateSelected,
      );
    }
  }

  /// Shows iOS-style date picker using CupertinoDatePicker
  static Future<DateTime?> _showIOSDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onDateSelected,
    String? title,
  }) async {
    DateTime selectedDate = initialDate;

    return material.showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: material.Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: material.Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: material.Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Title
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    title,
                    style: material.Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Date picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: material.Colors.grey[600],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          onDateSelected(selectedDate);
                          Navigator.of(context).pop(selectedDate);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.purple500,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows Android-style date picker using Material showDatePicker
  static Future<DateTime?> _showAndroidDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await material.showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      onDateSelected(picked);
    }

    return picked;
  }

  /// Shows a date picker specifically for date of birth selection
  /// with appropriate age restrictions (18+ years old)
  static Future<DateTime?> showDateOfBirthPicker({
    required BuildContext context,
    DateTime? initialDate,
    String? title,
  }) async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(1900);

    // Ensure initial date is within valid range
    DateTime defaultInitialDate;
    if (initialDate != null) {
      if (initialDate.isBefore(firstDate)) {
        defaultInitialDate = firstDate;
      } else if (initialDate.isAfter(eighteenYearsAgo)) {
        defaultInitialDate = eighteenYearsAgo;
      } else {
        defaultInitialDate = initialDate;
      }
    } else {
      defaultInitialDate = eighteenYearsAgo;
    }

    if (Platform.isIOS) {
      return _showIOSDatePicker(
        context: context,
        initialDate: defaultInitialDate,
        firstDate: firstDate,
        lastDate: eighteenYearsAgo,
        onDateSelected: (date) {}, // Will be handled by the return value
        title: title ?? 'Select Date of Birth',
      );
    } else {
      return _showAndroidDatePicker(
        context: context,
        initialDate: defaultInitialDate,
        firstDate: firstDate,
        lastDate: eighteenYearsAgo,
        onDateSelected: (date) {}, // Will be handled by the return value
      );
    }
  }

  /// Shows a date picker for general date selection
  static Future<DateTime?> showGeneralDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) async {
    final now = DateTime.now();
    final defaultInitialDate = initialDate ?? now;
    final defaultFirstDate = firstDate ?? DateTime(1900);
    final defaultLastDate =
        lastDate ?? DateTime(now.year + 10, now.month, now.day);

    if (Platform.isIOS) {
      return _showIOSDatePicker(
        context: context,
        initialDate: defaultInitialDate,
        firstDate: defaultFirstDate,
        lastDate: defaultLastDate,
        onDateSelected: (date) {}, // Will be handled by the return value
        title: title ?? 'Select Date',
      );
    } else {
      return _showAndroidDatePicker(
        context: context,
        initialDate: defaultInitialDate,
        firstDate: defaultFirstDate,
        lastDate: defaultLastDate,
        onDateSelected: (date) {}, // Will be handled by the return value
      );
    }
  }
}
