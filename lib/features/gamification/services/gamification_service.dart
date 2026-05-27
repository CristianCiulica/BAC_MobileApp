import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge_model.dart';
import '../models/gamification_model.dart';

class GamificationService {
  GamificationService._();

  static final GamificationService instance = GamificationService._();
  static const String _storageKey = 'gamification_model_v1';

  final ValueNotifier<GamificationModel> notifier =
      ValueNotifier<GamificationModel>(GamificationModel.initial());

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      _initialized = true;
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    notifier.value = GamificationModel.fromJson(decoded);
    _initialized = true;
  }

  Future<void> recordTaskCompleted({
    required String taskId,
    required DateTime completedAt,
    required bool isSimulationTask,
    required bool completedAllTasksToday,
  }) async {
    var model = notifier.value;
    if (model.rewardedTaskIds.contains(taskId)) return;

    model = _applyDailyStreak(model, completedAt);
    model = model.copyWith(
      xpTotal: model.xpTotal + 10,
      completedTasks: model.completedTasks + 1,
      rewardedTaskIds: <String>{...model.rewardedTaskIds, taskId},
    );

    if (isSimulationTask) {
      model = model.copyWith(
        xpTotal: model.xpTotal + 100,
        completedExamSimulations: model.completedExamSimulations + 1,
      );
    }

    final dayKey = _dayKey(completedAt);
    if (completedAllTasksToday &&
        !model.dailyCompletionBonusDates.contains(dayKey)) {
      model = model.copyWith(
        xpTotal: model.xpTotal + 50,
        dailyCompletionBonusDates: <String>{
          ...model.dailyCompletionBonusDates,
          dayKey,
        },
      );
    }

    model = _applyBadges(model, completedAt);
    notifier.value = model;
    await _persist(model);
  }

  Future<bool> recordStudySessionCompleted({
    required DateTime completedAt,
    bool isSimulation = false,
  }) async {
    var model = notifier.value;
    final dayKey = _dayKey(completedAt);
    if (model.sessionRewardDates.contains(dayKey)) {
      return false;
    }

    model = _applyDailyStreak(model, completedAt);
    model = model.copyWith(
      xpTotal: model.xpTotal + 25,
      completedStudySessions: model.completedStudySessions + 1,
      sessionRewardDates: <String>{...model.sessionRewardDates, dayKey},
    );

    if (isSimulation) {
      model = model.copyWith(
        xpTotal: model.xpTotal + 100,
        completedExamSimulations: model.completedExamSimulations + 1,
      );
    }

    model = _applyBadges(model, completedAt);
    notifier.value = model;
    await _persist(model);
    return true;
  }

  GamificationModel _applyDailyStreak(GamificationModel model, DateTime now) {
    final today = _dateOnly(now);
    final lastActive = model.lastActiveDate == null
        ? null
        : _dateOnly(model.lastActiveDate!);
    final lastRewarded = model.lastStreakRewardDate == null
        ? null
        : _dateOnly(model.lastStreakRewardDate!);

    var streak = model.streakDays;
    if (lastActive == null) {
      streak = 1;
    } else {
      final gap = today.difference(lastActive).inDays;
      if (gap == 0) {
        streak = model.streakDays;
      } else if (gap == 1) {
        streak = model.streakDays + 1;
      } else {
        streak = 1;
      }
    }

    var xp = model.xpTotal;
    if (lastRewarded == null || today.difference(lastRewarded).inDays > 0) {
      xp += 15;
    }

    return model.copyWith(
      xpTotal: xp,
      streakDays: streak,
      lastActiveDate: today,
      lastStreakRewardDate: today,
    );
  }

  GamificationModel _applyBadges(GamificationModel model, DateTime at) {
    final badges = <BadgeId, BadgeModel>{...model.badges};

    void unlock(BadgeId id) {
      final existing = badges[id];
      if (existing == null || existing.isUnlocked) return;
      badges[id] = existing.copyWith(unlockedAt: at);
    }

    if (model.completedTasks >= 1) unlock(BadgeId.firstTask);
    if (model.streakDays >= 7) unlock(BadgeId.sevenDayStreak);
    if (model.completedExamSimulations >= 1) unlock(BadgeId.examWarrior);
    if (model.completedTasks >= 30) unlock(BadgeId.consistentStudent);
    if (model.completedTasks >= 100) unlock(BadgeId.bacMachine);
    if (at.hour >= 22) unlock(BadgeId.nightOwl);
    if (at.hour < 8) unlock(BadgeId.earlyBird);

    return model.copyWith(badges: badges);
  }

  Future<void> _persist(GamificationModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(model.toJson()));
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String _dayKey(DateTime value) {
    final date = _dateOnly(value);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
