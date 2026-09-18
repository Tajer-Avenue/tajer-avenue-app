import 'dart:async';

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
  static const _emailRedirectUrl =
      'https://tajer-avenue.github.io/tajer-avenue-app/';

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Timer? _resendTimer;
  bool _signUp = false;
  bool _loading = false;
  bool _obscure = true;
  bool _awaitingConfirmation = false;
  int _secondsRemaining = 60;
  String _pendingEmail = '';

  @override
  void dispose() {
    _resendTimer?.cancel();
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
          emailRedirectTo: _emailRedirectUrl,
          data: {'full_name': name},
        );
        if (!mounted) return;
        if (response.session == null) {
          _showConfirmation(email);
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
      _message(_friendlyAuthError(error));
    } catch (_) {
      _message('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showConfirmation(String email) {
    _resendTimer?.cancel();
    setState(() {
      _pendingEmail = email;
      _awaitingConfirmation = true;
      _secondsRemaining = 60;
    });
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendConfirmation() async {
    if (_secondsRemaining > 0 || _loading || _pendingEmail.isEmpty) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _pendingEmail,
        emailRedirectTo: _emailRedirectUrl,
      );
      if (!mounted) return;
      setState(() => _secondsRemaining = 60);
      _startResendTimer();
      _message('A new confirmation email has been sent.');
    } on AuthException catch (error) {
      _message(_friendlyAuthError(error));
    } catch (_) {
      _message('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyAuthError(AuthException error) {
    if (error.message.toLowerCase().contains('email rate limit')) {
      return 'Too many confirmation emails were requested. Please try again in one hour.';
    }
    return error.message;
  }

  void _changeEmail() {
    _resendTimer?.cancel();
    setState(() {
      _awaitingConfirmation = false;
      _secondsRemaining = 60;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            _awaitingConfirmation
                ? 'Confirm your email'
                : (_signUp ? 'Create account' : 'Sign in'),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _awaitingConfirmation
                    ? _confirmationContent()
                    : _authForm(),
              ),
            ),
          ),
        ),
      );

  Widget _confirmationContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 72,
            color: Brand.accent,
          ),
          const SizedBox(height: 24),
          const Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a confirmation link to\n$_pendingEmail',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.muted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.tonal(
            onPressed: _secondsRemaining == 0 && !_loading
                ? _resendConfirmation
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _secondsRemaining > 0
                          ? 'Resend email in 00:' +
                              _secondsRemaining.toString().padLeft(2, '0')
                          : 'Resend confirmation email',
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : _changeEmail,
            child: const Text('Use a different email'),
          ),
        ],
      );

  Widget _authForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            Brand.wordmark,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const Text(
            Brand.submark,
            style: TextStyle(
              color: Brand.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          if (_signUp) ...[
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _loading ? null : _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_signUp ? 'Create account' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() => _signUp = !_signUp),
            child: Text(
              _signUp
                  ? 'Already have an account? Sign in'
                  : 'New to Tajer Avenue? Create account',
            ),
          ),
        ],
      );
}
