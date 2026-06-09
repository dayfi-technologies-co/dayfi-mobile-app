import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Avatar + corner badge (Dayfi logo for usernames, flag otherwise).
class RecipientAvatarBadge extends StatelessWidget {
  final BeneficiaryWithSource entry;
  final String Function(String countryCode) flagPathForCountry;
  final double size;
  final double badgeSize;

  const RecipientAvatarBadge({
    super.key,
    required this.entry,
    required this.flagPathForCountry,
    this.size = 40,
    this.badgeSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final initial = _initial(entry);
    final isDayfi = RecipientHistoryHelper.isDayfiRecipient(entry);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/account.svg',
              width: size,
              height: size,
              color: AppColors.peopleTab500,
            ),
            SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.neutral0,
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral200, width: 1),
          ),
          child: ClipOval(
            child: isDayfi
                ? Image.asset(
                    RecipientHistoryHelper.dayfiLogoAsset,
                    fit: BoxFit.cover,
                    width: badgeSize,
                    height: badgeSize,
                  )
                : SvgPicture.asset(
                    flagPathForCountry(
                      RecipientHistoryHelper.flagCountryForRecipient(entry),
                    ),
                    fit: BoxFit.cover,
                    width: badgeSize,
                    height: badgeSize,
                  ),
          ),
        ),
      ],
    );
  }

  String _initial(BeneficiaryWithSource entry) {
    final label = RecipientHistoryHelper.primaryLabel(
      entry.beneficiary,
      entry.source,
    );
    final clean = label.replaceAll('@', '').trim();
    if (clean.isEmpty) return '?';
    return clean[0].toUpperCase();
  }
}
