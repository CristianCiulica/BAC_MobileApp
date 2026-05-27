import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../countdown/services/countdown_service.dart';
import '../../gamification/services/gamification_service.dart';
import '../models/study_plan_model.dart';
import '../models/study_task_model.dart';
import '../models/subject_plan_model.dart';

class StudyPlannerService {
  StudyPlannerService._();

  static final StudyPlannerService instance = StudyPlannerService._();

  static const String _planStorageKey = 'study_plan_model_v1';
  static const String _tasksStorageKey = 'study_tasks_model_v1';
  static const int _generationHorizonDays = 28;

  final ValueNotifier<StudyPlanModel?> planNotifier = ValueNotifier(null);
  final ValueNotifier<List<StudyTaskModel>> tasksNotifier = ValueNotifier(
    const <StudyTaskModel>[],
  );

  bool _initialized = false;
  int _seedCounter = 0;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final rawPlan = prefs.getString(_planStorageKey);
    if (rawPlan != null) {
      planNotifier.value = StudyPlanModel.fromJson(
        jsonDecode(rawPlan) as Map<String, dynamic>,
      );
    }

    final rawTasks = prefs.getString(_tasksStorageKey);
    if (rawTasks != null) {
      final parsed = (jsonDecode(rawTasks) as List<dynamic>)
          .map((item) => StudyTaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
      tasksNotifier.value = parsed;
    }

    _initialized = true;
  }

  Future<void> savePlanAndGenerate(StudyPlanModel plan) async {
    planNotifier.value = plan;
    await CountdownService.instance.setExamDate(plan.examDate);
    final generated = _generateTasks(plan);
    tasksNotifier.value = generated;
    await _persist();
  }

  List<StudyTaskModel> tasksForDate(DateTime date) {
    final day = _dateOnly(date);
    return tasksNotifier.value
        .where((task) => _isSameDay(task.date, day))
        .toList()
      ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
  }

