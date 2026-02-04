// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_price')
  double? get discountPrice => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  int? get categoryId => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
    int stock,
    @JsonKey(name: 'category_id') int? categoryId,
    List<String>? images,
    String? brand,
    double rating,
    @JsonKey(name: 'review_count') int reviewCount,
    @JsonKey(name: 'is_featured') bool isFeatured,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? discountPrice = freezed,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? images = freezed,
    Object? brand = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isFeatured = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPrice: freezed == discountPrice
                ? _value.discountPrice
                : discountPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int?,
            images: freezed == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
    int stock,
    @JsonKey(name: 'category_id') int? categoryId,
    List<String>? images,
    String? brand,
    double rating,
    @JsonKey(name: 'review_count') int reviewCount,
    @JsonKey(name: 'is_featured') bool isFeatured,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? discountPrice = freezed,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? images = freezed,
    Object? brand = freezed,
    Object? rating = null,
    Object? reviewCount = null,
    Object? isFeatured = null,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPrice: freezed == discountPrice
            ? _value.discountPrice
            : discountPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int?,
        images: freezed == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl implements _Product {
  _$ProductImpl({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    @JsonKey(name: 'discount_price') this.discountPrice,
    required this.stock,
    @JsonKey(name: 'category_id') this.categoryId,
    final List<String>? images,
    this.brand,
    this.rating = 0,
    @JsonKey(name: 'review_count') this.reviewCount = 0,
    @JsonKey(name: 'is_featured') this.isFeatured = false,
  }) : _images = images;

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  @JsonKey(name: 'discount_price')
  final double? discountPrice;
  @override
  final int stock;
  @override
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? brand;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, price: $price, discountPrice: $discountPrice, stock: $stock, categoryId: $categoryId, images: $images, brand: $brand, rating: $rating, reviewCount: $reviewCount, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    discountPrice,
    stock,
    categoryId,
    const DeepCollectionEquality().hash(_images),
    brand,
    rating,
    reviewCount,
    isFeatured,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  factory _Product({
    required final int id,
    required final String name,
    final String? description,
    required final double price,
    @JsonKey(name: 'discount_price') final double? discountPrice,
    required final int stock,
    @JsonKey(name: 'category_id') final int? categoryId,
    final List<String>? images,
    final String? brand,
    final double rating,
    @JsonKey(name: 'review_count') final int reviewCount,
    @JsonKey(name: 'is_featured') final bool isFeatured,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  @JsonKey(name: 'discount_price')
  double? get discountPrice;
  @override
  int get stock;
  @override
  @JsonKey(name: 'category_id')
  int? get categoryId;
  @override
  List<String>? get images;
  @override
  String? get brand;
  @override
  double get rating;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
