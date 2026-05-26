import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileData {
  final String name;
  final String email;
  final String school;
  final String selectedProfile;
  final bool darkMode;
  final bool haptics;
  final bool autoSave;
  final bool dailyReminder;
  final bool examAlerts;
  final bool streakReminder;
  final bool gradeUpdates;

  const UserProfileData({
    required this.name,
    required this.email,
    required this.school,
    required this.selectedProfile,
    required this.darkMode,
    required this.haptics,
    required this.autoSave,
    required this.dailyReminder,
    required this.examAlerts,
    required this.streakReminder,
    required this.gradeUpdates,
  });

  factory UserProfileData.defaults(User user) {
    final displayName = user.displayName?.trim();
    final email = user.email?.trim() ?? '';

    return UserProfileData(
      name: displayName != null && displayName.isNotEmpty
          ? displayName
          : (email.isNotEmpty ? email.split('@').first : 'Utilizator Bac Pro'),
      email: email,
      school: 'Adaugă școala ta',
      selectedProfile: 'Mate-Info',
      darkMode: false,
      haptics: true,
      autoSave: true,
      dailyReminder: true,
      examAlerts: true,
      streakReminder: false,
      gradeUpdates: true,
    );
  }

  factory UserProfileData.fromMap(Map<String, dynamic>? data, User user) {
    final defaults = UserProfileData.defaults(user);
    if (data == null) return defaults;

    return UserProfileData(
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : defaults.name,
      email: (data['email'] as String?) ?? defaults.email,
      school: (data['school'] as String?) ?? defaults.school,
      selectedProfile:
          (data['selectedProfile'] as String?) ?? defaults.selectedProfile,
      darkMode: (data['darkMode'] as bool?) ?? defaults.darkMode,
      haptics: (data['haptics'] as bool?) ?? defaults.haptics,
      autoSave: (data['autoSave'] as bool?) ?? defaults.autoSave,
      dailyReminder: (data['dailyReminder'] as bool?) ?? defaults.dailyReminder,
      examAlerts: (data['examAlerts'] as bool?) ?? defaults.examAlerts,
      streakReminder:
          (data['streakReminder'] as bool?) ?? defaults.streakReminder,
      gradeUpdates: (data['gradeUpdates'] as bool?) ?? defaults.gradeUpdates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'school': school,
      'selectedProfile': selectedProfile,
      'darkMode': darkMode,
      'haptics': haptics,
      'autoSave': autoSave,
      'dailyReminder': dailyReminder,
      'examAlerts': examAlerts,
      'streakReminder': streakReminder,
      'gradeUpdates': gradeUpdates,
    };
  }
}

class StudySession {
  final String id;
  final String subjectName;
  final String year;
  final String sessionName;
  final int durationSeconds;
  final double estimatedGrade;
  final String notes;
  final DateTime completedAt;

  const StudySession({
    this.id = '',
    required this.subjectName,
    required this.year,
    required this.sessionName,
    required this.durationSeconds,
    required this.estimatedGrade,
    required this.notes,
    required this.completedAt,
  });

  factory StudySession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final completedAt = data['completedAt'];

    return StudySession(
      id: doc.id,
      subjectName: (data['subjectName'] as String?) ?? 'Subiect',
      year: (data['year'] as String?) ?? '',
      sessionName: (data['sessionName'] as String?) ?? '',
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      estimatedGrade: (data['estimatedGrade'] as num?)?.toDouble() ?? 0,
      notes: (data['notes'] as String?) ?? '',
      completedAt: completedAt is Timestamp
          ? completedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'year': year,
      'sessionName': sessionName,
      'durationSeconds': durationSeconds,
      'estimatedGrade': estimatedGrade,
      'notes': notes,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}

class ExamPdfAssets {
  final String subjectPdfAsset;
  final String answerPdfAsset;

  const ExamPdfAssets({
    required this.subjectPdfAsset,
    required this.answerPdfAsset,
  });

  factory ExamPdfAssets.fromMap(Map<String, dynamic> data) {
    return ExamPdfAssets(
      subjectPdfAsset: (data['subjectPdfAsset'] as String?)?.trim() ?? '',
      answerPdfAsset: (data['answerPdfAsset'] as String?)?.trim() ?? '',
    );
  }

  bool get isValid => subjectPdfAsset.isNotEmpty && answerPdfAsset.isNotEmpty;
}

class UserProgress {
  final int solvedCount;
  final int totalStudySeconds;
  final double averageGrade;
  final int streakDays;
  final Map<String, double> subjectProgress;

