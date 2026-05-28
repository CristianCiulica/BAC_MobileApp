import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/countdown_model.dart';

class CountdownService {
  CountdownService._();

  static final CountdownService instance = CountdownService._();

  static const String _storageKey = 'countdown_model_v1';
  static const int _defaultExamMonth = 6;
  static const int _defaultExamDay = 29;

  final ValueNotifier<CountdownModel> notifier = ValueNotifier<CountdownModel>(
    CountdownModel.initial(
      examDate: _computedDefaultExamDate(),
      startDate: DateTime.now(),
    ),
  );

  bool _initialized = false;

  static DateTime _computedDefaultExamDate() {
    final now = DateTime.now();
    var candidate = DateTime(now.year, _defaultExamMonth, _defaultExamDay);
    if (!candidate.isAfter(now)) {
      candidate = DateTime(now.year + 1, _defaultExamMonth, _defaultExamDay);
    }
    return candidate;
  }

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      final initial = CountdownModel.initial(
        examDate: _computedDefaultExamDate(),
        startDate: DateTime.now(),
      );
      notifier.value = initial;
      await prefs.setString(_storageKey, jsonEncode(initial.toJson()));
      _initialized = true;
      return;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final loaded = CountdownModel.fromJson(decoded);
    notifier.value = loaded.copyWith(now: _dateOnly(DateTime.now()));
    _initialized = true;
  }

  Future<void> setExamDate(DateTime newDate) async {
    final current = notifier.value;
    final updated = current.copyWith(examDate: _dateOnly(newDate));
    notifier.value = updated.copyWith(now: _dateOnly(DateTime.now()));
    await _persist(notifier.value);
  }

  Future<void> resetToDefault() async {
    final now = DateTime.now();
    final updated = CountdownModel.initial(
      examDate: _computedDefaultExamDate(),
      startDate: now,
    );
    notifier.value = updated;
    await _persist(updated);
  }

  Future<void> refreshNow() async {
    final current = notifier.value;
    notifier.value = current.copyWith(now: _dateOnly(DateTime.now()));
  }

  Future<void> _persist(CountdownModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(model.toJson()));
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
