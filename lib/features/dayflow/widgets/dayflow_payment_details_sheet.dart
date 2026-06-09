import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:flutter/material.dart';

/// Collects missing recipient / bill details before a budget is approved.
class DayFlowPaymentDetailsSheet extends StatefulWidget {
  final DayFlowAutopayDraftItem item;

  const DayFlowPaymentDetailsSheet({super.key, required this.item});

  static Future<String?> show(
    BuildContext context, {
    required DayFlowAutopayDraftItem item,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DayFlowPaymentDetailsSheet(item: item),
      ),
    );
  }

  @override
  State<DayFlowPaymentDetailsSheet> createState() =>
      _DayFlowPaymentDetailsSheetState();
}

class _DayFlowPaymentDetailsSheetState extends State<DayFlowPaymentDetailsSheet> {
  static const _recipientsCacheKey = 'recipients_v5';

  final _hintController = TextEditingController();
  List<BeneficiaryWithSource> _recipients = [];
  bool _loadingRecipients = true;

  @override
  void initState() {
    super.initState();
    _hintController.text = widget.item.recipientHint ?? '';
    _hydrateFromCache();
    _loadRecipients();
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  List<BeneficiaryWithSource> _filterRecipients(
    List<BeneficiaryWithSource> list,
  ) {
    return list
        .where(
          (e) =>
              !RecipientHistoryHelper.isDayflowRecipient(e) &&
              !RecipientHistoryHelper.isDayEarnRecipient(e),
        )
        .toList();
  }

  void _hydrateFromCache() {
    final cached = locator<LocalCache>().getFromLocalCache(_recipientsCacheKey);
    if (cached == null) return;
    try {
      final List<dynamic> raw =
          cached is String
              ? beneficiariesFromJson(cached)
              : (cached as List<dynamic>);
      final fromCache =
          raw
              .map((e) => BeneficiaryWithSource.fromJson(e))
              .where(RecipientHistoryHelper.isSendRecipient)
              .toList();
      final filtered = _filterRecipients(fromCache);
      if (filtered.isEmpty) return;
      _recipients = filtered;
      _loadingRecipients = false;
    } catch (_) {}
  }

  Future<void> _loadRecipients() async {
    try {
      final saved = await walletService.fetchSavedBeneficiaries();
      if (!mounted) return;
      setState(() {
        _recipients = _filterRecipients(
          RecipientHistoryHelper.mergeRecipients(_recipients, saved),
        );
        _loadingRecipients = false;
      });

      // Recent send history only (first page) — avoids scanning every transaction page.
      final txPage = await walletService.getWalletTransactions(limit: 50);
      final fromHistory = <BeneficiaryWithSource>[];
      for (final tx in txPage.data.transactions) {
        final parsed = RecipientHistoryHelper.fromTransaction(tx);
        if (parsed != null) fromHistory.add(parsed);
      }
      if (!mounted) return;
      setState(() {
        _recipients = _filterRecipients(
          RecipientHistoryHelper.mergeRecipients(_recipients, fromHistory),
        );
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRecipients = false);
    }
  }

  String _recipientLine(BeneficiaryWithSource entry) {
    final label = RecipientHistoryHelper.primaryLabel(
      entry.beneficiary,
      entry.source,
    );
    final tag = entry.source.accountNumber?.trim();
    if (tag != null && tag.startsWith('@')) return '$label · $tag';
    final acct = entry.source.accountNumber ?? entry.beneficiary.accountNumber;
    if (acct != null && acct.isNotEmpty) return '$label · $acct';
    return label;
  }

  String _hintFromRecipient(BeneficiaryWithSource entry) {
    final tag = entry.source.accountNumber?.trim();
    if (tag != null && tag.startsWith('@')) return tag;
    final acct = entry.source.accountNumber ?? entry.beneficiary.accountNumber;
    final name = RecipientHistoryHelper.primaryLabel(
      entry.beneficiary,
      entry.source,
    );
    if (acct != null && acct.isNotEmpty) {
      return '$name · $acct';
    }
    return name;
  }

  void _save(String hint) {
    final trimmed = hint.trim();
    if (trimmed.isEmpty) return;
    Navigator.pop(context, trimmed);
  }

  Future<void> _createRecipient() async {
    await Navigator.pushNamed(
      context,
      AppRoute.selectDestinationCountryView,
      arguments: <String, dynamic>{
        'hasBackButton': true,
        'addRecipientOnly': true,
      },
    );
    await _loadRecipients();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final item = widget.item;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: const TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatDayFlowAmount(item.amount, kDayFlowWalletCurrency),
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dayflowDetailHintLabel(item.paymentType),
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 10),
            if (_loadingRecipients && _recipients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: DayfiLoadingIndicator()),
              )
            else if (_recipients.isNotEmpty) ...[
              Text(
                DayFlowCopy.savedRecipients,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _recipients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final entry = _recipients[index];
                    return Material(
                      color: onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _save(_hintFromRecipient(entry)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            _recipientLine(entry),
                            style: const TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: _createRecipient,
              child: Text(
                DayFlowCopy.createRecipientOnSpot,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  color: AppColors.primary400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _hintController,
              label: 'Or enter details',
              hintText: dayflowDetailHintPlaceholder(
                item.paymentType,
                item.title,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: DayFlowCopy.savePaymentDetails,
              onPressed: () => _save(_hintController.text),
              fullWidth: true,
              height: 48,
              borderRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}
