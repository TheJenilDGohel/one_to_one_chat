/// Central validation utility following the Single Responsibility Principle.
/// All field-level validation rules live here — no validation logic in blocs or UI.
class Validator {
  Validator._(); // Prevent instantiation

  /// Validates an email address.
  /// Returns an error message, or null if valid.
  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w.-]+(\.[a-zA-Z]{2,})+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address.';
    return null;
  }

  /// Validates a password.
  /// Returns an error message, or null if valid.
  static String? password(String value) {
    if (value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  /// Validates a display name (used during registration).
  /// Returns an error message, or null if valid.
  static String? name(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please enter your name.';
    if (trimmed.length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  /// Converts a raw Firebase Auth exception message into a user-friendly string.
  static String firebaseAuthError(String raw) {
    if (raw.contains('email-already-in-use')) {
      return 'This email is already registered. Try logging in.';
    } else if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Invalid email or password.';
    } else if (raw.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (raw.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (raw.contains('network-request-failed')) {
      return 'No internet connection. Please try again.';
    } else if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
