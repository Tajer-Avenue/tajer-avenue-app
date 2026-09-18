import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../data/catalog.dart';
import '../widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onExplore,
    required this.isArabic,
    required this.preferredGender,
    super.key,
  });

  final VoidCallback onExplore;
  final bool isArabic;
  final String? preferredGender;

  String _text(String english, String arabic) =>
      isArabic ? arabic : english;

  @override
  Widget build(BuildContext context) {
    final personalizedCategories = [...categories];
    final personalizedStores = [...stores];

    int categoryPriority(CategoryItem item) {
      if (preferredGender == 'female') {
        if (item.name == 'Beauty') return 0;
        if (item.name == 'Fashion') return 1;
      } else if (preferredGender == 'male') {
        if (item.name == 'Fashion') return 0;
        if (item.name == 'Services') return 1;
      }
      return 2 + categories.indexOf(item);
    }

    int storePriority(StoreItem item) {
      if (preferredGender == 'female' && item.type == 'Beauty') return 0;
      if (preferredGender == 'male' && item.type == 'Streetwear') return 0;
      return 1 + stores.indexOf(item);
    }

    personalizedCategories.sort(
      (a, b) => categoryPriority(a).compareTo(categoryPriority(b)),
    );
    personalizedStores.sort(
      (a, b) => storePriority(a).compareTo(storePriority(b)),
    );

    return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(Brand.wordmark, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Text(Brand.submark, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: Brand.muted)),
                ])),
                IconButton.filledTonal(
                  onPressed: () => _showCart(context),
                  tooltip: _text('Cart', 'السلة'),
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            TextField(
              readOnly: true,
              onTap: onExplore,
              decoration: InputDecoration(
                hintText: _text(
                  'Search products, services & stores',
                  'ابحث عن المنتجات والخدمات والمتاجر',
                ),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 190,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Brand.ink,
                borderRadius: BorderRadius.circular(28),
                image: const DecorationImage(
                  image: AssetImage('assets/images/home-hero.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                const Text(Brand.tagline, style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                const SizedBox(height: 8),
                Text(_text("Discover what's\nnext.", 'اكتشف كل\nما هو جديد.'), style: const TextStyle(color: Colors.white, fontSize: 34, height: 1, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(_text('Local brands · Services · New drops', 'علامات محلية · خدمات · أحدث المنتجات'), style: const TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 24),
            SectionTitle(
              _text('Explore', 'استكشف'),
              action: _text('See all', 'عرض الكل'),
              onTap: onExplore,
            ),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: personalizedCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => InkWell(
                  onTap: onExplore,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 92,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(20)),
                    child: Column(children: [
                      Expanded(child: Image.asset(personalizedCategories[i].imagePath, width: double.infinity, fit: BoxFit.cover)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(personalizedCategories[i].name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            SectionTitle(_text('Trending stores', 'المتاجر الرائجة')),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _StorePreview(store: personalizedStores[0])),
              const SizedBox(width: 12),
              Expanded(child: _StorePreview(store: personalizedStores[1])),
            ]),
            const SizedBox(height: 26),
            SectionTitle(_text('Nearby', 'بالقرب منك')),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                const CircleAvatar(backgroundColor: Color(0xFFF0F0ED), child: Icon(Icons.location_on_outlined, color: Brand.ink)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_text('Find businesses around you', 'اكتشف المشاريع من حولك'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(_text('Explore stores and services across the UAE', 'استكشف المتاجر والخدمات في جميع أنحاء الإمارات'), style: const TextStyle(fontSize: 12, color: Brand.muted)),
                ])),
              ]),
            ),
          ],
        ),
      );
  }

  void _showCart(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shopping_bag_outlined, size: 44),
            const SizedBox(height: 12),
            Text(_text('Your cart is empty', 'سلتك فارغة'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_text('Items from different Tajer Avenue stores will appear here.', 'ستظهر هنا المنتجات من متاجر تاجر أفينيو المختلفة.'), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _StorePreview extends StatelessWidget {
  const _StorePreview({required this.store});
  final StoreItem store;

  @override
  Widget build(BuildContext context) => Container(
        height: 185,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: store.imagePath == null
                  ? Container(color: const Color(0xFFEAE8E2), child: Center(child: Text(store.name[0], style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900))))
                  : Image.asset(store.imagePath!, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 9),
          Text(store.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${store.type} · ${store.city}', style: const TextStyle(fontSize: 11, color: Brand.muted)),
        ]),
      );
}
