import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinCodeInput extends StatefulWidget {
  final int length;
  final double boxWidth;
  final double boxHeight;
  final double spacing;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final double borderWidth;
  final bool obscureText;
  final String obscureCharacter;
  final bool autoFocus;
  final bool enabled;
  final TextInputType keyboardType;
  final EdgeInsetsGeometry? margin;

  const PinCodeInput({
    super.key,
    this.length = 6,
    this.boxWidth = 48.0,
    this.boxHeight = 64.0,
    this.spacing = 8.0,
    this.onCompleted,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.textStyle,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.obscureText = false,
    this.obscureCharacter = '●',
    this.autoFocus = false,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
    this.margin,
  });

  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _currentPin = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());

    // Auto focus first field if enabled
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    // Remove any non-digit characters if using number keyboard
    if (widget.keyboardType == TextInputType.number) {
      value = value.replaceAll(RegExp(r'[^0-9]'), '');
    }

    // Handle paste operation (multiple characters)
    if (value.length > 1) {
      _handlePaste(index, value);
      return;
    }
    if (value.isNotEmpty) {
      _controllers[index].text = value;
      _updatePin();
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
     
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handlePaste(int startIndex, String pastedText) {
    for (
      int i = 0;
      i < pastedText.length && (startIndex + i) < widget.length;
      i++
    ) {
      _controllers[startIndex + i].text = pastedText[i];
    }
    _updatePin();

    int nextIndex = (startIndex + pastedText.length).clamp(
      0,
      widget.length - 1,
    );
    _focusNodes[nextIndex].requestFocus();
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
         
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          _updatePin();
        }
      }
    }
  }

  void _updatePin() {
    _currentPin = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(_currentPin);

    if (_currentPin.length == widget.length) {
      widget.onCompleted?.call(_currentPin);
    }
  }

  String get pin => _currentPin;

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _currentPin = '';
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  void setValue(String value) {
    for (int i = 0; i < widget.length; i++) {
      if (i < value.length) {
        _controllers[i].text = value[i];
      } else {
        _controllers[i].clear();
      }
    }
    _updatePin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: widget.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          return Container(
            margin: EdgeInsets.only(
              right: index < widget.length - 1 ? widget.spacing : 0,
            ),
            child: _buildPinBox(index, theme, colorScheme),
          );
        }),
      ),
    );
  }

  Widget _buildPinBox(int index, ThemeData theme, ColorScheme colorScheme) {
    final bool hasFocus = _focusNodes[index].hasFocus;
    // final bool hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: widget.boxWidth,
      height: widget.boxHeight,
      margin: const EdgeInsets.all(
        1.0,
      ), 
      decoration: BoxDecoration(
        color: widget.fillColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color:
              hasFocus
                  ? widget.focusedBorderColor ?? colorScheme.primary
                  : widget.borderColor ?? Colors.grey.shade300,
          width: hasFocus ? 2.0 : widget.borderWidth,
        ),
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyEvent(index, event),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscureCharacter,
          style:
              widget.textStyle ??
              theme.textTheme.headlineSmall?.copyWith(
                color: widget.textColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
          inputFormatters: [
            if (widget.keyboardType == TextInputType.number)
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: false, 
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
  }
}
