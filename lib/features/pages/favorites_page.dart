import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../widgets/common.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({required this.favorites, required this.onToggleFavorite, required this.isArabic, super.key});
  final Set<String> favorites;
  final ValueChanged<ProductItem> onToggleFavorite;
  final bool isArabic;
  String text(String en, String ar) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final saved = products.where((item) => favorites.contains(item.name)).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeading(text('Saved', 'المحفوظات'), subtitle: text('Your favorite finds in one place', 'كل ما حفظته في مكان واحد')),
          const SizedBox(height: 18),
          Expanded(
            child: saved.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.favorite_border_rounded, size: 54),
                    const SizedBox(height: 12),
                    Text(text('No saved items yet', 'لا توجد عناصر محفوظة بعد'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text(text('Tap the heart on a product to save it.', 'اضغط على القلب لحفظ المنتج.')),
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
