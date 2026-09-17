import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../widgets/common.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const PageHeading('Account', subtitle: 'Shop, sell and manage your activity'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Brand.ink, borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Welcome to Tajer Avenue', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                const Text('Sign in to save items, order and manage your store.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 18),
                FilledButton.tonal(onPressed: () {}, child: const Text('Sign in or create account')),
              ]),
            ),
            const SizedBox(height: 20),
            _tile(Icons.receipt_long_outlined, 'My orders'),
            _tile(Icons.location_on_outlined, 'Addresses'),
            _tile(Icons.settings_outlined, 'Settings'),
            const SizedBox(height: 18),
            const SectionTitle('For merchants'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Brand.surface,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
                title: const Text('Open your store', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Products, services, orders and analytics'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {},
              ),
            ),
          ],
        ),
      );

  Widget _tile(IconData icon, String label) => Card(
        elevation: 0,
        color: Brand.surface,
        child: ListTile(leading: Icon(icon), title: Text(label), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: () {}),
      );
}
