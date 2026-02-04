import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loader.dart';

class AdminOrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState
    extends ConsumerState<AdminOrderDetailsScreen> {
  late Future<Map<String, dynamic>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    final supabase = Supabase.instance.client;

    // Fetch order with user profile
    final orderData = await supabase
        .from('orders')
        .select(
          '*, profiles(full_name, email:id)',
        ) // email is actually in auth.users, but we can display user_id or join profiles
        .eq('id', widget.orderId)
        .single();

    // Fetch order items with product names
    final itemsData = await supabase
        .from('order_items')
        .select('*, products(name, images)')
        .eq('order_id', widget.orderId);

    return {'order': orderData, 'items': itemsData};
  }

  Future<void> _updateStatus(String status) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': status})
          .eq('id', widget.orderId);

      setState(() {
        _orderDetailsFuture = _fetchOrderDetails();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('Order Details #${widget.orderId}'),
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
          final profile = order['profiles'];
          final address = order['shipping_address'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Customer Details', [
                  _buildDetailRow('Name', profile?['full_name'] ?? 'N/A'),
                  _buildDetailRow('Phone', order['phone_number'] ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildSection('Shipping Address', [
                  _buildDetailRow('Street', address?['street'] ?? 'N/A'),
                  _buildDetailRow('City', address?['city'] ?? 'N/A'),
                  _buildDetailRow('ZIP', address?['zip'] ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildSection('Payment & Summary', [
                  _buildDetailRow(
                    'Payment Method',
                    (order['payment_method'] ?? 'cash_on_delivery')
                        .toString()
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                  ),
                  _buildDetailRow(
                    'Payment Status',
                    order['payment_status']?.toUpperCase() ?? 'UNPAID',
                  ),
                  _buildDetailRow(
                    'Total Amount',
                    '\$${order['total_amount']}',
                    isBold: true,
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
                    subtitle: Text(
                      'Qty: ${item['quantity']} x \$${item['price']}',
                    ),
                    trailing: Text(
                      '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                    ),
                  );
                }),
                const Divider(height: 32),
                const Text(
                  'Order Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(12),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        'pending',
                        'processing',
                        'shipped',
                        'delivered',
                        'cancelled',
                      ].map((status) {
                        final isSelected = order['status'] == status;
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val && !isSelected) {
                              _updateStatus(status);
                            }
                          },
                        );
                      }).toList(),
                ),
                const Gap(40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Gap(12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
