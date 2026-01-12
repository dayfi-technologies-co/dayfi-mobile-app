import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/reset_password/vm/reset_password_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordView extends ConsumerWidget {
  final String email;

  const ResetPasswordView({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final resetPasswordNotifier = ref.read(resetPasswordProvider.notifier);
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 600;
                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 400 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppBar(
                                scrolledUnderElevation: .5,
                                foregroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shadowColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                surfaceTintColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                elevation: 0,
                                leadingWidth: 72,
                                leading: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => Navigator.pop(context),
                                  child: Stack(
                                    alignment: AlignmentGeometry.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/svgs/notificationn.svg",
                                        height: 40,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color,
                                              // size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 24 : 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12),

                                    // Subtitle
                                    Center(
                                          child: Text(
                                            "Create a strong password with at least 8 characters, including uppercase, numbers, and special characters",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Chirp',
                                              letterSpacing: -.25,
                                              height: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(
                                          delay: 100.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .slideY(
                                          begin: 0.2,
                                          end: 0,
                                          delay: 100.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        ),

                                    SizedBox(height: 36),

                                    // Password field
                                    CustomTextField(
                                          label: "New Password",
                                          hintText: "Create a strong password",
                                          // errorText: resetPasswordState.passwordError,
                                          onChanged:
                                              resetPasswordNotifier.setPassword,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          obscureText:
                                              !resetPasswordState
                                                  .isPasswordVisible,
                                          suffixIcon: InkWell(
                                            child: EyeIcon(
                                              isVisible:
                                                  resetPasswordState
                                                      .isPasswordVisible,
                                              color: AppColors.neutral400,
                                              size: 20.0,
                                            ),
                                            onTap:
                                                () =>
                                                    resetPasswordNotifier
                                                        .togglePasswordVisibility(),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(
                                          delay: 200.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .slideY(
                                          begin: 0.3,
                                          end: 0,
                                          delay: 200.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .scale(
                                          begin: const Offset(0.98, 0.98),
                                          end: const Offset(1.0, 1.0),
                                          delay: 200.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .shimmer(
                                          delay: 400.ms,
                                          duration: 800.ms,
                                          color: AppColors.purple500ForTheme(
                                            context,
                                          ).withOpacity(0.1),
                                          angle: 15,
                                        ),

                                    // Password error text
                                    if (resetPasswordState
                                        .passwordError
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                          left: 14,
                                        ),
                                        child: Text(
                                          resetPasswordState.passwordError,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                            fontFamily: 'Chirp',
                                            letterSpacing: -.25,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),

                                    SizedBox(height: 18),

                                    // Confirm Password field
                                    CustomTextField(
                                          label: "Confirm new password",
                                          hintText:
                                              "Type your new password again",
                                          // errorText: resetPasswordState.confirmPasswordError,
                                          onChanged:
                                              resetPasswordNotifier
                                                  .setConfirmPassword,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                          obscureText:
                                              !resetPasswordState
                                                  .isConfirmPasswordVisible,
                                          suffixIcon: InkWell(
                                            child: EyeIcon(
                                              isVisible:
                                                  resetPasswordState
                                                      .isConfirmPasswordVisible,
                                              color: AppColors.neutral400,
                                              size: 20.0,
                                            ),
                                            onTap:
                                                () =>
                                                    resetPasswordNotifier
                                                        .toggleConfirmPasswordVisibility(),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(
                                          delay: 300.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .slideY(
                                          begin: 0.3,
                                          end: 0,
                                          delay: 300.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .scale(
                                          begin: const Offset(0.98, 0.98),
                                          end: const Offset(1.0, 1.0),
                                          delay: 300.ms,
                                          duration: 300.ms,
                                          curve: Curves.easeOutCubic,
                                        )
                                        .shimmer(
                                          delay: 500.ms,
                                          duration: 800.ms,
                                          color: AppColors.purple500ForTheme(
                                            context,
                                          ).withOpacity(0.1),
                                          angle: 15,
                                        ),

                                    // Confirm Password error text
                                    if (resetPasswordState
                                        .confirmPasswordError
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                          left: 14,
                                        ),
                                        child: Text(
                                          resetPasswordState
                                              .confirmPasswordError,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                            fontFamily: 'Chirp',
                                            letterSpacing: -.25,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),

                                    SizedBox(height: 72),
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
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 12, 18.0, 40.0),
              child:
              // Submit button
              PrimaryButton(
                    borderRadius: 38,
                    text: "Save Password",
                    onPressed:
                        resetPasswordState.isFormValid &&
                                !resetPasswordState.isBusy
                            ? () => resetPasswordNotifier.resetPassword(
                              email,
                              context,
                            )
                            : null,
                    enabled:
                        resetPasswordState.isFormValid &&
                        !resetPasswordState.isBusy,
                    isLoading: resetPasswordState.isBusy,
                    backgroundColor:
                        resetPasswordState.isFormValid
                            ? AppColors.purple500ForTheme(context)
                            : AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(.15),
                    height: 48.00000,
                    textColor:
                        resetPasswordState.isFormValid
                     ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                    fontFamily: 'Chirp',
                    letterSpacing: -.70,
                    fontSize: 18,
                    width: 375,
                    fullWidth: true,
                  )
                  .animate()
                  .fadeIn(
                    delay: 400.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 400.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    delay: 400.ms,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
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
          ),
          if (resetPasswordState.isBusy)
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              body: Opacity(
                opacity: 0.5,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
