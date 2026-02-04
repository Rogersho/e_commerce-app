import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/product/presentation/pages/product_list_screen.dart';
import '../../features/product/presentation/pages/product_details_screen.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/checkout/presentation/pages/checkout_screen.dart';
import '../../features/order/presentation/pages/order_history_screen.dart';
import '../../features/order/presentation/pages/order_details_screen.dart';
import '../../features/wishlist/presentation/pages/wishlist_screen.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/admin/presentation/pages/admin_order_details_screen.dart';

import '../../features/home/presentation/main_screen.dart';
import '../../features/home/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangeProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id']!) ?? 0;
                      return ProductDetailsScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ProductListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboard(),
                routes: [
                  GoRoute(
                    path: 'order/:id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id']!) ?? 0;
                      return AdminOrderDetailsScreen(orderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
        routes: [
          GoRoute(
            path: 'checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              return OrderDetailScreen(orderId: id);
            },
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final session = authState.value?.session;
      final isAuthenticated = session != null;

      const loginLoc = '/login';
      const signupLoc = '/signup';
      final isLoginRoute = state.uri.path == loginLoc;
      final isSignUpRoute = state.uri.path == signupLoc;

      // Public routes
      final publicRoutes = ['/', '/explore', '/login', '/signup'];
      final isPublicRoute =
          publicRoutes.any((route) => state.uri.path == route) ||
          state.uri.path.startsWith('/product/');

      if (!isAuthenticated) {
        if (isPublicRoute) return null;
        return loginLoc;
      }

      if (isLoginRoute || isSignUpRoute) {
        return '/';
      }

      return null;
    },
  );
});
