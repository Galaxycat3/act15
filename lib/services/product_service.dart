import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  Future<void> createProduct(Product product) async {
    await _products.add(product.toMap());
  }

  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromDocument(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (doc.exists) {
      return Product.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
