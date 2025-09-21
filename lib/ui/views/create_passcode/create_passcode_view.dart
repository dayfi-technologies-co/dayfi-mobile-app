import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_view.dart';
import 'package:stacked/stacked.dart';

import 'create_passcode_viewmodel.dart';

class CreatePasscodeView extends StackedView<CreatePasscodeViewModel> {
  const CreatePasscodeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CreatePasscodeViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<CreatePasscodeViewModel>.reactive(
      viewModelBuilder: () => CreatePasscodeViewModel(),
      builder: (context, model, child) => AppScaffold(
        backgroundColor: const Color(0xffF6F5FE),
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
                  
                  // Back button with subtle animation
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: () => model.navigationService.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff5645F5),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic)
                      .slideX(begin: -0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  
                  verticalSpace(16.h),
                  
                  // Title with smooth entrance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Create passcode",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 22.00,
                        height: 1.2,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff2A0079),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                  
                  verticalSpace(8.h),
                  
                  // Subtitle with smooth entrance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Enter 6-digit passcode to create",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: const Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                ],
              ),
              
              // Passcode widget with animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PasscodeWidget(
                  passcodeLength: 6,
                  currentPasscode: model.passcode,
                  onPasscodeChanged: model.updatePasscode,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  CreatePasscodeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CreatePasscodeViewModel();
}
