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
        onOpenMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
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
      textDirection: TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _index == 5 ? null : _buildDrawer(),
        body: Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: IndexedStack(index: _index, children: pages),
        ),
        bottomNavigationBar: _index == 5
            ? null
            : Directionality(
                textDirection:
                    _isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: NavigationBar(
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
      ),
    );
  }

  Widget _buildDrawer() => Directionality(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Brand.ink, Color(0xFF2C2418)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Brand.accent, width: 3),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Brand.wordmark,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      Brand.submark,
                      style: TextStyle(
                        color: Brand.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _drawerTile(
                icon: Icons.settings_outlined,
                label: _text('Settings', 'الإعدادات'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSettings();
                },
              ),
              _drawerTile(
                icon: Icons.report_problem_outlined,
                label: _text('Report a problem', 'الإبلاغ عن مشكلة'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openReportProblem();
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
                child: Text(
                  _text('Language', 'اللغة'),
                  style: const TextStyle(
                    color: Brand.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: _isArabic,
                activeColor: Brand.accent,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Text('🇦🇪', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'العربية',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
              ),
              RadioListTile<bool>(
                value: false,
                groupValue: _isArabic,
                activeColor: Brand.accent,
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'English',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
              ),
            ],
          ),
        ),
      ),
    );

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Material(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Brand.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Brand.ink),
            ),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Brand.accent,
            ),
            onTap: onTap,
          ),
        ),
      );
}
