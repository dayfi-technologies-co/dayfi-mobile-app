// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get canceledApiRequest => 'Request to API server was cancelled!!!';

  @override
  String get apiConnectionTimeout =>
      'Connection timeout. Please check your internet connection and try again!!!';

  @override
  String get apiBadCertificate =>
      'Server certificate error. We have failed to establish a connection due to certificate error!!!';

  @override
  String get apiConnectionError =>
      'Connection error. Please check your internet connection and try again!!!';

  @override
  String get apiUnknownConnection =>
      'An unknown error has occurred, we are unable to establish a connection with the server!!!';

  @override
  String get apiResponseTimeout =>
      'Ouch! Seems like you’re offline. Please check your internet connection and try again!!!';

  @override
  String get apiBadRequest =>
      'Failed to process user request, server responded with bad request';

  @override
  String get apiUnauthorized => 'Access unauthorized, please login to proceed';

  @override
  String get apiPermissionDenied =>
      'Permission denied, you are not authorized to access this content';

  @override
  String get apiContentNotFound => 'The requested content was not found';

  @override
  String get apiServerDowntime =>
      'We experienced a server downtime while processing your request, please try again later';

  @override
  String get apiInternalServerError =>
      'Internal server error. We are fixing it right away';

  @override
  String get apiGenericError =>
      'Ouch! Seems like you’re offline. Please check your internet connection and try again';

  @override
  String get apiCaughtError =>
      'Oops an error occurred while processing your request, we are fixing it';

  @override
  String get apiUnprocessableEntity =>
      'The data could not be processed, please enter valid inputs';
}
