import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../domain/product.dart';
import '../../domain/review.dart';
import '../providers/product_providers.dart';
import '../../data/product_repository_impl.dart';
import '../../../auth/data/auth_repository_impl.dart';

class RatingWidget extends ConsumerWidget {
  final Product product;
  const RatingWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _showReviewDialog(context, ref, product.id),
              child: const Text('Write a review'),
            ),
          ],
        ),
        const Gap(8),
        Row(
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: product.rating,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
                Text(
                  '${product.reviewCount} reviews',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const Gap(24),
        reviewsAsync.when(
          data: (reviews) => reviews.isEmpty
              ? const Center(child: Text('No reviews yet. Be the first!'))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.userFullName ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(review.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          RatingBarIndicator(
                            rating: review.rating.toDouble(),
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 14.0,
                            direction: Axis.horizontal,
                          ),
                          const Gap(4),
                          if (review.comment != null) Text(review.comment!),
                        ],
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading reviews: $err'),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, int productId) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to write a review')),
      );
      return;
    }

    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (r) => rating = r,
            ),
            const Gap(16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final review = Review(
                id: 0, // DB will generate
                userId: user.id,
                productId: productId,
                rating: rating.toInt(),
                comment: commentController.text,
              );
              final result = await ref
                  .read(productRepositoryProvider)
                  .submitReview(review);
              result.fold(
                (l) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.message))),
                (r) {
                  ref.invalidate(productReviewsProvider(productId));
                  ref.invalidate(productDetailsProvider(productId));
                  Navigator.pop(context);
                },
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

final productReviewsProvider = FutureProvider.family<List<Review>, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductReviews(productId);
  return result.fold((l) => throw l, (r) => r);
});
