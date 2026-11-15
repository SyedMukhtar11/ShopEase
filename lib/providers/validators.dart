/// Reusable form validators. Each returns an error string, or null if valid.
class Validators {
  Validators._();

  static String? notEmpty(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final empty = notEmpty(value, 'Email');
    if (empty != null) return empty;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    return ok ? null : 'Enter a valid email address';
  }

  static String? username(String? value) {
    final empty = notEmpty(value, 'Username');
    if (empty != null) return empty;
    if (value!.trim().length < 3) return 'Username must be at least 3 characters';
    if (value.contains(' ')) return 'Username cannot contain spaces';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? Function(String?) matches(String Function() other) {
    return (value) => value == other() ? null : 'Passwords do not match';
  }
}
