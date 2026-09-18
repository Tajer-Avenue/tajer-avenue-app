import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.isArabic, super.key});

  final bool isArabic;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = false;

  String _text(String en, String ar) => widget.isArabic ? ar : en;

  String _genderLabel(String? gender) {
    if (gender == 'male') return _text('Male', 'ذكر');
    if (gender == 'female') return _text('Female', 'أنثى');
    return _text('Not set', 'غير محدد');
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
          title: Text(_text('Gender', 'الجنس')),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'male',
                groupValue: selectedGender,
                title: Text(_text('Male', 'ذكر')),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedGender = value);
                  }
                },
              ),
              RadioListTile<String>(
                value: 'female',
                groupValue: selectedGender,
                title: Text(_text('Female', 'أنثى')),
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
              child: Text(_text('Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(selectedGender),
              child: Text(_text('Continue', 'متابعة')),
            ),
          ],
        ),
      ),
    );

    if (!mounted || newGender == null || newGender == currentGender) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_text('Change gender?', 'تغيير الجنس؟')),
        content: Text(
          _text('Are you sure you want to change your gender to ${_genderLabel(newGender)}? Your recommendations will be updated.', 'هل أنت متأكد من تغيير الجنس إلى ${_genderLabel(newGender)}؟ سيتم تحديث توصياتك.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_text('Yes, change', 'نعم، غيّر')),
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
        SnackBar(content: Text(_text('Gender and recommendations updated.', 'تم تحديث الجنس والتوصيات.'))),
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

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final gender = user?.userMetadata?['gender']?.toString();

    return Scaffold(
      appBar: AppBar(title: Text(_text('Settings', 'الإعدادات'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (user != null)
              Card(
                elevation: 0,
                color: Brand.surface,
                child: ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(_text('Gender', 'الجنس')),
                  subtitle: Text(_genderLabel(gender)),
                  trailing: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                        ),
                  onTap: _loading ? null : _changeGender,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    const Icon(Icons.manage_accounts_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      _text('Sign in to manage your account settings.', 'سجل الدخول لإدارة إعدادات حسابك.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Brand.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