  const UserProgress({
    required this.solvedCount,
    required this.totalStudySeconds,
    required this.averageGrade,
    required this.streakDays,
    required this.subjectProgress,
  });

  factory UserProgress.fromSessions(List<StudySession> sessions) {
    final solvedCount = sessions.length;
    final totalSeconds = sessions.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );
    final gradeSum = sessions.fold<double>(
      0,
      (total, session) => total + session.estimatedGrade,
    );
    final subjectCounts = <String, int>{};

    for (final session in sessions) {
      subjectCounts.update(
        session.subjectName,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return UserProgress(
      solvedCount: solvedCount,
      totalStudySeconds: totalSeconds,
      averageGrade: solvedCount == 0 ? 0 : gradeSum / solvedCount,
      streakDays: _calculateStreak(sessions),
      subjectProgress: {
        for (final entry in subjectCounts.entries)
          entry.key: (entry.value / 10).clamp(0.0, 1.0),
      },
    );
  }

  static int _calculateStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;

    final days =
        sessions
            .map((session) {
              final date = session.completedAt;
              return DateTime(date.year, date.month, date.day);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    if (days.first.isBefore(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    for (final day in days) {
      if (day == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }
}

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _db.collection('users').doc(uid);
  }

  static CollectionReference<Map<String, dynamic>> _sessions(String uid) {
    return _userDoc(uid).collection('sessions');
  }

  static Future<void> ensureUserDocument(User user) async {
    final ref = _userDoc(user.uid);
    final snapshot = await ref.get();
    final defaults = UserProfileData.defaults(user).toMap();

    if (!snapshot.exists) {
      await ref.set({
        ...defaults,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await ref.set({
      'name': defaults['name'],
      'email': defaults['email'],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<UserProfileData> watchProfile(User user) {
    return _userDoc(user.uid).snapshots().map((snapshot) {
      return UserProfileData.fromMap(snapshot.data(), user);
    });
  }

  static Future<void> updateProfile({
    required User user,
    String? name,
    String? school,
    String? selectedProfile,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name.trim();
    if (school != null) updates['school'] = school.trim();
    if (selectedProfile != null) updates['selectedProfile'] = selectedProfile;

    await _userDoc(user.uid).set(updates, SetOptions(merge: true));
  }

  static Future<void> updateSettings(
    User user, {
    bool? darkMode,
    bool? haptics,
    bool? autoSave,
    bool? dailyReminder,
    bool? examAlerts,
    bool? streakReminder,
    bool? gradeUpdates,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (darkMode != null) updates['darkMode'] = darkMode;
    if (haptics != null) updates['haptics'] = haptics;
    if (autoSave != null) updates['autoSave'] = autoSave;
    if (dailyReminder != null) updates['dailyReminder'] = dailyReminder;
    if (examAlerts != null) updates['examAlerts'] = examAlerts;
    if (streakReminder != null) updates['streakReminder'] = streakReminder;
    if (gradeUpdates != null) updates['gradeUpdates'] = gradeUpdates;

    await _userDoc(user.uid).set(updates, SetOptions(merge: true));
  }

  static Stream<List<StudySession>> watchSessions(User user) {
    return _sessions(user.uid)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => StudySession.fromDoc(doc)).toList(),
        );
  }

  static Future<void> addSession(User user, StudySession session) async {
    await _sessions(user.uid).add(session.toMap());
  }

  static Future<void> deleteAllSessions(User user) async {
    final snapshot = await _sessions(user.uid).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Future<ExamPdfAssets?> fetchExamPdfAssets({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) async {
    final baseQuery = _db
        .collection('exam_pdfs')
        .where('profile', isEqualTo: profile)
        .where('subject', isEqualTo: subject)
        .where('session', isEqualTo: session);

    final stringSnapshot =
        await baseQuery.where('year', isEqualTo: year).limit(1).get();
    DocumentSnapshot<Map<String, dynamic>>? doc =
        stringSnapshot.docs.isNotEmpty ? stringSnapshot.docs.first : null;

    if (doc == null) {
      final intYear = int.tryParse(year);
      if (intYear != null) {
        final intSnapshot =
            await baseQuery.where('year', isEqualTo: intYear).limit(1).get();
        if (intSnapshot.docs.isNotEmpty) {
          doc = intSnapshot.docs.first;
        }
      }
    }

    if (doc == null) return null;

    final assets = ExamPdfAssets.fromMap(doc.data() ?? {});
    return assets.isValid ? assets : null;
  }
}
