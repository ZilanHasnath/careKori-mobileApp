import 'package:flutter/foundation.dart';

import '../models/session.dart';
import '../services/auth_service.dart';
import '../services/session_storage.dart';

enum AuthStatus { initializing, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService, required SessionStorage storage})
      : _authService = authService,
        _storage = storage;

  final AuthService _authService;
  final SessionStorage _storage;

  AuthStatus _status = AuthStatus.initializing;
  Session? _session;

  AuthStatus get status => _status;
  Session? get session => _session;

  Future<void> restore() async {
    _session = await _storage.read();
    _status = _session == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    final session = await _authService.login(identifier, password);
    await _storage.write(session);
    _session = session;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final current = _session;
    if (current == null) return;
    final updated = current.copyWith(user: {...current.user, ...user});
    await _storage.write(updated);
    _session = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    _session = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
