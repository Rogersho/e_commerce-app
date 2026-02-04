import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart'; // import printing
import 'package:pdf/widgets.dart' as pw; // import pdf widgets
import '../../../../core/widgets/loader.dart';
import '../../domain/order.dart';
import '../../../auth/domain/profile.dart'; // Import Profile
import '../../../product/domain/product.dart'; // Import Product
import '../../services/invoice_service.dart'; // Import InvoiceService

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late Future<Map<String, dynamic>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    final supabase = Supabase.instance.client;

    final orderData = await supabase
        .from('orders')
        .select('*')
        .eq('id', widget.orderId)
        .single();

    final itemsData = await supabase
        .from('order_items')
        .select('*, products(name, images)')
        .eq('order_id', widget.orderId);

    return {'order': orderData, 'items': itemsData};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Track Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download Invoice',
            onPressed: () => _downloadInvoice(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final order = data['order'];
          final items = data['items'] as List;
          final status = order['status'] as String;
          final address = order['shipping_address'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusTracker(status),
                const Gap(32),
                _buildSection('Shipping Information', [
                  Text(
                    '${address?['street'] ?? ''}, ${address?['city'] ?? ''} ${address?['zip'] ?? ''}',
                  ),
                  const Gap(4),
                  Text('Phone: ${order['phone_number'] ?? 'N/A'}'),
                ]),
                const Divider(height: 32),
                _buildSection('Payment Info', [
                  Text(
                    'Method: ${(order['payment_method'] ?? 'cash_on_delivery').toString().replaceAll('_', ' ').toUpperCase()}',
                  ),
                  Text(
                    'Status: ${order['payment_status']?.toUpperCase() ?? 'UNPAID'}',
                  ),
                ]),
                const Divider(height: 32),
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                ...items.map((item) {
                  final product = item['products'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        product['images'] != null &&
                            (product['images'] as List).isNotEmpty
                        ? Image.network(
                            product['images'][0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(product['name']),
                    subtitle: Text('Qty: ${item['quantity']}'),
                    trailing: Text(
                      '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                    ),
                  );
                }),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${order['total_amount']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Gap(40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTracker(String currentStatus) {
    final stages = ['pending', 'processing', 'shipped', 'delivered'];
    final currentIndex = stages.indexOf(currentStatus);

    if (currentStatus == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            Gap(12),
            Text(
              'This order has been cancelled.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            final isCompleted = index <= currentIndex;
            return Column(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                const Gap(4),
                Text(
                  stages[index].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            );
          }),
        ),
        const Gap(16),
        LinearProgressIndicator(
          value: (currentIndex + 1) / stages.length,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Gap(8),
        ...children,
      ],
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      final data = await _orderDetailsFuture;
      final orderMap = data['order'];
      final itemsMap = data['items'] as List;

      final items = itemsMap
          .map(
            (i) => OrderItem(
              id: i['id'],
              orderId: i['order_id'],
              productId: i['product_id'],
              quantity: i['quantity'],
              price: i['price'].toDouble(),
              product: Product.fromJson(i['products']),
            ),
          )
          .toList();

      final order = Order(
        id: orderMap['id'],
        userId: orderMap['user_id'],
        status: orderMap['status'],
        totalAmount: orderMap['total_amount'].toDouble(),
        createdAt: DateTime.parse(orderMap['created_at']),
        items: items,
        shippingAddress: orderMap['shipping_address'] != null
            ? Map<String, dynamic>.from(orderMap['shipping_address'])
            : null,
        phoneNumber: orderMap['phone_number'],
      );

      final supabase = Supabase.instance.client;
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', order.userId)
          .single();
      final profile = Profile.fromJson(profileData);

      final pdfBytes = await InvoiceService().generateInvoice(order, profile);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'invoice_${order.id}.pdf',
      );
    } catch (e) {
      debugPrint('Error generating invoice: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate invoice: $e')),
        );
      }
    }
  }
}
