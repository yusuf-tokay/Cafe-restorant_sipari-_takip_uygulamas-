import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/wallet_screen.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/auth_provider.dart' as my_auth;
import 'providers/order_provider.dart';
import 'providers/favorite_provider.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/discount_service.dart';
import 'services/firebase_service.dart';

Future<void> ensureAdminUser() async {
  final email = "admin@admin.com";
  final password = "123456";
  UserCredential? userCredential;
  try {
    // Eğer kullanıcı yoksa oluştur
    final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (methods.isEmpty) {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
    // Firestore'da yoksa ekle
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
    final userData = userDoc.data();
    final isAdmin = userData?['isAdmin'] == true;
    if (!isAdmin) {
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': 'admin',
        'email': email,
        'phone': '5555555555',
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'walletBalance': 0.0,
        'addresses': [],
        'paymentMethods': [],
      });
    }
    print("Admin kullanıcı Authentication ve Firestore'a eklendi!");
  } catch (e) {
    print("Admin kullanıcı eklenemedi: $e");
  }
}

Future<void> addAdminToFirestore() async {
  const adminUid = "FCKnrl3DTzedBYtIWfI591iURvb2";
  await FirebaseFirestore.instance.collection('users').doc(adminUid).set({
    'name': 'admin',
    'email': 'admin@admin.com',
    'phone': '5555555555',
    'isAdmin': true,
    'createdAt': FieldValue.serverTimestamp(),
    'walletBalance': 0.0,
    'addresses': [],
    'paymentMethods': [],
  }, SetOptions(merge: true));
  print("Firestore'a admin eklendi!");
}

Future<void> fixAdminDoc() async {
  const adminUid = "FCKnrl3DTzedBYtIWfI591iURvb2";
  await FirebaseFirestore.instance.collection('users').doc(adminUid).update({
    'addresses': [],
    'paymentMethods': [],
  });
  print("Admin dokümanı düzeltildi!");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDjJarh0iaM712W8J88CowpViblagPoMUs",
      appId: "1:772689919226:android:558545f8639b8a9a079d43",
      messagingSenderId: "772689919226",
      projectId: "cafemobiluygulama",
      storageBucket: "cafemobiluygulama.firebasestorage.app",
    ),
  );
  await ensureAdminUser();
  await addAdminToFirestore();
  await fixAdminDoc();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => DiscountService()),
      ],
      child: MaterialApp(
        title: 'Cafe Restaurant App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/menu': (context) => MenuScreen(),
          '/cart': (context) => CartScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/my-orders': (context) => MyOrdersScreen(),
          '/order-details': (context) => OrderDetailsScreen(orderId: ''),
          '/reservations': (context) => ReservationScreen(),
          '/profile': (context) => ProfileScreen(),
          '/addresses': (context) => AddressesScreen(),
          '/wallet': (context) => WalletScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
} 