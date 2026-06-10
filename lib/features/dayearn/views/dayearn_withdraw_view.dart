import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_form_validation.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _withdrawAll = false;
  bool _isAgreed = false;
  String? _agreementError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Widget? _buildWithdrawAllSuffix() {
    if (widget.pot.balance <= 0) return null;

    return GestureDetector(
      onTap: () => _onWithdrawAllChanged(!_withdrawAll),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Withdraw all',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            letterSpacing: 0,
            height: 1.45,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!_isAgreed) {
      setState(() => _agreementError = DayEarnCopy.agreementRequired);
    } else {
      setState(() => _agreementError = null);
    }
    if (!formValid || !_isAgreed) return;

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
    await DayEarnFlow.onFundsMoved(ref);
    if (!mounted) return;

    TopSnackbar.showSafe(
      context,
      message: DayEarnCopy.withdrawSuccessful(
        formatDayEarnAmount(withdrawn, kDayEarnCurrency),
      ),
    );
    Navigator.pop(context, true);
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
    _formKey.currentState?.validate();
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
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                label: 'Amount',
                                hintText: '0.00',
                                controller: _amountController,
                                shouldReadOnly: _withdrawAll,
                                suffixIcon: _buildWithdrawAllSuffix(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                formatter: FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                                validator: (value) =>
                                    DayEarnFormValidation.withdrawAmount(
                                  value,
                                  potBalance: widget.pot.balance,
                                  withdrawAll: _withdrawAll,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (_withdrawAll) {
                                      final parsed =
                                          double.tryParse(value.trim());
                                      if (parsed != widget.pot.balance) {
                                        _withdrawAll = false;
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isAgreed = !_isAgreed;
                              if (_isAgreed) _agreementError = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _isAgreed,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAgreed = value ?? false;
                                        if (_isAgreed) _agreementError = null;
                                      });
                                    },
                                    activeColor: AppColors.purple500,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    DayEarnCopy.withdrawAgreement,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontFamily: 'Chirp',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.20,
                                          height: 1.4,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_agreementError != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _agreementError!,
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(64, 0, 64, 18),
                child: PrimaryButton(
                  text: 'Withdraw',
                  onPressed: _submit,
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
