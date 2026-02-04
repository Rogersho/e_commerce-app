import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_repository.dart';
import '../../data/cart_repository_impl.dart';

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<List<CartItem>>>((ref) {
      final repository = ref.watch(cartRepositoryProvider);
      return CartController(repository: repository)..loadCart();
    });

class CartController extends StateNotifier<AsyncValue<List<CartItem>>> {
  final CartRepository _repository;

  CartController({required CartRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading());

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCartItems();
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }

  Future<void> addItem({
    required int productId,
    int quantity = 1,
    BuildContext? context,
  }) async {
    final result = await _repository.addToCart(
      productId: productId,
      quantity: quantity,
    );
    result.fold(
      (l) {
        if (context != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.message)));
        }
      },
      (r) {
        if (context != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to cart')));
        }
        loadCart();
      },
    );
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    // Optimistic update could happen here
    final result = await _repository.updateQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
    result.fold(
      (l) => null, // Handle error
      (r) => loadCart(),
    );
  }

  Future<void> removeItem(int cartItemId) async {
    final result = await _repository.removeFromCart(cartItemId);
    result.fold(
      (l) => null, // Handle error
      (r) => loadCart(),
    );
  }

  Future<void> clearCart() async {
    final result = await _repository.clearCart();
    result.fold((l) => null, (r) => loadCart());
  }
}

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.maybeWhen(
    data: (items) => items.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    ),
    orElse: () => 0.0,
  );
});
