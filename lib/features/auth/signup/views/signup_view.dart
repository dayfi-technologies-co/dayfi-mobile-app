import 'package:dayfi/features/auth/check_email/vm/check_email_viewmodel.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/features/auth/signup/vm/signup_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupView extends ConsumerWidget {
  const SignupView({super.key});

  void _assignEmailFromArguments(
    BuildContext context,
    SignupViewArguments? args,
    SignupNotifier signupNotifier,
    TextEditingController emailController,
  ) {
    if (args != null && args.email.isNotEmpty) {
      signupNotifier.setEmail(args.email);
      emailController.text = args.email;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupProvider);
    final signupNotifier = ref.read(signupProvider.notifier);
    final emailController = TextEditingController(text: signupState.email);

    // Get arguments from ModalRoute
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    SignupViewArguments? signupArgs;
    if (routeArgs is SignupViewArguments) {
      signupArgs = routeArgs;
    } else if (routeArgs is String) {
      signupArgs = SignupViewArguments(email: routeArgs);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assignEmailFromArguments(
        context,
        signupArgs,
        signupNotifier,
        emailController,
      );
    });

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
            resizeToAvoidBottomInset: true,
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
                hoverColor: Colors.transparent,
                onTap: () {
                  signupNotifier.resetForm();
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svgs/notificationn.svg",
                      height: 40,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            // size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Image.asset('assets/images/logo_splash.png', height: 24),
              centerTitle: true,
            ),
            bottomNavigationBar: SafeArea(
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(.2),
                      width: 1,
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 10),
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 8,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).viewInsets.bottom + 8
                          : 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: PrimaryButton(
                            borderRadius: 38,
                            text: "Verify email address",
                            onPressed:
                                signupState.isFormValid && !signupState.isBusy
                                    ? () => signupNotifier.signup(context)
                                    : null,
                            enabled:
                                signupState.isFormValid && !signupState.isBusy,
                            isLoading: signupState.isBusy,

                            backgroundColor:
                                signupState.isFormValid
                                    ? AppColors.purple500ForTheme(context)
                                    : AppColors.purple500ForTheme(
                                      context,
                                    ).withOpacity(.15),
                            textColor:
                                signupState.isFormValid
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
                            delay: 800.ms,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 800.ms,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            delay: 800.ms,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            body: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 400 : double.infinity,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                "Create your account",
                                style: Theme.of(
                                  context,
                                ).textTheme.displayLarge?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineLarge?.color,
                                  fontSize: isWide ? 32 : 28,
                                  letterSpacing: -.250,
                                  fontWeight: FontWeight.w900,
                                  // fontWeight: FontWeight.w100,
                                  fontFamily: 'FunnelDisplay',
                                  // letterspacing: 0,
                                  height: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32),
                              Center(
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      // Email field
                                      CustomTextField(
                                            label: "Email Address",
                                            hintText:
                                                "Enter your email address here",
                                            controller: emailController,
                                            onChanged: signupNotifier.setEmail,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textCapitalization:
                                                TextCapitalization.none,
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
                                      const SizedBox(height: 18),

                                      // Name fields row
                                      SizedBox(
                                        width: isWide ? 360 : 420,
                                        child: Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    label: "First Name",
                                                    hintText:
                                                        "Enter your first name",
                                                    keyboardType:
                                                        TextInputType.name,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    maxLength: 50,
                                                    onChanged:
                                                        signupNotifier
                                                            .setFirstName,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: CustomTextField(
                                                    label:
                                                        "Last Name (Surname)",
                                                    hintText:
                                                        "Enter your last name",
                                                    keyboardType:
                                                        TextInputType.name,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    maxLength: 50,
                                                    onChanged:
                                                        signupNotifier
                                                            .setLastName,
                                                  ),
                                                ),
                                              ],
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
                                              color:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ).withOpacity(0.1),
                                              angle: 15,
                                            ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Middle name field
                                      CustomTextField(
                                            label: "Middle Name (Optional)",
                                            hintText:
                                                "Enter your middle name (if you have one)",
                                            keyboardType: TextInputType.name,
                                            textInputAction:
                                                TextInputAction.next,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLength: 50,
                                            onChanged:
                                                signupNotifier.setMiddleName,
                                          )
                                          .animate()
                                          .fadeIn(
                                            delay: 400.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .slideY(
                                            begin: 0.3,
                                            end: 0,
                                            delay: 400.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .scale(
                                            begin: const Offset(0.98, 0.98),
                                            end: const Offset(1.0, 1.0),
                                            delay: 400.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .shimmer(
                                            delay: 600.ms,
                                            duration: 800.ms,
                                            color: AppColors.purple500ForTheme(
                                              context,
                                            ).withOpacity(0.1),
                                            angle: 15,
                                          ),

                                      const SizedBox(height: 18),

                                      // Password field
                                      CustomTextField(
                                            label: "Password",
                                            hintText:
                                                "Create a secure password",
                                            onChanged:
                                                signupNotifier.setPassword,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText:
                                                signupState.isPasswordVisible,
                                            suffixIcon: InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              child: EyeIcon(
                                                isVisible:
                                                    signupState
                                                        .isPasswordVisible,
                                                color: AppColors.neutral400,
                                                size: 20.0,
                                              ),
                                              onTap:
                                                  () =>
                                                      signupNotifier
                                                          .togglePasswordVisibility(),
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(
                                            delay: 500.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .slideY(
                                            begin: 0.3,
                                            end: 0,
                                            delay: 500.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .scale(
                                            begin: const Offset(0.98, 0.98),
                                            end: const Offset(1.0, 1.0),
                                            delay: 500.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .shimmer(
                                            delay: 700.ms,
                                            duration: 800.ms,
                                            color: AppColors.purple500ForTheme(
                                              context,
                                            ).withOpacity(0.1),
                                            angle: 15,
                                          ),

                                      // Password requirements section
                                      if (signupState.password.isNotEmpty) ...[
                                        Center(
                                          child: SizedBox(
                                            width: 420,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 18),
                                                Text(
                                                  'Your password must include all of these:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontFamily: 'Chirp',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        // letterspacing: 0,
                                                        height: 1.2,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildPasswordRequirement(
                                                  'At least 8 characters long',
                                                  signupState.hasMinLength,
                                                ),
                                                _buildPasswordRequirement(
                                                  'One uppercase letter (A-Z)',
                                                  signupState.hasUppercase,
                                                ),
                                                _buildPasswordRequirement(
                                                  'One lowercase letter (a-z)',
                                                  signupState.hasLowercase,
                                                ),
                                                _buildPasswordRequirement(
                                                  'One number (0-9)',
                                                  signupState.hasNumber,
                                                ),
                                                _buildPasswordRequirement(
                                                  'One special character (!@#\$%^&*)',
                                                  signupState
                                                      .hasSpecialCharacter,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 18),

                                      // Confirm password field
                                      CustomTextField(
                                            label: "Confirm Password",
                                            hintText:
                                                "Type your password again",
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            onChanged:
                                                signupNotifier
                                                    .setConfirmPassword,
                                            textInputAction:
                                                TextInputAction.done,
                                            obscureText:
                                                signupState
                                                    .isConfirmPasswordVisible,
                                            suffixIcon: InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              child: EyeIcon(
                                                isVisible:
                                                    signupState
                                                        .isConfirmPasswordVisible,
                                                color: AppColors.neutral400,
                                                size: 20.0,
                                              ),
                                              onTap:
                                                  () =>
                                                      signupNotifier
                                                          .toggleConfirmPasswordVisibility(),
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(
                                            delay: 600.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .slideY(
                                            begin: 0.3,
                                            end: 0,
                                            delay: 600.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .scale(
                                            begin: const Offset(0.98, 0.98),
                                            end: const Offset(1.0, 1.0),
                                            delay: 600.ms,
                                            duration: 300.ms,
                                            curve: Curves.easeOutCubic,
                                          )
                                          .shimmer(
                                            delay: 800.ms,
                                            duration: 800.ms,
                                            color: AppColors.purple500ForTheme(
                                              context,
                                            ).withOpacity(0.1),
                                            angle: 15,
                                          ),

                                      if (signupState
                                          .confirmPasswordError
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            left: 16.0,
                                          ),
                                          child: Text(
                                            signupState.confirmPasswordError,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontFamily: 'Chirp',
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),
                              // SizedBox(height: 300),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (signupState.isBusy)
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

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Builder(
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                !isValid
                    ? Icon(
                      Icons.circle_outlined,
                      color: AppColors.neutral400,
                      size: 16,
                    )
                    : SvgPicture.asset(
                      'assets/icons/svgs/circle-check.svg',
                      color: Colors.green,
                      height: 16,
                    ),
                SizedBox(width: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isValid
                            ? null
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.25,
                    height: 1.450,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
