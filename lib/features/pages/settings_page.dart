import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = false;

  String _genderLabel(String? gender) {
    if (gender == 'male') return 'Male';
    if (gender == 'female') return 'Female';
    return 'Not set';
  }

  Future<void> _changeGender() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _loading) return;

    final currentGender = user.userMetadata?['gender']?.toString();
    var selectedGender = currentGender ?? 'male';

    final newGender = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gender'),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'male',
                groupValue: selectedGender,
                title: const Text('Male'),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedGender = value);
                  }
                },
              ),
              RadioListTile<String>(
                value: 'female',
                groupValue: selectedGender,
                title: const Text('Female'),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedGender = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(selectedGender),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || newGender == null || newGender == currentGender) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change gender?'),
        content: Text(
          'Are you sure you want to change your gender to '
          '${_genderLabel(newGender)}? Your recommendations will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, change'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final metadata = Map<String, dynamic>.from(user.userMetadata ?? {});
      metadata['gender'] = newGender;
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: metadata),
      );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gender and recommendations updated.'),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestSignOut() async {
    if (_loading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _signOut();
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final gender = user?.userMetadata?['gender']?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Card(
              elevation: 0,
              color: Brand.surface,
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.notifications_outlined),
                    title: Text('Notifications'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.language_rounded),
                    title: Text('Language'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  ),
                  if (user != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded),
                      title: const Text('Gender'),
                      subtitle: Text(_genderLabel(gender)),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                      onTap: _loading ? null : _changeGender,
                    ),
                  ],
                ],
              ),
            ),
            if (user != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _loading ? null : _requestSignOut,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
