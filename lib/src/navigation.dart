import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<T> cupertinoRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(builder: (_) => page);
}

