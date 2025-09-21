import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_viewmodel.dart';
import 'package:stacked/stacked.dart';

class ReenterPasscodeView extends StatelessWidget {
  const ReenterPasscodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReenterPasscodeViewModel>.reactive(
      viewModelBuilder: () => ReenterPasscodeViewModel(),
      builder:
          (context, model, child) => AppScaffold(
            // resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xffF6F5FE),
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(12.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          onPressed: () {
                            model.navigationService.back();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xff5645F5), // innit
                          ),
                        ),
                      ),
                      verticalSpace(16.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Re-enter passcode",
                          style: TextStyle(
                            fontSize: 22.00,
                            fontFamily: 'Boldonse',
                            height: 1.2,
                            letterSpacing: 0.00,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                            // color: Color( 0xff5645F5), // innit
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      verticalSpace(8.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Enter 6-digit passcode to confirm",
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.450,
                            color: Color(0xFF302D53),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 0.0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: PasscodeWidget(
                      passcodeLength: 6,
                      currentPasscode: model.passcode,
                      onPasscodeChanged:
                          (value) => model.updatePasscode(context, value),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 0.0)),
                ],
              ),
            ),
          ),
    );
  }
}

class PasscodeWidget extends StatelessWidget {
  final int passcodeLength;
  final String currentPasscode;
  final Function(String) onPasscodeChanged;

  const PasscodeWidget({
    super.key,
    required this.passcodeLength,
    required this.currentPasscode,
    required this.onPasscodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            passcodeLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < currentPasscode.length
                          ? const Color(0xff5645F5)
                          : Colors.transparent,
                  border: Border.all(
                    color: const Color(0xff5645F5), // innit
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * .25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Enter your 6-digit passcode",
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
              return _buildNumberButton(number);
            }),
            const SizedBox.shrink(), // Placeholder for the fingerprint button (not needed)
            _buildNumberButton('0'),
            _buildIconButton(
              icon: Icons.arrow_back_ios,
              onTap: () {
                if (currentPasscode.isNotEmpty) {
                  onPasscodeChanged(
                    currentPasscode.substring(0, currentPasscode.length - 1),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () {
        if (currentPasscode.length < passcodeLength) {
          onPasscodeChanged(currentPasscode + number);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24.00,
              fontFamily: 'Boldonse',
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            // size: 32,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
    );
  }
}
