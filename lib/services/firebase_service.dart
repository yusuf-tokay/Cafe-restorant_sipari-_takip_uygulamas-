import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeData() async {
    // Örnek menü öğeleri
    final menuItems = [
      {
        'name': 'Karışık Pizza',
        'price': 120.0,
        'category': 'Pizza',
        'description': 'Sucuk, sosis, mantar, yeşil biber, mısır',
        'imageUrl': 'https://example.com/pizza.jpg',
        'isAvailable': true,
      },
      {
        'name': 'Cheeseburger',
        'price': 85.0,
        'category': 'Burger',
        'description': 'Dana eti, cheddar peyniri, marul, domates',
        'imageUrl': 'https://example.com/burger.jpg',
        'isAvailable': true,
      },
      {
        'name': 'Sezar Salata',
        'price': 65.0,
        'category': 'Salata',
        'description': 'Marul, tavuk, kruton, parmesan peyniri',
        'imageUrl': 'https://example.com/salad.jpg',
        'isAvailable': true,
      },
    ];

    // Örnek masalar
    final tables = [
      {
        'number': 1,
        'capacity': 4,
        'isAvailable': true,
        'location': 'İç Mekan',
      },
      {
        'number': 2,
        'capacity': 2,
        'isAvailable': true,
        'location': 'İç Mekan',
      },
      {
        'number': 3,
        'capacity': 6,
        'isAvailable': true,
        'location': 'Bahçe',
      },
    ];

    // Örnek yönetici hesabı
    try {
      final adminCredential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@cafe.com',
        password: 'admin123',
      );

      await _firestore.collection('users').doc(adminCredential.user!.uid).set({
        'name': 'Admin User',
        'email': 'admin@cafe.com',
        'phone': '5551234567',
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Admin hesabı zaten var veya oluşturulamadı: $e');
    }

    // Örnek normal kullanıcı hesabı
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'user@cafe.com',
        password: 'user123',
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': 'Test User',
        'email': 'user@cafe.com',
        'phone': '5559876543',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı hesabı zaten var veya oluşturulamadı: $e');
    }

    // Menü öğelerini ekle
    for (var item in menuItems) {
      await _firestore.collection('menu').add(item);
    }

    // Masaları ekle
    for (var table in tables) {
      await _firestore.collection('tables').add(table);
    }

    // Örnek rezervasyon
    await _firestore.collection('reservations').add({
      'userId': 'user123',
      'tableNumber': 1,
      'date': Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
      'numberOfPeople': 2,
      'status': 'pending',
      'customerName': 'Ahmet Yılmaz',
      'customerPhone': '5551234567',
    });
  }
} 