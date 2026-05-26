import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvestView extends ConsumerStatefulWidget {
  const InvestView({super.key});

  @override
  ConsumerState<InvestView> createState() => _InvestViewState();
}

class _InvestViewState extends ConsumerState<InvestView> {
  InvestmentSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await investmentService.fetchSummary();
      if (mounted) setState(() => _summary = s);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(context, message: 'Could not load investment pocket', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _promptPin() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter PIN', style: TextStyle(fontFamily: 'Chirp')),
        content: PinTextField(
          controller: controller,
          onCompleted: (pin) => Navigator.pop(ctx, pin),
        ),
      ),
    );
  }

  Future<void> _deposit() async {
    if (_summary != null && !_summary!.riskAccepted) {
      await investmentService.acceptRisk();
    }
    final amountCtrl = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deposit to pocket'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Amount in USD'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(amountCtrl.text);
              Navigator.pop(ctx, v);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (amount == null || amount <= 0) return;
    final pin = await _promptPin();
    if (pin == null) return;
    try {
      await investmentService.deposit(amount: amount, pin: pin);
      await _load();
      if (mounted) TopSnackbar.show(context, message: 'Deposit successful');
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(context, message: '$e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: Text(
          'Invest',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Investment pocket',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${(s?.balance ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Up to ${s?.apyDisplayPercent.toStringAsFixed(0) ?? '12'}% APY · Deposits from USD wallet',
                          style: const TextStyle(fontFamily: 'Chirp', fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _deposit,
                          child: const Text('Deposit'),
                        ),
                      ),
                    ],
                  ),
                  if (s != null && !s.riskAccepted)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'First deposit accepts risk disclosure automatically.',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
