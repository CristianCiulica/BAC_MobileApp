enum StudyTaskType {
  theoryReview,
  exercises,
  bacVariant,
  mistakeCorrection,
  flashcards,
  examSimulation,
  lightReview,
}

enum TaskDifficulty { easy, medium, hard }

class StudyTaskModel {
  final String id;
  final String title;
  final String subject;
  final StudyTaskType type;
  final int durationMinutes;
  final DateTime date;
  final bool isCompleted;
  final TaskDifficulty difficulty;
  final int xpReward;

  const StudyTaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.durationMinutes,
    required this.date,
    required this.isCompleted,
    required this.difficulty,
    required this.xpReward,
  });

  StudyTaskModel copyWith({bool? isCompleted}) {
    return StudyTaskModel(
      id: id,
      title: title,
      subject: subject,
      type: type,
      durationMinutes: durationMinutes,
      date: date,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty,
      xpReward: xpReward,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'difficulty': difficulty.name,
      'xpReward': xpReward,
    };
  }

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      type: StudyTaskType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => StudyTaskType.exercises,
      ),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      difficulty: TaskDifficulty.values.firstWhere(
        (item) => item.name == json['difficulty'],
        orElse: () => TaskDifficulty.medium,
      ),
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 10,
    );
  }
}
