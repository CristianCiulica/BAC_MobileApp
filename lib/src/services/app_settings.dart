import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppSettings {
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> haptics = ValueNotifier<bool>(true);

  static void setDarkMode(bool value) {
    darkMode.value = value;
  }

  static void setHaptics(bool value) {
    haptics.value = value;
  }
}

class AppHaptics {
  static bool get enabled => AppSettings.haptics.value;

  static Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }
}
