import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'home_screen.dart';
import 'qr_scanner_screen.dart';
import 'qr_code_display_screen.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _userLogin() async {
    if (_userFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userEmailController.text.trim(),
          password: _userPasswordController.text,
        );
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı bulunamadı')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Giriş başarısız';
        if (e.code == 'user-not-found') {
          message = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
        } else if (e.code == 'wrong-password') {
          message = 'Yanlış şifre';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _adminLogin() async {
    if (_adminFormKey.currentState!.validate()) {  // Doğru form key'i kullanıyoruz
      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _adminEmailController.text.trim(),  // Doğru controller
          password: _adminPasswordController.text,  // Doğru controller
        );
        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['isAdmin'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yönetici yetkisi bulunmamaktadır')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Giriş başarısız';
        if (e.code == 'user-not-found') {
          message = 'Bu e-posta ile kayıtlı yönetici bulunamadı';
        } else if (e.code == 'wrong-password') {
          message = 'Yanlış şifre';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dekoratif arka plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffb347), // sıcak turuncu
                  Color(0xFFffcc33), // altın sarısı
                  Color(0xFFe57373), // kırmızımsı
                  Color(0xFF6d4c41), // koyu kahve
                ],
              ),
            ),
          ),
          // Hafif dekoratif görsel (ör: tabak)
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: 0.12,
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ve başlık
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 70,
                      color: Color(0xFFe57373),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Amida Restaurant'a Hoş Geldiniz",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lezzetli anlar, mutlu sofralar!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // QR ile Giriş
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QrScannerScreen()),
                      );
                      if (result != null && result is String) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    },
                    icon: Icon(Icons.qr_code_scanner, size: 32),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                      child: Text(
                        'QR ile Giriş',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 60),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // QR Kodunu Göster Butonu
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QrCodeDisplayScreen()),
                      );
                    },
                    icon: Icon(Icons.qr_code, color: Colors.white),
                    label: Text('Giriş QR Kodunu Göster', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 36),
                  // Kullanıcı Girişi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF6d4c41)),
                            const SizedBox(width: 8),
                            Text('Kullanıcı Girişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF6d4c41))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Kullanıcı girişi formunda:
                        Form(
                          key: _userFormKey,  // _formKey yerine
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _userEmailController,  // _emailController yerine
                                decoration: InputDecoration(
                                  labelText: 'E-posta',
                                  prefixIcon: Icon(Icons.email, color: Color(0xFFe57373)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen e-posta adresinizi girin';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Geçerli bir e-posta adresi girin';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _userPasswordController,  // _passwordController yerine
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFFe57373)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen şifrenizi girin';
                                  }
                                  if (value.length < 6) {
                                    return 'Şifre en az 6 karakter olmalıdır';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _userLogin,  // _login yerine
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Giriş Yap',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hesabınız yok mu?',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: Text(
                                      'Kayıt Ol',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Yönetici Girişi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Color(0xFF6d4c41)),
                            const SizedBox(width: 8),
                            Text('Yönetici Girişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF6d4c41))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Yönetici girişi formunda:
                        Form(
                          key: _adminFormKey,  // _formKey yerine doğru form key'i kullanıyoruz
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _adminEmailController,  // _emailController yerine doğru controller
                                decoration: InputDecoration(
                                  labelText: 'E-posta',
                                  prefixIcon: Icon(Icons.email, color: Color(0xFFe57373)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen e-posta adresinizi girin';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Geçerli bir e-posta adresi girin';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _adminPasswordController,  // _passwordController yerine doğru controller
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFFe57373)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373).withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Color(0xFFe57373),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen şifrenizi girin';
                                  }
                                  if (value.length < 6) {
                                    return 'Şifre en az 6 karakter olmalıdır';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _adminLogin,  // Loading durumunu kontrol ediyoruz
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Yönetici Girişi',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Alt slogan
                  Text(
                    'Amida Restaurant - Sofranıza Lezzet Katıyoruz',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}