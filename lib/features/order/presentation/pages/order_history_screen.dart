import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/loader.dart';
import '../../data/order_repository_impl.dart';
import '../../domain/order.dart';

final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getMyOrders();
  return result.fold((l) => throw l, (r) => r);
});

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    'Status: ${order.status.toUpperCase()}\nTotal: \$${order.totalAmount.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.go('/orders/${order.id}');
                  },
                ),
              );
            },
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Loader(),
      ),
    );
  }
}
