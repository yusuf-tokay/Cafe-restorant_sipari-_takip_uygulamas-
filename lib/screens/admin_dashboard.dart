import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin/menu_management.dart';
import 'admin/reservation_management.dart';
import 'admin/order_management.dart';
import 'admin/staff_management.dart';
import 'admin/inventory_management.dart';
import 'admin/reports.dart';
import 'home_screen.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Yönetici Paneli'),
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Çıkış yapılırken bir hata oluştu')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.home),
            tooltip: 'Uygulamaya Geç',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDashboardItem(
            context,
            'Menü Yönetimi',
            Icons.restaurant_menu,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuManagement()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            'Rezervasyon Yönetimi',
            Icons.calendar_today,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationManagement()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            'Sipariş Yönetimi',
            Icons.shopping_cart,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderManagement()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            'Personel Yönetimi',
            Icons.people,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StaffManagement()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            'Stok Takibi',
            Icons.inventory,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryManagement()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            'Raporlar',
            Icons.bar_chart,
            Colors.red[900]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Reports()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 