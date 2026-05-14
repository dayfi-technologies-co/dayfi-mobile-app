import 'package:flutter/material.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/l10n/app_localizations.dart';
import 'package:dayfi/l10n/app_localizations_en.dart';

class AppStrings {
  /// Resolves [AppLocalizations] from the app navigator when possible.
  ///
  /// Network error handling (e.g. [ApiError]) can run when [NavigatorState]
  /// has no [BuildContext] yet; a null [currentContext] used to throw via `!`
  /// and surface as "Null check operator used on a null value".
  AppLocalizations get localize {
    final context = NavigatorKey.appNavigatorKey.currentContext;
    if (context != null) {
      final loc = AppLocalizations.of(context);
      if (loc != null) return loc;
    }
    return AppLocalizationsEn();
  }
}
