import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderManagement extends StatefulWidget {
  @override
  _OrderManagementState createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  String _selectedStatus = 'Tümü';
  final List<String> _statuses = ['Tümü', 'Beklemede', 'Hazırlanıyor', 'Tamamlandı', 'İptal Edildi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Yönetimi'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Durum Filtresi',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return Center(child: Text('Sipariş bulunamadı'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Text('Sipariş #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          'Tarih: ${DateFormat('dd/MM/yyyy HH:mm').format((order['createdAt'] as Timestamp).toDate())}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Müşteri: ${order['customerName']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text('Sipariş Detayları:'),
                                ...(order['items'] as List).map((item) => Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item['name']} x${item['quantity']}'),
                                      Text('${item['price']} TL'),
                                    ],
                                  ),
                                )).toList(),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Toplam Tutar:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${order['totalAmount']} TL',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order['status']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusText(order['status']),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) => _updateOrderStatus(order.id, value),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'pending',
                                          child: Text('Beklemede'),
                                        ),
                                        PopupMenuItem(
                                          value: 'preparing',
                                          child: Text('Hazırlanıyor'),
                                        ),
                                        PopupMenuItem(
                                          value: 'completed',
                                          child: Text('Tamamlandı'),
                                        ),
                                        PopupMenuItem(
                                          value: 'cancelled',
                                          child: Text('İptal Et'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    Query query = FirebaseFirestore.instance.collection('orders')
        .orderBy('createdAt', descending: true);

    if (_selectedStatus != 'Tümü') {
      query = query.where('status', isEqualTo: _getStatusValue(_selectedStatus));
    }

    return query.snapshots();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'preparing':
        return 'Hazırlanıyor';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  String _getStatusValue(String status) {
    switch (status) {
      case 'Beklemede':
        return 'pending';
      case 'Hazırlanıyor':
        return 'preparing';
      case 'Tamamlandı':
        return 'completed';
      case 'İptal Edildi':
        return 'cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 