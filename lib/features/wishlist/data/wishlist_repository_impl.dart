import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/type_defs.dart';
import '../../product/domain/product.dart';
import '../domain/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(supabase: Supabase.instance.client);
});

class WishlistRepositoryImpl implements WishlistRepository {
  final SupabaseClient _supabase;

  WishlistRepositoryImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  FutureEither<List<Product>> getWishlist() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      final data = await _supabase
          .from('wishlist')
          .select('product:products(*)')
          .eq('user_id', userId);

      final products = (data as List)
          .map((e) => Product.fromJson(e['product']))
          .toList();
      return right(products);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid toggleWishlist(int productId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      final existing = await _supabase
          .from('wishlist')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('wishlist').delete().eq('id', existing['id']);
      } else {
        await _supabase.from('wishlist').insert({
          'user_id': userId,
          'product_id': productId,
        });
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureEither<bool> isInWishlist(int productId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return right(false);

      final existing = await _supabase
          .from('wishlist')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return right(existing != null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
