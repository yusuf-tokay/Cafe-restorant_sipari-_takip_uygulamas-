import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../providers/table_provider.dart';
import '../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final tableNumberController = TextEditingController();
    final cardController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryLinearGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sepetim',
                      style: AppTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Ana İçerik
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      if (cartProvider.items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: AppTheme.primaryColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sepetiniz boş',
                                style: AppTheme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Menüden ürün ekleyerek alışverişe başlayın',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Sepet Ürünleri
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: cartProvider.items.length,
                              itemBuilder: (context, index) {
                                final item = cartProvider.items[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Ürün Resmi
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            item.imageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Ürün Bilgileri
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: AppTheme.textTheme.titleSmall,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item.price.toStringAsFixed(2)} TL',
                                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (item.extras != null && item.extras!.isNotEmpty)
                                                Text('Ekstralar: ${item.extras!.join(", ")}', style: AppTheme.textTheme.bodySmall),
                                            ],
                                          ),
                                        ),
                                        // Miktar Kontrolü
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                color: AppTheme.primaryColor,
                                              ),
                                              onPressed: () {
                                                cartProvider.decreaseQuantity(item.productId);
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: AppTheme.textTheme.titleMedium,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: AppTheme.primaryColor,
                                              ),
                                              onPressed: () {
                                                cartProvider.increaseQuantity(item.productId);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Ödeme Formu ve Siparişi Onayla
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Teslimat ve Ödeme Bilgileri', style: AppTheme.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: nameController,
                                    decoration: const InputDecoration(labelText: 'Ad Soyad'),
                                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: addressController,
                                    decoration: const InputDecoration(labelText: 'Adres'),
                                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(labelText: 'Telefon'),
                                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: tableNumberController,
                                    decoration: const InputDecoration(labelText: 'Masa Numarası'),
                                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: cardController,
                                    decoration: const InputDecoration(labelText: 'Kart Numarası'),
                                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final user = FirebaseAuth.instance.currentUser;
                                          // Siparişi Firestore'a kaydet
                                          final order = {
                                            'userId': user?.uid,
                                            'userName': user?.displayName ?? nameController.text,
                                            'userEmail': user?.email,
                                            'address': addressController.text,
                                            'phone': phoneController.text,
                                            'tableNumber': tableNumberController.text,
                                            'cart': cartProvider.items.map((e) => {
                                              'productId': e.productId,
                                              'name': e.name,
                                              'quantity': e.quantity,
                                              'price': e.price,
                                              'imageUrl': e.imageUrl,
                                              'extras': e.extras,
                                            }).toList(),
                                            'total': cartProvider.totalPrice,
                                            'status': 'pending',
                                            'createdAt': FieldValue.serverTimestamp(),
                                          };
                                          await FirebaseFirestore.instance.collection('orders').add(order);
                                          cartProvider.clearCart();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Siparişiniz alındı!')),
                                          );
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        'Siparişi Onayla',
                                        style: AppTheme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 