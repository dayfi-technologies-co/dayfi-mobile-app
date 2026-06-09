import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:dayfi/features/invest/models/invest_lock_draft.dart';
import 'package:dayfi/features/invest/widgets/invest_lock_step_scaffold.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class InvestLockPreviewView extends ConsumerStatefulWidget {
  final InvestLockDraft draft;
  final InvestmentSummary? summary;
  final VoidCallback? onSuccess;
  final bool showBackButton;

  const InvestLockPreviewView({
    super.key,
    required this.draft,
    this.summary,
    this.onSuccess,
    this.showBackButton = true,
  });

  @override
  ConsumerState<InvestLockPreviewView> createState() =>
      _InvestLockPreviewViewState();
}

class _InvestLockPreviewViewState extends ConsumerState<InvestLockPreviewView> {
  InvestmentQuote? _quote;
  bool _loadingQuote = true;
  bool _authorize = false;
  bool _acknowledge = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final amount = widget.draft.amount;
    if (amount == null) return;
    try {
      final quote = await investmentService.fetchQuote(
        amount: amount,
        lockDays: widget.draft.plan.lockDays,
      );
      if (!mounted) return;
      setState(() {
        _quote = quote;
        widget.draft.quote = quote;
        _loadingQuote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingQuote = false);
      TopSnackbar.show(context, message: '$e', isError: true);
    }
  }

  String _formatMaturity(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('EEEE, d MMM yyyy').format(date.toLocal());
  }

  Future<void> _confirmLock() async {
    final amount = widget.draft.amount;
    final name = widget.draft.name;
    final quote = _quote;
    if (amount == null || name == null || quote == null) return;

    setState(() => _submitting = true);
    final ok = await TransactionPinFlow.requestPinAndRun<bool>(
      context: context,
      ref: ref,
      returnRoute: AppRoute.investView,
      task: (pin) async {
        await investmentService.deposit(
          amount: amount,
          lockDays: widget.draft.plan.lockDays,
          name: name,
          pin: pin,
        );
        FeatureActivityService.instance.invalidate();
        return true;
      },
    );
    if (mounted) setState(() => _submitting = false);
    if (ok != true || !mounted) return;

    widget.onSuccess?.call();
    await TransactionCompletionFlow.pushSuccess(
      context,
      screen: TransactionCompletionFlow.investLockSuccess(
        amount: amount,
        lockDays: widget.draft.plan.lockDays,
        apyPercent: quote.apyPercent,
        lockName: name,
      ),
    );
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _consentRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary400,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final amount = draft.amount ?? 0;
    final quote = _quote;
    final maturesAt = quote?.maturesAt;
    final canSubmit = _authorize &&
        _acknowledge &&
        quote != null &&
        !_loadingQuote &&
        !_submitting;

    return InvestLockStepScaffold(
      showBackButton: widget.showBackButton,
      step: 3,
      totalSteps: 4,
      title: 'Preview lock',
      subtitle: draft.name ?? '',
      bottomBar: InvestLockStepScaffold.primaryButton(
        context,
        text: InvestCopy.confirmCta,
        enabled: canSubmit,
        isLoading: _submitting,
        onPressed: _confirmLock,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingQuote)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            )
          else if (quote != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  _summaryRow('Lock name', draft.name ?? '—'),
                  _summaryRow(
                    'Amount to lock',
                    '\$${amount.toStringAsFixed(2)}',
                  ),
                  _summaryRow(
                    'Interest (APY)',
                    '${quote.apyPercent.toStringAsFixed(2)}%',
                  ),
                  _summaryRow(
                    'Est. interest',
                    '\$${quote.estimatedInterest.toStringAsFixed(2)}',
                  ),
                  _summaryRow(
                    'Total at maturity',
                    '\$${quote.estimatedPayout.toStringAsFixed(2)}',
                  ),
                  _summaryRow('Lock period', draft.plan.label),
                  _summaryRow(
                    'Maturity date',
                    _formatMaturity(maturesAt),
                  ),
                  _summaryRow('Funding source', 'USD wallet'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _consentRow(
              value: _authorize,
              onChanged: (v) => setState(() => _authorize = v == true),
              text:
                  'I authorize Dayfi to lock \$${amount.toStringAsFixed(2)} immediately and return it in full on ${_formatMaturity(maturesAt)} to my USD wallet. I confirm and approve this transaction.',
            ),
            _consentRow(
              value: _acknowledge,
              onChanged: (v) => setState(() => _acknowledge = v == true),
              text:
                  'I understand this lock cannot be broken until the end of the maturity period I have set.',
            ),
          ],
        ],
      ),
    );
  }
}
