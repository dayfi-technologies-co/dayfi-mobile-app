import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_category_emoji.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_chat_ui.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_payment_details_sheet.dart';
import 'package:flutter/material.dart';

class DayFlowPlanCard extends StatefulWidget {
  final DayFlowPlanDraft draft;
  final WalletHubSnapshot? hub;
  final String budgetCurrency;
  final bool canApprove;
  final bool reviewOnly;
  final bool approving;
  final VoidCallback? onApprove;
  final VoidCallback? onAddMoney;
  final VoidCallback? onSaveTemplate;
  final VoidCallback? onEdit;
  final void Function(int paymentIndex, DayFlowPaymentDraft payment)?
      onPaymentChanged;
  final ValueChanged<DayFlowPlanDraft>? onDraftResolved;

  const DayFlowPlanCard({
    super.key,
    required this.draft,
    required this.hub,
    this.budgetCurrency = kDayFlowWalletCurrency,
    required this.canApprove,
    this.reviewOnly = false,
    this.approving = false,
    this.onApprove,
    this.onAddMoney,
    this.onSaveTemplate,
    this.onEdit,
    this.onPaymentChanged,
    this.onDraftResolved,
  });

  @override
  State<DayFlowPlanCard> createState() => DayFlowPlanCardState();
}

class DayFlowPlanCardState extends State<DayFlowPlanCard> {
  late bool _sweepToDayEarn;
  late List<DayFlowPaymentDraft> _payments;
  final Map<int, String> _autopayHints = {};

  @override
  void initState() {
    super.initState();
    _sweepToDayEarn = widget.draft.sweepToDayEarn;
    _payments = List.of(widget.draft.payments);
    _syncAutopayHints();
  }

