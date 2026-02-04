import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/loader.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../order/data/order_repository_impl.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPlacingOrder = false;
  String _paymentMethod = 'cash_on_delivery';

  final List<Map<String, String>> _paymentMethods = [
    {'id': 'cash_on_delivery', 'label': 'Cash on Delivery', 'icon': 'money'},
    {'id': 'mobile_money', 'label': 'Mobile Money', 'icon': 'phone_android'},
    {'id': 'card', 'label': 'Credit/Debit Card', 'icon': 'credit_card'},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartItems = ref.read(cartControllerProvider).asData?.value ?? [];
    if (cartItems.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    final total = ref.read(cartTotalProvider);
    final address = {
      'street': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'zip': _zipController.text.trim(),
    };

    final items = cartItems
        .map(
          (item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          },
        )
        .toList();

    final result = await ref
        .read(orderRepositoryProvider)
        .createOrder(
          totalAmount: total,
          shippingAddress: address,
          items: items,
          phoneNumber: _phoneController.text.trim(),
          paymentMethod: _paymentMethod,
        );

    setState(() => _isPlacingOrder = false);

    result.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.message))),
      (r) {
        ref.read(cartControllerProvider.notifier).clearCart();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed!'),
            content: const Text('Your order has been placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.go('/');
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Checkout'),
      ),
      body: _isPlacingOrder
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: TextFormField(
                            controller: _zipController,
                            decoration: const InputDecoration(
                              labelText: 'ZIP Code',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const Gap(32),
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Gap(8),
                    ..._paymentMethods.map(
                      (method) => RadioListTile<String>(
                        title: Text(method['label']!),
                        value: method['id']!,
                        groupValue: _paymentMethod,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _paymentMethod = val);
                          }
                        },
                      ),
                    ),
                    const Gap(32),
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _placeOrder,
                        child: const Text('Place Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
