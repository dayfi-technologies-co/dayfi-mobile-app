import 'package:dayfi/services/remote/network/api_error.dart';

/// Extract a user-visible message from API / network errors.
String messageFromApiError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is ApiError) {
    final fromModel = (error.apiErrorModel?.message ?? '').trim();
    if (fromModel.isNotEmpty) return fromModel;

    final desc = (error.errorDescription ?? '').trim();
    if (desc.isNotEmpty && !desc.toLowerCase().contains('status code')) {
      return desc;
    }
  }

  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (raw.isNotEmpty &&
      raw != 'Instance of \'ApiError\'' &&
      !raw.toLowerCase().contains('status code')) {
    return raw;
  }

  return fallback;
}
