import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../providers/favorites_provider.dart';
import '../widgets/net_image.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final items = favorites.items;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: items.isEmpty
          ? const EmptyView(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle: 'Tap the heart on any product to save it here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = items[i];
                final tag = 'fav-${p.id}';
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => favorites.toggle(p),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
                  ),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => ProductDetailScreen.open(context, p, tag),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: Hero(tag: tag, child: NetImage(p.thumbnail)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    titleCase(p.category),
                                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    money(p.discountedPrice),
                                    style: text.titleSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => favorites.toggle(p),
                            icon: const Icon(Icons.favorite, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
