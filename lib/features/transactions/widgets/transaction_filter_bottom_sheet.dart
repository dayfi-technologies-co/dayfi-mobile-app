import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter_svg/svg.dart';

enum TransactionSortBy { newest, oldest, amountHighest, amountLowest }

enum TransactionStatus { all, success, pending, failed, cancelled }

class TransactionFilterOptions {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionStatus status;
  final TransactionSortBy sortBy;

  const TransactionFilterOptions({
    this.startDate,
    this.endDate,
    this.status = TransactionStatus.all,
    this.sortBy = TransactionSortBy.newest,
  });

  TransactionFilterOptions copyWith({
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
    TransactionSortBy? sortBy,
    bool clearDates = false,
  }) {
    return TransactionFilterOptions(
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        status != TransactionStatus.all ||
        sortBy != TransactionSortBy.newest;
  }

  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null) count++;
    if (status != TransactionStatus.all) count++;
    if (sortBy != TransactionSortBy.newest) count++;
    return count;
  }
}

class TransactionFilterBottomSheet extends StatefulWidget {
  final TransactionFilterOptions currentFilters;
  final Function(TransactionFilterOptions) onApply;

  const TransactionFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  late TransactionFilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
            bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildSortSection(),
                SizedBox(height: 24.h),
                _buildStatusSection(),
                SizedBox(height: 24.h),
                _buildDateRangeSection(),
                SizedBox(height: 32.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter & Sort',
          style: AppTypography.titleLarge.copyWith(
         fontFamily: 'FunnelDisplay',
             fontSize: 20.sp, // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (_filters.hasActiveFilters)
          TextButton(
            onPressed: () {
              HapticHelper.lightImpact();
              setState(() {
                _filters = TransactionFilterOptions();
              });
            },
            child: Text(
              'Clear All',
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Karla',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.purple500ForTheme(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SORT BY',
          style: AppTypography.labelMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.85),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        _buildSortOption(
          'Newest First',
          TransactionSortBy.newest,
          Icons.arrow_downward,
        ),
        SizedBox(height: 8.h),
        _buildSortOption(
          'Oldest First',
          TransactionSortBy.oldest,
          Icons.arrow_upward,
        ),
        SizedBox(height: 8.h),
        _buildSortOption(
          'Highest Amount',
          TransactionSortBy.amountHighest,
          Icons.trending_up,
        ),
        SizedBox(height: 8.h),
        _buildSortOption(
          'Lowest Amount',
          TransactionSortBy.amountLowest,
          Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildSortOption(
    String label,
    TransactionSortBy value,
    IconData icon,
  ) {
    final isSelected = _filters.sortBy == value;
    return InkWell(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() {
          _filters = _filters.copyWith(sortBy: value);
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.purple500ForTheme(context).withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.purple500ForTheme(context)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color:
                  isSelected
                      ? AppColors.purple500ForTheme(context)
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? AppColors.purple500ForTheme(context)
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: AppColors.purple500ForTheme(context),
                height: 24.sp,
                width: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS',
          style: AppTypography.labelMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.85),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildStatusChip('All', TransactionStatus.all),
            _buildStatusChip('Success', TransactionStatus.success),
            _buildStatusChip('Pending', TransactionStatus.pending),
            _buildStatusChip('Failed', TransactionStatus.failed),
            _buildStatusChip('Cancelled', TransactionStatus.cancelled),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, TransactionStatus value) {
    final isSelected = _filters.status == value;
    return InkWell(
      onTap: () {
        HapticHelper.lightImpact();
        setState(() {
          _filters = _filters.copyWith(status: value);
        });
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.purple500ForTheme(context)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.purple500ForTheme(context)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color:
                isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE RANGE',
          style: AppTypography.labelMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.85),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                label: 'Start Date',
                date: _filters.startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDateButton(
                label: 'End Date',
                date: _filters.endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        if (_filters.startDate != null || _filters.endDate != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: TextButton(
              onPressed: () {
                HapticHelper.lightImpact();
                setState(() {
                  _filters = _filters.copyWith(clearDates: true);
                });
              },
              child: Text(
                'Clear Date Range',
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.purple500ForTheme(context),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                date != null
                    ? AppColors.purple500ForTheme(context)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            width: date != null ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Karla',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        date != null
                            ? AppColors.purple500ForTheme(context)
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color:
                      date != null
                          ? AppColors.purple500ForTheme(context)
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    HapticHelper.lightImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _filters.startDate : _filters.endDate) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.purple500,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filters = _filters.copyWith(startDate: picked);
        } else {
          _filters = _filters.copyWith(endDate: picked);
        }
      });
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Apply Filters',
          onPressed: () {
            HapticHelper.lightImpact();
            widget.onApply(_filters);
            Navigator.pop(context);
          },
          backgroundColor: AppColors.purple500,
          textColor: Colors.white,
          borderRadius: 38,
          height: 56.h,
          width: double.infinity,
          fullWidth: true,
          fontFamily: 'Karla',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.8,
        ),
        SizedBox(height: 12.h),
        SecondaryButton(
          text: 'Cancel',
          onPressed: () {
            Navigator.pop(context);
          },
          borderColor: Colors.transparent,
          textColor: AppColors.purple500ForTheme(context),
          width: double.infinity,
          fullWidth: true,
          height: 56.h,
          borderRadius: 38,
          fontFamily: 'Karla',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.8,
        ),
      ],
    );
  }
}
