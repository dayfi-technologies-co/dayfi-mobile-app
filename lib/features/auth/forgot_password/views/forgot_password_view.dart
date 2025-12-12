import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/forgot_password/vm/forgot_password_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPasswordView extends ConsumerWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap:
                () => {
                  forgotPasswordNotifier.resetForm(),
                  Navigator.pop(context),
                  FocusScope.of(context).unfocus(),
                },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40.sp,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40.sp,
                  width: 40.sp,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20.sp,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        // size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 12, 18.0, 40.0),
          child: PrimaryButton(
                borderRadius: 38,
                text: "Receive Reset Code",
                onPressed:
                    forgotPasswordState.isFormValid &&
                            !forgotPasswordState.isBusy
                        ? () => forgotPasswordNotifier.forgotPassword(context)
                        : null,
                enabled:
                    forgotPasswordState.isFormValid &&
                    !forgotPasswordState.isBusy,
                isLoading: forgotPasswordState.isBusy,
                backgroundColor:
                    forgotPasswordState.isFormValid
                        ? AppColors.purple500ForTheme(context)
                        : AppColors.purple500ForTheme(context).withOpacity(.15),
                height: 48.00000.h,
                textColor:
                    forgotPasswordState.isFormValid
                        ? AppColors.neutral0
                        : AppColors.neutral0.withOpacity(.35),
                fontFamily: 'Karla',
                letterSpacing: -.70,
                fontSize: 18,
                width: 375.w,
                fullWidth: true,
              )
              .animate()
              .fadeIn(
                delay: 600.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              )
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 600.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
                delay: 600.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
        ),

        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),

                        Text(
                          "Reset password",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontSize: 18.sp,
                            fontFamily: 'Boldonse',
                            // letterSpacing: -.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Email field
                        CustomTextField(
                              label: "Email Address",
                              hintText: "Enter your email address here",
                              onChanged: forgotPasswordNotifier.setEmail,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                            )
                            .animate()
                            .fadeIn(
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .scale(
                              begin: const Offset(0.98, 0.98),
                              end: const Offset(1.0, 1.0),
                              delay: 400.ms,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .shimmer(
                              delay: 800.ms,
                              duration: 1000.ms,
                              color: AppColors.purple500ForTheme(
                                context,
                              ).withOpacity(0.1),
                              angle: 15,
                            ),

                        if (forgotPasswordState.emailError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 14),
                            child: Text(
                              forgotPasswordState.emailError,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontSize: 13,
                                fontFamily: 'Karla',
                                letterSpacing: -.6,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        SizedBox(height: 300.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
