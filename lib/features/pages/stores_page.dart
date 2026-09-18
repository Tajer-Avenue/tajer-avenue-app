import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/brand.dart';
import '../../data/catalog.dart';
import '../widgets/common.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({required this.isArabic, super.key});

  final bool isArabic;

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  static const _savedStoresKey = 'saved_stores';

  String _text(String en, String ar) => widget.isArabic ? ar : en;

  final _searchController = TextEditingController();
  final Set<String> _savedStores = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadSavedStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedStores() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedStores
        ..clear()
        ..addAll(preferences.getStringList(_savedStoresKey) ?? const []);
    });
  }

  Future<void> _toggleSaved(StoreItem store) async {
    setState(() {
      if (!_savedStores.add(store.name)) {
        _savedStores.remove(store.name);
      }
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _savedStoresKey,
      _savedStores.toList(),
    );
  }

  bool _matchesSearch(StoreItem store) {
    if (_query.isEmpty) return true;
    final searchable = '${store.name} ${store.type} ${store.city}'.toLowerCase();
    return searchable.contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    final filteredStores = stores.where(_matchesSearch).toList();
    final savedStores = stores
        .where((store) => _savedStores.contains(store.name))
        .where(_matchesSearch)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          PageHeading(_text('Stores', 'المتاجر'), subtitle: _text('Independent businesses across the UAE', 'مشاريع مستقلة في جميع أنحاء الإمارات')),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _query = value.trim().toLowerCase());
            },
            decoration: InputDecoration(
              hintText: _text('Search stores, categories or cities', 'ابحث عن متجر أو فئة أو مدينة'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: _text('Clear search', 'مسح البحث'),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          if (savedStores.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionTitle(_text('Saved stores', 'المتاجر المحفوظة')),
            const SizedBox(height: 10),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: savedStores.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final store = savedStores[index];
                  return InkWell(
                    onTap: () => _openStore(context, store),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Brand.ink,
                        borderRadius: BorderRadius.circular(20),
                        image: store.imagePath == null
                            ? null
                            : DecorationImage(
                                image: AssetImage(store.imagePath!),
                                fit: BoxFit.cover,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black45,
                                  BlendMode.darken,
                                ),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${store.type} · ${store.city}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          SectionTitle(
            _query.isEmpty ? _text('All stores', 'جميع المتاجر') : _text('Search results', 'نتائج البحث'),
          ),
          const SizedBox(height: 10),
          if (filteredStores.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(Icons.store_mall_directory_outlined, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    _text('No stores found', 'لم يتم العثور على متاجر'),
                    style: TextStyle(
                      color: Brand.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredStores.map(_storeCard),
        ],
      ),
    );
  }

  Widget _storeCard(StoreItem store) {
    final isSaved = _savedStores.contains(store.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        color: Brand.surface,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFEAE8E2),
            backgroundImage:
                store.imagePath == null ? null : AssetImage(store.imagePath!),
            child: store.imagePath == null
                ? Text(
                    store.name[0],
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  )
                : null,
          ),
          title: Text(
            store.name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text('${store.type} · ${store.city}'),
          trailing: IconButton(
            tooltip: isSaved ? _text('Remove from saved stores', 'إزالة من المتاجر المحفوظة') : _text('Save store', 'حفظ المتجر'),
            onPressed: () => _toggleSaved(store),
            icon: Icon(
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved ? Brand.accent : Brand.muted,
            ),
          ),
          onTap: () => _openStore(context, store),
        ),
      ),
    );
  }

  void _openStore(BuildContext context, StoreItem store) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(store.name)),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 210,
                  decoration: BoxDecoration(
                    color: Brand.ink,
                    borderRadius: BorderRadius.circular(26),
                    image: store.imagePath == null
                        ? null
                        : DecorationImage(
                            image: AssetImage(store.imagePath!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(blurRadius: 12, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  store.type,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${store.city}, UAE',
                  style: const TextStyle(color: Brand.muted),
                ),
                const SizedBox(height: 24),
                SectionTitle(_text('Products & services', 'المنتجات والخدمات')),
                const SizedBox(height: 10),
                ...products
                    .where((product) => product.store == store.name)
                    .map(
                      (product) => Card(
                        child: ListTile(
                          title: Text(product.name),
                          trailing: Text(
                            'AED ${product.price.toStringAsFixed(0)}',
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
}
