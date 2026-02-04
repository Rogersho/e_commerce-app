import '../../../../core/utils/type_defs.dart';
import 'cart_item.dart';

abstract class CartRepository {
  FutureEither<List<CartItem>> getCartItems();
  FutureVoid addToCart({required int productId, required int quantity});
  FutureVoid updateQuantity({required int cartItemId, required int quantity});
  FutureVoid removeFromCart(int cartItemId);
  FutureVoid clearCart();
}
