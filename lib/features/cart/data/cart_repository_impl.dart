import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/type_defs.dart';
import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(supabase: Supabase.instance.client);
});

class CartRepositoryImpl implements CartRepository {
  final SupabaseClient _supabase;

  CartRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  FutureEither<List<CartItem>> getCartItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      final data = await _supabase
          .from('cart_items')
          .select('*, product:products(*)')
          .eq('user_id', userId)
          .order('created_at');

      final cartItems = (data as List)
          .map((e) => CartItem.fromJson(e))
          .toList();
      return right(cartItems);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid addToCart({required int productId, required int quantity}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      // Check if item exists
      final existing = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        final newQuantity = existing['quantity'] + quantity;
        await _supabase
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existing['id']);
      } else {
        await _supabase.from('cart_items').insert({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        });
      }

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid removeFromCart(int cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  FutureVoid clearCart() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return left(const Failure('User not logged in'));

      await _supabase.from('cart_items').delete().eq('user_id', userId);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
