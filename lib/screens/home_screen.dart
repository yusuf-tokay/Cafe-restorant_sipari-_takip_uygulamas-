import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import 'settings_screen.dart';
import 'reservation_screen.dart';
import 'favorites_screen.dart';
import 'menu_screen.dart';
import 'my_orders_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import 'qr_scanner_screen.dart';
import '../theme/app_theme.dart';
import '../models/cart_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Tümü';
  final List<String> categories = [
    'Tümü',
    'Burger',
    'Pizza',
    'Salata',
    'Tatlı',
    'İçecek',
  ];

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 32, backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, color: Colors.white, size: 32)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Kullanıcı Adı', style: AppTheme.titleStyle),
                        IconButton(
                          icon: Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                      ],
                    ),
                    Text('mail@ornek.com', style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondaryColor)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(leading: Icon(Icons.receipt), title: Text('Siparişlerim'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/my-orders'); }),
            ListTile(leading: Icon(Icons.favorite), title: Text('Favorilerim'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/favorites'); }),
            ListTile(leading: Icon(Icons.location_on), title: Text('Adreslerim'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/addresses'); }),
            ListTile(leading: Icon(Icons.account_balance_wallet), title: Text('Cüzdanım'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/wallet'); }),
            ListTile(leading: Icon(Icons.logout), title: Text('Çıkış Yap'), onTap: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/login'); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final products = selectedCategory == 'Tümü'
        ? productService.products
        : productService.getProductsByCategory(selectedCategory);

    void _showProductDetail(Product product) {
      int quantity = 1;
      List<String> selectedExtras = [];
      final List<String> extraOptions = [
        'Ekstra Peynir',
        'Acı Sos',
        'Büyük Boy',
        'İçecek: Kola',
        'İçecek: Ayran',
      ];
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.imageUrl,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: 80, color: AppTheme.primaryColor.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(product.name, style: AppTheme.titleStyle),
                    const SizedBox(height: 8),
                    Text(product.description ?? '', style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondaryColor)),
                    const SizedBox(height: 16),
                    Text('${product.price.toStringAsFixed(2)} TL', style: AppTheme.bodyStyle.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('Ekstra Seçenekler', style: AppTheme.subtitleStyle),
                    ...extraOptions.map((extra) => CheckboxListTile(
                      title: Text(extra),
                      value: selectedExtras.contains(extra),
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selectedExtras.add(extra);
                          } else {
                            selectedExtras.remove(extra);
                          }
                        });
                      },
                    )),
                    const SizedBox(height: 8),
                    // Adet seçimi
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor),
                          onPressed: () {
                            if (quantity > 1) setModalState(() => quantity--);
                          },
                        ),
                        Text('$quantity', style: AppTheme.titleStyle),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                          onPressed: () => setModalState(() => quantity++),
                        ),
                        const Spacer(),
                        // Favorilere ekle
                        IconButton(
                          icon: Icon(Icons.favorite_border, color: AppTheme.primaryColor),
                          onPressed: () {
                            // Favorilere ekle işlemi (eklenebilir)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Favorilere eklendi')));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addItem(
                            CartItem(
                              id: DateTime.now().toString(),
                              productId: product.id,
                              name: product.name,
                              quantity: quantity,
                              price: product.price,
                              imageUrl: product.imageUrl,
                              extras: selectedExtras,
                            ),
                            quantity: quantity,
                            extras: selectedExtras,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} sepete eklendi')));
                        },
                        child: Text('Sepete Ekle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amida Restaurant'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryLinearGradient,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hoş Geldiniz', style: AppTheme.titleStyle.copyWith(color: Colors.white)),
                        Text('Lezzetli yemekler sizi bekliyor', style: AppTheme.bodyStyle.copyWith(color: Colors.white70)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showProfileModal(context),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.accentColor,
                        child: Icon(Icons.person, color: AppTheme.surfaceColor),
                      ),
                    ),
                  ],
                ),
              ),
              // Banner
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppTheme.secondaryLinearGradient,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image, size: 60, color: Colors.white24)),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Özel Menü', style: AppTheme.titleStyle.copyWith(color: Colors.white)),
                          Text('Bugünün özel menüsünü keşfedin', style: AppTheme.bodyStyle.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Kategoriler
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final selected = cat == selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: AppTheme.surfaceColor,
                        labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textPrimaryColor),
                        onSelected: (_) => setState(() => selectedCategory = cat),
                      );
                    },
                  ),
                ),
              ),
              // Ürünler
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: products.isEmpty
                      ? Center(child: Text('Bu kategoride ürün yok', style: AppTheme.bodyStyle))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                onTap: () => _showProductDetail(product),
                                contentPadding: const EdgeInsets.all(16),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: 40, color: AppTheme.primaryColor.withOpacity(0.3)),
                                  ),
                                ),
                                title: Text(product.name, style: AppTheme.subtitleStyle),
                                subtitle: Text('${product.price.toStringAsFixed(2)} TL', style: AppTheme.bodyStyle.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                trailing: IconButton(
                                  icon: Icon(Icons.add_circle, color: AppTheme.primaryColor),
                                  onPressed: () {
                                    _showProductDetail(product);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cartProvider.items.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartProvider.items.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
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