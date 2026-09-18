import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/brand.dart';
import '../data/catalog.dart';
import 'pages/account_page.dart';
import 'pages/auth_page.dart';
import 'pages/explore_page.dart';
import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'pages/report_problem_page.dart';
import 'pages/settings_page.dart';
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
  static const _languageKey = 'app_language';

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _favorites = {};

  late int _index;
  bool _authStartsWithSignUp = false;
  bool _isArabic = false;

  String _text(String english, String arabic) =>
      _isArabic ? arabic : english;

  @override
  void initState() {
    super.initState();
    _index = widget.openAccountOnLaunch ? 4 : 0;
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isArabic = preferences.getString(_languageKey) == 'ar');
  }

  Future<void> _setLanguage(bool isArabic) async {
    setState(() => _isArabic = isArabic);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, isArabic ? 'ar' : 'en');
  }

  void _openAuth({required bool signUp}) {
    setState(() {
      _authStartsWithSignUp = signUp;
      _index = 5;
    });
  }

  void _toggleFavorite(ProductItem product) {
    setState(() {
      if (!_favorites.add(product.name)) {
        _favorites.remove(product.name);
      }
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  void _openReportProblem() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportProblemPage(isArabic: _isArabic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        isArabic: _isArabic,
        onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
        onExplore: () => setState(() => _index = 1),
      ),
      ExplorePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      FavoritesPage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      const StoresPage(),
      AccountPage(
        onOpenSignIn: () => _openAuth(signUp: false),
        onOpenCreateAccount: () => _openAuth(signUp: true),
      ),
      AuthPage(
        key: ValueKey(_authStartsWithSignUp),
        initialSignUp: _authStartsWithSignUp,
        onBack: () => setState(() => _index = 4),
      ),
    ];

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _index == 5 ? null : _buildDrawer(),
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: _index == 5
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (value) {
                  setState(() => _index = value);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: _text('Home', 'الرئيسية'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_rounded),
                    label: _text('Explore', 'استكشف'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border_rounded),
                    selectedIcon: const Icon(Icons.favorite_rounded),
                    label: _text('Saved', 'المحفوظات'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.storefront_outlined),
                    selectedIcon: const Icon(Icons.storefront_rounded),
                    label: _text('Stores', 'المتاجر'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: _text('Account', 'الحساب'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                color: Brand.ink,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Brand.wordmark,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      Brand.submark,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(_text('Settings', 'الإعدادات')),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: Text(_text('Report a problem', 'الإبلاغ عن مشكلة')),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                onTap: () {
                  Navigator.of(context).pop();
                  _openReportProblem();
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Text(
                  _text('Language', 'اللغة'),
                  style: const TextStyle(
                    color: Brand.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              RadioListTile<bool>(
                value: false,
                groupValue: _isArabic,
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
                title: const Text('English'),
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: _isArabic,
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
                title: const Text('العربية'),
              ),
            ],
          ),
        ),
      );
}
