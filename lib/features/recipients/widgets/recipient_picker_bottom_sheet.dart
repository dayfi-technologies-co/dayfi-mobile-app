import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/helpers/recipients_list_cache.dart';
import 'package:dayfi/features/recipients/widgets/recipient_avatar_badge.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<BeneficiaryWithSource?> showRecipientPickerBottomSheet(
  BuildContext context,
) {
  return showAppBottomSheet<BeneficiaryWithSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const RecipientPickerBottomSheet(),
  );
}

class RecipientPickerBottomSheet extends StatefulWidget {
  const RecipientPickerBottomSheet({super.key});

  @override
  State<RecipientPickerBottomSheet> createState() =>
      _RecipientPickerBottomSheetState();
}

class _RecipientPickerBottomSheetState extends State<RecipientPickerBottomSheet> {
  List<BeneficiaryWithSource> _recipients = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadRecipients(silent: _recipients.isNotEmpty);
  }

  List<BeneficiaryWithSource> _filterRecipients(
    List<BeneficiaryWithSource> list,
  ) {
    return list
        .where(
          (e) =>
              RecipientHistoryHelper.isSendRecipient(e) &&
              !RecipientHistoryHelper.isDayflowRecipient(e) &&
              !RecipientHistoryHelper.isDayEarnRecipient(e),
        )
        .toList();
  }

  void _hydrateFromCache() {
    final fromCache = RecipientsListCache.read();
    if (fromCache == null) return;
    final filtered = _filterRecipients(fromCache);
    if (filtered.isEmpty) return;
    _recipients = filtered;
    _loading = false;
  }

  Future<void> _loadRecipients({bool silent = false}) async {
    if (!silent && _recipients.isEmpty && mounted) {
      setState(() => _loading = true);
    }
    try {
      final results = await Future.wait([
        locator<WalletService>().getUniqueBeneficiariesWithSource(),
        walletService.fetchSavedBeneficiaries(),
      ]);
      if (!mounted) return;
      final merged = _filterRecipients(
        RecipientHistoryHelper.mergeRecipients(results[0], results[1]),
      );
      await RecipientsListCache.write(merged);
      setState(() {
        _recipients = merged;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sheetHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const _PickerSheetHeader(title: 'Select recipient'),
          const SizedBox(height: 12),
          Expanded(
            child:
                _loading && _recipients.isEmpty
                    ? const Center(child: DayfiLoadingIndicator())
                    : _recipients.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Add a recipient first from Send or Recipients',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            color: onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      itemCount: _recipients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final entry = _recipients[i];
                        final name = StringUtils.toTitleCase(
                          RecipientHistoryHelper.primaryLabel(
                            entry.beneficiary,
                            entry.source,
                          ),
                        );
                        final channel =
                            RecipientHistoryHelper.recipientChannelLabel(entry);
                        return Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, entry),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  RecipientAvatarBadge(
                                    entry: entry,
                                    flagPathForCountry: _flagPathForCountry,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Chirp',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: onSurface,
                                          ),
                                        ),
                                        if (channel.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            channel,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Chirp',
                                              fontSize: 13,
                                              color: onSurface.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
  }
}

class _PickerSheetHeader extends StatelessWidget {
  final String title;

  const _PickerSheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          _PickerSheetCloseButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _PickerSheetCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PickerSheetCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onPressed();
        FocusScope.of(context).unfocus();
      },
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _flagPathForCountry(String? countryCode) {
  switch (countryCode?.toUpperCase()) {
    case 'NG':
      return 'assets/icons/svgs/world_flags/nigeria.svg';
    case 'GH':
      return 'assets/icons/svgs/world_flags/ghana.svg';
    case 'KE':
      return 'assets/icons/svgs/world_flags/kenya.svg';
    case 'UG':
      return 'assets/icons/svgs/world_flags/uganda.svg';
    case 'TZ':
      return 'assets/icons/svgs/world_flags/tanzania.svg';
    case 'RW':
      return 'assets/icons/svgs/world_flags/rwanda.svg';
    case 'ZA':
      return 'assets/icons/svgs/world_flags/south africa.svg';
    case 'US':
      return 'assets/icons/svgs/world_flags/united states.svg';
    case 'GB':
    case 'UK':
      return 'assets/icons/svgs/world_flags/united kingdom.svg';
    case 'EU':
      return 'assets/icons/svgs/world_flags/european-union.svg';
    default:
      return 'assets/icons/svgs/world_flags/nigeria.svg';
  }
}
