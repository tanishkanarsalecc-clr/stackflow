class Product {
  final String id;
  final String name;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final int stock;
  final int lowStockAlert;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    required this.stock,
    required this.lowStockAlert,
    this.imageUrl = '',
  });

  factory Product.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      sellingPrice:
      (map['sellingPrice'] ?? 0).toDouble(),
      costPrice:
      (map['costPrice'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      lowStockAlert:
      (map['lowStockAlert'] ?? 10).toInt(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'stock': stock,
      'lowStockAlert': lowStockAlert,
      'imageUrl': imageUrl,
    };
  }
}