import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../widgets/net_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product, required this.heroTag});

  final Product product;
  final String heroTag;

  static void open(BuildContext context, Product product, String heroTag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product, heroTag: heroTag),
      ),
    );
  }

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isFav = context.select<FavoritesProvider, bool>((f) => f.isFavorite(p.id));
    final images = p.images.isEmpty ? [p.thumbnail] : p.images;
    final inStock = p.stock > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => context.read<FavoritesProvider>().toggle(p),
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 320,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final img = NetImage(images[i], fit: BoxFit.contain);
                return i == 0 ? Hero(tag: widget.heroTag, child: img) : img;
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _page ? cs.primary : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.brand} • ${titleCase(p.category)}',
                  style: text.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(p.title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(p.rating.toStringAsFixed(1), style: text.bodyMedium),
                    const SizedBox(width: 16),
                    Icon(
                      inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 18,
                      color: inStock ? Colors.green : cs.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inStock ? '${p.stock} in stock' : 'Out of stock',
                      style: text.bodyMedium?.copyWith(color: inStock ? Colors.green : cs.error),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      money(p.discountedPrice),
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    if (p.discountPercentage >= 1) ...[
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          money(p.price),
                          style: text.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: cs.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${p.discountPercentage.round()}% OFF',
                            style: TextStyle(
                              color: cs.onErrorContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Text('Description', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(p.description, style: text.bodyMedium?.copyWith(height: 1.5)),
                if (p.tags.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final t in p.tags) Chip(label: Text(t))],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: inStock
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p.title} added to cart')),
                      )
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                inStock ? 'Add to cart' : 'Out of stock',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
