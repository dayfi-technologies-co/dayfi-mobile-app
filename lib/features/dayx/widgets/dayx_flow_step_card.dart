import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/widgets/dayx_flow_deposit_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-chat step UI for the DayX flow orchestrator (chips, fields, review).
class DayxFlowStepCard extends StatefulWidget {
  final DayxFlowUi ui;
  final bool busy;

  /// When true, text steps use the overlay composer instead of an inline field.
  final bool hideInlineInput;
  final VoidCallback? onCancel;
  final void Function(DayxFlowOption option) onSelect;
  final void Function(String field, String value) onSubmit;

  const DayxFlowStepCard({
    super.key,
    required this.ui,
    this.busy = false,
    this.hideInlineInput = false,
    this.onCancel,
    required this.onSelect,
    required this.onSubmit,
  });

  @override
  State<DayxFlowStepCard> createState() => _DayxFlowStepCardState();
}

class _DayxFlowStepCardState extends State<DayxFlowStepCard> {
  final _fieldCtrl = TextEditingController();

  @override
  void didUpdateWidget(covariant DayxFlowStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStep = oldWidget.ui.step;
    final newStep = widget.ui.step;
    final oldField = oldWidget.ui.input?.field;
    final newField = widget.ui.input?.field;
    if (oldStep != newStep || oldField != newField) {
      _fieldCtrl.clear();
    }
  }

  @override
  void dispose() {
    _fieldCtrl.dispose();
    super.dispose();
  }

  DayxFlowOption? _primaryActionOption(List<DayxFlowOption> options) {
    for (final id in ['confirm', 'top_up']) {
      for (final o in options) {
        if (o.id == id) return o;
      }
    }
    return null;
  }

  /// Chips only — confirm/top_up/cancel use PrimaryButton and footer TextButton.
  List<DayxFlowOption> _wrapOptions(List<DayxFlowOption> options) {
    return options
        .where((o) => o.id != 'confirm' && o.id != 'cancel' && o.id != 'top_up')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ui = widget.ui;
    final compact = widget.hideInlineInput;
    final showTitle = ui.title != null && ui.title!.isNotEmpty &&
        (!compact || ui.review.isNotEmpty);
    final primaryAction = _primaryActionOption(ui.options);
    final wrapOptions = _wrapOptions(ui.options);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (ui.rateLine != null && ui.rateLine!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              ui.rateLine!,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary400,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (!compact && ui.hint != null && ui.hint!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              ui.hint!,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (ui.panel == 'deposit' && ui.deposit != null) ...[
          DayxFlowDepositPanel(panel: ui.deposit!),
          const SizedBox(height: 12),
        ],
        if (showTitle) ...[
          Text(
            ui.title!,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        if (ui.review.isNotEmpty) ...[
          ...ui.review.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      line.label,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      line.value,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (ui.input != null && !widget.hideInlineInput) ...[
          _buildInput(context, ui.input!),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: PrimaryButton(
                  borderRadius: 38,
                  text: ui.input!.isAmount ? 'Continue' : 'Next',
                  onPressed:
                      widget.busy
                          ? null
                          : () {
                            final v = _fieldCtrl.text.trim();
                            if (v.isEmpty) return;
                            widget.onSubmit(ui.input!.field, v);
                          },
                  enabled: !widget.busy,
                  isLoading: widget.busy,
                  backgroundColor: AppColors.purple500ForTheme(context),
                  height: 48,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  letterSpacing: -.70,
                  fontSize: 18,
                  fullWidth: true,
                ),
              ),
            ),
          ),
        ],
        if (primaryAction != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PrimaryButton(
                  borderRadius: 38,
                  text: primaryAction.label,
                  onPressed:
                      widget.busy ? null : () => widget.onSelect(primaryAction),
                  enabled: !widget.busy,
                  isLoading: widget.busy,
                  backgroundColor: AppColors.purple500ForTheme(context),
                  height: 48,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  letterSpacing: -.70,
                  fontSize: 18,
                  fullWidth: true,
                ),
              ),
            ),
          ),
        ],
        if (wrapOptions.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 215),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: -2,
                children: [
                  for (final opt in wrapOptions)
                    ActionChip(
                      label: Text(
                        opt.label,
                        style: const TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed:
                          widget.busy ? null : () => widget.onSelect(opt),
                    ),
                ],
              ),
            ),
          ),
        if (widget.onCancel != null) ...[
          // const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: widget.busy ? null : widget.onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(
                  // fontFamily: 'Chirp',
                  fontSize: 16,
                  fontFamily: AppTypography.secondaryFontFamily,
                  fontWeight: AppTypography.bold,
                  height: 1,
                  letterSpacing: -.4,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInput(BuildContext context, DayxFlowInput input) {
    final isPin = input.isPin;
    final keyboard =
        isPin || input.keyboard == 'number' && !input.isAmount
            ? TextInputType.number
            : input.isAmount
            ? const TextInputType.numberWithOptions(decimal: true)
            : input.keyboard == 'phone'
            ? TextInputType.phone
            : TextInputType.text;

    final isTagField =
        input.field == 'dayfiId' ||
        input.label.toLowerCase().contains('tag') ||
        input.label.toLowerCase().contains('username');

    return CustomTextField(
      controller: _fieldCtrl,
      label: input.label,
      hintText: input.placeholder ?? input.label,
      keyboardType: keyboard,
      obscureText: isPin,
      maxLength: isPin ? 4 : null,
      formatter:
          isPin
              ? FilteringTextInputFormatter.digitsOnly
              : isTagField
              ? FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.-]'))
              : null,
      textInputAction: TextInputAction.done,
      capitalizeFirstLetter: false,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      isDayfiId: isTagField,
      minLines: input.isMultiline ? 2 : 1,
      maxLines: input.isMultiline ? 4 : 1,
      onFieldSubmitted: (_) {
        final v = _fieldCtrl.text.trim();
        if (v.isNotEmpty && !widget.busy) {
          widget.onSubmit(input.field, v);
        }
      },
    );
  }
}
