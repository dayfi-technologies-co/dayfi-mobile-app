import 'package:flutter/material.dart';
import 'package:dayfi/core/extensions/context_extension.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/l10n/app_localizations.dart';

class AppStrings {
  AppLocalizations get localize {
    BuildContext? context = NavigatorKey.appNavigatorKey.currentContext;
    return context!.localizations;
  }
}
