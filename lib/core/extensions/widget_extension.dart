

import 'package:flutter/material.dart';

extension PaddingExtension on Widget {
  Padding padAll([double value = 0.0]) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Padding padSymmetric({double horizontal = 0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Padding padOnly({
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
    double left = 0.0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
      child: this,
    );
  }
}

extension MarginExtension on Widget {
  Container marginAll([double value = 0.0]) {
    return Container(
      margin: EdgeInsets.all(value),
      child: this,
    );
  }

  Container marginSymmetric({double horizontal = 0, double vertical = 0.0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Container marginOnly({
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
    double left = 0.0,
  }) {
    return Container(
      margin:
          EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
      child: this,
    );
  }
}
