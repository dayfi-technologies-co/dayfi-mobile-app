import 'package:intl/intl.dart';


extension DateFormatterExtensionString on String {
  String get formatDateToMMMMddyyyy {
    DateTime dateTime = DateTime.parse(this);
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }
}
