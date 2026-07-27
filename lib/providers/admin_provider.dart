import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// Manages admin mode state with API authentication & local fallback.
class AdminProvider extends ChangeNotifier {
  static const _validUsername = 'admin';
  static const _validPassword = 'admin123';

  bool _isAdminMode = false;
  String _authToken = '';

  bool get isAdminMode => _isAdminMode;
  String get authToken => _authToken;

  /// Validates credentials with API first, falling back to local credentials.
  Future<bool> loginAsync(String username, String password) async {
    final apiResult = await ApiService.loginAdmin(username, password);
    if (apiResult != null && apiResult['success'] == true) {
      _authToken = apiResult['token'] ?? '';
      _isAdminMode = true;
      notifyListeners();
      return true;
    }

    // Local fallback for development / offline server
    if (username == _validUsername && password == _validPassword) {
      _isAdminMode = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Synchronous login (legacy support).
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
