import '../../../../core/utils/type_defs.dart';
import 'order.dart';

abstract class OrderRepository {
  FutureEither<Order> createOrder({
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    required String phoneNumber,
    required String paymentMethod,
  });

  FutureEither<List<Order>> getMyOrders();
  FutureEither<List<OrderItem>> getOrderItems(int orderId);
}
