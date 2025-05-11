class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;
  final List<String>? extras;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    this.extras = const [],
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    double? price,
    String? imageUrl,
    List<String>? extras,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      extras: extras ?? this.extras,
    );
  }
} 