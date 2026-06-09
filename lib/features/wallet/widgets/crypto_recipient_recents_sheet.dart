import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<BeneficiaryWithSource?> showCryptoRecipientRecentsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String currency,
}) async {
  await ref.read(recipientsProvider.notifier).loadBeneficiaries();

  if (!context.mounted) return null;

  return showAppBottomSheet<BeneficiaryWithSource>(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.85),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, sheetRef, _) {
          final recipientsState = sheetRef.watch(recipientsProvider);
          final entries = RecipientHistoryHelper.filterForSendContext(
            recipientsState.beneficiaries,
            deliveryMethod: 'crypto',
            currency: currency,
          );

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'Recents & beneficiaries',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/svgs/notificationn.svg',
                              height: 40,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            Image.asset(
                              'assets/icons/pngs/cancelicon.png',
                              height: 20,
                              width: 20,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Choose a recent crypto recipient to auto-fill the wallet address.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.65),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            'No recent crypto recipients for $currency yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final label = RecipientHistoryHelper.primaryLabel(
                              entry.beneficiary,
                              entry.source,
                            );
                            final subtitle = RecipientHistoryHelper.secondaryLabel(
                              entry.beneficiary,
                              entry.source,
                              ledgerCurrency: entry.ledgerCurrency,
                            );
                            return Material(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(sheetContext, entry),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/svgs/currency-dollar.svg',
                                        height: 22,
                                        color: AppColors.orange500,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              label,
                                              style: const TextStyle(
                                                fontFamily: 'Chirp',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              subtitle,
                                              style: TextStyle(
                                                fontFamily: 'Chirp',
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.55),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
