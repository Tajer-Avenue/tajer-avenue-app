import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../widgets/common.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({required this.favorites, required this.onToggleFavorite, super.key});
  final Set<String> favorites;
  final ValueChanged<ProductItem> onToggleFavorite;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((item) => '${item.name} ${item.store}'.toLowerCase().contains(query.toLowerCase())).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeading('Explore', subtitle: 'Products, services and local discoveries'),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: const InputDecoration(hintText: 'What are you looking for?', prefixIcon: Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(label: Text(categories[i].name), avatar: Icon(categories[i].icon, size: 17), onPressed: () => setState(() => query = categories[i].name)),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No results found'))
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ProductCard(product: filtered[i], isFavorite: widget.favorites.contains(filtered[i].name), onFavorite: () => widget.onToggleFavorite(filtered[i])),
                  ),
          ),
        ]),
      ),
    );
  }
}
