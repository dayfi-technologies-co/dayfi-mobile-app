// import 'package:epass/ui/common/app_colors.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class PinTextField extends StatefulWidget {
  final Function(String)? onTextChanged;
  final Function()? onCancel;
  final Function(String)? onCompleted;
  final TextEditingController? controller;
  final bool isEnabled;
  final double? height;
  final double? width;
  final int length;
  final bool obscureText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const PinTextField({
    super.key,
    this.onTextChanged,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.isEnabled = true,
    this.height,
    this.width,
    this.length = 4,
    this.onCancel,
    this.onCompleted,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PinTextField> createState() => _PinTextFieldState();
}

class _PinTextFieldState extends State<PinTextField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Paste digits into the field without the pin_code_fields confirmation dialog.
  bool _pasteSilently(String? text) {
    if (text == null) return false;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;
    final value =
        digits.length > widget.length
            ? digits.substring(0, widget.length)
            : digits;
    _controller.text = value;
    widget.onTextChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      keyboardType: TextInputType.number,
      focusNode: widget.focusNode,
      enablePinAutofill: true,
      controller: _controller,
      beforeTextPaste: _pasteSilently,
      autoDisposeControllers: false,
      blinkDuration: const Duration(milliseconds: 10),
      enabled: widget.isEnabled,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      cursorWidth: 1,
      enableActiveFill: true,
      obscureText: widget.obscureText,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        fontFamily: 'Chirp',
        letterSpacing: 0,
      ),
      pinTheme: PinTheme(
        errorBorderWidth: 1,
        activeBorderWidth: 1,
        disabledBorderWidth: 1,
        inactiveBorderWidth: 1,
        selectedBorderWidth: 1,
        borderWidth: 1,
        fieldHeight: widget.height ?? 60.0,
        fieldWidth: widget.width ?? 48.0,
        borderRadius: BorderRadius.circular(12),
        shape: PinCodeFieldShape.box,
        inactiveFillColor: Theme.of(context).colorScheme.surface,
        activeFillColor: Theme.of(context).colorScheme.surface,
        selectedFillColor: Theme.of(context).colorScheme.surface,
        inactiveColor: AppColors.purple500ForTheme(context).withOpacity(.2),
        activeColor: AppColors.purple500ForTheme(context).withOpacity(.2),
        selectedColor: AppColors.purple500ForTheme(context),
      ),
      appContext: context,
      length: widget.length,
      onCompleted: widget.onCompleted,
      onChanged: widget.onTextChanged!,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 150),
      cursorColor: AppColors.purple500ForTheme(context),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
