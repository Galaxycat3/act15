import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductList extends StatelessWidget {
  final ProductService productService;
  final void Function(Product)? onEdit;
  final String searchQuery;
  final String selectedFilter;
  final bool bulkMode;
  final Set<String> selectedIds;
  final void Function(String id) onToggleSelect;

  const ProductList({
    Key? key,
    required this.productService,
    this.onEdit,
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.bulkMode = false,
    required this.selectedIds,
    required this.onToggleSelect,
  }) : super(key: key);

  bool _matchesFilter(Product product) {
    if (selectedFilter == 'Low Stock' && product.stock > 5) return false;
    if (selectedFilter == 'In Stock' && product.stock <= 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: productService.getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var products = snapshot.data!
            .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .where(_matchesFilter)
            .toList();

        if (products.isEmpty) return const Center(child: Text('No products found.'));

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final selected = selectedIds.contains(product.id);

            return ListTile(
              leading: bulkMode
                  ? Checkbox(
                      value: selected,
                      onChanged: (_) => onToggleSelect(product.id),
                    )
                  : null,
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
              trailing: !bulkMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEdit?.call(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => productService.deleteProduct(product.id),
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
