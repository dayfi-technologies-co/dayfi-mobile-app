import 'dart:developer';

extension StringExtension on String {
  void logger({String? name}) => log(this, name: name ?? '');
}
