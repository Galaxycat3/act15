import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/product_service.dart';
import 'widgets/product_list.dart';

class YourClassActivity extends StatefulWidget {
  const YourClassActivity({Key? key}) : super(key: key);

  @override
  State<YourClassActivity> createState() => _YourClassActivityState();
}

class _YourClassActivityState extends State<YourClassActivity> {
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  String _searchQuery = '';
  final Set<String> _selectedProductIds = {};
  bool _bulkMode = false;

  Future<void> _createOrEditProduct([Product? product]) async {
    final isEdit = product != null;
    if (isEdit) {
      _nameController.text = product.name;
      _priceController.text = product.price.toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text(isEdit ? 'Update' : 'Create'),
              onPressed: () async {
                final name = _nameController.text.trim();
                final price = double.tryParse(_priceController.text.trim());
                if (name.isNotEmpty && price != null) {
                  if (isEdit) {
                    await _productService.updateProduct(Product(id: product!.id, name: name, price: price));
                  } else {
                    await _productService.createProduct(Product(id: '', name: name, price: price));
                  }
                  _nameController.clear();
                  _priceController.clear();
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSelected() async {
    for (var id in _selectedProductIds) {
      await _productService.deleteProduct(id);
    }
    setState(() {
      _selectedProductIds.clear();
      _bulkMode = false;
    });
  }

  Future<void> _updateSelectedPrices(double increment) async {
    for (var id in _selectedProductIds) {
      final product = await _productService.getProductById(id);
      if (product != null) {
        await _productService.updateProduct(Product(id: product.id, name: product.name, price: product.price + increment));
      }
    }
    setState(() {
      _selectedProductIds.clear();
      _bulkMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          if (_bulkMode)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteSelected),
          if (_bulkMode)
            IconButton(icon: const Icon(Icons.attach_money), onPressed: () => _updateSelectedPrices(1.0)),
          IconButton(
            icon: Icon(_bulkMode ? Icons.cancel : Icons.select_all),
            onPressed: () => setState(() {
              _bulkMode = !_bulkMode;
              _selectedProductIds.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search)),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
              ],
              onChanged: (val) => setState(() => _selectedFilter = val!),
            ),
          ),
          Expanded(
            child: ProductList(
              productService: _productService,
              onEdit: _createOrEditProduct,
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
              bulkMode: _bulkMode,
              selectedIds: _selectedProductIds,
              onToggleSelect: (id) => setState(() {
                if (_selectedProductIds.contains(id)) _selectedProductIds.remove(id);
                else _selectedProductIds.add(id);
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: !_bulkMode
          ? FloatingActionButton(onPressed: () => _createOrEditProduct(), child: const Icon(Icons.add))
          : null,
    );
  }
}