  @override
  void didUpdateWidget(covariant DayFlowPlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) {
      _sweepToDayEarn = widget.draft.sweepToDayEarn;
      _payments = List.of(widget.draft.payments);
      _syncAutopayHints();
    }
  }

  void _syncAutopayHints() {
    _autopayHints.clear();
    for (final item in collectAutopayDraftItems(widget.draft)) {
      final hint = item.recipientHint?.trim();
      if (hint != null && hint.isNotEmpty) {
        _autopayHints[item.index] = hint;
      }
    }
  }

  DayFlowPlanDraft resolveDraft(DayFlowPlanDraft base) {
    return dayflowDraftWithAutopayDetails(base, _autopayHints);
  }

  bool get _autopayComplete =>
      dayflowDraftAutopayComplete(resolveDraft(widget.draft));

  List<DayFlowAutopayDraftItem> get _autopayItems =>
      collectAutopayDraftItems(resolveDraft(widget.draft));

  bool get _insufficient => dayFlowBudgetExceedsWallet(
        hub: widget.hub,
        budgetTotal: widget.draft.totalBudget,
        budgetCurrency: widget.budgetCurrency,
      );

  Future<void> _editAutopayDetails(DayFlowAutopayDraftItem item) async {
    final hint = await DayFlowPaymentDetailsSheet.show(context, item: item);
    if (hint == null || hint.trim().isEmpty || !mounted) return;
    setState(() {
      _autopayHints[item.index] = hint.trim();
      if (!item.fromCategory && item.index < _payments.length) {
        _payments[item.index] = _payments[item.index].copyWith(
          recipientHint: hint.trim(),
          autoSend: true,
        );
        widget.onPaymentChanged?.call(item.index, _payments[item.index]);
      }
    });
    widget.onDraftResolved?.call(resolveDraft(widget.draft));
  }

  void _toggleAutoSend(int index, bool value) {
    setState(() {
      _payments[index] = _payments[index].copyWith(autoSend: value);
    });
    widget.onPaymentChanged?.call(index, _payments[index]);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          draft.title,
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardTitle(context),
        ),
        const SizedBox(height: 6),
        Text(
          '${draft.periodLabel} • ${formatDayFlowBudgetAmount(amount: draft.totalBudget, currency: widget.budgetCurrency, sourceAmount: draft.inputCurrency == 'NGN' ? _sumSourceAmounts(draft) : null, sourceCurrency: draft.inputCurrency)}',
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardHint(context),
        ),
        if (_insufficient) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(DayFlowChatUi.insetPanelRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insufficient balance',
                  style: DayFlowChatUi.emphasis(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'You need ${formatDayFlowBudgetAmount(amount: dayFlowBudgetShortfall(hub: widget.hub, budgetTotal: draft.totalBudget, budgetCurrency: widget.budgetCurrency), currency: widget.budgetCurrency)} more in your global wallet.',
                  style: DayFlowChatUi.cardHint(context),
                ),
                if (widget.onAddMoney != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onAddMoney,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Add money →',
                      style: DayFlowChatUi.emphasis(context).copyWith(
                        color: AppColors.primary400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (_autopayItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Scheduled payments',
            style: DayFlowChatUi.sectionHeader(context),
          ),
          if (!_autopayComplete && !widget.reviewOnly) ...[
            const SizedBox(height: 6),
            Text(
              DayFlowCopy.addDetailsBeforeApprove,
              style: DayFlowChatUi.cardHint(context).copyWith(
                color: AppColors.orange500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          ..._autopayItems.map((item) {
            final hint = _autopayHints[item.index]?.trim();
            final hasDetail = hint != null && hint.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: DayFlowChatUi.emphasis(context),
                        ),
                        Text(
                          '${formatDayFlowBudgetAmount(amount: item.amount, currency: widget.budgetCurrency, sourceAmount: _paymentSourceAmount(item), sourceCurrency: draft.inputCurrency)}${item.dueLabel != null ? ' • ${item.dueLabel}' : ''}',
                          style: DayFlowChatUi.cardHint(context),
                        ),
                        if (hasDetail)
                          Text(
                            hint,
                            style: DayFlowChatUi.cardHint(context).copyWith(
                              color: AppColors.teal500,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (!widget.reviewOnly)
                          TextButton(
                            onPressed: () => _editAutopayDetails(item),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              DayFlowCopy.addPaymentDetails,
                              style: DayFlowChatUi.emphasis(context).copyWith(
                                color: AppColors.orange500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!item.fromCategory && !widget.reviewOnly)
                    Column(
                      children: [
                        Text(
                          'Auto-send',
                          style: DayFlowChatUi.sectionHeader(context).copyWith(
                            fontSize: 10,
                          ),
                        ),
                        Switch.adaptive(
                          value: item.autoSend,
                          onChanged:
                              item.index < _payments.length
                                  ? (v) => _toggleAutoSend(item.index, v)
                                  : null,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
        if (draft.categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Categories',
            style: DayFlowChatUi.sectionHeader(context),
          ),
          ...draft.categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dayFlowCategoryLabel(c.name),
                      style: DayFlowChatUi.rowLabel(context),
                    ),
                  ),
                  Text(
                    formatDayFlowBudgetAmount(
                      amount: c.allocated,
                      currency: widget.budgetCurrency,
                      sourceAmount: c.sourceAmount,
                      sourceCurrency: draft.inputCurrency,
                    ),
                    style: DayFlowChatUi.rowValue(context),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (draft.leftover > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leftover → DayEarn',
                  style: DayFlowChatUi.cardHint(context),
                ),
              ),
              Switch.adaptive(
                value: _sweepToDayEarn,
                onChanged: (v) => setState(() => _sweepToDayEarn = v),
              ),
            ],
          ),
        ],
        if (widget.canApprove && draft.readyToApprove) ...[
          const SizedBox(height: 14),
          DayFlowChatUi.primaryButton(
            context,
            text:
                widget.reviewOnly
                    ? 'Confirm & schedule'
                    : DayFlowCopy.automateThisBudget,
            onPressed:
                _insufficient || !_autopayComplete ? null : widget.onApprove,
            isLoading: widget.approving,
          ),
          if (widget.onEdit != null) ...[
            const SizedBox(height: 10),
            DayFlowChatUi.secondaryButton(
              context,
              text: DayFlowCopy.editThisBudget,
              onPressed: widget.onEdit,
            ),
          ],
        ],
      ],
    );
  }

  bool get sweepToDayEarn => _sweepToDayEarn;

  List<DayFlowPaymentDraft> get payments => _payments;

  DayFlowPlanDraft resolveForApproval(DayFlowPlanDraft base) =>
      resolveDraft(base);

  double? _paymentSourceAmount(DayFlowAutopayDraftItem item) {
    if (item.fromCategory) return null;
    if (item.index < 0 || item.index >= widget.draft.payments.length) {
      return null;
    }
    return widget.draft.payments[item.index].sourceAmount;
  }

  double? _sumSourceAmounts(DayFlowPlanDraft draft) {
    var total = 0.0;
    var hasSource = false;
    for (final c in draft.categories) {
      if (c.sourceAmount != null && c.sourceAmount! > 0) {
        total += c.sourceAmount!;
        hasSource = true;
      }
    }
    for (final p in draft.payments) {
      if (p.sourceAmount != null && p.sourceAmount! > 0) {
        total += p.sourceAmount!;
        hasSource = true;
      }
    }
    return hasSource ? total : null;
  }
}
