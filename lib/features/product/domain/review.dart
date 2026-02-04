import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
class Review with _$Review {
  factory Review({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'product_id') required int productId,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'full_name') String? userFullName,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
