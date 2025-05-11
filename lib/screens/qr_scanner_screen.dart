import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/table_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Kod'),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isGenerating)
              QrImageView(
                data: _controller.text,
                version: QrVersions.auto,
                size: 200.0,
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isGenerating = true;
                    _controller.text = DateTime.now().millisecondsSinceEpoch.toString();
                  });
                  // Masa/oturum bilgisini TableProvider ile kaydet
                  Provider.of<TableProvider>(context, listen: false)
                      .setTable(_controller.text);
                },
                child: Text('QR Kod Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            SizedBox(height: 20),
            if (_isGenerating)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                child: Text('Menüye Git'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 