import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:flutter/material.dart';

class DayxTransferCard extends StatelessWidget {
  final DayxTransferProposal proposal;
  final bool confirming;
  final VoidCallback? onConfirm;
  final ValueChanged<DayxTransferCandidate>? onSelectCandidate;

  const DayxTransferCard({
    super.key,
    required this.proposal,
    this.confirming = false,
    this.onConfirm,
    this.onSelectCandidate,
  });

  String _amountLabel() {
    final amount = proposal.amount;
    final currency = proposal.currency ?? 'NGN';
    if (amount == null) return '';
    final sym = currencySymbol(currency);
    return '$sym${formatDayFlowAmount(amount, currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (proposal.isAmbiguous && proposal.candidates.isNotEmpty) {
      return _card(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which recipient?',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 8),
            ...proposal.candidates.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: OutlinedButton(
                  onPressed: () => onSelectCandidate?.call(c),
                  child: Text(
                    c.accountMask != null
                        ? '${c.name} ···${c.accountMask}'
                        : c.name,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!proposal.needsConfirmation) return const SizedBox.shrink();

    final mask = proposal.accountMask;
    final name = proposal.recipientName ?? 'Recipient';

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer ready',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _amountLabel(),
            style: const TextStyle(
              fontFamily: 'FunnelDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mask != null ? '$name ···$mask' : name,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              color: onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: BiometricService.getPrimaryBiometricType(),
            builder: (context, snap) {
              final bio = snap.data ?? 'Face ID';
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: confirming ? null : onConfirm,
                  child: confirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Confirm with $bio'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary400.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}
