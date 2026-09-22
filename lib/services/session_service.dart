import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SessionService extends ChangeNotifier {
  static const _tokenKey = 'session_token';
  static const _usernameKey = 'session_username';
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _username;
  int? _userId;

  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restore() async {
    _token = await _storage.read(key: _tokenKey);
    _username = await _storage.read(key: _usernameKey);
    if (_token != null && _isExpired(_token!)) {
      await signOut();
      return;
    }
    _userId = _token == null ? null : _readUserId(_token!);
    notifyListeners();
  }

  Future<void> signIn({required String token, required String username}) async {
    _token = token;
    _username = username;
    _userId = _readUserId(token);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _usernameKey, value: username);
    notifyListeners();
  }

  Future<void> signOut() async {
    _token = null;
    _username = null;
    _userId = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    notifyListeners();
  }

  int? _readUserId(String token) {
    final payload = _decodePayload(token);
    return (payload?['userId'] as num?)?.toInt();
  }

  bool _isExpired(String token) {
    final exp = (_decodePayload(token)?['exp'] as num?)?.toInt();
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= exp * 1000;
  }

  Map<String, dynamic>? _decodePayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) return null;
    try {
      return jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(segments[1]))),
          )
          as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

final session = SessionService();
