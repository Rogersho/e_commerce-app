// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  userId: json['user_id'] as String,
  status: json['status'] as String? ?? 'pending',
  totalAmount: (json['total_amount'] as num).toDouble(),
  shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  phoneNumber: json['phone_number'] as String?,
  paymentMethod: json['payment_method'] as String? ?? 'cash_on_delivery',
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'user_id': instance.userId,
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'shipping_address': instance.shippingAddress,
      'payment_status': instance.paymentStatus,
      'phone_number': instance.phoneNumber,
      'payment_method': instance.paymentMethod,
    };

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: (json['id'] as num).toInt(),
      orderId: (json['order_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'price': instance.price,
    };
