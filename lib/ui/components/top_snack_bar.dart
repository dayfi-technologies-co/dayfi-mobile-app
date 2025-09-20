import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_svg/svg.dart';

class TopSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = isError ? Colors.red.shade50 : Colors.green.shade50;
    final borderColor = isError ? Colors.red.shade900 : Colors.green.shade900;

    Flushbar(
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w600,
          letterSpacing: -.025,
          height: 1.450,
          color: borderColor,
        ),
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(4),
      backgroundColor: color,
      borderColor: borderColor,
      borderWidth: 1,
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(),
      icon: Image.asset(
        !isError ? "assets/images/check.png" : "assets/images/warning.png",
        height: 24,
        // color: borderColor,
      ),
    ).show(context);
  }
}
