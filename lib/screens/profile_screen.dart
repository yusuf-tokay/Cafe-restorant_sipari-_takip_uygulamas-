import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import 'order_details_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  String? userEmail;
  String? userId;
  String? createdAt;
  List<String> addresses = [];
  Position? currentPosition;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = 'yusuf tokay';
    userEmail = 'yusuftokay019@gmail.com';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        phoneController.text = doc['phone'] ?? '';
        addresses = List<String>.from(doc['addresses'] ?? []);
        createdAt = doc['createdAt'] != null ? (doc['createdAt'] as Timestamp).toDate().toString().substring(0, 16) : null;
        setState(() {});
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => isLoading = true);
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum servisleri kapalı')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni reddedildi')),
          );
          return;
        }
      }

      currentPosition = await Geolocator.getCurrentPosition();
      if (currentPosition != null) {
        // Burada reverse geocoding yapılabilir
        final address = '${currentPosition!.latitude}, ${currentPosition!.longitude}';
        setState(() {
          addresses.add(address);
          addressController.clear();
        });
        await _saveProfile();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (userId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': nameController.text,
      'phone': phoneController.text,
      'addresses': addresses,
      'email': userEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil güncellendi.')));
  }

  void _addAddress() {
    if (addressController.text.isNotEmpty) {
      setState(() {
        addresses.add(addressController.text);
        addressController.clear();
      });
      _saveProfile();
    }
  }

  void _removeAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
    _saveProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  // Profil Fotoğrafı ve Bilgiler
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'yusuf tokay',
                          style: AppTheme.titleStyle,
                        ),
                        Text(
                          'yusuftokay019@gmail.com',
                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                        Text(phoneController.text, style: AppTheme.bodyStyle),
                        if (createdAt != null)
                          Text('Kayıt: $createdAt', style: AppTheme.bodyStyle.copyWith(fontSize: 12, color: AppTheme.textSecondaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profil Bilgileri Düzenleme
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefon',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: 'yusuftokay019@gmail.com',
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveProfile();
                              }
                            },
                            child: const Text('Profili Kaydet'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Adresler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Adreslerim', style: AppTheme.textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Mevcut Konumu Ekle',
                      ),
                    ],
                  ),
                  ...addresses.asMap().entries.map((entry) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.green),
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeAddress(entry.key),
                      ),
                    ),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Yeni Adres',
                            prefixIcon: Icon(Icons.add_location_alt),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: _addAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sipariş Geçmişi
                  Text('Sipariş Geçmişim', style: AppTheme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('userId', isEqualTo: user?.uid)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('Henüz siparişiniz yok.');
                      }
                      final orders = snapshot.data!.docs;
                      return Column(
                        children: orders.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? 'pending';
                          return ListTile(
                            title: Text('Sipariş: ${doc.id}'),
                            subtitle: Text('Tutar: ${data['total'] ?? '-'} TL'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: status == 'approved' ? Colors.green.withOpacity(0.1)
                                    : status == 'rejected' ? Colors.red.withOpacity(0.1)
                                    : status == 'cancelled' ? Colors.red.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status == 'approved' ? 'Onaylandı'
                                  : status == 'rejected' ? 'Reddedildi'
                                  : status == 'cancelled' ? 'İptal Edildi'
                                  : 'Beklemede',
                                style: TextStyle(
                                  color: status == 'approved' ? Colors.green
                                      : status == 'rejected' ? Colors.red
                                      : status == 'cancelled' ? Colors.red
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
} 