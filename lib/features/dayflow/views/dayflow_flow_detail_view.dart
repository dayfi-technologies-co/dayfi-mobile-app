import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';

class DayFlowFlowDetailView extends StatelessWidget {
  final DayFlowEnvelope flow;
  final Future<void> Function()? onStopFlow;

  const DayFlowFlowDetailView({
    super.key,
    required this.flow,
    this.onStopFlow,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(title: flow.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
        children: [
          _sectionCard(
            context,
            title: 'Flow summary',
            children: [
              _row(
                context,
                'Total budget',
                formatDayFlowAmount(flow.totalAmount, flow.currency),
              ),
              _row(
                context,
                'Held amount',
                formatDayFlowAmount(flow.heldAmount, flow.currency),
              ),
              _row(
                context,
                'Spent amount',
                formatDayFlowAmount(flow.spentAmount, flow.currency),
              ),
              _row(
                context,
                'Remaining',
                formatDayFlowAmount(flow.remainingAmount, flow.currency),
              ),
              _row(context, 'Type', flow.flowType.toUpperCase()),
              _row(context, 'Status', flow.status.toUpperCase()),
              if (flow.periodLabel != null && flow.periodLabel!.isNotEmpty)
                _row(context, 'Period', flow.periodLabel!),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            context,
            title: 'Budget categories',
            children: [
              if (flow.categories.isEmpty)
                Text(
                  'No categories yet.',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    color: onSurface.withValues(alpha: 0.58),
                  ),
                )
              else
                ...flow.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _row(
                      context,
                      c.name,
                      '${formatDayFlowAmount(c.allocated, flow.currency)}${c.locked ? ' · locked' : ''}',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            context,
            title: 'Schedules / autopay',
            children: [
              if (flow.schedules.isEmpty)
                Text(
                  'No schedules yet. Add bill or recipient info in the flow chat to enable autopay setup.',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    height: 1.35,
                    color: onSurface.withValues(alpha: 0.58),
                  ),
                )
              else
                ...flow.schedules.map(
                  (s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _row(
                          context,
                          'Amount',
                          formatDayFlowAmount(s.amount, flow.currency),
                        ),
                        _row(
                          context,
                          'Autopay',
                          s.autoPay ? 'Enabled' : 'Not enabled',
                        ),
                        _row(context, 'Frequency', s.frequency),
                        if (s.dueLabel != null && s.dueLabel!.isNotEmpty)
                          _row(context, 'Date', s.dueLabel!),
                        if (s.recipientHint != null &&
                            s.recipientHint!.isNotEmpty)
                          _row(context, 'Recipient / bill', s.recipientHint!),
                        if (s.paymentType.isNotEmpty)
                          _row(context, 'Type', s.paymentType),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (onStopFlow != null && flow.isActive) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onStopFlow!(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error.withValues(
                          alpha: 0.45,
                        ),
                  ),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  DayFlowCopy.cancelFlow,
                  style: const TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String key, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(
          child: Text(
            key,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              color: onSurface.withValues(alpha: 0.62),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
