import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _userName;
  String? _currentEmail;

  String? get userName => _userName;
  String? get currentEmail => _currentEmail;

  // Hash password for secure storage
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Register new user
  Future<void> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if email already exists
    final usersJson = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (users.containsKey(email)) {
      throw Exception('Email already registered');
    }

    users[email] = {
      'name': name,
      'email': email,
      'password': _hashPassword(password),
    };

    await prefs.setString('users', jsonEncode(users));
    _userName = name;
    _currentEmail = email;
    notifyListeners();
  }

  // Login user
  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);

    if (!users.containsKey(email)) {
      throw Exception('No account found with this email');
    }

    final user = users[email];
    if (user['password'] != _hashPassword(password)) {
      throw Exception('Incorrect password');
    }

    _userName = user['name'];
    _currentEmail = email;
    await prefs.setString('current_user', email);
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _userName = null;
    _currentEmail = null;
    notifyListeners();
  }

  // Auto-login on app start
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user');
    if (email == null) return false;

    final usersJson = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(usersJson);
    if (!users.containsKey(email)) return false;

    _userName = users[email]['name'];
    _currentEmail = email;
    notifyListeners();
    return true;
  }
}
