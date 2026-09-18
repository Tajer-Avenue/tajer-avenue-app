import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';
import '../widgets/common.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.onOpenSignIn,
    required this.onOpenCreateAccount,
    required this.onOpenMenu,
    required this.isArabic,
  });

  final VoidCallback onOpenSignIn;
  final VoidCallback onOpenCreateAccount;
  final VoidCallback onOpenMenu;
  final bool isArabic;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  String _firstName(User user) {
    final fullName = user.userMetadata?['full_name']?.toString().trim() ?? '';
    if (fullName.isEmpty) return widget.isArabic ? 'عضو' : 'Member';
    return fullName.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    String t(String en, String ar) => widget.isArabic ? ar : en;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PageHeading(t('Account', 'الحساب'), subtitle: t('Shop, sell and manage your activity', 'تسوق وبع وأدر نشاطك')),
                ),
                IconButton.filledTonal(
                  onPressed: widget.onOpenMenu,
                  tooltip: t('Menu', 'القائمة'),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Brand.ink,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Welcome to Tajer Avenue', 'مرحباً بك في تاجر أفينيو'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  user == null
                      ? t('Sign in to save items, order and manage your store.', 'سجل الدخول لحفظ المنتجات والطلب وإدارة متجرك.')
                      : _firstName(user),
                  style: const TextStyle(color: Colors.white70),
                ),
                if (user == null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: widget.onOpenSignIn,
                          child: Text(t('Sign in', 'تسجيل الدخول')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onOpenCreateAccount,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                          ),
                          child: Text(t('Create account', 'إنشاء حساب')),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(Icons.receipt_long_outlined, t('My orders', 'طلباتي')),
          _tile(Icons.location_on_outlined, t('Addresses', 'العناوين')),
          const SizedBox(height: 18),
          SectionTitle(t('For merchants', 'للتجار')),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Brand.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(Icons.storefront_rounded),
              ),
              title: Text(
                t('Open your store', 'افتح متجرك'),
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                t('Products, services, orders and analytics', 'المنتجات والخدمات والطلبات والتحليلات'),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              onTap: user == null ? widget.onOpenSignIn : () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) =>
      Card(
        elevation: 0,
        color: Brand.surface,
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
          ),
          onTap: onTap ?? () {},
        ),
      );
}
