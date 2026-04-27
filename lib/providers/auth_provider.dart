import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const _usersKey = 'local_users';
  static const _sessionKey = 'session_email';

  String? _userName;
  String? _role;
  String? _email;

  String? get userName => _userName;
  String? get role => _role;
  String? get email => _email;
  bool get isLoggedIn => _email != null;
  bool get isAdmin => _role == 'admin';

  AuthProvider() {
    _restoreSession();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Load all users from SharedPreferences.
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  /// Save users list back to SharedPreferences.
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Restore session on app start.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_sessionKey);
    if (savedEmail != null) {
      final users = await _loadUsers();
      final match = users.firstWhere(
        (u) => u['email'] == savedEmail,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        _email = match['email'];
        _userName = match['name'];
        _role = match['role'];
        notifyListeners();
      }
    }
  }

  /// Register a new user locally.
  Future<void> register(String name, String email, String password, {String role = 'user'}) async {
    final users = await _loadUsers();
    final exists = users.any((u) => u['email'] == email);
    if (exists) throw Exception('An account with this email already exists.');

    users.add({
      'name': name,
      'email': email,
      'password': _hashPassword(password),
      'role': role,
    });
    await _saveUsers(users);
  }

  /// Login locally and return the user's role.
  Future<String> login(String email, String password) async {
    final users = await _loadUsers();
    final match = users.firstWhere(
      (u) => u['email'] == email && u['password'] == _hashPassword(password),
      orElse: () => {},
    );
    if (match.isEmpty) throw Exception('Invalid email or password.');

    _email = match['email'];
    _userName = match['name'];
    _role = match['role'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);

    notifyListeners();
    return _role!;
  }

  /// Logout and clear session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _email = null;
    _userName = null;
    _role = null;
    notifyListeners();
  }
}
