import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/favorite_provider.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final orders = Provider.of<OrderProvider>(context).orders;
    final favorites = Provider.of<FavoriteProvider>(context).favorites;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Hesabım',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[900]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kullanıcı Profil Kartı
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Misafir Kullanıcı',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user?.email ?? 'Giriş yapın',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Cüzdan ve Kuponlar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Cüzdanım',
                      subtitle: '₺150.00',
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.local_offer,
                      title: 'Kuponlarım',
                      subtitle: '3 Kupon',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Menü Seçenekleri
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Sipariş Geçmişi',
                    subtitle: '${orders.length} Sipariş',
                    onTap: () {
                      // Sipariş geçmişi sayfasına git
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'Favorilerim',
                    subtitle: '${favorites.length} Ürün',
                    onTap: () {
                      // Favoriler sayfasına git
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Adreslerim',
                    subtitle: '2 Adres',
                    onTap: () {
                      // Adresler sayfasına git
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Ödeme Yöntemlerim',
                    subtitle: '2 Kart',
                    onTap: () {
                      // Ödeme yöntemleri sayfasına git
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Ayarlar',
                    subtitle: 'Bildirimler, Dil, Tema',
                    onTap: () {
                      // Ayarlar sayfasına git
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Çıkış Yap Butonu
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue[900],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }
} 