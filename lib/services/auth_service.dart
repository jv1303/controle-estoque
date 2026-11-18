import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import 'database_service.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _sessionKey = 'logged_user_id';

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// chamado no main: se o usuario nao fez logout, entra direto
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_sessionKey);
    if (userId == null) return;

    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'users',
      columns: ['id', 'name', 'email'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await prefs.remove(_sessionKey);
      return;
    }
    _currentUser = AppUser.fromRow(rows.first);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseService.instance.database;
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final salt = _generateSalt();

    try {
      final id = await db.insert('users', {
        'name': cleanName,
        'email': cleanEmail,
        'password_hash': _hashPassword(password, salt),
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      });
      return await _openSession(
        AppUser(id: id, name: cleanName, email: cleanEmail),
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const AuthException('Já existe uma conta com esse e-mail.');
      }
      rethrow;
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AuthException('Nenhuma conta com esse e-mail.');
    }

    final row = rows.first;
    final expected = row['password_hash']! as String;
    if (_hashPassword(password, row['salt']! as String) != expected) {
      throw const AuthException('Senha incorreta.');
    }
    return _openSession(AppUser.fromRow(row));
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser> _openSession(AppUser user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, user.id);
    return user;
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
