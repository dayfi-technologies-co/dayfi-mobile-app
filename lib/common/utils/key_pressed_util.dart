import 'package:flutter/material.dart';
import 'package:dayfi/common/widgets/buttons/numerical_keyboard.dart';

onKeyPressed(
  int key,
  TextEditingController otpController,
  int length, [
  Function? faceIDCall,
]) {
  if (key == NumericalKeyboard.faceIDKey) {
    faceIDCall!();
    return;
  }

  if (key == NumericalKeyboard.backspaceKey) {
    if (otpController.text.isNotEmpty) {
      otpController.text = otpController.text.substring(
        0,
        otpController.text.length - 1,
      );
    }
  } else {
    if (otpController.text.length < length) {
      otpController.text += key.toString();
    }
  }
}
