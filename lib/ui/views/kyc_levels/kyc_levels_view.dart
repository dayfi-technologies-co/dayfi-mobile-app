import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

import 'kyc_levels_viewmodel.dart';

class KycLevelsView extends StackedView<KycLevelsViewModel> {
  const KycLevelsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    KycLevelsViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => model.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue, // Updated to match the blue arrow in the image
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {},
        //     child: const Text(
        //       "Need Help?",
        //       style: TextStyle(
        //         color: Colors.black,
        //         fontSize: 14,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      backgroundColor: Color(0xffF6F5FE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stepper(
                    currentStep: model.currentStep,
                    onStepTapped: (step) => model.setCurrentStep(step),
                    steps: [
                      Step(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Level One - Personal Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Unverified",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Phone number"),
                                  SizedBox(height: 8),
                                  Text("Date of birth"),
                                  SizedBox(height: 8),
                                  Text("Gender"),
                                  SizedBox(height: 8),
                                  Text("Country of residence"),
                                  SizedBox(height: 8),
                                  Text("Full address (residence)"),
                                ],
                              ),
                            ),
                            verticalSpace(16.h),
                            const Text(
                              "Sending Limit: \$1,000",
                              style: TextStyle(fontSize: 14),
                            ),
                            verticalSpace(8.h),
                            const Text(
                              "Receiving Limit: Limitless",
                              style: TextStyle(fontSize: 14),
                            ),
                            verticalSpace(16.h),
                            SizedBox(
                              width: double.infinity,
                              child: FilledBtn(
                                onPressed: model.startProcess,
                                text: "Start Level One",
                                isLoading: model.isBusy,
                                backgroundColor: const Color(
                                    0xff5e35b1), // Purple color to match the image
                                // textStyle: const TextStyle(
                                //   color: Colors.white,
                                //   fontWeight: FontWeight.w600,
                                // ),
                              ),
                            ),
                          ],
                        ),
                        state: model.currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        isActive: model.currentStep >= 0,
                      ),
                      Step(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Level Two - Verify ID",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Unverified",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Upload government ID"),
                                  SizedBox(height: 8),
                                  Text("Take a selfie"),
                                ],
                              ),
                            ),
                            verticalSpace(16.h),
                            const Text(
                              "Sending Limit: \$2,500",
                              style: TextStyle(fontSize: 14),
                            ),
                            verticalSpace(8.h),
                            const Text(
                              "Receiving Limit: Limitless",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        state: model.currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        isActive: model.currentStep >= 1,
                      ),
                    ],
                    controlsBuilder:
                        (BuildContext context, ControlsDetails details) {
                      return Container(); // Hides default buttons
                    },
                  ),
                  verticalSpace(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  KycLevelsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      KycLevelsViewModel();
}
