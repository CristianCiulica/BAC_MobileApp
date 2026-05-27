enum SubjectLevel { weak, medium, good }

class SubjectPlanModel {
  final String subject;
  final SubjectLevel level;

  const SubjectPlanModel({required this.subject, required this.level});

  SubjectPlanModel copyWith({String? subject, SubjectLevel? level}) {
    return SubjectPlanModel(
      subject: subject ?? this.subject,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toJson() {
    return {'subject': subject, 'level': level.name};
  }

  factory SubjectPlanModel.fromJson(Map<String, dynamic> json) {
    return SubjectPlanModel(
      subject: json['subject'] as String,
      level: SubjectLevel.values.firstWhere(
        (item) => item.name == json['level'],
        orElse: () => SubjectLevel.medium,
      ),
    );
  }
}
