import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationManagement extends StatefulWidget {
  @override
  _ReservationManagementState createState() => _ReservationManagementState();
}

class _ReservationManagementState extends State<ReservationManagement> {
  String _selectedStatus = 'Tümü';
  final List<String> _statuses = ['Tümü', 'Beklemede', 'Onaylandı', 'İptal Edildi'];
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rezervasyon Yönetimi'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
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
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getReservationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var reservations = snapshot.data!.docs;
                if (reservations.isEmpty) {
                  return Center(child: Text('Rezervasyon bulunamadı'));
                }

                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = reservations[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(reservation['customerName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tarih: ${DateFormat('dd/MM/yyyy').format((reservation['date'] as Timestamp).toDate())}'),
                            Text('Saat: ${reservation['time']}'),
                            Text('Kişi Sayısı: ${reservation['numberOfPeople']}'),
                            Text('Telefon: ${reservation['phone']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(reservation['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(reservation['status']),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) => _updateReservationStatus(reservation.id, value),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'pending',
                                  child: Text('Beklemede'),
                                ),
                                PopupMenuItem(
                                  value: 'approved',
                                  child: Text('Onayla'),
                                ),
                                PopupMenuItem(
                                  value: 'cancelled',
                                  child: Text('İptal Et'),
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
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getReservationsStream() {
    Query query = FirebaseFirestore.instance.collection('reservations')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)))
        .where('date', isLessThan: Timestamp.fromDate(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day + 1)));

    if (_selectedStatus != 'Tümü') {
      query = query.where('status', isEqualTo: _getStatusValue(_selectedStatus));
    }

    return query.snapshots();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'approved':
        return 'Onaylandı';
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
      case 'Onaylandı':
        return 'approved';
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
      case 'approved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateReservationStatus(String reservationId, String newStatus) async {
    await FirebaseFirestore.instance.collection('reservations').doc(reservationId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 