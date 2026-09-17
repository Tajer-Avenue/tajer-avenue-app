import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../data/catalog.dart';
import '../widgets/common.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PageHeading('Stores', subtitle: 'Independent businesses across the UAE'),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: stores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => Card(
                  elevation: 0,
                  color: Brand.surface,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(radius: 26, backgroundColor: const Color(0xFFEAE8E2), child: Text(stores[i].name[0], style: const TextStyle(fontWeight: FontWeight.w900))),
                    title: Text(stores[i].name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${stores[i].type} · ${stores[i].city}'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _openStore(context, stores[i]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );

  void _openStore(BuildContext context, StoreItem store) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(store.name)),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            Container(height: 170, decoration: BoxDecoration(color: Brand.ink, borderRadius: BorderRadius.circular(26)), child: Center(child: Text(store.name, style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)))),
            const SizedBox(height: 20),
            Text(store.type, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text('${store.city}, UAE', style: const TextStyle(color: Brand.muted)),
            const SizedBox(height: 24),
            const SectionTitle('Products & services'),
            const SizedBox(height: 10),
            ...products.where((product) => product.store == store.name).map((product) => Card(child: ListTile(title: Text(product.name), trailing: Text('AED ${product.price.toStringAsFixed(0)}')))),
          ]),
        ),
      ));
}
