import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_screen.dart';
import '../providers/order_provider.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişlerim'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Giriş yapmalısınız.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz siparişiniz yok.'));
                }
                final orders = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status'] ?? 'pending';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(orderId: order.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sipariş: ${order.id.substring(0, 8)}', style: AppTheme.textTheme.titleMedium),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: status == 'approved' ? Colors.green.withOpacity(0.1)
                                          : status == 'rejected' ? Colors.red.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status == 'approved' ? 'Onaylandı'
                                        : status == 'rejected' ? 'Reddedildi'
                                        : 'Beklemede',
                                      style: TextStyle(
                                        color: status == 'approved' ? Colors.green
                                            : status == 'rejected' ? Colors.red
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Adres: ${order['address'] ?? ''}'),
                              Text('Masa No: ${order['tableNumber'] ?? '-'}'),
                              Text('Toplam: ${order['total']?.toStringAsFixed(2) ?? ''} TL'),
                              const SizedBox(height: 8),
                              Text('Ürünler:', style: AppTheme.textTheme.bodyMedium),
                              ...((order['cart'] as List).map((item) => Text('- ${item['name']} x${item['quantity']}')).toList()),
                              if (status == 'pending')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance.collection('orders').doc(order.id).update({'status': 'cancelled'});
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş iptal edildi.')));
                                    },
                                    child: const Text('İptal Et', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 