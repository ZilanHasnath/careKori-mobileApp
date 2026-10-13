import '../constants/app_constants.dart';

abstract final class Validators {
  static final _phone = RegExp(r'^(?:\+8801|8801|01)[3-9]\d{8}$');
  static final _email = RegExp(
    r'^[a-zA-Z0-9](?:[a-zA-Z0-9._%+-]*[a-zA-Z0-9])?@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
  );

  static String? required(String? value, [String label = 'This field']) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    return _phone.hasMatch(text) ? null : 'Enter a valid Bangladeshi phone number';
  }

  static String? optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return _email.hasMatch(text.toLowerCase()) ? null : 'Enter a valid email address';
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    return optionalEmail(text);
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < AppConstants.minPasswordLength) {
      return 'Use at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? positiveInt(String? value, [String label = 'Value']) {
    final parsed = int.tryParse(value?.trim() ?? '');
    return (parsed == null || parsed <= 0) ? '$label must be a positive number' : null;
  }

  static String? positiveNumber(String? value, [String label = 'Value']) {
    final parsed = double.tryParse(value?.trim() ?? '');
    return (parsed == null || parsed <= 0) ? '$label must be a positive number' : null;
  }
}
