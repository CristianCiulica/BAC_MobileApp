import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/ui.dart';
import '../models/app_data.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

/// Landing — bright, luminous, Apple-like. Soft color fields under glass.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _openLogin(BuildContext context) {
    AppHaptics.selection();
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const LoginFormScreen()),
    );
  }

  void _openSignup(BuildContext context) {
    AppHaptics.selection();
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      AppColors.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      body: _AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x6,
                  AppSpacing.x5,
                  AppSpacing.x6,
                  AppSpacing.x6,
                ),
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 700 ? 500.0 : 430.0;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x4,
                  AppSpacing.x5,
                  AppSpacing.x4 + keyboardInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _AuthPanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BackButtonRow(onTap: () => Navigator.pop(context)),
                            const SizedBox(height: AppSpacing.x2),
                            Text(
                              'Autentificare',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.label,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Continuă-ți pregătirea.',
                              textAlign: TextAlign.center,
                              style: AppText.subheadStyle,
                            ),
                            const SizedBox(height: AppSpacing.x6),
                            AppInput(
                              controller: _emailController,
                              hint: 'Email',
                              prefixIcon: CupertinoIcons.envelope,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            AppInput(
                              controller: _passwordController,
                              hint: 'Parolă',
                              prefixIcon: CupertinoIcons.lock,
                              obscureText: _obscurePassword,
                              suffix: _VisibilityToggle(
                                obscured: _obscurePassword,
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: _isLoading ? null : _resetPassword,
                                child: const Text(
                                  'Ai uitat parola?',
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            AppButton(
                              label: 'Intră în cont',
                              loading: _isLoading,
                              onPressed: _isLoading ? null : _signIn,
                            ),
                            const SizedBox(height: AppSpacing.x4),
                            const _AuthSectionDivider(label: 'sau continuă cu'),
                            const SizedBox(height: AppSpacing.x4),
                            _GoogleAuthButton(
                              enabled: !_isLoading,
                              onTap: _signInWithGoogle,
                            ),
                            const SizedBox(height: AppSpacing.x5),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  AppHaptics.selection();
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Nu ai cont?  ',
                                    style: AppText.subheadStyle,
                                    children: const [
                                      TextSpan(
                                        text: 'Creează unul',
                                        style: TextStyle(
                                          color: AppColors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 700 ? 500.0 : 430.0;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x4,
                  AppSpacing.x5,
                  AppSpacing.x4 + keyboardInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _AuthPanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BackButtonRow(onTap: () => Navigator.pop(context)),
                            const SizedBox(height: AppSpacing.x2),
                            Text(
                              'Creează cont',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.label,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Îți salvăm progresul și sesiunile.',
                              textAlign: TextAlign.center,
                              style: AppText.subheadStyle,
                            ),
                            const SizedBox(height: AppSpacing.x6),
                            AppInput(
                              controller: _emailController,
                              hint: 'Email',
                              prefixIcon: CupertinoIcons.envelope,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            AppInput(
                              controller: _passwordController,
                              hint: 'Parolă',
                              prefixIcon: CupertinoIcons.lock,
                              obscureText: _obscurePassword,
                              suffix: _VisibilityToggle(
                                obscured: _obscurePassword,
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            AppInput(
                              controller: _confirmController,
                              hint: 'Confirmă parola',
                              prefixIcon: CupertinoIcons.lock_rotation,
                              obscureText: _obscureConfirm,
                              suffix: _VisibilityToggle(
                                obscured: _obscureConfirm,
                                onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x5),
                            AppButton(
                              label: 'Creează cont',
                              loading: _isLoading,
                              onPressed: _isLoading ? null : _register,
                            ),
                            const SizedBox(height: AppSpacing.x4),
                            const _AuthSectionDivider(label: 'sau continuă cu'),
                            const SizedBox(height: AppSpacing.x4),
                            _GoogleAuthButton(
                              enabled: !_isLoading,
                              onTap: _signInWithGoogle,
                            ),
                            const SizedBox(height: AppSpacing.x5),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  AppHaptics.selection();
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => const LoginFormScreen(),
                                    ),
                                  );
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Ai deja cont?  ',
                                    style: AppText.subheadStyle,
                                    children: const [
                                      TextSpan(
                                        text: 'Intră în cont',
                                        style: TextStyle(
                                          color: AppColors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
        const Spacer(flex: 2),
        Column(
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.floating,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl - 2),
                child: Image.asset(
                  'assets/images/login_hero.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            Text(
              'BacPro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: AppColors.label,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Bacalaureatul, mai simplu.',
              textAlign: TextAlign.center,
              style: AppText.subheadStyle.copyWith(fontSize: 16, height: 1.4),
            ),
          ],
        ),
        const Spacer(flex: 3),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(label: 'Autentificare', onPressed: onLogin, height: 56),
              const SizedBox(height: AppSpacing.x3),
              AppButton(
                label: 'Creează cont',
                onPressed: onSignup,
                style: AppButtonStyle.glass,
                height: 56,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bright, luminous background: off-white canvas with soft blue/cyan fields.
class _AuroraBackground extends StatelessWidget {
  final Widget child;
  const _AuroraBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.loginBackground),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _GlowField(
            color: AppColors.blue.withValues(
              alpha: AppColors.isDark ? 0.10 : 0.07,
            ),
            alignment: Alignment.topLeft,
            size: 420,
            dx: -120,
            dy: -140,
          ),
          _GlowField(
            color: AppColors.cyan.withValues(
              alpha: AppColors.isDark ? 0.07 : 0.08,
            ),
            alignment: Alignment.bottomRight,
            size: 440,
            dx: 140,
            dy: 180,
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowField extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double size;
  final double dx;
  final double dy;

  const _GlowField({
    required this.color,
    required this.alignment,
    required this.size,
    this.dx = 0,
    this.dy = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass auth panel.
class _AuthPanel extends StatelessWidget {
  final Widget child;
  const _AuthPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppRadius.xl,
      shadows: AppShadows.floating,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x6,
        AppSpacing.x5,
        AppSpacing.x6,
        AppSpacing.x6,
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
        Expanded(child: Container(height: 0.5, color: AppColors.separator)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text(label, style: AppText.captionStyle),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.separator)),
      ],
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;

  const _VisibilityToggle({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          obscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          size: 19,
          color: AppColors.tertiaryLabel,
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
          CupertinoIcons.chevron_back,
          size: 24,
          color: AppColors.blue,
        ),
      ),
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _GoogleAuthButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled
          ? () {
              AppHaptics.light();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.separator),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                painter: _GoogleLogoPainter(),
                size: const Size(22, 22),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Continuă cu Google',
                style: TextStyle(
                  color: AppColors.label,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the four-color Google "G": red top, yellow left, green bottom,
/// blue upper-right plus the horizontal crossbar entering from the right.
class _GoogleLogoPainter extends CustomPainter {
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);
  static const _blue = Color(0xFF4285F4);

  double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.22;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Angles are clockwise from east (3 o'clock); the right side stays open
    // for the crossbar.
    paint.color = _green;
    canvas.drawArc(rect, _rad(40), _rad(95), false, paint);
    paint.color = _yellow;
    canvas.drawArc(rect, _rad(135), _rad(75), false, paint);
    paint.color = _red;
    canvas.drawArc(rect, _rad(210), _rad(100), false, paint);
    paint.color = _blue;
    canvas.drawArc(rect, _rad(310), _rad(42), false, paint);

    // Blue crossbar: from the centre out to the ring on the right side.
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _blue;
    final barRect = Rect.fromLTRB(
      center.dx - strokeWidth * 0.1,
      center.dy - strokeWidth / 2,
      center.dx + radius + strokeWidth / 2,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
