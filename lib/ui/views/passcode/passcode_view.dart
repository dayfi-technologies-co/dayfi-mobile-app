import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/main/main_view.dart';
import 'package:dayfi/ui/views/passcode/passcode_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

class PasscodeView extends StackedView<PasscodeViewModel> {
  const PasscodeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PasscodeViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: const NetworkImage(
                    'https://avatar.iran.liara.run/public/52'),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 22.00,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                ),
              ),
              verticalSpace(8.h),
              model.user != null && model.user!.firstName != ""
                  ? Text(
                      model.user!.firstName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Color(0xff2A0079),
                      ),
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 32),
              model.isVerifying
                  ? CupertinoActivityIndicator(
                      color: Color(0xff5645F5), // innit
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < model.passcode.length
                                  ? const Color(0xff5645F5)
                                  : Colors.transparent,
                              border: Border.all(
                                  color: const Color(0xff5645F5), // innit
                                  width: 2),
                            ),
                          ),
                        );
                      }),
                    ),
              SizedBox(height: MediaQuery.of(context).size.width * .3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Enter your passcode',
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.450,
                    color: Color(0xff2A0079),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...List.generate(9, (index) {
                    final number = (index + 1).toString();
                    return _buildNumberButton(number, model);
                  }),
                  _buildIconButton(
                    iconSvg: "assets/svgs/fingerprint.svg",
                    icon: Icons.fingerprint,
                    onTap: model.isBiometricAvailable
                        ? () async {
                            final authenticated =
                                await model.authenticateWithBiometrics();
                            if (authenticated) {
                              model.navigationService
                                  .clearStackAndShowView(MainView());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Biometric authentication failed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                      height: 1.450,
                                      color: Colors.white,
                                      fontFamily: 'Karla',
                                    ),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Biometric authentication not available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    height: 1.450,
                                    color: Colors.white,
                                    fontFamily: "Karla",
                                  ),
                                ),
                              ),
                            );
                          },
                  ),
                  _buildNumberButton('0', model),
                  _buildIconButton(
                    iconSvg: "",
                    icon: Icons.arrow_back,
                    onTap: model.removeDigit,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              //  SizedBox(height: 24.h),
              Center(
                child: Text.rich(
                  textAlign: TextAlign.end,
                  TextSpan(
                    text: "Not your account?",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.04,
                      height: 1.450,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          // ignore: deprecated_member_use
                          .withOpacity(.85),
                    ),
                    children: [
                      TextSpan(
                        text: " Log out",
                        style: const TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.04,
                          height: 1.450,
                          color: Color(0xff5645F5), // innit
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            model.logout();
                          },
                      )
                    ],
                  ),
                  semanticsLabel: '',
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number, PasscodeViewModel model) {
    return GestureDetector(
      onTap: () => model.addDigit(number),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28.00,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String iconSvg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: icon == Icons.fingerprint
              ? SvgPicture.asset(
                  iconSvg,
                  height: 36,
                  color: Color(0xff5645F5), // innit
                )
              : Icon(
                  icon,
                  size: icon == Icons.fingerprint ? 36 : 24,
                  color: Color(0xff5645F5), // innit
                ),
        ),
      ),
    );
  }

  @override
  PasscodeViewModel viewModelBuilder(BuildContext context) =>
      PasscodeViewModel();

  @override
  void onViewModelReady(PasscodeViewModel viewModel) {
    viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
