import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: p.sort,
            onSelected: p.setSort,
            itemBuilder: (_) => [
              for (final option in SortOption.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: p.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: p.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          p.setQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (p.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: p.category == null,
                    onSelected: () => p.setCategory(null),
                  ),
                  for (final c in p.categories)
                    _CategoryChip(
                      label: titleCase(c),
                      selected: p.category == c,
                      onSelected: () => p.setCategory(c),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(p)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductProvider p) {
    if (p.state == LoadState.loading) return const LoadingView();

    if (p.state == LoadState.error) {
      return ErrorView(
        message: p.errorMessage ?? 'Unable to load products',
        onRetry: p.loadProducts,
      );
    }

    final items = p.products;
    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        subtitle: 'Try a different search or category.',
        actionLabel: p.hasFilters ? 'Clear filters' : null,
        onAction: p.hasFilters
            ? () {
                _searchCtrl.clear();
                p.clearFilters();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: p.loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 0.66,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => ProductCard(product: items[i], heroPrefix: 'list'),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
