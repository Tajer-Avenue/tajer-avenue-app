import 'package:flutter/material.dart';

import '../data/catalog.dart';
import 'pages/account_page.dart';
import 'pages/auth_page.dart';
import 'pages/explore_page.dart';
import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'pages/stores_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.openAccountOnLaunch = false,
  });

  final bool openAccountOnLaunch;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;
  final Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _index = widget.openAccountOnLaunch ? 4 : 0;
  }

  void _toggleFavorite(ProductItem product) {
    setState(() {
      if (!_favorites.add(product.name)) {
        _favorites.remove(product.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onExplore: () => setState(() => _index = 1)),
      ExplorePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      FavoritesPage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      const StoresPage(),
      AccountPage(onOpenAuth: () => setState(() => _index = 5)),
      AuthPage(onBack: () => setState(() => _index = 4)),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _index == 5
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) {
                setState(() => _index = value);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Stores',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Account',
                ),
              ],
            ),
    );
  }
}
