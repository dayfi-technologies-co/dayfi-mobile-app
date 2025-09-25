import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? labelColor;
  final Color? focusedLabelColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final double borderRadius;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.labelColor,
    this.focusedLabelColor,
    this.textStyle,
    this.labelStyle,
    this.contentPadding,
    this.readOnly = false,
    this.borderRadius = 8.0,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late FocusNode _focusNode;
  late TextEditingController _controller;

  bool get _hasValue =>
      _controller.text.isNotEmpty || widget.initialValue?.isNotEmpty == true;
  bool get _shouldAnimateLabel => _focusNode.hasFocus || _hasValue;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldAnimateLabel) {
        _animationController.forward();
      }
    });
  }

  void _onFocusChange() {
    if (_shouldAnimateLabel) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    if (_shouldAnimateLabel && !_animationController.isCompleted) {
      _animationController.forward();
    } else if (!_shouldAnimateLabel && _animationController.isCompleted) {
      _animationController.reverse();
    }

    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _labelAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(
            1.0,
          ), // Add margin to prevent border clipping
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color:
                  _focusNode.hasFocus
                      ? widget.focusedBorderColor ?? colorScheme.primary
                      : widget.borderColor ?? Colors.grey.shade300,
              width: _focusNode.hasFocus ? 2.0 : 1.0,
            ),
            color: widget.fillColor,
          ),
          child: Stack(
            children: [
              // Text Field
              TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                validator: widget.validator,
                onTap: widget.onTap,
                onFieldSubmitted: widget.onSubmitted,
                style: widget.textStyle ?? theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: _shouldAnimateLabel ? widget.hintText : null,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: false,
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.only(
                        left: widget.prefixIcon != null ? 48 : 16,
                        right: 16,
                        top: _shouldAnimateLabel ? 28 : 20,
                        bottom: 12,
                      ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),

              // Animated Label
              Positioned(
                left: widget.prefixIcon != null ? 48 : 16,
                top: _labelAnimation.value == 0 ? 20 : 6,
                child: IgnorePointer(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: (widget.labelStyle ?? theme.textTheme.bodyMedium!)
                        .copyWith(
                          color:
                              _focusNode.hasFocus
                                  ? widget.focusedLabelColor ??
                                      colorScheme.primary
                                  : widget.labelColor ?? Colors.grey.shade600,
                          fontSize: _labelAnimation.value == 0 ? 16 : 11,
                          fontWeight:
                              _labelAnimation.value == 0
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                        ),
                    child: Text(widget.label),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Example usage widget
