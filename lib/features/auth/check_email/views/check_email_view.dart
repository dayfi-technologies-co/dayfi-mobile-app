import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/check_email/vm/check_email_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:flutter_svg/svg.dart';

class CheckEmailView extends ConsumerStatefulWidget {
  final bool showBackButton;

  const CheckEmailView({super.key, this.showBackButton = true});

  @override
  ConsumerState<CheckEmailView> createState() => _CheckEmailViewState();
}

class _CheckEmailViewState extends ConsumerState<CheckEmailView> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkEmailState = ref.watch(checkEmailProvider);
    final checkEmailNotifier = ref.read(checkEmailProvider.notifier);

    // Sync controller with state if state has value and controller is empty
    if (checkEmailState.email.isNotEmpty && emailController.text.isEmpty) {
      emailController.text = checkEmailState.email;
    }

    return PopScope(
      canPop:
          widget.showBackButton, // Only allow back if showBackButton is true
      child: GestureDetector(
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
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                centerTitle: true,
                leadingWidth: 72,
                leading: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 40,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.arrow_back_ios, size: 20),
                      ),
                    ],
                  ),
                ),
                title: Image.asset('assets/images/logo_splash.png', height: 24),
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
                  curve: Curves.easeOut,
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
                          text: "Continue",
                          onPressed:
                              checkEmailState.isFormValid &&
                                      !checkEmailState.isBusy
                                  ? () =>
                                      checkEmailNotifier.validateEmail(context)
                                  : null,
                          enabled:
                              checkEmailState.isFormValid &&
                              !checkEmailState.isBusy,
                          isLoading: checkEmailState.isBusy,
                          backgroundColor:
                              checkEmailState.isFormValid
                                  ? AppColors.purple500ForTheme(context)
                                  : AppColors.purple500ForTheme(
                                    context,
                                  ).withOpacity(.15),
                          textColor:
                                checkEmailState.isFormValid
                                    ? AppColors.neutral0
                                    : AppColors.neutral0.withOpacity(.20),
                          fontFamily: 'Chirp',
                          fullWidth: true,
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
                      physics: const ClampingScrollPhysics(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 400 : double.infinity,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24.0 : 18.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                      "Sign up or sign in",
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
                                        // fontWeight: FontWeight.w100,
                                        fontFamily: 'FunnelDisplay',
                                        // letterspacing: 0,
                                        height: 1,
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideY(
                                      begin: 0.25,
                                      end: 0,
                                      duration: 600.ms,
                                    )
                                    .then()
                                    .shimmer(
                                      duration: 1800.ms,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withOpacity(0.4),
                                      angle: 20,
                                    ),

                                const SizedBox(height: 32),

                                // Email field
                                CustomTextField(
                                      label: "Email Address",
                                      hintText: "Enter your email address here",
                                      controller: emailController,
                                      onChanged: checkEmailNotifier.setEmail,
                                      keyboardType: TextInputType.emailAddress,
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
            if (checkEmailState.isBusy)
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
      ),
    );
  }
}
