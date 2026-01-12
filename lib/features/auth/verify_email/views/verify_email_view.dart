import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/features/auth/verify_email/vm/verify_email_viewmodel.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:open_mail_app_plus/open_mail_app_plus.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final name = parts[0];
  final domain = parts[1];
  String maskedName;
  if (name.length <= 2) {
    maskedName = name[0] + '*';
  } else if (name.length <= 4) {
    maskedName = name[0] + '*' * (name.length - 2) + name[name.length - 1];
  } else {
    maskedName =
        name.substring(0, 2) +
        '*' * (name.length - 4) +
        name.substring(name.length - 2);
  }
  final domainParts = domain.split('.');
  if (domainParts.length < 2) return '$maskedName@${domain}';
  final domainName = domainParts[0];
  final domainExt = domainParts.sublist(1).join('.');
  String maskedDomain = domainName[0] + '*' * (domainName.length - 1);
  return '$maskedName@$maskedDomain.$domainExt';
}

class VerifyEmailView extends ConsumerWidget {
  final bool isSignUp;
  final String email;
  final String password;

  const VerifyEmailView({
    super.key,
    this.isSignUp = false,
    required this.email,
    this.password = "",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyState = ref.watch(verifyEmailProvider);
    final verifyNotifier = ref.read(verifyEmailProvider.notifier);

    // Initialize email when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (verifyState.email != email) {
        verifyNotifier.setEmail(email);
      }
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
            resizeToAvoidBottomInset: false,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: PrimaryButton(
                                borderRadius: 38,
                                text:
                                    isSignUp
                                        ? "Verify Account"
                                        : "Reset Password",
                                onPressed:
                                    verifyState.isFormValid &&
                                            !verifyState.isVerifying
                                        ? () =>
                                            isSignUp
                                                ? verifyNotifier.verifySignup(
                                                  context,
                                                  email,
                                                  password,
                                                )
                                                : verifyNotifier
                                                    .verifyForgotPassword(
                                                      context,
                                                      email,
                                                    )
                                        : null,
                                enabled:
                                    verifyState.isFormValid &&
                                    !verifyState.isVerifying,
                                isLoading: verifyState.isVerifying,
                                backgroundColor:
                                    verifyState.isFormValid
                                        ? AppColors.purple500ForTheme(context)
                                        : AppColors.purple500ForTheme(
                                          context,
                                        ).withOpacity(.25),
                                textColor:
                                    verifyState.isFormValid
                                      ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                                fontFamily: 'Chirp',
                                letterSpacing: -.40,
                                fontSize: 18,
                                fullWidth: true,
                              )
                              .animate()
                              .fadeIn(
                                delay: 500.ms,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 500.ms,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.0, 1.0),
                                delay: 500.ms,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 12),

                    // TextButton(
                    //       style: TextButton.styleFrom(
                    //         splashFactory: NoSplash.splashFactory,
                    //         backgroundColor: Colors.transparent,
                    //         foregroundColor: Colors.transparent,
                    //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //         alignment: Alignment.center,
                    //       ),
                    //       onPressed: () async {
                    //         var result = await OpenMailApp.openMailApp();

                    //         // If no mail apps found, show error
                    //         if (!result.didOpen && !result.canOpen) {
                    //           showDialog(
                    //             context: context,
                    //             builder: (context) {
                    //               return AlertDialog(
                    //                 title: Text("No Mail Apps Found"),
                    //                 content: Text(
                    //                   "No mail apps are installed on your device.",
                    //                 ),
                    //                 actions: <Widget>[
                    //                   TextButton(
                    //                     child: Text("OK"),
                    //                     onPressed: () {
                    //                       Navigator.pop(context);
                    //                     },
                    //                   ),
                    //                 ],
                    //               );
                    //             },
                    //           );
                    //         } else if (!result.didOpen && result.canOpen) {
                    //           // iOS: multiple mail apps available, show picker
                    //           showDialog(
                    //             context: context,
                    //             builder: (_) {
                    //               return MailAppPickerDialog(
                    //                 mailApps: result.options,
                    //               );
                    //             },
                    //           );
                    //         }
                    //       },
                    //       child: Text(
                    //         "Open email app",
                    //         style: TextStyle(
                    //           fontFamily: 'Chirp',
                    //           color:
                    //               Theme.of(context).textTheme.bodyLarge!.color,
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w500,
                    //           letterSpacing: -.40,
                    //           decoration: TextDecoration.underline,
                    //         ),
                    //       ),
                    //     )
                    //     .animate()
                    //     .fadeIn(delay: 200.ms, duration: 600.ms)
                    //     .slideY(
                    //       begin: 0.3,
                    //       end: 0,
                    //       delay: 200.ms,
                    //       duration: 600.ms,
                    //     )
                    //     .shimmer(
                    //       delay: 1000.ms,
                    //       duration: 1500.ms,
                    //       color: Theme.of(
                    //         context,
                    //       ).scaffoldBackgroundColor.withOpacity(0.4),
                    //       angle: 45,
                    //     ),
                  ],
                ),
              ),
            ),

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
                      verifyNotifier.resetForm(),
                      Navigator.pop(context),
                      FocusScope.of(context).unfocus(),
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
            ),

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
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 32 : 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  "Verify email",
                                  textAlign: TextAlign.center,
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
                                    fontFamily: 'FunnelDisplay',
                                    height: 1,
                                  ),
                                ),

                                SizedBox(height: 12),

                                // Subtitle
                                Text(
                                      isSignUp
                                          ? "We've sent a verification code to ${maskEmail(email)}.\nCheck your email inbox and enter the 6-digit code below to complete your account setup."
                                          : "We've sent a reset code to ${maskEmail(email)}.\nCheck your email inbox and enter the 6-digit code below to reset your password.",
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

                                SizedBox(height: 32),

                                // PIN field
                                PinTextField(
                                      length: 6,
                                      onTextChanged: verifyNotifier.setOtpCode,
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
                                    ),

                                SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!verifyState.canResend) ...[
                                      Icon(
                                        Icons.timer_outlined,
                                        color: AppColors.neutral400,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        verifyState.timerText,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Chirp',
                                          color: AppColors.neutral400,
                                        ),
                                      ),
                                    ] else ...[
                                      GestureDetector(
                                        onTap:
                                            verifyState.isResending
                                                ? null
                                                : () => verifyNotifier
                                                    .resendOTP(context, email),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (verifyState.isResending) ...[
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    LoadingAnimationWidget.horizontalRotatingDots(
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                      size: 20,
                                                    ),
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                            Text(
                                              verifyState.isResending
                                                  ? "..."
                                                  : "Send new code",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontFamily: 'Chirp',
                                                color:
                                                    verifyState.isResending
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.onSurface
                                                        : AppColors.purple500ForTheme(
                                                          context,
                                                        ),
                                                fontSize:
                                                    verifyState.isResending
                                                        ? 14
                                                        : 16,

                                                decoration:
                                                    verifyState.isResending
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                            .underline,
                                                letterSpacing: -.25,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                SizedBox(height: 24),
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
          ),
          if (verifyState.isBusy)
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
