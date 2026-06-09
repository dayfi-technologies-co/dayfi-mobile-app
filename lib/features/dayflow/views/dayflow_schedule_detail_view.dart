import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_instance_display.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_instances.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_setup_launcher.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DayFlowScheduleDetailView extends StatelessWidget {
  final DayBudgetScheduleInstance item;
  final VoidCallback? onUpdated;

  const DayFlowScheduleDetailView({
    super.key,
    required this.item,
    this.onUpdated,
  });

  static Future<void> open(
    BuildContext context, {
    required DayBudgetScheduleInstance item,
    VoidCallback? onUpdated,
  }) {
    return Navigator.push<void>(
      context,
      DayfiPageRoute<void>(
        builder:
            (_) => DayFlowScheduleDetailView(
              item: item,
              onUpdated: onUpdated,
            ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    if (item.needsSetup) {
      await DayFlowScheduleSetupLauncher.open(
        context,
        item,
        onUpdated: onUpdated,
      );
      return;
    }

    final seed =
        'Update "${item.title}" — currently '
        '${formatDayFlowAmount(item.amount, kDayFlowWalletCurrency)}';
    final updated = await DayBudgetFlow.openEditChat(
      context,
      initialPrompt: seed,
      onActivated: onUpdated,
    );
    if (updated && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _stopAutomation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(DayFlowCopy.cancelFlow),
            content: Text(DayFlowCopy.cancelFlowConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(DayFlowCopy.cancelFlow),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await dayFlowApiService.cancelFlow(item.flowId);
      onUpdated?.call();
      if (!context.mounted) return;
      TopSnackbar.showSafe(
        context,
        message: DayFlowCopy.flowCancelled,
        isError: false,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      TopSnackbar.showSafe(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final amount = formatDayFlowAmount(item.amount, kDayFlowWalletCurrency);
    final statusLabel = instanceStatusLabel(
      item.status,
      needsSetup: item.needsSetup,
    );
    final statusColor = instanceStatusColor(
      item.status,
      needsSetup: item.needsSetup,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DayFlowCopy.scheduleDetailsTitle,
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: DayFlowCopy.editPayment,
                onPressed: () => _edit(context),
                fullWidth: true,
                height: 52,
                borderRadius: 40,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _stopAutomation(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    DayFlowCopy.cancelFlow,
                    style: const TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svgs/account.svg',
                        height: 56,
                        color: instanceTypeColor(item.paymentType),
                      ),
                      SvgPicture.asset(
                        instanceTypeIcon(item.paymentType),
                        height: 22,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _DetailCard(
                  rows: [
                    _DetailRow(
                      label: 'Due date',
                      value: formatInstanceDueDate(item.dueAt),
                    ),
                    if (item.dueLabel != null && item.dueLabel!.trim().isNotEmpty)
                      _DetailRow(label: 'Frequency', value: item.dueLabel!.trim()),
                    _DetailRow(
                      label: 'Auto-send',
                      value: item.autoPay ? 'On' : 'Off',
                    ),
                    if (item.flowTitle != null && item.flowTitle!.trim().isNotEmpty)
                      _DetailRow(label: 'Budget', value: item.flowTitle!.trim()),
                    _DetailRow(
                      label: 'Type',
                      value: _paymentTypeLabel(item.paymentType),
                    ),
                  ],
                ),
                if (item.recipientHint != null &&
                    item.recipientHint!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailCard(
                    title: 'Recipient / biller',
                    rows: [
                      _DetailRow(
                        label: 'Details',
                        value: item.recipientHint!.trim(),
                        emphasize: true,
                      ),
                      if (item.recipientId != null &&
                          item.recipientId!.trim().isNotEmpty)
                        _DetailRow(
                          label: 'Recipient ID',
                          value: item.recipientId!.trim(),
                        ),
                    ],
                  ),
                ] else if (item.needsSetup) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.orange500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.orange500.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      DayFlowCopy.addDetailsBeforeApprove,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.orange500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _paymentTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'bill':
        return 'Bill payment';
      case 'savings':
        return 'Savings';
      default:
        return 'Send';
    }
  }
}

class _DetailRow {
  final String label;
  final String value;
  final bool emphasize;

  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });
}

class _DetailCard extends StatelessWidget {
  final String? title;
  final List<_DetailRow> rows;

  const _DetailCard({this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    rows[i].label,
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 13,
                      color: onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: TextStyle(
                      fontFamily: rows[i].emphasize ? 'Chirp' : 'Karla',
                      fontSize: rows[i].emphasize ? 15 : 14,
                      fontWeight:
                          rows[i].emphasize ? FontWeight.w600 : FontWeight.w500,
                      color:
                          rows[i].emphasize
                              ? AppColors.teal500
                              : onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
