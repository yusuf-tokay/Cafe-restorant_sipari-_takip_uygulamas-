import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Detayı'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Sipariş bulunamadı.'));
          }
          final order = snapshot.data!;
          final status = order['status'] ?? 'pending';
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
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
                const SizedBox(height: 16),
                Text('Adres: ${order['address'] ?? ''}'),
                Text('Telefon: ${order['phone'] ?? ''}'),
                Text('Masa No: ${order['tableNumber'] ?? '-'}'),
                Text('Toplam: ${order['total']?.toStringAsFixed(2) ?? ''} TL'),
                const SizedBox(height: 16),
                Text('Ürünler:', style: AppTheme.textTheme.titleMedium),
                ...((order['cart'] as List).map((item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('- ${item['name']} x${item['quantity']}'),
                    if (item['extras'] != null && (item['extras'] as List).isNotEmpty)
                      Text('  Ekstralar: ${(item['extras'] as List).join(", ")}'),
                  ],
                )).toList()),
              ],
            ),
          );
        },
      ),
    );
  }
} 