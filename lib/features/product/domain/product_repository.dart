import '../../../../core/utils/type_defs.dart';
import 'category.dart';
import 'product.dart';
import 'review.dart';

abstract class ProductRepository {
  FutureEither<List<Category>> getCategories();

  FutureEither<List<Product>> getProducts({
    int? categoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? brand,
  });

  FutureEither<Product> getProductById(int id);

  FutureEither<List<Product>> getFeaturedProducts();

  Stream<List<Product>> getProductsStream();

  FutureEither<List<Review>> getProductReviews(int productId);

  FutureEither<void> submitReview(Review review);
}
