import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../data/catalog.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Brand.muted)),
        ],
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.action, this.onTap, super.key});
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ]);
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.isFavorite, required this.onFavorite, super.key});
  final ProductItem product;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Brand.surface, borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(children: [
            Positioned.fill(child: Container(color: const Color(0xFFEAE8E2), child: const Icon(Icons.inventory_2_outlined, size: 48))),
            Positioned(right: 8, top: 8, child: IconButton.filledTonal(onPressed: onFavorite, icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded))),
          ])),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.store, style: const TextStyle(fontSize: 10, color: Brand.muted, fontWeight: FontWeight.w700)),
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('AED ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
            ]),
          ),
        ]),
      );
}
