import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/type_defs.dart';
import '../domain/order.dart';
import '../domain/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(supabase: Supabase.instance.client);
});

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _supabase;

  OrderRepositoryImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  FutureEither<Order> createOrder({
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      // 1. Create Order
      final orderData = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'total_amount': totalAmount,
            'shipping_address': shippingAddress,
            'phone_number': phoneNumber,
            'payment_method': paymentMethod,
            'status': 'pending',
            'payment_status': 'unpaid',
          })
          .select()
          .single();

      final order = Order.fromJson(orderData);

      // 2. Create Order Items
      final itemsToInsert = items
          .map(
            (item) => {
              'order_id': order.id,
              'product_id': item['product_id'],
              'quantity': item['quantity'],
              'price': item['price'],
            },
          )
          .toList();

      await _supabase.from('order_items').insert(itemsToInsert);

      return right(order);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<List<Order>> getMyOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      final data = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final orders = (data as List).map((e) => Order.fromJson(e)).toList();
      return right(orders);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      final data = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);
      final items = (data as List).map((e) => OrderItem.fromJson(e)).toList();
      return right(items);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
