import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../data/catalog.dart';
import '../widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onExplore, super.key});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(Brand.wordmark, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text(Brand.submark, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: Brand.muted)),
              ])),
              IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
              const SizedBox(width: 8),
              IconButton.filledTonal(onPressed: () => _showCart(context), icon: const Icon(Icons.shopping_bag_outlined)),
            ]),
            const SizedBox(height: 22),
            TextField(
              readOnly: true,
              onTap: onExplore,
              decoration: const InputDecoration(hintText: 'Search products, services & stores', prefixIcon: Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: 20),
            Container(
              height: 190,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Brand.ink, borderRadius: BorderRadius.circular(28)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(Brand.tagline, style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                SizedBox(height: 8),
                Text("Discover what's\nnext.", style: TextStyle(color: Colors.white, fontSize: 34, height: 1, fontWeight: FontWeight.w800)),
                SizedBox(height: 12),
                Text('Local brands · Services · New drops', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 24),
            SectionTitle('Explore', action: 'See all', onTap: onExplore),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => InkWell(
                  onTap: onExplore,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 78,
                    decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(20)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(categories[i].icon),
                      const SizedBox(height: 8),
                      Text(categories[i].name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const SectionTitle('Trending stores'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _StorePreview(store: stores[0])),
              const SizedBox(width: 12),
              Expanded(child: _StorePreview(store: stores[1])),
            ]),
            const SizedBox(height: 26),
            const SectionTitle('Nearby'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(22)),
              child: const Row(children: [
                CircleAvatar(backgroundColor: Color(0xFFF0F0ED), child: Icon(Icons.location_on_outlined, color: Brand.ink)),
                SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Find businesses around you', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Explore stores and services across the UAE', style: TextStyle(fontSize: 12, color: Brand.muted)),
                ])),
              ]),
            ),
          ],
        ),
      );

  void _showCart(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_bag_outlined, size: 44),
            SizedBox(height: 12),
            Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Items from different Tajer Avenue stores will appear here.', textAlign: TextAlign.center),
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
          Expanded(child: Container(decoration: BoxDecoration(color: const Color(0xFFEAE8E2), borderRadius: BorderRadius.circular(17)), child: Center(child: Text(store.name[0], style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900))))),
          const SizedBox(height: 9),
          Text(store.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${store.type} · ${store.city}', style: const TextStyle(fontSize: 11, color: Brand.muted)),
        ]),
      );
}
