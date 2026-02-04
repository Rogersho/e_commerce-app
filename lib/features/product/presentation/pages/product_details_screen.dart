import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loader.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../wishlist/presentation/controllers/wishlist_controller.dart';
import '../providers/product_providers.dart';
import '../widgets/rating_widget.dart';
import '../../../auth/data/auth_repository_impl.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final isInWishlist = ref.watch(isInWishlistProvider(productId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : null,
            ),
            onPressed: () {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user == null) {
                context.go('/login');
                return;
              }
              ref
                  .read(wishlistControllerProvider.notifier)
                  .toggleWishlist(productId);
            },
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.images != null && product.images!.isNotEmpty)
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: product.images!.first,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      product.description ?? 'No description available.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Gap(24),
                    const Divider(),
                    const Gap(16),
                    RatingWidget(product: product),
                    const Gap(32),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Loader(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: () {
            final user = ref.read(authRepositoryProvider).currentUser;
            if (user == null) {
              context.go('/login');
              return;
            }
            ref
                .read(cartControllerProvider.notifier)
                .addItem(productId: productId, context: context);
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Add to Cart'),
        ),
      ),
    );
  }
}
