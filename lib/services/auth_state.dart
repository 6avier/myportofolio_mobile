import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session.
///
/// Widgets that `watch` this object rebuild when the user logs in or out.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Revokes the token on the server, but always forgets it locally, even if
  /// the server call fails (for example the token was already revoked).
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;
    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // The token is dropped below either way.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
