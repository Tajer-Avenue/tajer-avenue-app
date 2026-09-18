import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();

    if (email.isEmpty || password.length < 6 || (_signUp && name.isEmpty)) {
      _message('Enter a valid email, name, and a password of at least 6 characters.');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_signUp) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );
        if (!mounted) return;
        if (response.session == null) {
          _message('Account created. Check your email to confirm your account.');
        } else {
          widget.onBack();
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted) widget.onBack();
      }
    } on AuthException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back_rounded)),
          title: Text(_signUp ? 'Create account' : 'Sign in'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(Brand.wordmark, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    const Text(Brand.submark, style: TextStyle(color: Brand.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 32),
                    if (_signUp) ...[
                      TextField(controller: _name, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.name], decoration: const InputDecoration(labelText: 'Full name')),
                      const SizedBox(height: 12),
                    ],
                    TextField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      onSubmitted: (_) => _loading ? null : _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_signUp ? 'Create account' : 'Sign in'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loading ? null : () => setState(() => _signUp = !_signUp),
                      child: Text(_signUp ? 'Already have an account? Sign in' : 'New to Tajer Avenue? Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

}
