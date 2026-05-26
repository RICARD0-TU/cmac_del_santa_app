class AuthFormValidators {
  const AuthFormValidators._();

  static bool isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  static bool isValidPassword(String value) {
    return value.length >= 6;
  }

  static bool isValidDni(String value) {
    return RegExp(r'^\d{8}$').hasMatch(value.trim());
  }

  static bool isValidPhone(String value) {
    return RegExp(r'^\d{9}$').hasMatch(value.trim());
  }
}
