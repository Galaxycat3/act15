class Product {
  final String id;
  final String name;
  final double price;
  final int stock; // optional: used for Low/In Stock filter

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
    };
  }

  factory Product.fromDocument(Map<String, dynamic> doc, String id) {
    return Product(
      id: id,
      name: doc['name'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      stock: (doc['stock'] ?? 10).toInt(),
    );
  }
}
