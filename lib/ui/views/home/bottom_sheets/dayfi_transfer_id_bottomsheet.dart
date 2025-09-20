// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';

import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';

import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/home/home_viewmodel.dart';

class DayfiTransferIDBottomSheet extends StatefulWidget {
  final HomeViewModel viewModel;
  final Wallet wallet;

  const DayfiTransferIDBottomSheet({
    super.key,
    required this.viewModel,
    required this.wallet,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DayfiTransferIDBottomSheetState createState() =>
      _DayfiTransferIDBottomSheetState();
}

class _DayfiTransferIDBottomSheetState
    extends State<DayfiTransferIDBottomSheet> {
  late TextEditingController _controller;
  String? reaction;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.dayfiId);
    // Update reaction based on initial state
    _updateReaction();
    // Listen to view model changes
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    // Sync controller with view model, but avoid loops
    if (_controller.text != widget.viewModel.dayfiId) {
      _controller.text = widget.viewModel.dayfiId;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
    _updateReaction();
    setState(() {});
  }

  void _updateReaction() {
    if (widget.viewModel.isFormValid) {
      reaction = '✅'; // Valid ID
      // } else if (widget.viewModel.dayfiIdError != null) {
      //   _reaction = '⚠️'; // Invalid ID
    } else {
      reaction = null; // No reaction until input
    }
  }

  void _enforceAtPrefix(String value) {
    String newValue = value.trim();
    if (newValue.isNotEmpty && !newValue.startsWith('@')) {
      newValue = '@$newValue';
    } else if (newValue.isEmpty) {
      newValue = '';
    }
    // Only update controller if necessary to avoid loops
    if (_controller.text != newValue) {
      _controller.text = newValue;
      _controller.selection = TextSelection.collapsed(offset: newValue.length);
    }
    widget.viewModel.setDayfiId(newValue);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () => dismissKeyboard(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.00),
              topRight: Radius.circular(28.00),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => widget.viewModel.navigationService.back(),
                  child: SvgPicture.asset(
                    'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                    color: const Color(0xff5645F5), // innit
                    height: 28.00,
                  ),
                ),
              ),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildDayfieIdInputContent(
                context,
                widget.viewModel,
                widget.wallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayfieIdInputContent(
    BuildContext context,
    HomeViewModel model,
    Wallet wallet,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBottomSheetHeader(
              context,
              title: "Enter dayfi ID",
              subtitle: 'Provide the dayfi ID of who you want to send money to',
            ),
            verticalSpace(28.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "dayfi ID",
                    hintText: 'e.g., @user123',
                    maxLength: 16,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    onChanged: _enforceAtPrefix,
                    controller: _controller,
                    errorText: model.dayfiIdError,
                    errorFontSize: 0,
                    suffixIcon: model.isBusy
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CupertinoActivityIndicator(
                              color: Color(0xff5645F5), // innit
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: GestureDetector(
                              onTap: () async {
                                if (widget.viewModel.dayfiIdError != null) {
                                  //
                                  widget.viewModel.dayfiId = "";
                                  widget.viewModel.dayfiIdErr = null;
                                  widget.viewModel.dayfiIdRes = null;
                                  widget.viewModel.notifyListeners();
                                } else if (widget.viewModel.dayfiIdError ==
                                    null) {
                                } else {
                                  final clipboardData =
                                      await Clipboard.getData('text/plain');
                                  if (clipboardData != null &&
                                      clipboardData.text != null) {
                                    String pastedText =
                                        clipboardData.text!.trim();
                                    pastedText = pastedText.replaceAll('@', '');
                                    if (pastedText.isNotEmpty) {
                                      pastedText = '@$pastedText';
                                    }
                                    _controller.text = pastedText;
                                    _controller.selection =
                                        TextSelection.collapsed(
                                            offset: pastedText.length);
                                    model.setDayfiId(pastedText);
                                    setState(() {});
                                  }
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                child: Text(
                                  widget.viewModel.dayfiIdError != null
                                      ? "Clear"
                                      : widget.viewModel.dayfiIdError == null
                                          ? ""
                                          : "Paste",
                                  style: TextStyle(
                                    color: Color(0xFF302D53),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            verticalSpace(6),
            if (model.dayfiIdResponse != null)
              Text(
                model.dayfiIdResponse!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.1,
                  height: 1.450,
                  color: model.dayfiIdResponse!.contains('User not found')
                      ? Colors.red.shade800
                      : Colors.green.shade600,
                ),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            verticalSpace(MediaQuery.of(context).size.height * .12),
            const SizedBox(height: 16),
            FilledBtn(
              // isLoading: widget.viewModel.isBusy,
              onPressed: model.isFormValid
                  ? () => model.navigateToCurrencyAmount(context, wallet)
                  : null,
              text: 'Next - Amount',
              backgroundColor: const Color(0xff5645F5),
            ),
            const SizedBox(height: 20),
            FilledBtn(
              onPressed: () {},
              text: 'Do you need help?',
              backgroundColor: Colors.transparent,
              textColor: const Color(0xff5645F5), // innit
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
