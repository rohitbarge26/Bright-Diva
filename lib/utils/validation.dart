class Validator {
  static bool emailValidate(String email) {
    if (email.isEmpty) {
      return false; // Return true for an empty email
    } else {
      return _isValidEmail(email);
    }
  }

  static bool passwordValidate(String password) {
    final RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    final RegExp digitRegex = RegExp(r'[0-9]');
    final RegExp alphabetRegex = RegExp(r'[a-zA-Z]'); // New regex for alphabet

    bool hasMinimumLength = password.length >= 8;
    bool hasSpecialChar = specialCharRegex.hasMatch(password);
    bool hasDigit = digitRegex.hasMatch(password);
    bool hasSpace = password.contains(' ');
    bool hasAlphabet = alphabetRegex.hasMatch(password);
    bool hasAlphanumeric = alphanumericValidate(password); // Check for alphabet

    if (!hasMinimumLength ||
        !hasSpecialChar ||
        !hasDigit ||
        hasSpace ||
        !hasAlphabet ||
        !hasAlphanumeric) {
      if (!hasMinimumLength) {
        return false;
      }
      if (!hasSpecialChar) {
        return false;
      }
      if (!hasDigit) {
        return false;
      }
      if (hasSpace) {
        return false;
      }
      if (!hasAlphabet) {
        return false;
      }
      if (!hasAlphanumeric) {
        return false;
      }
      return false;
    }
    return true;
  }

  static bool alphanumericValidate(String input) {
    final RegExp alphabetRegex = RegExp(r'[a-zA-Z]'); // Check for alphabets
    final RegExp digitRegex = RegExp(r'[0-9]'); // Check for digits

    bool hasAlphabet =
        alphabetRegex.hasMatch(input); // Contains at least one letter
    bool hasDigit = digitRegex.hasMatch(input); // Contains at least one digit

    return hasAlphabet && hasDigit; // Must contain both letters and digits
  }

  static bool stringValidate(String name) {
    final RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
    return nameRegex.hasMatch(name);
  }

  static bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w.-]+@[a-zA-Z_]+?\.[a-zA-Z]{2,}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  static bool confirmPasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static bool oldPasswordMatch(String password, String confirmPassword) {
    return password != confirmPassword;
  }

  static bool phoneNumberValidate(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return false;
    }
    return true;
  }

  static bool mobileNumberValidate(String phoneNumber) {
    // Remove non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if the number has exactly 10 digits
    return digitsOnly.length == 10;
  }

  static bool emptyFieldValidate(String text) {
    return text.isNotEmpty;
  }

  static bool isToday(DateTime dateTime) {
    // Get the current date
    DateTime now = DateTime.now();

    // Compare the year, month, and day components
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool amountValidate(String amount) {
    // Check if the amount is a valid number and not empty
    if (amount.isEmpty) {
      return false;
    }

    // Check if the amount is a valid number with optional decimal places
    final RegExp amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    return amountRegex.hasMatch(amount);
  }
}
