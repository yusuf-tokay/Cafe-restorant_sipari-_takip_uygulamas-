class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isOnSale;
  final double? salePrice;
  bool isFavorite;
  final List<String> ingredients;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isOnSale = false,
    this.salePrice,
    this.isFavorite = false,
    required this.ingredients,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isOnSale: json['isOnSale'] as bool,
      salePrice: json['salePrice'] as double?,
      isFavorite: json['isFavorite'] as bool,
      ingredients: List<String>.from(json['ingredients'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isOnSale': isOnSale,
      'salePrice': salePrice,
      'isFavorite': isFavorite,
      'ingredients': ingredients,
    };
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
} 