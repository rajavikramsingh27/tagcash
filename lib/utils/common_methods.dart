import 'package:intl/intl.dart';

class CommonMethods {
  static String removeTrailingZeros(input) {
    return input.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  static String formatDateTime(DateTime input, [String format]) {
    format ??= "dd-MMM-yyyy hh:mm a";
    return DateFormat(format).format(input);
  }

  static String formatTime(DateTime input, [String format]) {
    format ??= "hh:mm a";
    return DateFormat(format).format(input);
  }
}
