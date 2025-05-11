import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qrData = 'amida-restaurant-user-login';
    return Scaffold(
      appBar: AppBar(title: Text('Giriş QR Kodu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 24),
            Text(
              'Bu QR kodu uygulama giriş ekranında okutarak giriş yapabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 