enum BadgeId {
  firstTask,
  sevenDayStreak,
  examWarrior,
  consistentStudent,
  bacMachine,
  nightOwl,
  earlyBird,
}

class BadgeModel {
  final BadgeId id;
  final String title;
  final String description;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  BadgeModel copyWith({DateTime? unlockedAt}) {
    return BadgeModel(
      id: id,
      title: title,
      description: description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.name,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: BadgeId.values.firstWhere(
        (item) => item.name == json['id'],
        orElse: () => BadgeId.firstTask,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );
  }
}
