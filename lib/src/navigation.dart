import 'package:flutter/cupertino.dart';

Route<T> cupertinoRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(builder: (_) => page);
}
