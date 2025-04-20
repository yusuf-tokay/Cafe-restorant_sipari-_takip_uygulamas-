import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  // Örnek sepet öğeleri (gerçek uygulamada provider veya bloc'tan gelecek)
  final List<CartItem> cartItems = [
    CartItem(
      id: '1',
      productId: '1',
      name: 'Karışık Pizza',
      quantity: 2,
      price: 120.0,
      imageUrl: 'https://example.com/pizza.jpg',
    ),
  ];

  CartScreen({Key? key}) : super(key: key);

  double get totalAmount {
    return cartItems.fold(0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Sepetiniz boş',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                // Sepet öğeleri listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          // TODO: Sepetten ürün silme işlemi
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} sepetten çıkarıldı'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item.imageUrl),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.restaurant),
                            ),
                            title: Text(item.name),
                            subtitle: Text('Toplam: ₺${item.total.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    // TODO: Ürün miktarını azalt
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    // TODO: Ürün miktarını artır
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Toplam tutar ve sipariş ver butonu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toplam Tutar:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₺${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Sipariş verme işlemi
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sipariş Onayı'),
                                content: const Text('Siparişinizi onaylıyor musunuz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Siparişiniz alındı!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context); // Sepet sayfasını kapat
                                    },
                                    child: const Text('Onayla'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Sipariş Ver',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 