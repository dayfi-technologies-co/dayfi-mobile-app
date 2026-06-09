import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/dayfi_circle_check_icon.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<BillItem?> showBillPackageBottomSheet({
  required BuildContext context,
  required List<BillItem> items,
  BillItem? selected,
}) {
  final sortedItems = sortBillItemsByAmount(items);

  return showAppBottomSheet<BillItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (sheetContext) {
      final searchController = TextEditingController();
      var filtered = List<BillItem>.from(sortedItems);

      return StatefulBuilder(
        builder: (context, setModalState) {
          void filter(String query) {
            final q = query.trim().toLowerCase();
            setModalState(() {
              filtered =
                  q.isEmpty
                      ? List<BillItem>.from(sortedItems)
                      : sortBillItemsByAmount(
                        items.where((item) {
                          return item.displayLabel.toLowerCase().contains(q);
                        }).toList(),
                      );
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const SizedBox(width: 40, height: 40),
                      Expanded(
                        child: Text(
                          'Select package',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => Navigator.pop(sheetContext),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/svgs/notificationn.svg',
                              height: 40,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/pngs/cancelicon.png',
                                  height: 20,
                                  width: 20,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: CustomTextField(
                    isSearch: true,
                    controller: searchController,
                    label: '',
                    hintText: 'Search packages',
                    borderRadius: 40,
                    prefixIcon: Container(
                      width: 40,
                      alignment: Alignment.centerRight,
                      constraints: const BoxConstraints.tightForFinite(),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/svgs/search-normal.svg',
                          height: 26,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    onChanged: filter,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      filtered.isEmpty
                          ? Center(
                            child: Text(
                              'No packages found',
                              style: AppTypography.bodyMedium.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final label = item.displayLabel;
                              final isSelected = selected?.itemCode == item.itemCode;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                title: Text(
                                  label,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontFamily: 'Chirp',
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle:
                                    item.amount > 0
                                        ? Text(
                                          formatBillNgnAmount(item.amount),
                                          style: TextStyle(
                                            fontFamily: 'Chirp',
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.55),
                                          ),
                                        )
                                        : null,
                                trailing:
                                    isSelected
                                        ? DayfiCircleCheckIcon(
                                          color: AppColors.purple500ForTheme(
                                            context,
                                          ),
                                        )
                                        : null,
                                onTap: () => Navigator.pop(sheetContext, item),
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
