import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/reset_password/vm/reset_password_viewmodel.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  
  const ResetPasswordView({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xffFEF9F3),
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor: const Color(0xffFEF9F3),
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      "Create new password",
                      style: TextStyle(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 30.00,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),

                        // Subtitle
                        Center(
                          child: Text(
                            "Please create a strong password for your account.\nMake sure it's something you can remember but others can't guess.",
                            style: TextStyle(
                              color: AppColors.neutral800,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400, //
                              fontFamily: 'Karla',
                              letterSpacing: -.6,
                              height: 1.4,
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

                        SizedBox(height: 36.h),

                        // Password field
                        CustomTextField(
                          label: "New Password",
                          hintText: "Create a new password here",
                          errorText: _viewModel.passwordError,
                          onChanged: _viewModel.setPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          obscureText: !_viewModel.isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: _viewModel.isPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed: () => _viewModel.togglePasswordVisibility(),
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
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        SizedBox(height: 18.h),

                        // Confirm Password field
                        CustomTextField(
                          label: "Confirm new password",
                          hintText: "Type your new password again",
                          errorText: _viewModel.confirmPasswordError,
                          onChanged: _viewModel.setConfirmPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: !_viewModel.isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: EyeIcon(
                              isVisible: _viewModel.isConfirmPasswordVisible,
                              color: AppColors.neutral500,
                              size: 20.0,
                            ),
                            onPressed: () => _viewModel.toggleConfirmPasswordVisibility(),
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
                          color: AppColors.purple500.withOpacity(0.1),
                          angle: 15,
                        ),

                        SizedBox(height: 72.h),

                        // Submit button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Save my new password",
                          onPressed: _viewModel.isFormValid && !_viewModel.isBusy
                              ? () => _viewModel.resetPassword(widget.email, context)
                              : null,
                          enabled: _viewModel.isFormValid && !_viewModel.isBusy,
                          isLoading: _viewModel.isBusy,
                          backgroundColor: _viewModel.isFormValid
                              ? AppColors.purple500
                              : AppColors.purple200,
                          height: 60.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.48,
                          fontSize: 18,
                          width: 375.w,
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
                        ),

                        SizedBox(height: 40.h),
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