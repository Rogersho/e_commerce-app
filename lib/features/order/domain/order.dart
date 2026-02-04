import 'package:freezed_annotation/freezed_annotation.dart';

import '../../product/domain/product.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  const Order._(); // Added for custom getters if needed

  factory Order({
    required int id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'user_id') required String userId,
    @Default('pending') String status,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'shipping_address') Map<String, dynamic>? shippingAddress,
    @JsonKey(name: 'payment_status') @Default('unpaid') String paymentStatus,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'payment_method')
    @Default('cash_on_delivery')
    String paymentMethod,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<OrderItem>? items,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();

  factory OrderItem({
    required int id,
    @JsonKey(name: 'order_id') required int orderId,
    @JsonKey(name: 'product_id') required int productId,
    required int quantity,
    required double price,
    @JsonKey(includeFromJson: false, includeToJson: false) Product? product,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
