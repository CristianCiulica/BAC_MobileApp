import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/models/app_data.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/main_shell.dart';
import 'src/services/app_settings.dart';
import 'src/services/auth_service.dart';

class BacApp extends StatelessWidget {
  const BacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.darkMode,
      builder: (context, isDark, _) {
        AppColors.isDark = isDark;

        return MaterialApp(
          title: 'Bac Pro',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(isDark),
          home: StreamBuilder<User?>(
            stream: AuthService.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CupertinoActivityIndicator()),
                );
              }
              if (snapshot.hasData) return const MainShell();
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        brightness: isDark ? Brightness.dark : Brightness.light,
        seedColor: AppColors.blue,
        primary: AppColors.blue,
        secondary: AppColors.indigo,
        surface: AppColors.surface,
      ),
      fontFamily: '.SF Pro Text',
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.label,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.blue),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
    );
  }
}
