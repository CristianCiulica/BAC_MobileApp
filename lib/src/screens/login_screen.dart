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
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _LandingContent(
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
              final panelHeight = (constraints.maxHeight - 20).clamp(
                560.0,
                constraints.maxHeight,
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SizedBox(
                      height: panelHeight,
                      child: _AuthPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BackButtonRow(onTap: () => Navigator.pop(context)),
                            const Spacer(flex: 1),
                            Text(
                              'Autentificare',
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
                              hint: 'Parolă',
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
                                  'Ai uitat parola?',
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
                              label: 'Intră în cont',
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
                                  'Creează cont nou',
                                  style: TextStyle(
                                    color: _AuthColors.textDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _AuthSectionDivider(label: 'Sau continuă cu'),
                            const SizedBox(height: 10),
                            _SocialAuthRow(
                              enabled: !_isLoading,
                              onGoogleTap: _signInWithGoogle,
                            ),
                            const Spacer(flex: 2),
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
              final panelHeight = (constraints.maxHeight - 20).clamp(
                580.0,
                constraints.maxHeight,
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SizedBox(
                      height: panelHeight,
                      child: _AuthPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BackButtonRow(onTap: () => Navigator.pop(context)),
                            const Spacer(flex: 1),
                            Text(
                              'Creează cont',
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
                              hint: 'Parolă',
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
                              hint: 'Confirmă parola',
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
                              label: 'Creează cont',
                              loading: _isLoading,
                              onPressed: _isLoading ? null : _register,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Ai deja cont',
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
                                'Intră în cont',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _AuthColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _AuthSectionDivider(label: 'Sau continuă cu'),
                            const SizedBox(height: 10),
                            _SocialAuthRow(
                              enabled: !_isLoading,
                              onGoogleTap: _signInWithGoogle,
                            ),
                            const Spacer(flex: 2),
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

class _LandingContent extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _LandingContent({required this.onLogin, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 0),
        Column(
          children: [
            Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: Image.asset(
                    'assets/images/login_hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'BacPro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 46,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Singura aplicație dedicată elevilor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(215),
                height: 1.35,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 58,
                child: CupertinoButton(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: onLogin,
                  child: Text(
                    'Autentificare',
                    style: TextStyle(
                      color: _AuthColors.blueStrong,
                      fontFamily: '.SF Pro Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: CupertinoButton(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: onSignup,
                  child: Text(
                    'Înregistrare',
                    style: TextStyle(
                      color: _AuthColors.blueStrong,
                      fontFamily: '.SF Pro Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          colors: [Color(0xFF0F57DA), Color(0xFF2A78FF)],
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
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

class _AuthSectionDivider extends StatelessWidget {
  final String label;
  const _AuthSectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: _AuthColors.textMuted.withAlpha(70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              color: _AuthColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _AuthColors.textMuted.withAlpha(70),
          ),
        ),
      ],
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
      height: 62,
      child: CupertinoButton(
        color: _AuthColors.blueStrong,
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        onPressed: onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: '.SF Pro Display',
                  fontSize: 25,
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
    return Row(
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
