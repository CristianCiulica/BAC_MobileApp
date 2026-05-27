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

class RubricCriterion {
  final String title;
  final int maxPoints;
  final String guidance;

  const RubricCriterion({
    required this.title,
    required this.maxPoints,
    required this.guidance,
  });

  factory RubricCriterion.fromMap(Map<String, dynamic> data) {
    final parsedPoints = (data['maxPoints'] as num?)?.toInt() ?? 0;
    return RubricCriterion(
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : 'Criteriu',
      maxPoints: parsedPoints <= 0 ? 1 : parsedPoints,
      guidance: (data['guidance'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'maxPoints': maxPoints, 'guidance': guidance};
  }
}

class ExamRubric {
  final String profile;
  final String subject;
  final String year;
  final String session;
  final String strategyTip;
  final List<RubricCriterion> criteria;

  const ExamRubric({
    required this.profile,
    required this.subject,
    required this.year,
    required this.session,
    required this.strategyTip,
    required this.criteria,
  });

  int get maxScore {
    return criteria.fold<int>(0, (total, item) => total + item.maxPoints);
  }

  factory ExamRubric.fromMap({
    required String profile,
    required String subject,
    required String year,
    required String session,
    required Map<String, dynamic> data,
  }) {
    final raw = data['criteria'];
    final parsedCriteria = <RubricCriterion>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          parsedCriteria.add(RubricCriterion.fromMap(item));
        } else if (item is Map) {
          parsedCriteria.add(
            RubricCriterion.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ExamRubric(
      profile: profile,
      subject: subject,
      year: year,
      session: session,
      strategyTip:
          (data['strategyTip'] as String?)?.trim() ??
          'Parcurge întâi cerințele sigure, apoi revino la cele dificile.',
      criteria: parsedCriteria.isEmpty
          ? _defaultCriteriaForSubject(subject)
          : parsedCriteria,
    );
  }

  factory ExamRubric.fallback({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) {
    final normalizedProfile = profile.toLowerCase().trim();
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedSession = session.toLowerCase().trim();
    final isMateInfoProfile = normalizedProfile.contains('mate-info');
    final isMathM1 =
        normalizedSubject.contains('matematic') &&
        normalizedSubject.contains('m1');
    final isBac2025 =
        year.trim() == '2025' &&
        (normalizedSession.contains('iunie') ||
            normalizedSession.contains('vara'));

    if (isMateInfoProfile && isMathM1 && isBac2025) {
      return const ExamRubric(
        profile: 'Mate-Info',
        subject: 'Matematică (M1)',
        year: '2025',
        session: 'Sesiunea Iunie',
        strategyTip:
            'Respectă baremul punct cu punct. 10p sunt din oficiu, apoi urmărește cele 18 repere a câte 5p.',
        criteria: [
          RubricCriterion(
            title: 'Punctaj din oficiu',
            maxPoints: 10,
            guidance: 'Aceste puncte se acordă automat.',
          ),
          RubricCriterion(
            title: 'Subiectul I.1 numere complexe',
            maxPoints: 5,
            guidance:
                'Verifică forma finală și calculul corect al părții reale.',
          ),
          RubricCriterion(
            title: 'Subiectul I.2 compunere funcții',
            maxPoints: 5,
            guidance: 'Folosește relația f(f(a)) și rezolvă ecuația în a.',
          ),
          RubricCriterion(
            title: 'Subiectul I.3 ecuație de gradul al doilea',
            maxPoints: 5,
            guidance:
                'Obține corect rădăcinile și menționează explicit soluțiile.',
          ),
          RubricCriterion(
            title: 'Subiectul I.4 probabilitate',
            maxPoints: 5,
            guidance: 'Numără separat cazurile posibile și favorabile.',
          ),
          RubricCriterion(
            title: 'Subiectul I.5 geometrie analitică',
            maxPoints: 5,
            guidance: 'Determină corect mijloacele și egalează coordonatele.',
          ),
          RubricCriterion(
            title: 'Subiectul I.6 trigonometrie în triunghi',
            maxPoints: 5,
            guidance: 'Aplică raportul trigonometric și teorema lui Pitagora.',
          ),
          RubricCriterion(
            title: 'Subiectul II.1.a determinant',
            maxPoints: 5,
            guidance: 'Calculează determinantul complet, fără salturi de pași.',
          ),
          RubricCriterion(
            title: 'Subiectul II.1.b operații cu matrice',
            maxPoints: 5,
            guidance: 'Simplifică expresiile matriciale până la forma finală.',
          ),
          RubricCriterion(
            title: 'Subiectul II.1.c ecuație matricială',
            maxPoints: 5,
            guidance:
                'Folosește relația dată și concluzionează valorile lui x.',
          ),
          RubricCriterion(
            title: 'Subiectul II.2.a evaluare polinom',
            maxPoints: 5,
            guidance: 'Înlocuiește atent și grupează termenii corect.',
          ),
          RubricCriterion(
            title: 'Subiectul II.2.b împărțire polinomială',
            maxPoints: 5,
            guidance: 'Menționează explicit câtul și restul.',
          ),
          RubricCriterion(
            title: 'Subiectul II.2.c relație cu parametru',
            maxPoints: 5,
            guidance:
                'Transformă identitatea și rezolvă corect pentru parametru.',
          ),
          RubricCriterion(
            title: 'Subiectul III.1.a derivată',
            maxPoints: 5,
            guidance:
                'Aplică regulile de derivare și simplifică expresia finală.',
          ),
          RubricCriterion(
            title: 'Subiectul III.1.b asimptotă oblică',
            maxPoints: 5,
            guidance: 'Calculează limita diferenței față de dreapta propusă.',
          ),
          RubricCriterion(
            title: 'Subiectul III.1.c bijectivitate',
            maxPoints: 5,
            guidance: 'Justifică injectivitatea și surjectivitatea separat.',
          ),
          RubricCriterion(
            title: 'Subiectul III.2.a integrală polinomială',
            maxPoints: 5,
            guidance: 'Integrează corect și evaluează la capete.',
          ),
          RubricCriterion(
            title: 'Subiectul III.2.b integrală cu logaritm',
            maxPoints: 5,
            guidance: 'Folosește descompunerea potrivită și limitele exacte.',
          ),
          RubricCriterion(
            title: 'Subiectul III.2.c integrală cu exponențială',
            maxPoints: 5,
            guidance: 'Simplifică expresia înainte de integrare.',
          ),
        ],
      );
    }

    return ExamRubric(
      profile: profile,
      subject: subject,
      year: year,
      session: session,
      strategyTip:
          'Concentrează-te pe claritate și justificări scurte la fiecare pas.',
      criteria: _defaultCriteriaForSubject(subject),
    );
  }

  static List<RubricCriterion> _defaultCriteriaForSubject(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('rom')) {
      return const [
        RubricCriterion(
          title: 'Înțelegerea textului și identificarea ideilor',
          maxPoints: 20,
          guidance: 'Reia exercițiile de înțelegere pe text la prima vedere.',
        ),
        RubricCriterion(
          title: 'Argumentare și coerență',
          maxPoints: 25,
          guidance: 'Construiește răspunsuri în 2-3 pași clari.',
        ),
        RubricCriterion(
          title: 'Eseu: structură și exemple relevante',
          maxPoints: 35,
          guidance: 'Folosește schema: teză, argument, exemplu, concluzie.',
        ),
        RubricCriterion(
          title: 'Corectitudine gramaticală și exprimare',
          maxPoints: 20,
          guidance: 'Lasă 10 minute pentru revizie finală.',
        ),
      ];
    }

    if (lower.contains('matematic')) {
      return const [
        RubricCriterion(
          title: 'Subiectul I - calcule rapide și formule',
          maxPoints: 30,
          guidance: 'Recapitulează formulele de bază și exercițiile tip.',
        ),
        RubricCriterion(
          title: 'Subiectul II - justificare pași',
          maxPoints: 30,
          guidance: 'Scrie explicit transformările, nu doar rezultatul final.',
        ),
        RubricCriterion(
          title: 'Subiectul III - metodă completă',
          maxPoints: 30,
          guidance: 'Împarte rezolvarea în pași scurți și verifica semnele.',
        ),
        RubricCriterion(
          title: 'Acuratețe și verificare finală',
          maxPoints: 10,
          guidance:
              'Reverifică numeric rezultatele critice înainte de predare.',
        ),
      ];
    }

    return const [
      RubricCriterion(
        title: 'Corectitudine conceptuală',
        maxPoints: 35,
        guidance: 'Recitește noțiunile teoretice pentru capitolele slabe.',
      ),
      RubricCriterion(
        title: 'Aplicare pe cerințe',
        maxPoints: 35,
        guidance: 'Rezolvă 2-3 exerciții tipice pentru fiecare subiect.',
      ),
      RubricCriterion(
        title: 'Structură și claritate',
        maxPoints: 20,
        guidance: 'Folosește pași numerotați și formulări concise.',
      ),
      RubricCriterion(
        title: 'Revizie finală',
        maxPoints: 10,
        guidance: 'Păstrează 5-10 minute pentru verificare.',
      ),
    ];
  }
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

  static Future<void> submitAppFeedback(
    User user, {
    required int rating,
    required String message,
  }) async {
    final cleanRating = rating.clamp(1, 5);
    final cleanMessage = message.trim();
    final entry = {
      'rating': cleanRating,
      'message': cleanMessage,
      'createdAtIso': DateTime.now().toIso8601String(),
    };

    await _userDoc(user.uid).set({
      'lastFeedbackRating': cleanRating,
      'lastFeedbackMessage': cleanMessage,
      'lastFeedbackAt': FieldValue.serverTimestamp(),
      'feedbackCount': FieldValue.increment(1),
      'feedbackHistory': FieldValue.arrayUnion([entry]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    final stringSnapshot = await baseQuery
        .where('year', isEqualTo: year)
        .limit(1)
        .get();
    DocumentSnapshot<Map<String, dynamic>>? doc = stringSnapshot.docs.isNotEmpty
        ? stringSnapshot.docs.first
        : null;

    if (doc == null) {
      final intYear = int.tryParse(year);
      if (intYear != null) {
        final intSnapshot = await baseQuery
            .where('year', isEqualTo: intYear)
            .limit(1)
            .get();
        if (intSnapshot.docs.isNotEmpty) {
          doc = intSnapshot.docs.first;
        }
      }
    }

    if (doc == null) return null;

    final assets = ExamPdfAssets.fromMap(doc.data() ?? {});
    return assets.isValid ? assets : null;
  }

  static Future<ExamRubric?> fetchExamRubric({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) async {
    final baseQuery = _db
        .collection('exam_rubrics')
        .where('profile', isEqualTo: profile)
        .where('subject', isEqualTo: subject)
        .where('session', isEqualTo: session);

    final stringSnapshot = await baseQuery
        .where('year', isEqualTo: year)
        .limit(1)
        .get();
    DocumentSnapshot<Map<String, dynamic>>? doc = stringSnapshot.docs.isNotEmpty
        ? stringSnapshot.docs.first
        : null;

    if (doc == null) {
      final intYear = int.tryParse(year);
      if (intYear != null) {
        final intSnapshot = await baseQuery
            .where('year', isEqualTo: intYear)
            .limit(1)
            .get();
        if (intSnapshot.docs.isNotEmpty) {
          doc = intSnapshot.docs.first;
        }
      }
    }

    if (doc == null) return null;

    return ExamRubric.fromMap(
      profile: profile,
      subject: subject,
      year: year,
      session: session,
      data: doc.data() ?? const {},
    );
  }
}
