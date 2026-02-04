import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loader.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../../../product/domain/product.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Add Product', icon: Icon(Icons.add_box)),
            Tab(text: 'Manage Products', icon: Icon(Icons.inventory)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_bag)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductForm(),
          ManageProductsView(),
          ManageOrdersView(),
        ],
      ),
    );
  }
}

class ProductForm extends ConsumerStatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isFeatured = false;
  final List<XFile> _pickedImages = [];
  final Map<String, Uint8List> _imageBytes = {};
  final List<String> _existingImages = []; // For editing
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _brandController.text = widget.product!.brand ?? '';
      _isFeatured = widget.product!.isFeatured;
      if (widget.product!.images != null) {
        _existingImages.addAll(widget.product!.images!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var image in images) {
          final bytes = await image.readAsBytes();
          _imageBytes[image.path] = bytes;
        }
        setState(() {
          _pickedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];
    final supabase = Supabase.instance.client;

    for (var image in _pickedImages) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final path = 'products/$fileName';
      final bytes = _imageBytes[image.path]!;

      await supabase.storage
          .from('products')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final url = supabase.storage.from('products').getPublicUrl(path);
      imageUrls.add(url);
    }
    return imageUrls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImages.isEmpty && _existingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newImageUrls = await _uploadImages();
      final allImages = [..._existingImages, ...newImageUrls];
      final supabase = Supabase.instance.client;

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'brand': _brandController.text.trim(),
        'images': allImages,
        'is_featured': _isFeatured,
      };

      if (widget.product == null) {
        // Insert
        await supabase.from('products').insert(productData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        _resetForm();
      } else {
        // Update
        await supabase
            .from('products')
            .update(productData)
            .eq('id', widget.product!.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        // If inside a navigation stack (Edit screen), pop.
        if (context.canPop()) {
          context.pop();
        }
      }

      // Refresh providers to ensure UI updates immediately
      ref.invalidate(productsProvider);
      ref.invalidate(featuredProductsProvider);
      ref.invalidate(productsStreamProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();
    _brandController.clear();
    setState(() {
      _pickedImages.clear();
      _imageBytes.clear();
      _existingImages.clear();
      _isFeatured = false;
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Loader();
    final isEditing = widget.product != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Gap(24),

            // Image Picker Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Images',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Images'),
                ),
              ],
            ),
            const Gap(8),
            SizedBox(
              height: 120,
              child: (_pickedImages.isEmpty && _existingImages.isEmpty)
                  ? Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: Colors.grey),
                            Text(
                              'No images selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Existing Images
                        ..._existingImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final url = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingImage(index),
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // New Picked Images
                        ..._pickedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          final bytes = _imageBytes[image.path];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: bytes != null
                                      ? Image.memory(
                                          bytes,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey,
                                        ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _pickedImages.removeAt(index);
                                      _imageBytes.remove(image.path);
                                    }),
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            const Gap(24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const Gap(16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Gap(16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),

            // Featured Toggle
            SwitchListTile(
              title: const Text('Set as Featured Product'),
              subtitle: const Text(
                'Featured products appear in the home carousel',
              ),
              value: _isFeatured,
              onChanged: (val) => setState(() => _isFeatured = val),
            ),

            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saveProduct,
                child: Text(isEditing ? 'Update Product' : 'Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageProductsView extends ConsumerWidget {
  const ManageProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return productsAsync.when(
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  product.images != null && product.images!.isNotEmpty
                  ? NetworkImage(product.images!.first)
                  : null,
            ),
            title: Text(product.name),
            subtitle: Text('\$${product.price} - Stock: ${product.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editProduct(context, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(context, ref, product.id),
                ),
              ],
            ),
          );
        },
      ),
      loading: () => const Loader(),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _editProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Edit Product')),
          body: ProductForm(product: product),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.from('products').delete().eq('id', id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product deleted')));
        }
        // Refresh providers
        ref.invalidate(productsProvider);
        ref.invalidate(featuredProductsProvider);
        ref.invalidate(productsStreamProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }
}

class ManageOrdersView extends ConsumerStatefulWidget {
  const ManageOrdersView({super.key});

  @override
  ConsumerState<ManageOrdersView> createState() => _ManageOrdersViewState();
}

class _ManageOrdersViewState extends ConsumerState<ManageOrdersView> {
  @override
  Widget build(BuildContext context) {
    // We'll fetch all orders here
    final supabase = Supabase.instance.client;
    final ordersStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ordersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(order['status']),
                child: const Icon(Icons.shopping_bag, color: Colors.white),
              ),
              title: Text('Order #${order['id']}'),
              subtitle: Text(
                'Status: ${order['status']}\nTotal: \$${order['total_amount']}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/admin/order/${order['id']}');
              },
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
