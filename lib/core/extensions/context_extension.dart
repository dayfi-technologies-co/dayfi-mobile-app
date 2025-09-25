import 'package:flutter/material.dart';
import 'package:dayfi/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get size => MediaQuery.sizeOf(this);
  double get totlaDeviceHeight => size.height;
  double deviceHeight(double h) => size.height * h;
  double deviceWidth(double w) => size.width * w;

  double divideHeight(double h) => size.height / h;
  double divideWidth(double w) => size.width / w;
}
