import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../widgets/common.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({required this.favorites, required this.onToggleFavorite, required this.preferredGender, required this.isArabic, super.key});
  final Set<String> favorites;
  final ValueChanged<ProductItem> onToggleFavorite;
  final String? preferredGender;
  final bool isArabic;

  String text(String en, String ar) => isArabic ? ar : en;
  String categoryLabel(String name) => isArabic ? const {'Fashion':'الأزياء','Beauty':'الجمال','Food':'الطعام','Services':'الخدمات','Home':'المنزل'}[name] ?? name : name;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String query = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((item) {
      final matchesSearch = '${item.name} ${item.store} ${item.category}'.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = selectedCategory == null || item.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    int productPriority(ProductItem item) {
      if (widget.preferredGender == 'female') {
        if (item.category == 'Beauty') return 0;
        if (item.category == 'Fashion') return 1;
      } else if (widget.preferredGender == 'male') {
        if (item.category == 'Fashion') return 0;
        if (item.category == 'Services') return 1;
      }
      return 2 + products.indexOf(item);
    }

    filtered.sort(
      (a, b) => productPriority(a).compareTo(productPriority(b)),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeading(widget.text('Categories', 'الفئات'), subtitle: widget.text('Browse products and services by category', 'تصفح المنتجات والخدمات حسب الفئة')),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(hintText: widget.text('What are you looking for?', 'عن ماذا تبحث؟'), prefixIcon: const Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return FilterChip(
                    label: Text(widget.text('All', 'الكل')),
                    selected: selectedCategory == null,
                    onSelected: (_) => setState(() => selectedCategory = null),
                  );
                }
                final category = categories[i - 1];
                return FilterChip(
                  label: Text(widget.categoryLabel(category.name)),
                  avatar: Icon(category.icon, size: 17),
                  selected: selectedCategory == category.name,
                  onSelected: (_) => setState(() => selectedCategory = category.name),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(widget.text('No results found', 'لم يتم العثور على نتائج')))
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
