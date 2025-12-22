import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_svg/svg.dart';

class DayfiTagExplanationView extends ConsumerWidget {
  const DayfiTagExplanationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 400 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 24, width: 24),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                "assets/icons/pngs/cancelicon.png",
                                height: 24,
                                width: 24,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        Stack(
                          alignment: AlignmentDirectional.center,

                          children: [
                            SvgPicture.asset(
                              'assets/icons/svgs/at.svg',
                              height:
                                  isWide
                                      ? 160
                                      : MediaQuery.of(context).size.width * 0.5,
                              width:
                                  isWide
                                      ? 160
                                      : MediaQuery.of(context).size.width * 0.5,
                              color: AppColors.warning500,
                            ),
                            // Text(
                            //   '@',
                            //   style: TextStyle(
                            //  fontFamily: 'FunnelDisplay',
                            //     fontSize: MediaQuery.of(context).size.width * 0.3,
                            //     fontWeight: FontWeight.w600,
                            //     color: AppColors.error500,
                            //   ),
                            // ),
                          ],
                        ),

                        Text(
                          "Meet your Dayfi Tag",
                          style: AppTypography.headlineLarge.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: isWide ? 32 : 28,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral0,
                            // height: 1.2,
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Your unique username for instant money transfers. Share it with friends and family - no bank details needed.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Chirp',
                            color: AppColors.neutral50,
                            letterSpacing: -.25,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // SizedBox(height: 24),
                        // Text(
                        //   "Benefits:\n• Easy to share - just your unique tag\n• Instant transfers\n• No bank details needed\n• Free to use",
                        //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w500,
                        //     fontFamily: 'Chirp',
                        //     color: AppColors.neutral50.withOpacity(0.9),
                        //     letterSpacing: -.25,
                        //     height: 1.5,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        SizedBox(height: 32),
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Create Dayfi Tag",
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoute.createDayfiTagView,
                            );
                            if (result != null && result is String) {
                              Navigator.pop(context, result);
                            }
                          },
                          backgroundColor: AppColors.neutral0,
                          height: 48.00000,
                          textColor: AppColors.purple500ForTheme(context),
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
