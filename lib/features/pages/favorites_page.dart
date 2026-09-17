import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../widgets/common.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({required this.favorites, required this.onToggleFavorite, super.key});
  final Set<String> favorites;
  final ValueChanged<ProductItem> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final saved = products.where((item) => favorites.contains(item.name)).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageHeading('Saved', subtitle: 'Your favorite finds in one place'),
          const SizedBox(height: 18),
          Expanded(
            child: saved.isEmpty
                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_border_rounded, size: 54),
                    SizedBox(height: 12),
                    Text('No saved items yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Tap the heart on a product to save it.'),
                  ]))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: saved.length,
                    itemBuilder: (_, i) => ProductCard(product: saved[i], isFavorite: true, onFavorite: () => onToggleFavorite(saved[i])),
                  ),
          ),
        ]),
      ),
    );
  }
}
