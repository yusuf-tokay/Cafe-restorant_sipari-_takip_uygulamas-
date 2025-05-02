import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Kullanıcı Paneli'),
        backgroundColor: Colors.red[900],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDashboardItem(
            context,
            'Menü',
            Icons.restaurant_menu,
            Colors.red[900]!,
            () {
              // Menü sayfasına yönlendir
            },
          ),
          _buildDashboardItem(
            context,
            'Rezervasyon',
            Icons.calendar_today,
            Colors.red[900]!,
            () {
              // Rezervasyon sayfasına yönlendir
            },
          ),
          _buildDashboardItem(
            context,
            'Siparişlerim',
            Icons.shopping_cart,
            Colors.red[900]!,
            () {
              // Siparişlerim sayfasına yönlendir
            },
          ),
          _buildDashboardItem(
            context,
            'Profilim',
            Icons.person,
            Colors.red[900]!,
            () {
              // Profil sayfasına yönlendir
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
            ),
          ],
        ),
      ),
    );
  }
} 