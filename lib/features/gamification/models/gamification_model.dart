import 'badge_model.dart';

class GamificationModel {
  final int xpTotal;
  final int streakDays;
  final DateTime? lastActiveDate;
  final DateTime? lastStreakRewardDate;
  final int completedTasks;
  final int completedStudySessions;
  final int completedExamSimulations;
  final Set<String> dailyCompletionBonusDates;
  final Set<String> sessionRewardDates;
  final Set<String> rewardedTaskIds;
  final Map<BadgeId, BadgeModel> badges;

  const GamificationModel({
    required this.xpTotal,
    required this.streakDays,
    required this.lastActiveDate,
    required this.lastStreakRewardDate,
    required this.completedTasks,
    required this.completedStudySessions,
    required this.completedExamSimulations,
    required this.dailyCompletionBonusDates,
    required this.sessionRewardDates,
    required this.rewardedTaskIds,
    required this.badges,
  });

  factory GamificationModel.initial() {
    final defaults = <BadgeId, BadgeModel>{
      BadgeId.firstTask: const BadgeModel(
        id: BadgeId.firstTask,
        title: 'First Task',
        description: 'Completează primul task',
      ),
      BadgeId.sevenDayStreak: const BadgeModel(
        id: BadgeId.sevenDayStreak,
        title: '7 Day Streak',
        description: 'Menține streak 7 zile',
      ),
      BadgeId.examWarrior: const BadgeModel(
        id: BadgeId.examWarrior,
        title: 'Exam Warrior',
        description: 'Finalizează prima simulare',
      ),
      BadgeId.consistentStudent: const BadgeModel(
        id: BadgeId.consistentStudent,
        title: 'Consistent Student',
        description: 'Completează 30 task-uri',
      ),
      BadgeId.bacMachine: const BadgeModel(
        id: BadgeId.bacMachine,
        title: 'Bac Machine',
        description: 'Completează 100 task-uri',
      ),
      BadgeId.nightOwl: const BadgeModel(
        id: BadgeId.nightOwl,
        title: 'Night Owl',
        description: 'Sesiune completată după ora 22:00',
      ),
      BadgeId.earlyBird: const BadgeModel(
        id: BadgeId.earlyBird,
        title: 'Early Bird',
        description: 'Sesiune completată înainte de ora 8:00',
      ),
    };

    return GamificationModel(
      xpTotal: 0,
      streakDays: 0,
      lastActiveDate: null,
      lastStreakRewardDate: null,
      completedTasks: 0,
      completedStudySessions: 0,
      completedExamSimulations: 0,
      dailyCompletionBonusDates: <String>{},
      sessionRewardDates: <String>{},
      rewardedTaskIds: <String>{},
      badges: defaults,
    );
  }

  int get level => (xpTotal ~/ 100) + 1;
  int get xpInCurrentLevel => xpTotal % 100;
  double get nextLevelProgress => xpInCurrentLevel / 100;
  int get xpToNextLevel => 100 - xpInCurrentLevel;

  GamificationModel copyWith({
    int? xpTotal,
    int? streakDays,
    DateTime? lastActiveDate,
    DateTime? lastStreakRewardDate,
    int? completedTasks,
    int? completedStudySessions,
    int? completedExamSimulations,
    Set<String>? dailyCompletionBonusDates,
    Set<String>? sessionRewardDates,
    Set<String>? rewardedTaskIds,
    Map<BadgeId, BadgeModel>? badges,
  }) {
    return GamificationModel(
      xpTotal: xpTotal ?? this.xpTotal,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lastStreakRewardDate: lastStreakRewardDate ?? this.lastStreakRewardDate,
      completedTasks: completedTasks ?? this.completedTasks,
      completedStudySessions:
          completedStudySessions ?? this.completedStudySessions,
      completedExamSimulations:
          completedExamSimulations ?? this.completedExamSimulations,
      dailyCompletionBonusDates:
          dailyCompletionBonusDates ?? this.dailyCompletionBonusDates,
      sessionRewardDates: sessionRewardDates ?? this.sessionRewardDates,
      rewardedTaskIds: rewardedTaskIds ?? this.rewardedTaskIds,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xpTotal': xpTotal,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'lastStreakRewardDate': lastStreakRewardDate?.toIso8601String(),
      'completedTasks': completedTasks,
      'completedStudySessions': completedStudySessions,
      'completedExamSimulations': completedExamSimulations,
      'dailyCompletionBonusDates': dailyCompletionBonusDates.toList(),
      'sessionRewardDates': sessionRewardDates.toList(),
      'rewardedTaskIds': rewardedTaskIds.toList(),
      'badges': badges.values.map((badge) => badge.toJson()).toList(),
    };
  }

  factory GamificationModel.fromJson(Map<String, dynamic> json) {
    final seed = GamificationModel.initial();
    final decodedBadges = <BadgeId, BadgeModel>{...seed.badges};
    final badgesList = (json['badges'] as List<dynamic>? ?? const []);
    for (final item in badgesList) {
      final badge = BadgeModel.fromJson(item as Map<String, dynamic>);
      decodedBadges[badge.id] = badge;
    }

    return seed.copyWith(
      xpTotal: (json['xpTotal'] as int?) ?? 0,
      streakDays: (json['streakDays'] as int?) ?? 0,
      lastActiveDate: json['lastActiveDate'] == null
          ? null
          : DateTime.parse(json['lastActiveDate'] as String),
      lastStreakRewardDate: json['lastStreakRewardDate'] == null
          ? null
          : DateTime.parse(json['lastStreakRewardDate'] as String),
      completedTasks: (json['completedTasks'] as int?) ?? 0,
      completedStudySessions: (json['completedStudySessions'] as int?) ?? 0,
      completedExamSimulations: (json['completedExamSimulations'] as int?) ?? 0,
      dailyCompletionBonusDates:
          ((json['dailyCompletionBonusDates'] as List<dynamic>?) ??
                  const <dynamic>[])
              .map((item) => item.toString())
              .toSet(),
      sessionRewardDates:
          ((json['sessionRewardDates'] as List<dynamic>?) ?? const <dynamic>[])
              .map((item) => item.toString())
              .toSet(),
      rewardedTaskIds:
          ((json['rewardedTaskIds'] as List<dynamic>?) ?? const <dynamic>[])
              .map((item) => item.toString())
              .toSet(),
      badges: decodedBadges,
    );
  }
}
