import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  factory Product({
    required int id,
    required String name,
    String? description,
    required double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
    required int stock,
    @JsonKey(name: 'category_id') int? categoryId,
    List<String>? images,
    String? brand,
    @Default(0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
