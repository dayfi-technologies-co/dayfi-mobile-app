import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_checkbox.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/transaction_success_view.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class DayEarnWithdrawView extends ConsumerStatefulWidget {
  final String potId;
  final DayEarnPot pot;

  const DayEarnWithdrawView({super.key, required this.potId, required this.pot});

  @override
  ConsumerState<DayEarnWithdrawView> createState() => _DayEarnWithdrawViewState();
}

class _DayEarnWithdrawViewState extends ConsumerState<DayEarnWithdrawView> {
  final _amountController = TextEditingController();
  bool _withdrawAll = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_withdrawAll) return widget.pot.balance > 0;
    final amount = double.tryParse(_amountController.text.trim());
    return amount != null && amount > 0 && amount <= widget.pot.balance;
  }

  Future<void> _submit() async {
    final amount = _withdrawAll
        ? widget.pot.balance
        : double.tryParse(_amountController.text.trim());

    final result = await TransactionPinFlow.requestPinAndRun<Map<String, dynamic>?>(
      context: context,
      ref: ref,
      task: (pin) => dayEarnService.withdraw(
        potId: widget.potId,
        pin: pin,
        amount: _withdrawAll ? null : amount,
        withdrawAll: _withdrawAll,
      ),
    );

    if (!mounted || result == null) return;

    final withdrawn = (result['withdrawn'] as num?)?.toDouble() ?? amount ?? 0;
    await TransactionCompletionFlow.pushSuccess(
      context,
      screen: TransactionSuccessView(
        headline: 'Withdrawal successful',
        title: 'Funds returned to your ${dayEarnWalletLabel()}',
        amountText: formatDayEarnAmount(withdrawn, kDayEarnCurrency),
        subtitle: 'Instant — no penalty',
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _onWithdrawAllChanged(bool value) {
    setState(() {
      _withdrawAll = value;
      if (_withdrawAll) {
        _amountController.text = widget.pot.balance.toStringAsFixed(2);
      } else {
        _amountController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(
        title: 'Withdraw',
        showBackButton: true,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DayfiScreenDescription(
                          text: DayEarnCopy.withdrawDescription,
                          bottomSpacing: 24,
                        ),
                        Text(
                          'Available: ${formatDayEarnAmount(widget.pot.balance, kDayEarnCurrency)}',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Amount',
                          hintText: '0.00',
                          controller: _amountController,
                          shouldReadOnly: _withdrawAll,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          formatter: FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        DayfiCheckboxTile(
                          value: _withdrawAll,
                          onChanged:
                              widget.pot.balance > 0
                                  ? (v) => _onWithdrawAllChanged(v)
                                  : null,
                          label: 'Withdraw all',
                          checkboxSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                child: PrimaryButton(
                  text: 'Withdraw',
                  onPressed: _canSubmit ? _submit : null,
                  fullWidth: true,
                  applyFeatureInset: false,
                  height: 48,
                  borderRadius: 38,
                  backgroundColor: AppColors.purple500ForTheme(context),
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
