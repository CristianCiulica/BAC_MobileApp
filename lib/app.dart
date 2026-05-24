import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/models/app_data.dart';
import 'src/screens/login_screen.dart';

class BacApp extends StatelessWidget {
  const BacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBAC',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const LoginScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.blue,
        secondary: AppColors.indigo,
        surface: Colors.white,
      ),
      fontFamily: '.SF Pro Text',
      appBarTheme: const AppBarTheme(
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