  List<StudyTaskModel> tasksForWeek(DateTime dayInWeek) {
    final weekStart = _weekStart(dayInWeek);
    final weekEnd = weekStart.add(const Duration(days: 7));
    return tasksNotifier.value
        .where(
          (task) =>
              !task.date.isBefore(weekStart) && task.date.isBefore(weekEnd),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double completionForDate(DateTime date) {
    final todayTasks = tasksForDate(date);
    if (todayTasks.isEmpty) return 0;
    final completed = todayTasks.where((task) => task.isCompleted).length;
    return completed / todayTasks.length;
  }

  Future<void> toggleTaskCompletion(String taskId, bool completed) async {
    final tasks = [...tasksNotifier.value];
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) return;

    final previous = tasks[index];
    if (previous.isCompleted == completed) return;

    tasks[index] = previous.copyWith(isCompleted: completed);
    tasksNotifier.value = tasks;
    await _persistTasks(tasks);

    if (!completed) return;

    final dayTasks = tasksForDate(previous.date);
    final allCompleted =
        dayTasks.isNotEmpty && dayTasks.every((task) => task.isCompleted);

    await GamificationService.instance.recordTaskCompleted(
      taskId: previous.id,
      completedAt: DateTime.now(),
      isSimulationTask: previous.type == StudyTaskType.examSimulation,
      completedAllTasksToday: allCompleted,
    );
  }

  Future<bool> completeStudySessionForToday() async {
    return GamificationService.instance.recordStudySessionCompleted(
      completedAt: DateTime.now(),
    );
  }

  List<StudyTaskModel> _generateTasks(StudyPlanModel plan) {
    final now = _dateOnly(DateTime.now());
    final examDate = _dateOnly(plan.examDate);
    final lastDay =
        now.add(const Duration(days: _generationHorizonDays)).isBefore(examDate)
        ? now.add(const Duration(days: _generationHorizonDays))
        : examDate;

    final generated = <StudyTaskModel>[];
    var cursor = now;
    while (!cursor.isAfter(lastDay)) {
      if (plan.availableWeekdays.contains(cursor.weekday)) {
        generated.addAll(_buildTasksForDay(plan, cursor, examDate));
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return generated;
  }

  List<StudyTaskModel> _buildTasksForDay(
    StudyPlanModel plan,
    DateTime day,
    DateTime examDate,
  ) {
    final daysRemaining = examDate.difference(day).inDays.clamp(0, 9999);
    final phase = _phaseForDays(daysRemaining);
    final taskCount = _taskCountForMinutes(plan.dailyMinutes);
    final minuteBudget = _minuteBudgetForDay(plan.dailyMinutes, day.weekday);
    final subjectsPool = _subjectPool(plan.subjects);

    final mathEntry = plan.subjects.where(
      (item) => item.subject == 'Matematică',
    );
    if (mathEntry.isNotEmpty && mathEntry.first.level == SubjectLevel.weak) {
      return _buildBeginnerMathTasks(
        day: day,
        taskCount: taskCount,
        minuteBudget: minuteBudget,
      );
    }

    final tasks = <StudyTaskModel>[];
    for (var i = 0; i < taskCount; i++) {
      final subject = subjectsPool.isEmpty
          ? SubjectPlanModel(subject: 'General', level: SubjectLevel.medium)
          : subjectsPool[_seedCounter++ % subjectsPool.length];

      final type = _pickTaskType(
        phase: phase,
        index: i,
        isSunday: day.weekday == DateTime.sunday,
      );
      final duration = max(20, (minuteBudget / taskCount).round());
      final difficulty = _difficultyFor(subject.level, phase);
      final title = _taskTitle(type, subject.subject);

      tasks.add(
        StudyTaskModel(
          id: '${day.millisecondsSinceEpoch}_${i}_${subject.subject}',
          title: title,
          subject: subject.subject,
          type: type,
          durationMinutes: duration,
          date: day,
          isCompleted: false,
          difficulty: difficulty,
          xpReward: type == StudyTaskType.examSimulation ? 110 : 10,
        ),
      );
    }
    return tasks;
  }

  List<StudyTaskModel> _buildBeginnerMathTasks({
    required DateTime day,
    required int taskCount,
    required int minuteBudget,
  }) {
    const beginnerTemplates =
        <({String title, StudyTaskType type, TaskDifficulty difficulty})>[
          (
            title: 'Matrici · exerciții de bază',
            type: StudyTaskType.exercises,
            difficulty: TaskDifficulty.easy,
          ),
          (
            title: 'Legi de compoziție · recapitulare + exemple',
            type: StudyTaskType.theoryReview,
            difficulty: TaskDifficulty.easy,
          ),
          (
            title: 'Polinoame · punctele a și b',
            type: StudyTaskType.exercises,
            difficulty: TaskDifficulty.easy,
          ),
          (
            title: 'Subiectul I · primele 4 exerciții',
            type: StudyTaskType.bacVariant,
            difficulty: TaskDifficulty.medium,
          ),
          (
            title: 'Derivată · punctul a',
            type: StudyTaskType.theoryReview,
            difficulty: TaskDifficulty.medium,
          ),
          (
            title: 'Integrală · punctul a',
            type: StudyTaskType.theoryReview,
            difficulty: TaskDifficulty.medium,
          ),
        ];

    final duration = max(20, (minuteBudget / taskCount).round());
    final tasks = <StudyTaskModel>[];
    for (var i = 0; i < taskCount; i++) {
      final template =
          beginnerTemplates[_seedCounter++ % beginnerTemplates.length];
      tasks.add(
        StudyTaskModel(
          id: '${day.millisecondsSinceEpoch}_math_beginner_$i',
          title: template.title,
          subject: 'Matematică',
          type: template.type,
          durationMinutes: duration,
          date: day,
          isCompleted: false,
          difficulty: template.difficulty,
          xpReward: 10,
        ),
      );
    }
    return tasks;
  }

  _PlannerPhase _phaseForDays(int daysRemaining) {
    if (daysRemaining > 90) return _PlannerPhase.foundation;
    if (daysRemaining >= 30) return _PlannerPhase.practice;
    if (daysRemaining >= 7) return _PlannerPhase.simulation;
    return _PlannerPhase.finalReview;
  }

  int _taskCountForMinutes(int minutes) {
    if (minutes <= 30) return 1;
    if (minutes <= 60) return 2;
    if (minutes <= 120) return 3;
    return 4;
  }

  int _minuteBudgetForDay(int baseMinutes, int weekday) {
    if (weekday == DateTime.saturday) return baseMinutes + 20;
    if (weekday == DateTime.sunday) return baseMinutes + 30;
    return baseMinutes;
  }

  List<SubjectPlanModel> _subjectPool(List<SubjectPlanModel> subjects) {
    final pool = <SubjectPlanModel>[];
    for (final subject in subjects) {
      final weight = switch (subject.level) {
        SubjectLevel.weak => 3,
        SubjectLevel.medium => 2,
        SubjectLevel.good => 1,
      };
      for (var i = 0; i < weight; i++) {
        pool.add(subject);
      }
    }
    pool.shuffle();
    return pool;
  }

  StudyTaskType _pickTaskType({
    required _PlannerPhase phase,
    required int index,
    required bool isSunday,
  }) {
    if (isSunday && phase != _PlannerPhase.foundation) {
      return index == 0
          ? StudyTaskType.examSimulation
          : StudyTaskType.lightReview;
    }

    final options = switch (phase) {
      _PlannerPhase.foundation => const <StudyTaskType>[
        StudyTaskType.theoryReview,
        StudyTaskType.exercises,
        StudyTaskType.flashcards,
      ],
      _PlannerPhase.practice => const <StudyTaskType>[
        StudyTaskType.exercises,
        StudyTaskType.bacVariant,
        StudyTaskType.mistakeCorrection,
      ],
      _PlannerPhase.simulation => const <StudyTaskType>[
        StudyTaskType.examSimulation,
        StudyTaskType.mistakeCorrection,
        StudyTaskType.bacVariant,
      ],
      _PlannerPhase.finalReview => const <StudyTaskType>[
        StudyTaskType.lightReview,
        StudyTaskType.flashcards,
        StudyTaskType.mistakeCorrection,
      ],
    };
    return options[index % options.length];
  }

  TaskDifficulty _difficultyFor(SubjectLevel level, _PlannerPhase phase) {
    if (phase == _PlannerPhase.finalReview) return TaskDifficulty.easy;
    if (phase == _PlannerPhase.simulation && level != SubjectLevel.good) {
      return TaskDifficulty.hard;
    }
    if (level == SubjectLevel.weak) return TaskDifficulty.medium;
    if (level == SubjectLevel.good && phase == _PlannerPhase.foundation) {
      return TaskDifficulty.easy;
    }
    return TaskDifficulty.medium;
  }

  String _taskTitle(StudyTaskType type, String subject) {
    return switch (type) {
      StudyTaskType.theoryReview => 'Recapitulare teorie · $subject',
      StudyTaskType.exercises => 'Exerciții aplicate · $subject',
      StudyTaskType.bacVariant => 'Variantă BAC · $subject',
      StudyTaskType.mistakeCorrection => 'Corectare greșeli · $subject',
      StudyTaskType.flashcards => 'Flashcards · $subject',
      StudyTaskType.examSimulation => 'Simulare examen · $subject',
      StudyTaskType.lightReview => 'Recapitulare ușoară · $subject',
    };
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final plan = planNotifier.value;
    if (plan != null) {
      await prefs.setString(_planStorageKey, jsonEncode(plan.toJson()));
    }
    await _persistTasks(tasksNotifier.value);
  }

  Future<void> _persistTasks(List<StudyTaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksStorageKey,
      jsonEncode(tasks.map((item) => item.toJson()).toList()),
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static DateTime _weekStart(DateTime value) {
    final date = _dateOnly(value);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }
}

enum _PlannerPhase { foundation, practice, simulation, finalReview }
