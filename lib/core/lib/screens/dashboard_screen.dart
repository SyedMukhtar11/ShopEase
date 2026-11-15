import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/net_image.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onBrowse});

  /// Switches the shell to the Products tab.
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final products = context.watch<ProductProvider>();
    final favCount = context.select<FavoritesProvider, int>((f) => f.items.length);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final catalog = products.catalog;

    Widget body;
    if (catalog.isEmpty && products.state == LoadState.loading) {
      body = const LoadingView();
    } else if (catalog.isEmpty && products.state == LoadState.error) {
      body = ErrorView(
        message: products.errorMessage ?? 'Unable to load products',
        onRetry: products.loadProducts,
      );
    } else {
      final featured = ([...catalog]..sort((a, b) => b.rating.compareTo(a.rating))).take(8).toList();
      body = ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(icon: Icons.inventory_2_outlined, label: 'Products', value: '${catalog.length}'),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.category_outlined, label: 'Categories', value: '${products.categories.length}'),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.favorite_border, label: 'Favorites', value: '$favCount'),
              ],
            ),
          ),
          if (products.categories.isNotEmpty) ...[
            _SectionHeader(title: 'Shop by category', actionLabel: 'See all', onAction: () {
              products.setCategory(null);
              onBrowse();
            }),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.categories.take(12).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = products.categories[i];
                  return ActionChip(
                    label: Text(titleCase(c)),
                    onPressed: () {
                      products.setCategory(c);
                      onBrowse();
                    },
                  );
                },
              ),
            ),
          ],
          const _SectionHeader(title: 'Top rated'),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: 170,
                child: ProductCard(product: featured[i], heroPrefix: 'feat'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer,
              child: user != null && user.image.isNotEmpty
                  ? ClipOval(child: NetImage(user.image))
                  : Text(
                      user?.initials ?? '?',
                      style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700),
                    ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(
                  user?.firstName.isNotEmpty == true ? user!.firstName : 'Shopper',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(height: 10),
            Text(value, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
