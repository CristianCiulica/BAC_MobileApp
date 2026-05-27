import 'subject_plan_model.dart';

class StudyPlanModel {
  final DateTime examDate;
  final int dailyMinutes;
  final List<int> availableWeekdays;
  final List<SubjectPlanModel> subjects;
  final DateTime generatedAt;

  const StudyPlanModel({
    required this.examDate,
    required this.dailyMinutes,
    required this.availableWeekdays,
    required this.subjects,
    required this.generatedAt,
  });

  StudyPlanModel copyWith({
    DateTime? examDate,
    int? dailyMinutes,
    List<int>? availableWeekdays,
    List<SubjectPlanModel>? subjects,
    DateTime? generatedAt,
  }) {
    return StudyPlanModel(
      examDate: examDate ?? this.examDate,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      availableWeekdays: availableWeekdays ?? this.availableWeekdays,
      subjects: subjects ?? this.subjects,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examDate': examDate.toIso8601String(),
      'dailyMinutes': dailyMinutes,
      'availableWeekdays': availableWeekdays,
      'subjects': subjects.map((item) => item.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      examDate: DateTime.parse(json['examDate'] as String),
      dailyMinutes: (json['dailyMinutes'] as num).toInt(),
      availableWeekdays: (json['availableWeekdays'] as List<dynamic>)
          .map((item) => (item as num).toInt())
          .toList(),
      subjects: (json['subjects'] as List<dynamic>)
          .map(
            (item) => SubjectPlanModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}
