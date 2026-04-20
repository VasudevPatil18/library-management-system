import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  String? _userName;
  String? get userName => _userName;

  // Constructor: App khulne par user check karo
  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) fetchUserData(user.uid);
    });
  }

  // User ka name Firestore se uthana
  Future<void> fetchUserData(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      _userName = doc.data()?['name'];
      notifyListeners();
    }
  }

  // Registration Logic
  Future<void> register(String name, String email, String password) async {
    try {
      // 1. Firebase Auth mein account banao
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      // 2. Name Firestore mein save karo
      await _db.collection('users').doc(res.user!.uid).set({
        'name': name,
        'email': email,
        'uid': res.user!.uid,
      });
      _userName = name;
      notifyListeners();
    } catch (e) {
      rethrow; // Error screen par dikhane ke liye
    }
  }

  // Login Logic
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}