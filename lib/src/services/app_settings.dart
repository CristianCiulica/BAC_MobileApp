import 'package:flutter/foundation.dart';

class AppSettings {
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

  static void setDarkMode(bool value) {
    darkMode.value = value;
  }
}
