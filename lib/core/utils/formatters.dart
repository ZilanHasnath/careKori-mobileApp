import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _date = DateFormat('d MMM y');
  static final _dateTime = DateFormat('d MMM y, h:mm a');
  static final _money = NumberFormat.decimalPattern();

  static String date(DateTime? value) => value == null ? '-' : _date.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '-' : _dateTime.format(value);

  static String salary(double value) => '৳${_money.format(value.round())}';

  static String orDash(String? value) =>
      (value == null || value.trim().isEmpty) ? '-' : value;
}
