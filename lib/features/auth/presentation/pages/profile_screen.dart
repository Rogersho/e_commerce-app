import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/theme/theme_controller.dart';
import '../controllers/profile_provider.dart';
import '../../data/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Account Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Placeholder for nested settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Loader()
          : profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return const Center(child: Text('No profile found'));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(profile),
                      const Gap(16),
                      _buildShoppingActivity(),
                      const Divider(height: 32),
                      _buildPersonalInformation(profile),
                      const Divider(height: 32),
                      _buildRewardsAndEngagement(),
                      const Divider(height: 32),
                      _buildPreferences(),
                      const Divider(height: 32),
                      _buildSupportAndHelp(),
                      const Divider(height: 32),
                      _buildSmartFeatures(),
                      const Divider(height: 32),
                      _buildSecurityManagement(),
                      const Gap(40),
                    ],
                  ),
                );
              },
              error: (e, s) => Center(child: Text('Error: $e')),
              loading: () => const Loader(),
            ),
    );
  }

  Widget _buildHeader(dynamic profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName ?? 'Welcome Back!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Supabase.instance.client.auth.currentUser?.email ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${profile.role?.toString().toUpperCase()} MEMBER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Shopping Activity'),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                Icons.list_alt,
                'Orders',
                () => context.push('/orders'),
              ),
              _buildQuickAction(
                Icons.favorite_border,
                'Wishlist',
                () => context.go('/wishlist'),
              ),
              _buildQuickAction(
                Icons.shopping_cart_outlined,
                'Cart',
                () => context.push('/cart'),
              ),
              _buildQuickAction(Icons.history, 'Recent', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(dynamic profile) {
    return Column(
      children: [
        _buildSectionHeader('Personal Information', padding: true),
        _buildListTile(Icons.phone_outlined, 'Phone Number', 'Add your phone'),
        _buildListTile(
          Icons.location_on_outlined,
          'Delivery Addresses',
          profile.address ?? 'Manage addresses',
        ),
        _buildListTile(
          Icons.credit_card_outlined,
          'Payment Methods',
          'Manage cards/wallets',
        ),
      ],
    );
  }

  Widget _buildRewardsAndEngagement() {
    return Column(
      children: [
        _buildSectionHeader('Rewards & Engagement', padding: true),
        _buildListTile(
          Icons.stars_outlined,
          'Loyalty Points',
          '250 Points available',
          trailing: const Text('Silver Tier'),
        ),
        _buildListTile(
          Icons.confirmation_number_outlined,
          'Coupons & Discounts',
          '3 active coupons',
        ),
        _buildListTile(
          Icons.card_giftcard_outlined,
          'Referral Program',
          'Invite friends & earn',
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return Column(
      children: [
        _buildSectionHeader('Preferences', padding: true),
        _buildListTile(
          Icons.notifications_active_outlined,
          'Notification Settings',
          'Push, Email, SMS',
        ),
        _buildListTile(
          Icons.dark_mode_outlined,
          'Theme Mode',
          ref.watch(themeControllerProvider).name.toUpperCase(),
          onTap: () => _showThemeSelector(context, ref),
        ),
        _buildListTile(
          Icons.language_outlined,
          'Language & Region',
          'English (US) | Africa',
        ),
      ],
    );
  }

  Widget _buildSupportAndHelp() {
    return Column(
      children: [
        _buildSectionHeader('Support & Help', padding: true),
        _buildListTile(Icons.help_outline, 'Help Center / FAQs', ''),
        _buildListTile(
          Icons.chat_bubble_outline,
          'Contact Support',
          'Chat, Email, Phone',
        ),
        _buildListTile(
          Icons.assignment_return_outlined,
          'Returns & Refunds',
          'Status of requests',
        ),
      ],
    );
  }

  Widget _buildSmartFeatures() {
    return Column(
      children: [
        _buildSectionHeader('Advanced Smart Features', padding: true),
        _buildListTile(
          Icons.analytics_outlined,
          'Personalized Analytics',
          'Spending trends',
        ),
        _buildListTile(
          Icons.visibility_outlined,
          'AR Try-on History',
          'View your try-on records',
        ),
        _buildListTile(
          Icons.watch_outlined,
          'Connected Devices',
          'Apple Watch, Alexa',
        ),
      ],
    );
  }

  Widget _buildSecurityManagement() {
    return Column(
      children: [
        _buildSectionHeader('Security & Account', padding: true),
        _buildListTile(Icons.lock_outline, 'Account Settings', 'Password, 2FA'),
        _buildListTile(
          Icons.devices_outlined,
          'Session History',
          'Devices logged in',
        ),
        _buildListTile(
          Icons.logout,
          'Log Out',
          'Sign out of your account',
          textColor: Colors.red,
          iconColor: Colors.red,
          onTap: () => _handleLogout(),
        ),
        _buildListTile(
          Icons.delete_forever_outlined,
          'Delete Account',
          'Irreversible action',
          textColor: Colors.red,
          iconColor: Colors.red,
          onTap: () => _handleDeleteAccount(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {bool padding = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ? 16 : 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blueAccent),
          ),
          const Gap(8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String subtitle, {
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ?? () {},
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                trailing: ref.watch(themeControllerProvider) == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: ref.watch(themeControllerProvider) == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_brightness),
                title: const Text('System Default'),
                trailing: ref.watch(themeControllerProvider) == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      ref.read(authRepositoryProvider).signOut();
      context.go('/login');
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and you will lose all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).deleteAccount(context);
    }
  }
}
