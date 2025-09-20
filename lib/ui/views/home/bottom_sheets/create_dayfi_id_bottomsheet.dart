import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/home/home_viewmodel.dart';

class CreateDayfiIDSheet extends StatefulWidget {
  final HomeViewModel viewModel;

  final Function(String) onCreate;

  CreateDayfiIDSheet({required this.onCreate, required this.viewModel});

  @override
  // ignore: library_private_types_in_public_api
  _CreateDayfiIDSheetState createState() => _CreateDayfiIDSheetState();
}

class _CreateDayfiIDSheetState extends State<CreateDayfiIDSheet> {
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
    if (widget.viewModel.isFormValid2) {
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
    widget.viewModel.setDayfiI2(newValue);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Pushes content above keyboard
      ),
      child: SingleChildScrollView(
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => dismissKeyboard(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 88,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.25),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      color: const Color(0xff5645F5), // innit
                      height: 28.00,
                    ),
                  ),
                ),
                buildBottomSheetHeader(
                  context,
                  title: "Unique Username",
                  subtitle:
                      'Send and receive money for free from your friends and family that own a Dayfi account by creating Dayfi-ID. Provide a name in the field below to begin',
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: "dayfi ID",
                  hintText: 'e.g., @user123',
                  maxLength: 16,
                  minLines: 1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.none,
                  onChanged: _enforceAtPrefix,
                  controller: _controller,
                  isDayfiId: true,
                  errorText: widget.viewModel.dayfiIdError,
                  errorFontSize: 0,
                  suffixIcon: widget.viewModel.isBusy
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
                              // if (widget.viewModel.dayfiIdError != null) {
                              //   //
                              //   widget.viewModel.dayfiId = "";
                              //   widget.viewModel.dayfiIdErr = null;
                              //   widget.viewModel.dayfiIdRes = null;
                              //   widget.viewModel.notifyListeners();
                              // } else {
                              final clipboardData =
                                  await Clipboard.getData('text/plain');
                              if (clipboardData != null &&
                                  clipboardData.text != null) {
                                String pastedText = clipboardData.text!.trim();
                                pastedText = pastedText.replaceAll('@', '');
                                if (pastedText.isNotEmpty) {
                                  pastedText = '@$pastedText';
                                }
                                _controller.text = pastedText;
                                _controller.selection = TextSelection.collapsed(
                                    offset: pastedText.length);
                                widget.viewModel.setDayfiId(pastedText);
                                setState(() {});
                              }
                              // }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12.0),
                              child: Text(
                                widget.viewModel.dayfiIdError != null
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
                const SizedBox(height: 24),
                FilledBtn(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onCreate(_controller.text
                          .replaceFirst(_controller.text[0], ''));
                    }
                  },
                  isLoading: widget.viewModel.isFormValid2,
                  text: 'Create Dayfi-ID',
                  backgroundColor: const Color(0xff5645F5),
                ),
                const SizedBox(height: 16),
                OutlineBtn(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Skip for now',
                  backgroundColor: Colors.transparent,
                  textColor: const Color(0xff5645F5), // innit
                  borderColor: const Color(0xff5645F5), // innit
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
