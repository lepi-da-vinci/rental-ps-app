import 'package:flutter/foundation.dart';

/// Manages admin mode state.
///
/// Separated from [BookingProvider] following Single Responsibility Principle.
/// In the future this can be extended with authentication, role-based
/// access control, and persistent login state.
class AdminProvider extends ChangeNotifier {
  // TODO: ganti ke auth beneran (API/Firebase) sebelum production.
  static const _validUsername = 'admin';
  static const _validPassword = 'admin123';

  bool _isAdminMode = false;

  bool get isAdminMode => _isAdminMode;

  /// Validates credentials and enters admin mode if correct.
  /// Returns true on success, false on invalid credentials.
  bool login(String username, String password) {
    if (username == _validUsername && password == _validPassword) {
      _isAdminMode = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void toggleAdminMode() {
    _isAdminMode = !_isAdminMode;
    notifyListeners();
  }

  /// Explicitly set admin mode (useful for login/logout flows).
  void setAdminMode(bool value) {
    if (_isAdminMode != value) {
      _isAdminMode = value;
      notifyListeners();
    }
  }
}
