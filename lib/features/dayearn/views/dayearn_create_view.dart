import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create DayEarn pot — name, amount, live preview, PIN, snackbar confirmation.
class DayEarnCreateView extends ConsumerStatefulWidget {
  const DayEarnCreateView({super.key});

  @override
  ConsumerState<DayEarnCreateView> createState() => _DayEarnCreateViewState();
}

class _DayEarnCreateViewState extends ConsumerState<DayEarnCreateView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  static const _currency = kDayEarnCurrency;
  double? _usdBalance;
  bool _submitting = false;

  DayEarnInterestPreview get _interestPreview {
    final parsed = double.tryParse(_amountController.text.trim());
    final amount = parsed == null || parsed < 0 ? 0.0 : parsed;
    return DayEarnInterestPreview.compute(amount: amount, currency: _currency);
  }

  @override
  void initState() {
    super.initState();
    _loadBalances();
    _nameController.addListener(_onFieldsChanged);
    _amountController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    try {
      final hub = await walletService.fetchWalletHub();
      if (mounted) {
        setState(() => _usdBalance = hub.totalAvailableBalance.amount);
      }
    } catch (_) {}
  }

  bool get _canContinue {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) return false;
    final bal = _usdBalance;
    if (bal != null && amount > bal) return false;
    return true;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      TopSnackbar.show(
        context,
        message: 'Enter a name and amount',
        isError: true,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final result =
          await TransactionPinFlow.requestPinAndRun<Map<String, dynamic>?>(
            context: context,
            ref: ref,
            returnRoute: AppRoute.dayEarnCreateView,
            task: (pin) => dayEarnService.createPot(
              name: name,
              amount: amount,
              currency: _currency,
              pin: pin,
            ),
          );

      if (!mounted || result == null) return;

      DayEarnFlow.completeWithSnackbar(
        context: context,
        ref: ref,
        message: DayEarnCopy.potCreated(name),
        afterPotCreated: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final preview = _interestPreview;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(title: DayEarnCopy.featureName),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DayfiScreenDescription(text: DayEarnCopy.createDescription),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: CustomTextField(
                  label: 'Name',
                  hintText: 'Emergency Fund',
                  controller: _nameController,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: CustomTextField(
                  label: 'Amount',
                  hintText: '0.00',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  formatter: FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9.]'),
                  ),
                ),
              ),
              if (_usdBalance != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Available: ${formatDayEarnAmount(_usdBalance!, _currency)}',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12.5,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Estimated Returns',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _PreviewRow(
                label: 'Daily',
                value: formatDayEarnInterestAmount(
                  preview.daily,
                  preview.currency,
                ),
              ),
              _PreviewRow(
                label: 'Monthly',
                value: formatDayEarnAmount(preview.monthly, preview.currency),
              ),
              _PreviewRow(
                label: 'Yearly',
                value: formatDayEarnAmount(preview.yearly, preview.currency),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning600.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning600.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  DayEarnCopy.accrualNote,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    height: 1.45,
                    color: onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: PrimaryButton(
                  text: 'Next',
                  onPressed: _canContinue && !_submitting ? _submit : null,
                  isLoading: _submitting,
                  fullWidth: true,
                  height: 48,
                  borderRadius: 40,
                  backgroundColor: AppColors.purple500ForTheme(context),
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'Chirp', fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
