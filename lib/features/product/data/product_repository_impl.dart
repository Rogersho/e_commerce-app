import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/type_defs.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/review.dart';
import '../domain/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(supabase: Supabase.instance.client);
});

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _supabase;

  ProductRepositoryImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  FutureEither<List<Category>> getCategories() async {
    try {
      final data = await _supabase.from('categories').select().order('name');
      final categories = (data as List)
          .map((e) => Category.fromJson(e))
          .toList();
      return right(categories);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<List<Product>> getProducts({
    int? categoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? brand,
  }) async {
    try {
      var queryBuilder = _supabase.from('products').select();

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('name', '%$query%');
      }
      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price', minPrice);
      }
      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }
      if (brand != null) {
        queryBuilder = queryBuilder.eq('brand', brand);
      }

      final data = await queryBuilder.order('created_at', ascending: false);
      final products = (data as List).map((e) => Product.fromJson(e)).toList();
      return right(products);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<Product> getProductById(int id) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();
      return right(Product.fromJson(data));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<List<Product>> getFeaturedProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      final products = (data as List).map((e) => Product.fromJson(e)).toList();
      return right(products);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<Product>> getProductsStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => Product.fromJson(e)).toList());
  }

  @override
  FutureEither<List<Review>> getProductReviews(int productId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('*, profiles(full_name)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final reviews = (data as List).map((e) {
        final reviewMap = Map<String, dynamic>.from(e);
        if (e['profiles'] != null) {
          reviewMap['full_name'] = e['profiles']['full_name'];
        }
        return Review.fromJson(reviewMap);
      }).toList();

      return right(reviews);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<void> submitReview(Review review) async {
    try {
      await _supabase.from('reviews').upsert({
        'user_id': review.userId,
        'product_id': review.productId,
        'rating': review.rating,
        'comment': review.comment,
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
