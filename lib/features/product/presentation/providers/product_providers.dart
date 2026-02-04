import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/product_repository_impl.dart';
import '../../domain/category.dart';
import '../../domain/product.dart';

class ProductFilter {
  final int? categoryId;
  final String? query;
  final double? minPrice;
  final double? maxPrice;
  final String? brand;

  ProductFilter({
    this.categoryId,
    this.query,
    this.minPrice,
    this.maxPrice,
    this.brand,
  });

  ProductFilter copyWith({
    int? categoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? brand,
  }) {
    return ProductFilter(
      categoryId: categoryId ?? this.categoryId,
      query: query ?? this.query,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      brand: brand ?? this.brand,
    );
  }
}

final productFilterProvider = StateProvider<ProductFilter>((ref) {
  return ProductFilter();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getCategories();
  return result.fold((l) => throw l, (r) => r);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final filter = ref.watch(productFilterProvider);

  final result = await repository.getProducts(
    categoryId: filter.categoryId,
    query: filter.query,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    brand: filter.brand,
  );

  return result.fold((l) => throw l, (r) => r);
});

final productDetailsProvider = FutureProvider.family<Product, int>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(id);
  return result.fold((l) => throw l, (r) => r);
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getFeaturedProducts();
  return result.fold((l) => throw l, (r) => r);
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsStream();
});
