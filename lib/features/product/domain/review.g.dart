// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  productId: (json['product_id'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  userFullName: json['full_name'] as String?,
);

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'product_id': instance.productId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt?.toIso8601String(),
      'full_name': instance.userFullName,
    };
