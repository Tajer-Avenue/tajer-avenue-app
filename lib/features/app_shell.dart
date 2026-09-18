import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(_text('Notifications', 'الإشعارات')),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: Brand.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _text('No notifications yet', 'لا توجد إشعارات حالياً'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _text(
                      'Updates about orders and stores will appear here.',
                      'ستظهر هنا تحديثات الطلبات والمتاجر.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Brand.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SettingsPage(isArabic: _isArabic)),
    );
    if (mounted) setState(() {});
  }

  void _openReportProblem() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportProblemPage(isArabic: _isArabic),
      ),
    );
  }

  Future<void> _requestSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Sign out?', 'تسجيل الخروج؟')),
        content: Text(
          _text(
            'Are you sure you want to sign out?',
            'هل أنت متأكد من تسجيل الخروج؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_text('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: Text(_text('Sign out', 'تسجيل الخروج')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) setState(() => _index = 4);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferredGender = Supabase.instance.client.auth.currentUser
        ?.userMetadata?['gender']
        ?.toString();
    final pages = [
      HomePage(
        isArabic: _isArabic,
        preferredGender: preferredGender,
        onExplore: () => setState(() => _index = 1),
      ),
      ExplorePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        preferredGender: preferredGender,
        isArabic: _isArabic,
      ),
      FavoritesPage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
        isArabic: _isArabic,
      ),
      StoresPage(isArabic: _isArabic),
      AccountPage(
        onOpenSignIn: () => _openAuth(signUp: false),
        onOpenCreateAccount: () => _openAuth(signUp: true),
        onOpenMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
        isArabic: _isArabic,
      ),
      AuthPage(
        key: ValueKey(_authStartsWithSignUp),
        initialSignUp: _authStartsWithSignUp,
        isArabic: _isArabic,
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
                    icon: const Icon(Icons.explore_outlined),
                    selectedIcon: const Icon(Icons.explore_rounded),
                    label: _text('Discover', 'اكتشف'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_rounded),
                    label: _text('Categories', 'الفئات'),
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
        width: (MediaQuery.sizeOf(context).width * 0.64)
            .clamp(250.0, 285.0)
            .toDouble(),
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
                icon: Icons.notifications_none_rounded,
                label: _text('Notifications', 'الإشعارات'),
                onTap: () {
                  _openNotifications();
                },
              ),
              _drawerTile(
                icon: Icons.settings_outlined,
                label: _text('Settings', 'الإعدادات'),
                onTap: () {
                  _openSettings();
                },
              ),
              _drawerTile(
                icon: Icons.report_problem_outlined,
                label: _text('Report a problem', 'الإبلاغ عن مشكلة'),
                onTap: () {
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
                  _text('English', 'الإنجليزية'),
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
              ),
              if (Supabase.instance.client.auth.currentUser != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Divider(),
                ),
                _drawerTile(
                  icon: Icons.logout_rounded,
                  label: _text('Sign out', 'تسجيل الخروج'),
                  foregroundColor: Colors.red.shade700,
                  onTap: () {
                      _requestSignOut();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? foregroundColor,
  }) {
    final color = foregroundColor ?? Brand.ink;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Material(
          color: Brand.surface,
          borderRadius: BorderRadius.circular(13),
          child: ListTile(
            dense: true,
            minTileHeight: 50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: color,
            ),
            onTap: onTap,
          ),
        ),
      );
  }
}
