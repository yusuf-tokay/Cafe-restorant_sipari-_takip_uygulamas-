import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double walletBalance;
  final List<String> addresses;
  final List<String> paymentMethods;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.walletBalance = 0.0,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
      addresses: List<String>.from(data['addresses'] ?? []),
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
    );
  }
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserData(userCredential.user!.uid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'da kullanıcı dokümanı oluştur
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'walletBalance': 0.0,
        'addresses': [],
        'paymentMethods': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData(userCredential.user!.uid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _user = UserModel.fromFirestore(doc);
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    if (_user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore.collection('users').doc(_user!.id).update(updates);
    await _loadUserData(_user!.id);
  }

  Future<void> addAddress(String address) async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.id).update({
      'addresses': FieldValue.arrayUnion([address]),
    });
    await _loadUserData(_user!.id);
  }

  Future<void> addPaymentMethod(String cardNumber) async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.id).update({
      'paymentMethods': FieldValue.arrayUnion([cardNumber]),
    });
    await _loadUserData(_user!.id);
  }

  Future<void> updateWalletBalance(double amount) async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.id).update({
      'walletBalance': FieldValue.increment(amount),
    });
    await _loadUserData(_user!.id);
  }
} 