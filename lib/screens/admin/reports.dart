import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'Günlük Satışlar';
  final List<String> _reportTypes = [
    'Günlük Satışlar',
    'Kategori Bazlı Satışlar',
    'En Çok Satan Ürünler',
    'Rezervasyon İstatistikleri'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raporlar'),
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
                    value: _selectedReportType,
                    items: _reportTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedReportType = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Rapor Tipi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: Icon(Icons.date_range),
                  label: Text('Tarih Aralığı'),
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
              stream: _getReportData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return _buildReportContent(snapshot.data!.docs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getReportData() {
    switch (_selectedReportType) {
      case 'Günlük Satışlar':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
            .snapshots();
      case 'Kategori Bazlı Satışlar':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
            .snapshots();
      case 'En Çok Satan Ürünler':
        return FirebaseFirestore.instance
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
            .snapshots();
      case 'Rezervasyon İstatistikleri':
        return FirebaseFirestore.instance
            .collection('reservations')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
            .snapshots();
      default:
        return FirebaseFirestore.instance.collection('orders').snapshots();
    }
  }

  Widget _buildReportContent(List<QueryDocumentSnapshot> docs) {
    switch (_selectedReportType) {
      case 'Günlük Satışlar':
        return _buildDailySalesChart(docs);
      case 'Kategori Bazlı Satışlar':
        return _buildCategorySalesChart(docs);
      case 'En Çok Satan Ürünler':
        return _buildTopSellingProducts(docs);
      case 'Rezervasyon İstatistikleri':
        return _buildReservationStats(docs);
      default:
        return Center(child: Text('Rapor bulunamadı'));
    }
  }

  Widget _buildDailySalesChart(List<QueryDocumentSnapshot> docs) {
    Map<DateTime, double> dailySales = {};
    
    for (var doc in docs) {
      DateTime date = (doc['createdAt'] as Timestamp).toDate();
      date = DateTime(date.year, date.month, date.day);
      double total = doc['totalAmount'] ?? 0;
      
      dailySales[date] = (dailySales[date] ?? 0) + total;
    }

    List<FlSpot> spots = [];
    int index = 0;
    dailySales.forEach((date, total) {
      spots.add(FlSpot(index.toDouble(), total));
      index++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Günlük Satış Grafiği',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.red[900],
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySalesChart(List<QueryDocumentSnapshot> docs) {
    Map<String, double> categorySales = {};
    
    for (var doc in docs) {
      List<dynamic> items = doc['items'] ?? [];
      for (var item in items) {
        String category = item['category'] ?? 'Diğer';
        double price = (item['price'] ?? 0) * (item['quantity'] ?? 1);
        categorySales[category] = (categorySales[category] ?? 0) + price;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Kategori Bazlı Satışlar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: categorySales.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${entry.key}\n${entry.value.toStringAsFixed(2)} TL',
                    color: Colors.primaries[categorySales.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                    radius: 100,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingProducts(List<QueryDocumentSnapshot> docs) {
    Map<String, int> productSales = {};
    
    for (var doc in docs) {
      List<dynamic> items = doc['items'] ?? [];
      for (var item in items) {
        String name = item['name'] ?? 'Bilinmeyen Ürün';
        int quantity = item['quantity'] ?? 0;
        productSales[name] = (productSales[name] ?? 0) + quantity;
      }
    }

    var sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'En Çok Satan Ürünler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedProducts.length,
              itemBuilder: (context, index) {
                var product = sortedProducts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                    title: Text(product.key),
                    trailing: Text(
                      '${product.value} adet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationStats(List<QueryDocumentSnapshot> docs) {
    Map<String, int> statusCounts = {
      'Beklemede': 0,
      'Onaylandı': 0,
      'İptal Edildi': 0,
    };

    for (var doc in docs) {
      String status = _getStatusText(doc['status']);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Rezervasyon İstatistikleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: statusCounts.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.key}\n${entry.value}',
                    color: _getStatusColor(_getStatusValue(entry.key)),
                    radius: 100,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
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
} 