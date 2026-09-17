import 'package:flutter/material.dart';

void main() => runApp(const TajerAvenueApp());

class TajerAvenueApp extends StatelessWidget {
  const TajerAvenueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tajer Avenue',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111111)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final categories = const [
    ('Fashion', Icons.checkroom_rounded),
    ('Beauty', Icons.spa_rounded),
    ('Food', Icons.restaurant_rounded),
    ('Services', Icons.handyman_rounded),
    ('Home', Icons.chair_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TAJER', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      Text('AVENUE · UAE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: Colors.black54)),
                    ],
                  ),
                ),
                _circleButton(Icons.notifications_none_rounded),
                const SizedBox(width: 8),
                _circleButton(Icons.shopping_bag_outlined),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products, services & stores',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: const Icon(Icons.tune_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              height: 190,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(28)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('THE UAE\'S DIGITAL AVENUE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.7)),
                  SizedBox(height: 8),
                  Text('Discover what\'s\nnext.', style: TextStyle(color: Colors.white, fontSize: 34, height: 1, fontWeight: FontWeight.w800)),
                  SizedBox(height: 12),
                  Text('Local brands · Services · New drops', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _sectionTitle('Explore', 'See all'),
            const SizedBox(height: 14),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => Container(
                  width: 78,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(categories[i].$2),
                    const SizedBox(height: 8),
                    Text(categories[i].$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('Trending now', 'View all'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _storeCard('NOIR', 'Streetwear', 'Dubai')),
              const SizedBox(width: 12),
              Expanded(child: _storeCard('FORM', 'Home & Living', 'Abu Dhabi')),
            ]),
            const SizedBox(height: 30),
            _sectionTitle('Nearby', 'Open map'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: const Row(children: [
                CircleAvatar(backgroundColor: Color(0xFFF0F0ED), child: Icon(Icons.location_on_outlined, color: Colors.black)),
                SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Find businesses around you', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text('Explore stores and services across the UAE', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => setState(() => selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Stores'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Account'),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) => Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon),
      );

  Widget _sectionTitle(String title, String action) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
        Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
      ]);

  Widget _storeCard(String name, String type, String city) => Container(
        height: 190,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(decoration: BoxDecoration(color: const Color(0xFFEAEAE6), borderRadius: BorderRadius.circular(17)), child: Center(child: Text(name.substring(0, 1), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900))))),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('$type · $city', style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ]),
      );
}
