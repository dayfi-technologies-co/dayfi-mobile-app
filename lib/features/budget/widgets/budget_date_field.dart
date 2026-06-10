import 'package:dayfi/common/utils/platform_date_picker.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Read-only date field — same interaction as DOB in onboarding.
class BudgetDateField extends StatelessWidget {
  final String label;
  final String hintText;
  final DateTime? value;
  final double width;
  final DateTime firstDate;
  final DateTime lastDate;
  final String pickerTitle;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onClear;

  const BudgetDateField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.width,
    required this.firstDate,
    required this.lastDate,
    required this.pickerTitle,
    required this.onDateSelected,
    this.onClear,
  });

  static String formatDisplay(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  static String toIsoDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _openPicker(BuildContext context) async {
    final initial = value ?? firstDate;
    final picked = await PlatformDatePicker.showDatePicker(
      context: context,
      initialDate:
          initial.isBefore(firstDate)
              ? firstDate
              : (initial.isAfter(lastDate) ? lastDate : initial),
      firstDate: firstDate,
      lastDate: lastDate,
      onDateSelected: (_) {},
      title: pickerTitle,
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = value != null ? formatDisplay(value!) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: label,
          hintText: hintText,
          controller: TextEditingController(text: display),
          width: width,
          shouldReadOnly: true,
          onTap: () => _openPicker(context),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onClear != null && value != null)
                GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              Container(
                width: 40,
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  'assets/icons/svgs/calendar.svg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
