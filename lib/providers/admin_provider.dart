import 'package:flutter/foundation.dart';

/// Manages admin mode state.
///
/// Separated from [BookingProvider] following Single Responsibility Principle.
/// In the future this can be extended with authentication, role-based
/// access control, and persistent login state.
class AdminProvider extends ChangeNotifier {
  bool _isAdminMode = false;

  bool get isAdminMode => _isAdminMode;

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
