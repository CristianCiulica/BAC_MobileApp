class CountdownModel {
  final DateTime examDate;
  final DateTime startDate;
  final DateTime now;

  const CountdownModel({
    required this.examDate,
    required this.startDate,
    required this.now,
  });

  factory CountdownModel.initial({
    required DateTime examDate,
    required DateTime startDate,
  }) {
    final normalizedNow = DateTime.now();
    return CountdownModel(
      examDate: _dateOnly(examDate),
      startDate: _dateOnly(startDate),
      now: _dateOnly(normalizedNow),
    );
  }

  CountdownModel copyWith({
    DateTime? examDate,
    DateTime? startDate,
    DateTime? now,
  }) {
    return CountdownModel(
      examDate: examDate ?? this.examDate,
      startDate: startDate ?? this.startDate,
      now: now ?? this.now,
    );
  }

  int get daysRemaining {
    final diff = examDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get weeksRemaining => (daysRemaining / 7).ceil();

  double get progressPercent {
    final totalDays = examDate.difference(startDate).inDays;
    if (totalDays <= 0) return 1;
    final elapsed = now.difference(startDate).inDays;
    final normalized = elapsed.clamp(0, totalDays);
    return normalized / totalDays;
  }

  String get motivationalMessage {
    if (daysRemaining > 90) {
      return 'Ai timp suficient să construiești o bază solidă.';
    }
    if (daysRemaining >= 30) {
      return 'E perioada perfectă pentru variante și recapitulare.';
    }
    if (daysRemaining >= 7) {
      return 'Focus pe simulări și greșeli frecvente.';
    }
    return 'Recapitulare ușoară. Nu te suprasolicita.';
  }

  Map<String, dynamic> toJson() {
    return {
      'examDate': examDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
    };
  }

  factory CountdownModel.fromJson(Map<String, dynamic> json) {
    return CountdownModel(
      examDate: _dateOnly(DateTime.parse(json['examDate'] as String)),
      startDate: _dateOnly(DateTime.parse(json['startDate'] as String)),
      now: _dateOnly(DateTime.now()),
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
