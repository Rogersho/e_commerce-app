import '../../../../core/utils/type_defs.dart';
import '../../product/domain/product.dart';

abstract class WishlistRepository {
  FutureEither<List<Product>> getWishlist();
  FutureVoid toggleWishlist(int productId);
  FutureEither<bool> isInWishlist(int productId);
}
