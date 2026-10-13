import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session.dart';

class SessionStorage {
  SessionStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'carekori_session';

  final FlutterSecureStorage _storage;

  Future<Session?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      return raw == null ? null : Session.decode(raw);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(Session session) =>
      _storage.write(key: _key, value: session.encode());

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}
