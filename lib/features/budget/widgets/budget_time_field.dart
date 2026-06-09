import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Time-of-day picker paired with [BudgetDateField] for scheduled automations.
class BudgetTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final double width;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const BudgetTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.width,
    required this.onTimeSelected,
  });

  static String formatDisplay(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onTimeSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hintText: '9:00 AM',
      controller: TextEditingController(text: formatDisplay(value)),
      width: width,
      shouldReadOnly: true,
      onTap: () => _openPicker(context),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SvgPicture.asset(
          'assets/icons/svgs/clock-dollar.svg',
          height: 20,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
