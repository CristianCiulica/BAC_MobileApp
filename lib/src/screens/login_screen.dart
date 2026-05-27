import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import 'main_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _openLogin(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const LoginFormScreen()),
    );
  }

  void _openSignup(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1180) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1500),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -8,
                            right: 315,
                            child: const _FloatingSymbol(
                              icon: CupertinoIcons.lock_fill,
                              size: 110,
                              color: Color(0xFF5B2BFF),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _EntryCard(
                                  onLogin: () => _openLogin(context),
                                  onSignup: () => _openSignup(context),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: Transform.rotate(
                                  angle: -0.08,
                                  child: _LoginPreviewCard(
                                    onLogin: () => _openLogin(context),
                                    onSignup: () => _openSignup(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: _SignupPreviewCard(
                                  onSignup: () => _openSignup(context),
                                  onLogin: () => _openLogin(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _EntryCard(
                        onLogin: () => _openLogin(context),
                        onSignup: () => _openSignup(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Completează email-ul și parola.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithEmail(email, password);
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyLoginError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (!mounted) return;
      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }
      _goToDashboard();
    } catch (_) {
      if (!mounted) return;
      _showError('Autentificare Google eșuată. Încearcă din nou.');
      setState(() => _isLoading = false);
    }
  }

  void _goToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showError('Introdu email-ul mai întâi.');
      return;
    }
    try {
      await AuthService.resetPassword(email);
      _showInfo('Email de resetare trimis la $email');
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyLoginError(e.code));
    }
  }

  String _friendlyLoginError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nu există un cont cu acest email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email sau parolă incorectă.';
      case 'invalid-email':
        return 'Adresa de email nu este validă.';
      case 'too-many-requests':
        return 'Prea multe încercări. Încearcă mai târziu.';
      case 'network-request-failed':
        return 'Eroare de rețea. Verifică conexiunea.';
      default:
        return 'Eroare la autentificare. Încearcă din nou.';
    }
  }

  Future<void> _showDialog(String title, String message) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) => _showDialog('Eroare', msg);
  void _showInfo(String msg) => _showDialog('Info', msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 700 ? 640.0 : 460.0;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: _AuthPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BackButtonRow(onTap: () => Navigator.pop(context)),
                          Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: '.SF Pro Display',
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: _AuthColors.blueStrong,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lucrează un subiect :)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: '.SF Pro Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _AuthColors.textDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _AuthField(
                            controller: _emailController,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            outlined: true,
                          ),
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _passwordController,
                            hint: 'Password',
                            obscureText: _obscurePassword,
                            suffix: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Icon(
                                  _obscurePassword
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash,
                                  size: 18,
                                  color: _AuthColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              onPressed: _isLoading ? null : _resetPassword,
                              child: Text(
                                'Forgot your password?',
                                style: TextStyle(
                                  color: _AuthColors.blueStrong,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _PrimaryAuthButton(
                            label: 'Sign in',
                            loading: _isLoading,
                            onPressed: _isLoading ? null : _signIn,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Create new account',
                                style: TextStyle(
                                  color: _AuthColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SocialAuthRow(
                            enabled: !_isLoading,
                            onGoogleTap: _signInWithGoogle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Completează toate câmpurile.');
      return;
    }
    if (password != confirm) {
      _showError('Parolele nu coincid.');
      return;
    }
    if (password.length < 6) {
      _showError('Parola trebuie să aibă cel puțin 6 caractere.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.registerWithEmail(email, password);
      await AuthService.updateDisplayName(email.split('@').first);
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyRegisterError(e.code));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (!mounted) return;
      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }
      _goToDashboard();
    } catch (_) {
      if (!mounted) return;
      _showError('Autentificare Google eșuată. Încearcă din nou.');
      setState(() => _isLoading = false);
    }
  }

  void _goToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  String _friendlyRegisterError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Există deja un cont cu acest email.';
      case 'invalid-email':
        return 'Adresa de email nu este validă.';
      case 'weak-password':
        return 'Parola este prea slabă.';
      case 'network-request-failed':
        return 'Eroare de rețea. Verifică conexiunea.';
      default:
        return 'Eroare la creare cont. Încearcă din nou.';
    }
  }

  Future<void> _showDialog(String title, String message) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) => _showDialog('Eroare', msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 700 ? 640.0 : 460.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _AuthPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BackButtonRow(onTap: () => Navigator.pop(context)),
                            Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: _AuthColors.blueStrong,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Creează un cont pentru a salva\nprogresul și sesiunile tale BAC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _AuthColors.textDark,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _AuthField(
                              controller: _emailController,
                              hint: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              outlined: true,
                            ),
                            const SizedBox(height: 12),
                            _AuthField(
                              controller: _passwordController,
                              hint: 'Password',
                              obscureText: _obscurePassword,
                              suffix: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(
                                    _obscurePassword
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    size: 18,
                                    color: _AuthColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _AuthField(
                              controller: _confirmController,
                              hint: 'Confirm Password',
                              obscureText: _obscureConfirm,
                              suffix: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(
                                    _obscureConfirm
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    size: 18,
                                    color: _AuthColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PrimaryAuthButton(
                              label: 'Sign up',
                              loading: _isLoading,
                              onPressed: _isLoading ? null : _register,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Already have an account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _AuthColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => const LoginFormScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign in',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _AuthColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SocialAuthRow(
                              enabled: !_isLoading,
                              onGoogleTap: _signInWithGoogle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _EntryCard({required this.onLogin, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return _AuthPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECFA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD3DCF7)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.asset(
                'assets/images/login_hero.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'BacPro',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: _AuthColors.blueStrong,
              height: 1.05,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Singura aplicație dedicată elevilor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _AuthColors.textDark,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  color: _AuthColors.blueStrong,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: onLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: '.SF Pro Display',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  color: const Color(0xFFECEFF6),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: onSignup,
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      color: _AuthColors.textDark,
                      fontFamily: '.SF Pro Display',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginPreviewCard extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _LoginPreviewCard({required this.onLogin, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return _AuthPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: _AuthColors.blueStrong,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lucrează un subiect :)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _AuthColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          const _PreviewField(hint: 'Email', outlined: true),
          const SizedBox(height: 10),
          const _PreviewField(hint: 'Password'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot your password?',
              style: TextStyle(
                color: _AuthColors.blueStrong,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          CupertinoButton(
            color: _AuthColors.blueStrong,
            borderRadius: BorderRadius.circular(14),
            onPressed: onLogin,
            child: const Text(
              'Sign in',
              style: TextStyle(
                color: Colors.white,
                fontFamily: '.SF Pro Display',
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onSignup,
            child: Text(
              'Create new account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _AuthColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SocialPreviewRow(),
        ],
      ),
    );
  }
}

class _SignupPreviewCard extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback onLogin;

  const _SignupPreviewCard({required this.onSignup, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return _AuthPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _AuthColors.blueStrong,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creează cont pentru progresul tău BAC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _AuthColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          const _PreviewField(hint: 'Email', outlined: true),
          const SizedBox(height: 10),
          const _PreviewField(hint: 'Password'),
          const SizedBox(height: 10),
          const _PreviewField(hint: 'Confirm Password'),
          const SizedBox(height: 12),
          CupertinoButton(
            color: _AuthColors.blueStrong,
            borderRadius: BorderRadius.circular(14),
            onPressed: onSignup,
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: Colors.white,
                fontFamily: '.SF Pro Display',
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Already have an account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AuthColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onLogin,
            child: Text(
              'Sign in',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _AuthColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _SocialPreviewRow(),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  final Widget child;
  const _AuthBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1662EB), Color(0xFF2E7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _Blob(
            width: 430,
            height: 520,
            color: Color(0x3348A6FF),
            alignment: Alignment.bottomLeft,
            dx: -100,
            dy: 120,
          ),
          const _Blob(
            width: 380,
            height: 430,
            color: Color(0x224CA6FF),
            alignment: Alignment.topRight,
            dx: 82,
            dy: -90,
          ),
          const _Blob(
            width: 260,
            height: 220,
            color: Color(0x663EC7AF),
            alignment: Alignment.bottomRight,
            dx: 78,
            dy: 66,
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Alignment alignment;
  final double dx;
  final double dy;

  const _Blob({
    required this.width,
    required this.height,
    required this.color,
    required this.alignment,
    this.dx = 0,
    this.dy = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height * 0.52),
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  final Widget child;
  const _AuthPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      decoration: BoxDecoration(
        color: _AuthColors.card,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool outlined;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.outlined = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: outlined ? Colors.white : const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: outlined ? _AuthColors.blueStrong : const Color(0xFFECEFF6),
          width: outlined ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: _AuthColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _AuthColors.textMuted,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _PrimaryAuthButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CupertinoButton(
        color: _AuthColors.blueStrong,
        borderRadius: BorderRadius.circular(14),
        onPressed: onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: '.SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _BackButtonRow extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButtonRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: Icon(
          CupertinoIcons.back,
          size: 24,
          color: _AuthColors.blueStrong,
        ),
      ),
    );
  }
}

class _SocialAuthRow extends StatelessWidget {
  final bool enabled;
  final VoidCallback onGoogleTap;

  const _SocialAuthRow({required this.enabled, required this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            color: _AuthColors.blueStrong,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIconSquare(
              enabled: enabled,
              onTap: onGoogleTap,
              child: CustomPaint(
                painter: _GoogleLogoPainter(),
                size: const Size(20, 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialPreviewRow extends StatelessWidget {
  const _SocialPreviewRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            color: _AuthColors.blueStrong,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [_StaticSocialIcon(child: _StaticGoogleIcon())],
        ),
      ],
    );
  }
}

class _SocialIconSquare extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback onTap;

  const _SocialIconSquare({
    required this.child,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: _StaticSocialIcon(child: child),
      ),
    );
  }
}

class _StaticSocialIcon extends StatelessWidget {
  final Widget child;
  const _StaticSocialIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }
}

class _StaticGoogleIcon extends StatelessWidget {
  const _StaticGoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter(), size: const Size(20, 20));
  }
}

class _PreviewField extends StatelessWidget {
  final String hint;
  final bool outlined;
  const _PreviewField({required this.hint, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: outlined ? Colors.white : const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: outlined ? _AuthColors.blueStrong : const Color(0xFFECEFF6),
          width: outlined ? 2 : 1,
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        hint,
        style: TextStyle(
          color: _AuthColors.textMuted,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FloatingSymbol extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const _FloatingSymbol({
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(34),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.45, color: Colors.white),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF4F4F4));

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFamily: '.SF Pro Display',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthColors {
  static const Color card = Color(0xFFF3F5FB);
  static const Color blueStrong = Color(0xFF2A4CC8);
  static const Color textDark = Color(0xFF111111);
  static const Color textMuted = Color(0xFF666B78);
}
