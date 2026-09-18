import 'package:flutter/material.dart';

import '../../core/brand.dart';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _details = TextEditingController();
  String? _category;

  String _text(String english, String arabic) =>
      widget.isArabic ? arabic : english;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      _text('Order problem', 'مشكلة في طلب'),
      _text('Payment problem', 'مشكلة في الدفع'),
      _text('Account problem', 'مشكلة في الحساب'),
      _text('Store problem', 'مشكلة في متجر'),
      _text('Other', 'أخرى'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_text('Report a problem', 'الإبلاغ عن مشكلة'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              _text(
                'What can we help you with?',
                'كيف نقدر نساعدك؟',
              ),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              _text(
                'Choose the problem type and tell us what happened.',
                'اختر نوع المشكلة واكتب لنا ماذا حدث.',
              ),
              style: const TextStyle(color: Brand.muted),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: _text('Problem type', 'نوع المشكلة'),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _details,
              minLines: 5,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: _text('Describe the problem', 'اشرح المشكلة'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (_category == null || _details.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _text(
                          'Choose a problem type and add details.',
                          'اختر نوع المشكلة وأضف التفاصيل.',
                        ),
                      ),
                    ),
                  );
                  return;
                }
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(_text('Report prepared', 'تم تجهيز البلاغ')),
                    content: Text(
                      _text(
                        'The support submission channel will be connected in the next setup step.',
                        'سيتم ربط إرسال البلاغ إلى الدعم في خطوة الإعداد القادمة.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(_text('OK', 'حسناً')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded),
              label: Text(_text('Continue', 'متابعة')),
            ),
          ],
        ),
      ),
    );
  }
}
