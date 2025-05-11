import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  final double balance = 250.75; // Örnek bakiye
  final List<String> coupons = [
    '10 TL İndirim Kuponu',
    'Ücretsiz Kargo',
    '2 Al 1 Öde',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cüzdanım')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bakiye', style: Theme.of(context).textTheme.titleLarge),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor),
                title: Text('${balance.toStringAsFixed(2)} TL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                subtitle: Text('Kullanılabilir Bakiye'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Kuponlarım', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: coupons.isEmpty
                  ? Center(child: Text('Hiç kuponunuz yok.'))
                  : ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: Icon(Icons.card_giftcard, color: Theme.of(context).primaryColor),
                          title: Text(coupons[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 