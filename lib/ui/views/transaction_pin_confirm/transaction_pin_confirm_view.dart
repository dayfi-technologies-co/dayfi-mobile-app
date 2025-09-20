import 'package:flutter/material.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:stacked/stacked.dart';
import 'transaction_pin_confirm_viewmodel.dart';

class TransactionPinConfirmView
    extends StackedView<TransactionPinConfirmViewModel> {
  const TransactionPinConfirmView({
    super.key,
    required this.pin,
  });

  final String pin;

  @override
  Widget builder(
    BuildContext context,
    TransactionPinConfirmViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(10),
              const Text(
                "Confirm PIN",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                ),
                textAlign: TextAlign.start,
              ),
              verticalSpace(12),
              const Text(
                "Re-enter your new transaction PIN to confirm",
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
              verticalSpace(48),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.125),
                child: Column(
                  children: [
                    PinTextField(
                      length: 4,
                      obscureText: true,
                      controller: viewModel.pinTextEditingController,
                      textInputAction: TextInputAction.done,
                      onTextChanged: viewModel.validatePin,
                    ),
                  ],
                ),
              ),
              verticalSpace(MediaQuery.of(context).size.height * 0.2),
              SizedBox(
                child: FilledBtn(
                  onPressed: viewModel.isPinValid && !viewModel.isBusy
                      ? () => viewModel.confirmPin(pin)
                      : null,
                  text: "Confirm PIN",
                  backgroundColor: const Color(0xff5645F5),
                ),
              ),
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  TransactionPinConfirmViewModel viewModelBuilder(BuildContext context) =>
      TransactionPinConfirmViewModel();
}
