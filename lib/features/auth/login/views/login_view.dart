import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/eye_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/check_email/vm/check_email_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/features/auth/login/vm/login_viewmodel.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:flutter_svg/svg.dart';

class LoginView extends ConsumerStatefulWidget {
  final bool showBackButton;

  const LoginView({super.key, this.showBackButton = true});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _hasInitializedEmail = false;

  @override
  void initState() {
    super.initState();
    // Initialize email from args after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEmailFromArgs();
    });
  }

  void _initializeEmailFromArgs() {
    if (_hasInitializedEmail) return;

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    LoginViewArguments? loginArgs;
    if (routeArgs is LoginViewArguments) {
      loginArgs = routeArgs;
    } else if (routeArgs is String) {
      loginArgs = LoginViewArguments(email: routeArgs);
    }

    if (loginArgs != null && loginArgs.email.isNotEmpty) {
      ref.read(loginProvider.notifier).setEmail(loginArgs.email);
      emailController.text = loginArgs.email;
      _hasInitializedEmail = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

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
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
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
                                  text: "Continue",
                                  onPressed:
                                      loginState.isFormValid &&
                                              !loginState.isBusy
                                          ? () => loginNotifier.login(context)
                                          : null,
                                  enabled:
                                      loginState.isFormValid &&
                                      !loginState.isBusy,
                                  isLoading: loginState.isBusy,
                                  backgroundColor:
                                      loginState.isFormValid
                                          ? AppColors.purple500ForTheme(context)
                                          : AppColors.purple500ForTheme(
                                            context,
                                          ).withOpacity(.15),
                                  height: 48.00000,
                                  textColor:
                                      loginState.isFormValid
                                       ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                                  fontFamily: 'Chirp',
                                  letterSpacing: -.70,
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
                      SizedBox(height: 12),

                      // if (isCurrentStepOptional)
                      TextButton(
                        style: TextButton.styleFrom(
                          // padding: EdgeInsets.zero,
                          // minimumSize: Size(50, 30),
                          splashFactory: NoSplash.splashFactory,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.center,
                        ),
                        onPressed:
                            () => loginNotifier.navigateToForgotPassword(),
                        child: Text(
                          'I forgot my password',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.40,
                            decoration: TextDecoration.underline,
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
                                  "Sign in",
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

                                SizedBox(height: 32),

                                // Email field
                                CustomTextField(
                                      label: "Email Address",
                                      hintText: "Enter your email address here",
                                      controller: emailController,
                                      onChanged: loginNotifier.setEmail,
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

                                if (loginState.emailError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      left: 14,
                                    ),
                                    child: Text(
                                      loginState.emailError,
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

                                SizedBox(height: 17.5),

                                // Password field
                                CustomTextField(
                                      label: "Password",
                                      hintText: "Enter your password here",
                                      controller: passwordController,
                                      onChanged: loginNotifier.setPassword,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: loginState.isPasswordVisible,
                                      suffixIcon: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: EyeIcon(
                                          isVisible:
                                              loginState.isPasswordVisible,
                                          color: AppColors.neutral400,
                                          size: 20.0,
                                        ),
                                        onTap:
                                            () =>
                                                loginNotifier
                                                    .togglePasswordVisibility(),
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

                                if (loginState.passwordError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      left: 14,
                                    ),
                                    child: Text(
                                      loginState.passwordError,
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
            if (loginState.isBusy)
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
