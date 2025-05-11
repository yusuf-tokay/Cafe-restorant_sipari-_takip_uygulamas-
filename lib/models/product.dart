class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String>? categories;
  final List<String>? ingredients;
  final bool isAvailable;
  final bool isOnSale;
  final String category;
  bool isFavorite;
  final double? salePrice;
  final List<String>? extras;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categories = const [],
    this.ingredients = const [],
    this.isAvailable = true,
    this.isOnSale = false,
    required this.category,
    this.isFavorite = false,
    this.salePrice,
    this.extras = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories ?? [],
      'ingredients': ingredients ?? [],
      'isAvailable': isAvailable,
      'isOnSale': isOnSale,
      'category': category,
      'isFavorite': isFavorite,
      'salePrice': salePrice,
      'extras': extras ?? [],
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      imageUrl: map['imageUrl'] as String,
      categories: map['categories'] != null ? List<String>.from(map['categories'] as List) : [],
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients'] as List) : [],
      isAvailable: map['isAvailable'] as bool? ?? true,
      isOnSale: map['isOnSale'] as bool? ?? false,
      category: map['category'] as String,
      isFavorite: map['isFavorite'] as bool? ?? false,
      salePrice: map['salePrice'] as double?,
      extras: map['extras'] != null ? List<String>.from(map['extras'] as List) : [],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    List<String>? ingredients,
    bool? isAvailable,
    bool? isOnSale,
    String? category,
    bool? isFavorite,
    double? salePrice,
    List<String>? extras,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnSale: isOnSale ?? this.isOnSale,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      salePrice: salePrice ?? this.salePrice,
      extras: extras ?? this.extras,
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
} 