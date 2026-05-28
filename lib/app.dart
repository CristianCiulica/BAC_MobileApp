import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/models/app_data.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/main_shell.dart';
import 'src/screens/onboarding_screen.dart';
import 'src/services/auth_service.dart';
import 'src/services/firestore_service.dart';

class BacApp extends StatelessWidget {
  const BacApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BacPro is a light-only, Apple-clean experience.
    AppColors.isDark = false;

    return MaterialApp(
      title: 'BacPro',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: StreamBuilder<User?>(
        stream: AuthService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CupertinoActivityIndicator()),
            );
          }
          final user = snapshot.data;
          if (user != null) return _AuthedGate(user: user);
          return const LoginScreen();
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
      ),
      fontFamily: '.SF Pro Text',
      dividerColor: AppColors.separator,
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.blue,
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 16,
            letterSpacing: -0.2,
            color: AppColors.label,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.label,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.blue),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }
}

/// Once the user is authenticated, ensures their document exists and routes to
/// the welcome flow (first launch) or the main app.
class _AuthedGate extends StatefulWidget {
  final User user;

  const _AuthedGate({required this.user});

  @override
  State<_AuthedGate> createState() => _AuthedGateState();
}

class _AuthedGateState extends State<_AuthedGate> {
  @override
  void initState() {
    super.initState();
    FirestoreService.ensureUserDocument(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfileData>(
      stream: FirestoreService.watchProfile(widget.user),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (!snapshot.data!.onboardingCompleted) {
          return OnboardingScreen(user: widget.user);
        }
        return const MainShell();
      },
    );
  }
}
