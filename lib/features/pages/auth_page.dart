import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/brand.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.onBack,
    this.initialSignUp = false,
    required this.isArabic,
  });

  final VoidCallback onBack;
  final bool initialSignUp;
  final bool isArabic;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _text(String en, String ar) => widget.isArabic ? ar : en;
  static const _emailRedirectUrl =
      'https://tajer-avenue.github.io/tajer-avenue-app/';
  static const _emailRateLimitUntilKey = 'email_rate_limit_until';

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Timer? _resendTimer;
  Timer? _rateLimitTimer;
  late bool _signUp;
  bool _loading = false;
  bool _obscure = true;
  bool _awaitingConfirmation = false;
  int _secondsRemaining = 60;
  int _rateLimitSecondsRemaining = 0;
  String _pendingEmail = '';
  String? _gender;
  DateTime? _emailRateLimitUntil;

  @override
  void initState() {
    super.initState();
    _signUp = widget.initialSignUp;
    _restoreEmailRateLimit();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _rateLimitTimer?.cancel();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();

    if (email.isEmpty ||
        password.length < 6 ||
        (_signUp && (name.isEmpty || _gender == null))) {
      _message(_signUp
          ? 'Enter your name, gender, a valid email, and a password of at least 6 characters.'
          : 'Enter a valid email and a password of at least 6 characters.');
      return;
    }

    if (_signUp && _rateLimitSecondsRemaining > 0) {
      _message(_rateLimitMessage);
      return;
    }

    setState(() => _loading = true);
    try {
      if (_signUp) {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: _emailRedirectUrl,
          data: {'full_name': name, 'gender': _gender},
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
      await _handleAuthError(error);
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
    if (_rateLimitSecondsRemaining > 0) {
      _message(_rateLimitMessage);
      return;
    }
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
      await _handleAuthError(error);
    } catch (_) {
      _message('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restoreEmailRateLimit() async {
    final preferences = await SharedPreferences.getInstance();
    final savedUntil = preferences.getString(_emailRateLimitUntilKey);
    if (savedUntil == null) return;

    final until = DateTime.tryParse(savedUntil);
    if (until == null || !until.isAfter(DateTime.now())) {
      await preferences.remove(_emailRateLimitUntilKey);
      return;
    }

    _emailRateLimitUntil = until;
    if (!mounted) return;
    _updateRateLimitRemaining();
    _startRateLimitTimer();
  }

  Future<void> _beginEmailRateLimit() async {
    final until = DateTime.now().add(const Duration(hours: 1));
    _emailRateLimitUntil = until;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_emailRateLimitUntilKey, until.toIso8601String());
    if (!mounted) return;
    _updateRateLimitRemaining();
    _startRateLimitTimer();
  }

  void _startRateLimitTimer() {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateRateLimitRemaining();
      if (_rateLimitSecondsRemaining == 0) {
        timer.cancel();
        SharedPreferences.getInstance().then(
          (preferences) => preferences.remove(_emailRateLimitUntilKey),
        );
      }
    });
  }

  void _updateRateLimitRemaining() {
    final until = _emailRateLimitUntil;
    final remaining = until?.difference(DateTime.now()).inSeconds ?? 0;
    if (!mounted) return;
    setState(() {
      _rateLimitSecondsRemaining = remaining > 0 ? remaining + 1 : 0;
      if (_rateLimitSecondsRemaining == 0) _emailRateLimitUntil = null;
    });
  }

  String get _formattedRateLimit {
    final minutes = _rateLimitSecondsRemaining ~/ 60;
    final seconds = _rateLimitSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get _rateLimitMessage =>
      'Email limit reached. Please try again in $_formattedRateLimit.';

  Future<void> _handleAuthError(AuthException error) async {
    if (error.message.toLowerCase().contains('email rate limit')) {
      await _beginEmailRateLimit();
      _message(_rateLimitMessage);
      return;
    }
    _message(error.message);
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
          title: Text(_awaitingConfirmation ? _text('Confirm your email', 'تأكيد البريد الإلكتروني') : (_signUp ? _text('Create account', 'إنشاء حساب') : _text('Sign in', 'تسجيل الدخول'))),
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
          Text(
            _text('Check your email', 'تحقق من بريدك الإلكتروني'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            _text('We sent a confirmation link to\n$_pendingEmail', 'أرسلنا رابط التأكيد إلى\n$_pendingEmail'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Brand.muted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.tonal(
            onPressed: _secondsRemaining == 0 &&
                    _rateLimitSecondsRemaining == 0 &&
                    !_loading
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
                      _rateLimitSecondsRemaining > 0
                          ? 'Try again in $_formattedRateLimit'
                          : _secondsRemaining > 0
                              ? 'Resend email in 00:' +
                                  _secondsRemaining.toString().padLeft(2, '0')
                              : _text('Resend confirmation email', 'إعادة إرسال رسالة التأكيد'),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading ? null : _changeEmail,
            child: Text(_text('Use a different email', 'استخدام بريد إلكتروني آخر')),
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
              decoration: InputDecoration(labelText: _text('Full name', 'الاسم الكامل')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                labelText: _text('Gender', 'الجنس'),
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              hint: Text(_text('Select gender', 'اختر الجنس')),
              items: [
                DropdownMenuItem(value: 'male', child: Text(_text('Male', 'ذكر'))),
                DropdownMenuItem(value: 'female', child: Text(_text('Female', 'أنثى'))),
              ],
              onChanged: _loading
                  ? null
                  : (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: _text('Email', 'البريد الإلكتروني')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _loading ? null : _submit(),
            decoration: InputDecoration(
              labelText: _text('Password', 'كلمة المرور'),
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
          if (_signUp && _rateLimitSecondsRemaining > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Brand.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: Brand.ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _rateLimitMessage,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  : Text(_signUp ? _text('Create account', 'إنشاء حساب') : _text('Sign in', 'تسجيل الدخول')),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _loading
                ? null
                : () => setState(() => _signUp = !_signUp),
            child: Text(
              _signUp
                  ? _text('Already have an account? Sign in', 'لديك حساب بالفعل؟ سجل الدخول')
                  : _text('New to Tajer Avenue? Create account', 'جديد في تاجر أفينيو؟ أنشئ حساباً'),
            ),
          ),
        ],
      );
}
