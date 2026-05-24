import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_data.dart';
import '../navigation.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MathBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _MockLogo(),
                    const SizedBox(height: 16),
                    const Text(
                      'BacHub',
                      style: TextStyle(
                        fontFamily: '.SF Pro Display',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pregătește-te pentru BAC. Mate + Info.',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 15,
                        color: Color(0xFF3C3C43),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Parolă',
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => HapticFeedback.selectionClick(),
                              child: const Text(
                                'Ai uitat parola?',
                                style: TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 13,
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pushReplacement(
                                  context,
                                  cupertinoRoute(const MainShell()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Conectează-te',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'Sau continuă cu',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3C3C43),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                icon: Icons.apple,
                                color: Colors.black,
                                onTap: () {},
                              ),
                              const SizedBox(width: 20),
                              _buildSocialButton(
                                isGoogle: true,
                                onTap: () {},
                              ),
                              const SizedBox(width: 20),
                              _buildSocialButton(
                                icon: Icons.facebook,
                                color: const Color(0xFF1877F2),
                                iconSize: 28,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () => HapticFeedback.selectionClick(),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 14,
                            color: Color(0xFF3C3C43),
                          ),
                          children: [
                            TextSpan(text: 'Nu ai cont? '),
                            TextSpan(
                              text: 'Creează unul acum.',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    Color? color,
    double iconSize = 24,
    bool isGoogle = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        ),
        child: Center(
          child: isGoogle ? _buildGoogleIcon() : Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontWeight: FontWeight.bold,
        fontSize: 24,
        fontFamily: '.SF Pro Display',
      ),
    );
  }
}

class _MathBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFFE5E5EA).withAlpha(128)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintCircle = Paint()
      ..color = const Color(0xFFE5E5EA).withAlpha(128)
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.1, 0), Offset(size.width * 0.4, size.height * 0.3), paintLine);
    canvas.drawLine(Offset(size.width * 0.4, size.height * 0.3), Offset(size.width, size.height * 0.1), paintLine);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2), Offset(size.width * 0.6, size.height * 0.5), paintLine);
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width * 0.3, size.height * 0.4), paintLine);

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 3, paintCircle);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 3, paintCircle);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 3, paintCircle);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 3, paintCircle);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 3, paintCircle);

    _drawSymbol(canvas, 'Σ', Offset(size.width * 0.25, size.height * 0.25), 20);
    _drawSymbol(canvas, 'π', Offset(size.width * 0.85, size.height * 0.12), 18);
    _drawSymbol(canvas, '÷', Offset(size.width * 0.6, size.height * 0.15), 18);
    _drawSymbol(canvas, '+', Offset(size.width * 0.8, size.height * 0.28), 16);
    _drawSymbol(canvas, '=', Offset(size.width * 0.65, size.height * 0.27), 16);
    _drawSymbol(canvas, '−', Offset(size.width * 0.65, size.height * 0.18), 16);
    _drawSymbol(canvas, '</>', Offset(size.width * 0.82, size.height * 0.31), 14);
    _drawSymbol(canvas, 'x', Offset(size.width * 0.22, size.height * 0.32), 16);
  }

  void _drawSymbol(Canvas canvas, String symbol, Offset position, double size) {
    final textSpan = TextSpan(
      text: symbol,
      style: TextStyle(
        color: const Color(0xFFC7C7CC).withAlpha(102),
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFamily: '.SF Pro Display',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MockLogo extends StatelessWidget {
  const _MockLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            bottom: 5,
            child: Text(
              'B',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                height: 1.0,
                letterSpacing: -2.0,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 5,
            child: Transform.rotate(
              angle: -0.1,
              child: const Icon(
                Icons.school,
                size: 55,
                color: AppColors.navy,
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: AppColors.loginBackground,
              child: const Text(
                '</>',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


