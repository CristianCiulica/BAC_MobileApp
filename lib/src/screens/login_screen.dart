import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
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
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.signInWithGoogle();
      if (result == null && mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Autentificare Google eșuată. Încearcă din nou.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Introdu email-ul mai întâi.');
      return;
    }
    try {
      await AuthService.resetPassword(email);
      _showInfo('Email de resetare trimis la $email');
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nu există un cont cu acest email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email sau parolă incorectă.';
      case 'invalid-email':
        return 'Adresa de email nu este validă.';
      case 'user-disabled':
        return 'Contul a fost dezactivat.';
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

  void _openRegister() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Widget _buildActiveCard() {
    return Transform.rotate(
      angle: -0.045,
      child: _AuthPanel(
        width: 440,
        child: Transform.rotate(
          angle: 0.045,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Text(
                'Login here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 47,
                  fontWeight: FontWeight.w800,
                  color: _AuthPalette.blueStrong,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome back you've\nbeen missed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: _AuthPalette.textDark,
                ),
              ),
              const SizedBox(height: 24),
              _AuthField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                outlined: true,
              ),
              const SizedBox(height: 14),
              _AuthField(
                controller: _passwordController,
                hint: 'Password',
                obscureText: _obscurePassword,
                suffix: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      size: 18,
                      color: _AuthPalette.textMuted,
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
                      color: _AuthPalette.blueStrong,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryAuthButton(
                label: 'Sign in',
                loading: _isLoading,
                onPressed: _isLoading ? null : _signIn,
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: _openRegister,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 16,
                        color: _AuthPalette.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Create new account '),
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: _AuthPalette.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _SocialAuthRow(
                enabled: !_isLoading,
                onGoogleTap: _signInWithGoogle,
                onOtherTap: () => _showInfo('Facebook și Apple vin curând.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _AuthSceneLayout(
                leftCard: _DiscoverSideCard(onPrimaryTap: () {}),
                centerCard: _buildActiveCard(),
                rightCard: _RegisterPreviewCard(onPrimaryTap: _openRegister),
                mobileTop: const _BacHeroShowcase(),
                mobileCard: _buildActiveCard(),
              ),
            ),
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

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
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
      final fallbackName = email.split('@').first;
      await AuthService.updateDisplayName(fallbackName);
      // StreamBuilder-ul din root va muta utilizatorul în app.
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      _showError('Autentificare Google eșuată. Încearcă din nou.');
      setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Există deja un cont cu acest email.';
      case 'invalid-email':
        return 'Adresa de email nu este validă.';
      case 'weak-password':
        return 'Parola este prea slabă. Folosește cel puțin 6 caractere.';
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
  void _showInfo(String msg) => _showDialog('Info', msg);

  Widget _buildActiveCard() {
    return _AuthPanel(
      width: 440,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: _AuthPalette.blueStrong,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create an account so you can\nexplore all Bac Pro subjects',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: _AuthPalette.textDark,
            ),
          ),
          const SizedBox(height: 24),
          _AuthField(
            controller: _emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            outlined: true,
          ),
          const SizedBox(height: 14),
          _AuthField(
            controller: _passwordController,
            hint: 'Password',
            obscureText: _obscurePassword,
            suffix: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _obscurePassword = !_obscurePassword);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  _obscurePassword
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  size: 18,
                  color: _AuthPalette.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _AuthField(
            controller: _confirmController,
            hint: 'Confirm Password',
            obscureText: _obscureConfirm,
            suffix: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  _obscureConfirm
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                  size: 18,
                  color: _AuthPalette.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PrimaryAuthButton(
            label: 'Sign up',
            loading: _isLoading,
            onPressed: _isLoading ? null : _register,
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 16,
                    color: _AuthPalette.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: _AuthPalette.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _SocialAuthRow(
            enabled: !_isLoading,
            onGoogleTap: _signInWithGoogle,
            onOtherTap: () => _showInfo('Facebook și Apple vin curând.'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: _AuthBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _AuthSceneLayout(
                leftCard: _DiscoverSideCard(
                  onPrimaryTap: () => Navigator.pop(context),
                ),
                centerCard: _buildActiveCard(),
                rightCard: _LoginPreviewCard(
                  onPrimaryTap: () => Navigator.pop(context),
                ),
                mobileTop: const _BacHeroShowcase(),
                mobileCard: _buildActiveCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSceneLayout extends StatelessWidget {
  final Widget leftCard;
  final Widget centerCard;
  final Widget rightCard;
  final Widget mobileTop;
  final Widget mobileCard;

  const _AuthSceneLayout({
    required this.leftCard,
    required this.centerCard,
    required this.rightCard,
    required this.mobileTop,
    required this.mobileCard,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1180) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1420),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -10,
                      right: 290,
                      child: _FloatingRoundIcon(
                        icon: CupertinoIcons.lock_fill,
                        size: 112,
                        color: const Color(0xFF5B2BFF),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftCard),
                        const SizedBox(width: 22),
                        Expanded(child: centerCard),
                        const SizedBox(width: 22),
                        Expanded(child: rightCard),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
          child: Column(
            children: [
              mobileTop,
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: mobileCard,
              ),
            ],
          ),
        );
      },
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
            width: 420,
            height: 520,
            color: Color(0x3348A6FF),
            alignment: Alignment.bottomLeft,
            dx: -110,
            dy: 120,
          ),
          const _Blob(
            width: 360,
            height: 430,
            color: Color(0x224CA6FF),
            alignment: Alignment.topRight,
            dx: 80,
            dy: -90,
          ),
          const _Blob(
            width: 260,
            height: 220,
            color: Color(0x663EC7AF),
            alignment: Alignment.bottomRight,
            dx: 80,
            dy: 70,
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
            borderRadius: BorderRadius.circular(height * 0.5),
          ),
        ),
      ),
    );
  }
}

class _BacHeroShowcase extends StatelessWidget {
  const _BacHeroShowcase();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(24),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.doc_text_fill,
                  color: _AuthPalette.blueStrong,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bac Pro',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const _FloatingRoundIcon(
                icon: CupertinoIcons.sparkles,
                size: 52,
                color: Color(0xFF4B86FF),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroBadge(icon: CupertinoIcons.book_fill, label: 'Subiecte PDF'),
              _HeroBadge(icon: CupertinoIcons.clock_fill, label: 'Timer 3h'),
              _HeroBadge(
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Coach pe barem',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(74)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  final Widget child;
  final double width;
  const _AuthPanel({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
      decoration: BoxDecoration(
        color: _AuthPalette.card,
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
      height: 62,
      decoration: BoxDecoration(
        color: outlined ? Colors.white : const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: outlined ? _AuthPalette.blueStrong : const Color(0xFFECEFF6),
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
                fontSize: 27,
                fontWeight: FontWeight.w500,
                color: _AuthPalette.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _AuthPalette.textMuted,
                  fontSize: 27,
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
      height: 64,
      child: CupertinoButton(
        color: _AuthPalette.blueStrong,
        borderRadius: BorderRadius.circular(14),
        onPressed: onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _SocialAuthRow extends StatelessWidget {
  final bool enabled;
  final VoidCallback onGoogleTap;
  final VoidCallback onOtherTap;

  const _SocialAuthRow({
    required this.enabled,
    required this.onGoogleTap,
    required this.onOtherTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _AuthPalette.blueStrong,
          ),
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
            _SocialIconSquare(
              enabled: enabled,
              onTap: onOtherTap,
              child: const Icon(
                CupertinoIcons.person_2_fill,
                size: 22,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 12),
            _SocialIconSquare(
              enabled: enabled,
              onTap: onOtherTap,
              child: const Icon(
                Icons.apple,
                size: 24,
                color: Color(0xFF111111),
              ),
            ),
          ],
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
        child: Container(
          width: 56,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _DiscoverSideCard extends StatelessWidget {
  final VoidCallback onPrimaryTap;
  const _DiscoverSideCard({required this.onPrimaryTap});

  @override
  Widget build(BuildContext context) {
    return _AuthPanel(
      width: 420,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 190,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              CupertinoIcons.book_circle_fill,
              color: Color(0xFF2A53CC),
              size: 84,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Discover Your\nBest Grade Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 50,
              fontWeight: FontWeight.w800,
              color: _AuthPalette.blueStrong,
              letterSpacing: -0.6,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore subiecte oficiale și bareme\npentru profilul tău.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 20,
              color: _AuthPalette.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: _AuthPalette.blueStrong,
              borderRadius: BorderRadius.circular(14),
              onPressed: onPrimaryTap,
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
          const SizedBox(height: 14),
          Text(
            'Register',
            style: TextStyle(
              color: _AuthPalette.textDark,
              fontFamily: '.SF Pro Display',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterPreviewCard extends StatelessWidget {
  final VoidCallback onPrimaryTap;
  const _RegisterPreviewCard({required this.onPrimaryTap});

  @override
  Widget build(BuildContext context) {
    return _AuthPanel(
      width: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: _AuthPalette.blueStrong,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account so you can explore all the existing subjects',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 18,
              color: _AuthPalette.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 22),
          const _PreviewField(hint: 'Email', outlined: true),
          const SizedBox(height: 12),
          const _PreviewField(hint: 'Password'),
          const SizedBox(height: 12),
          const _PreviewField(hint: 'Confirm Password'),
          const SizedBox(height: 20),
          CupertinoButton(
            color: _AuthPalette.blueStrong,
            borderRadius: BorderRadius.circular(14),
            onPressed: onPrimaryTap,
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: Colors.white,
                fontFamily: '.SF Pro Display',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Already have an account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 17,
              color: _AuthPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SocialAuthRow(
            enabled: true,
            onGoogleTap: onPrimaryTap,
            onOtherTap: onPrimaryTap,
          ),
        ],
      ),
    );
  }
}

class _LoginPreviewCard extends StatelessWidget {
  final VoidCallback onPrimaryTap;
  const _LoginPreviewCard({required this.onPrimaryTap});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.03,
      child: _AuthPanel(
        width: 420,
        child: Transform.rotate(
          angle: 0.03,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: _AuthPalette.blueStrong,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Welcome back you've\nbeen missed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _AuthPalette.textDark,
                ),
              ),
              const SizedBox(height: 22),
              const _PreviewField(hint: 'Email', outlined: true),
              const SizedBox(height: 12),
              const _PreviewField(hint: 'Password'),
              const SizedBox(height: 16),
              CupertinoButton(
                color: _AuthPalette.blueStrong,
                borderRadius: BorderRadius.circular(14),
                onPressed: onPrimaryTap,
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: '.SF Pro Display',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SocialAuthRow(
                enabled: true,
                onGoogleTap: onPrimaryTap,
                onOtherTap: onPrimaryTap,
              ),
            ],
          ),
        ),
      ),
    );
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
          color: outlined ? _AuthPalette.blueStrong : const Color(0xFFECEFF6),
          width: outlined ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        hint,
        style: TextStyle(
          color: _AuthPalette.textMuted,
          fontSize: 26,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FloatingRoundIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const _FloatingRoundIcon({
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
            color: Colors.black.withAlpha(36),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.46, color: Colors.white),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final fill = Paint()..color = const Color(0xFFF4F4F4);
    canvas.drawCircle(center, radius, fill);

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

class _AuthPalette {
  static const Color card = Color(0xFFF3F5FB);
  static const Color blueStrong = Color(0xFF2A4CC8);
  static const Color textDark = Color(0xFF111111);
  static const Color textMuted = Color(0xFF666B78);
}
