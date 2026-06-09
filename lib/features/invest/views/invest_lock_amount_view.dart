import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:dayfi/features/invest/models/invest_lock_draft.dart';
import 'package:dayfi/features/invest/views/invest_lock_name_view.dart';
import 'package:dayfi/features/invest/widgets/invest_lock_step_scaffold.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvestLockAmountView extends StatefulWidget {
  final InvestLockDraft draft;
  final InvestmentSummary? summary;
  final VoidCallback? onSuccess;
  final bool showBackButton;

  const InvestLockAmountView({
    super.key,
    required this.draft,
    this.summary,
    this.onSuccess,
    this.showBackButton = true,
  });

  @override
  State<InvestLockAmountView> createState() => _InvestLockAmountViewState();
}

class _InvestLockAmountViewState extends State<InvestLockAmountView> {
  final _amountCtrl = TextEditingController();
  double? _usdBalance;
  bool _loadingBalance = true;

  @override
  void initState() {
    super.initState();
    if (widget.draft.amount != null) {
      _amountCtrl.text = widget.draft.amount!.toStringAsFixed(0);
    }
    _loadBalance();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    try {
      final hub = await walletService.fetchWalletHub();
      if (!mounted) return;
      setState(() {
        _usdBalance = hub.rowFor('USD')?.balance ?? 0;
        _loadingBalance = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingBalance = false);
    }
  }

  bool get _canContinue {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 1) return false;
    if (_usdBalance != null && amount > _usdBalance!) return false;
    return true;
  }

  void _continue() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 1) {
      TopSnackbar.show(
        context,
        message: 'Enter at least \$1',
        isError: true,
      );
      return;
    }
    if (_usdBalance != null && amount > _usdBalance!) {
      TopSnackbar.show(
        context,
        message: 'Insufficient USD wallet balance',
        isError: true,
      );
      return;
    }

    widget.draft.amount = amount;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvestLockNameView(
          draft: widget.draft,
          summary: widget.summary,
          onSuccess: widget.onSuccess,
          showBackButton: widget.showBackButton,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.draft.plan;

    return InvestLockStepScaffold(
      showBackButton: widget.showBackButton,
      step: 1,
      totalSteps: 4,
      title: 'Amount to lock away',
      subtitle:
          'Locking for ${plan.label} at ${plan.apyPercent.toStringAsFixed(1)}% APY. Funds come from your USD wallet.',
      bottomBar: InvestLockStepScaffold.primaryButton(
        context,
        text: 'Continue',
        enabled: _canContinue,
        onPressed: _continue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _amountCtrl,
            label: 'Amount',
            hintText: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '\$',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            formatter: FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (_loadingBalance)
            Text(
              'Loading wallet balance…',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            )
          else if (_usdBalance != null)
            Text(
              'Available: \$${_usdBalance!.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Minimum \$1 · ${InvestCopy.featureName}',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
