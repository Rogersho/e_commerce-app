// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      stock: (json['stock'] as num).toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      brand: json['brand'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'discount_price': instance.discountPrice,
      'stock': instance.stock,
      'category_id': instance.categoryId,
      'images': instance.images,
      'brand': instance.brand,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'is_featured': instance.isFeatured,
    };
