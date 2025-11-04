import 'package:email_validator/email_validator.dart';
import 'constants.dart';

class Validators {
  // Validate mobile number (Indian format: 10 digits starting with 6-9)
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.mobileRequiredMessage;
    }

    final mobileRegex = RegExp(AppConstants.mobileNumberPattern);
    if (!mobileRegex.hasMatch(value.trim())) {
      return AppConstants.invalidMobileMessage;
    }

    return null;
  }

  // Validate email (optional field)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    if (!EmailValidator.validate(value.trim())) {
      return AppConstants.invalidEmailMessage;
    }

    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequiredMessage;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShortMessage;
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    return null;
  }

  // Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.usernameRequiredMessage;
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }

    if (trimmedValue.length > AppConstants.maxUsernameLength) {
      return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
    }

    // Username can contain letters, numbers, and underscores
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Generic required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
