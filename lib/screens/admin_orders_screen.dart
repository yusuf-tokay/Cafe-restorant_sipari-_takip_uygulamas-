import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Yönetimi'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz sipariş yok.'));
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sipariş: ${order.id.substring(0, 8)}', style: AppTheme.textTheme.titleMedium),
                          Text(order['userName'] ?? order['userEmail'] ?? '', style: AppTheme.textTheme.bodyMedium),
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
                      Text('Ad: ${order['userName'] ?? ''}'),
                      Text('Masa No: ${order['tableNumber'] ?? '-'}'),
                      Text('Adres: ${order['address'] ?? ''}'),
                      Text('Telefon: ${order['phone'] ?? ''}'),
                      Text('Toplam: ${order['total']?.toStringAsFixed(2) ?? ''} TL'),
                      const SizedBox(height: 8),
                      Text('Ürünler:', style: AppTheme.textTheme.bodyMedium),
                      ...((order['cart'] as List).map((item) => Text('- ${item['name']} x${item['quantity']}')).toList()),
                      const SizedBox(height: 12),
                      if (status == 'pending')
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => updateOrderStatus(order.id, 'approved'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Onayla'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => updateOrderStatus(order.id, 'rejected'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Reddet'),
                            ),
                          ],
                        ),
                    ],
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