import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Selected language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @canceledApiRequest.
  ///
  /// In en, this message translates to:
  /// **'Request to API server was cancelled!!!'**
  String get canceledApiRequest;

  /// No description provided for @apiConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection and try again!!!'**
  String get apiConnectionTimeout;

  /// No description provided for @apiBadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Server certificate error. We have failed to establish a connection due to certificate error!!!'**
  String get apiBadCertificate;

  /// No description provided for @apiConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection and try again!!!'**
  String get apiConnectionError;

  /// No description provided for @apiUnknownConnection.
  ///
  /// In en, this message translates to:
  /// **'An unknown error has occurred, we are unable to establish a connection with the server!!!'**
  String get apiUnknownConnection;

  /// No description provided for @apiResponseTimeout.
  ///
  /// In en, this message translates to:
  /// **'Ouch! Seems like you’re offline. Please check your internet connection and try again!!!'**
  String get apiResponseTimeout;

  /// No description provided for @apiBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to process user request, server responded with bad request'**
  String get apiBadRequest;

  /// No description provided for @apiUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Access unauthorized, please login to proceed'**
  String get apiUnauthorized;

  /// No description provided for @apiPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied, you are not authorized to access this content'**
  String get apiPermissionDenied;

  /// No description provided for @apiContentNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested content was not found'**
  String get apiContentNotFound;

  /// No description provided for @apiServerDowntime.
  ///
  /// In en, this message translates to:
  /// **'We experienced a server downtime while processing your request, please try again later'**
  String get apiServerDowntime;

  /// No description provided for @apiInternalServerError.
  ///
  /// In en, this message translates to:
  /// **'Internal server error. We are fixing it right away'**
  String get apiInternalServerError;

  /// No description provided for @apiGenericError.
  ///
  /// In en, this message translates to:
  /// **'Ouch! Seems like you’re offline. Please check your internet connection and try again'**
  String get apiGenericError;

  /// No description provided for @apiCaughtError.
  ///
  /// In en, this message translates to:
  /// **'Oops an error occurred while processing your request, we are fixing it'**
  String get apiCaughtError;

  /// No description provided for @apiUnprocessableEntity.
  ///
  /// In en, this message translates to:
  /// **'The data could not be processed, please enter valid inputs'**
  String get apiUnprocessableEntity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
