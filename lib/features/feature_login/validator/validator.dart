class Validator {
  static bool isValidEmail(String input) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(input);
  }

  static String normalizePhone(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (RegExp(r'\+').allMatches(cleaned).length > 1 ||
        (cleaned.contains('+') && !cleaned.startsWith('+'))) {
      return cleaned.replaceAll('+', '');
    }
    return cleaned;
  }

  static bool isValidPhone(String input) {
    final normalized = normalizePhone(input);
    return RegExp(r'^\+?\d{10}$').hasMatch(normalized);
  }

  static String? validate(String userName, String password) {
    if (userName.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    if (!Validator.isValidEmail(userName) &&
        !Validator.isValidPhone(userName)) {
      return 'Enter a valid email address or phone number';
    }
    return null;
  }
}
