import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PayBillsInternationalView extends StatelessWidget {
  const PayBillsInternationalView({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return DayfiFeatureScaffold(
      title: payViaTitle('International bills'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/router.svg',
              height: 64,
              colorFilter: ColorFilter.mode(
                AppColors.primary400.withValues(alpha: 0.8),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            DayfiScreenDescription(
              text: kPayBillsInternationalDescription,
            ),
          ],
        ),
      ),
    );
  }
}
