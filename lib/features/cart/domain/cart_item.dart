import 'package:freezed_annotation/freezed_annotation.dart';
import '../../product/domain/product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  factory CartItem({
    required int id,
    required Product product,
    required int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
