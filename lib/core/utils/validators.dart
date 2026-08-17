class Validators {
  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  static String? positiveNumber(
      String? value, {
        String label = 'Value',
      }) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    final number = double.tryParse(value);

    if (number == null || number < 0) {
      return 'Enter a valid $label';
    }

    return null;
  }
}