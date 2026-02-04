import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/wishlist_repository_impl.dart';
import '../../domain/wishlist_repository.dart';
import '../../../product/domain/product.dart';

final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, AsyncValue<List<Product>>>((ref) {
      final repository = ref.watch(wishlistRepositoryProvider);
      return WishlistController(repository: repository)..loadWishlist();
    });

class WishlistController extends StateNotifier<AsyncValue<List<Product>>> {
  final WishlistRepository _repository;

  WishlistController({required WishlistRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading());

  Future<void> toggleWishlist(int productId) async {
    final result = await _repository.toggleWishlist(productId);
    result.fold(
      (l) => null, // Handle error if needed
      (r) => loadWishlist(silent: true),
    );
  }

  Future<void> loadWishlist({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    final result = await _repository.getWishlist();
    result.fold(
      (l) => state = AsyncValue.error(l, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }
}

final isInWishlistProvider = Provider.family<bool, int>((ref, productId) {
  final wishlistAsync = ref.watch(wishlistControllerProvider);
  return wishlistAsync.maybeWhen(
    data: (products) => products.any((p) => p.id == productId),
    orElse: () => false,
  );
});
