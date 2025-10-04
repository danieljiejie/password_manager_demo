import 'dart:math';

class PasswordGenerator {
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String numbers = '0123456789';
  static const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    if (!includeUppercase && !includeLowercase && !includeNumbers && !includeSymbols) {
      throw ArgumentError('At least one character type must be selected');
    }

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static PasswordStrength getStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) strength++;

    if (strength <= 2) {
      return PasswordStrength.weak;
    } else if (strength <= 4) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.strong;
    }
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}