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

class DayEarnAddView extends ConsumerStatefulWidget {
  final String potId;
  final DayEarnPot pot;

  const DayEarnAddView({super.key, required this.potId, required this.pot});

  @override
  ConsumerState<DayEarnAddView> createState() => _DayEarnAddViewState();
}

class _DayEarnAddViewState extends ConsumerState<DayEarnAddView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double? _walletBalance;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    try {
      final hub = await walletService.fetchWalletHub();
      if (mounted) {
        setState(() {
          _walletBalance = hub.totalAvailableBalance.amount;
        });
        _formKey.currentState?.validate();
      }
    } catch (_) {}
  }

  void _onAddAll() {
    if (_walletBalance == null || _walletBalance! <= 0) return;
    setState(() {
      _amountController.text = _walletBalance!.toStringAsFixed(2);
    });
    _formKey.currentState?.validate();
  }

  Widget? _buildAddAllSuffix() {
    if (_walletBalance == null || _walletBalance! <= 0) return null;

    return GestureDetector(
      onTap: _onAddAll,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Add all',
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    final result = await TransactionPinFlow.requestPinAndRun(
      context: context,
      ref: ref,
      task: (pin) => dayEarnService.deposit(
        potId: widget.potId,
        amount: amount,
        pin: pin,
      ),
    );

    if (!mounted || result == null) return;

    await DayEarnFlow.onFundsMoved(ref);
    if (!mounted) return;

    TopSnackbar.showSafe(
      context,
      message: DayEarnCopy.fundsAdded(
        widget.pot.name,
        formatDayEarnAmount(amount, kDayEarnCurrency),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: 'Add More', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DayfiScreenDescription(text: DayEarnCopy.addMoreDescription),
            if (_walletBalance != null)
              Text(
                'Available: ${formatDayEarnAmount(_walletBalance!, kDayEarnCurrency)}',
                style: const TextStyle(fontFamily: 'Chirp', fontSize: 14),
              ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: CustomTextField(
                label: 'Amount',
                hintText: '0.00',
                controller: _amountController,
                autofocus: true,
                suffixIcon: _buildAddAllSuffix(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                validator: (value) => DayEarnFormValidation.depositAmount(
                  value,
                  walletBalance: _walletBalance,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child:   PrimaryButton(
              text: 'Add to Daily Earn',
              onPressed: _submit,
              fullWidth: true,
              height: 48,
              borderRadius: 40,
              backgroundColor: AppColors.purple500ForTheme(context),
              textColor: AppColors.neutral0,
              fontFamily: 'Chirp',
            ),),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
