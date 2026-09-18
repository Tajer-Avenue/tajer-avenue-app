import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';
import '../widgets/common.dart';
import 'settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.onOpenAuth});

  final VoidCallback onOpenAuth;

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

  void _openAuth() => widget.onOpenAuth();

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  String _firstName(User user) {
    final fullName = user.userMetadata?['full_name']?.toString().trim() ?? '';
    if (fullName.isEmpty) return 'Member';
    return fullName.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          const PageHeading(
            'Account',
            subtitle: 'Shop, sell and manage your activity',
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
                const Text(
                  'Welcome to Tajer Avenue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  user == null
                      ? 'Sign in to save items, order and manage your store.'
                      : _firstName(user),
                  style: const TextStyle(color: Colors.white70),
                ),
                if (user == null) ...[
                  const SizedBox(height: 18),
                  FilledButton.tonal(
                    onPressed: _openAuth,
                    child: const Text('Sign in or create account'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(Icons.receipt_long_outlined, 'My orders'),
          _tile(Icons.location_on_outlined, 'Addresses'),
          _tile(Icons.settings_outlined, 'Settings', onTap: _openSettings),
          const SizedBox(height: 18),
          const SectionTitle('For merchants'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Brand.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(Icons.storefront_rounded),
              ),
              title: const Text(
                'Open your store',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Products, services, orders and analytics',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              onTap: user == null ? _openAuth : () {},
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
