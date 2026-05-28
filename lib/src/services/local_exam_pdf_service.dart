import 'dart:convert';

import 'package:flutter/services.dart';

import 'exam_catalog.dart';
import 'firestore_service.dart';

class LocalExamPdfService {
  LocalExamPdfService._();

  static Future<ExamPdfAssets?> resolve({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) async {
    final curated = ExamCatalog.resolve(
      profile: profile,
      subject: subject,
      year: year,
      session: session,
    );
    if (curated != null) return curated;

    final direct = await _resolveDirectByConvention(
      profile: profile,
      subject: subject,
      year: year,
      session: session,
    );
    if (direct != null) return direct;

    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;

    final allPdfAssets = manifest.keys
        .where(
          (path) =>
              path.startsWith('assets/subiecte/') &&
              path.toLowerCase().endsWith('.pdf'),
        )
        .toList();

    if (allPdfAssets.isEmpty) return null;

    final folder = _subjectFolder(subject);
    final folderAssets = allPdfAssets
        .where((path) => path.startsWith('assets/subiecte/$folder/'))
        .toList();

    if (folderAssets.isEmpty) return null;

    final yearToken = _normalize(year);
    final profileTokens = _profileTokens(profile, subject);
    final sessionTokens = _sessionTokens(session);
    final subjectTokens = _subjectTokens(subject);

    _Candidate? bestSubiect;
    _Candidate? bestBarem;

    for (final path in folderAssets) {
      final name = path.split('/').last.replaceAll('.pdf', '');
      final normalized = _normalize(name);

      var score = 0;
      if (normalized.contains(yearToken)) score += 120;
      for (final token in profileTokens) {
        if (normalized.contains(token)) score += 30;
      }
      for (final token in sessionTokens) {
        if (normalized.contains(token)) score += 24;
      }
      for (final token in subjectTokens) {
        if (normalized.contains(token)) score += 16;
      }

      final isBarem =
          normalized.contains('barem') ||
          normalized.contains('rezolvare') ||
          normalized.contains('solutie') ||
          normalized.contains('solutii');

      final candidate = _Candidate(path: path, score: score, isBarem: isBarem);

      if (candidate.isBarem) {
        if (bestBarem == null || candidate.score > bestBarem.score) {
          bestBarem = candidate;
        }
      } else {
        if (bestSubiect == null || candidate.score > bestSubiect.score) {
          bestSubiect = candidate;
        }
      }
    }

    final fallbackBest = [...folderAssets]
      ..sort(
        (a, b) =>
            _assetScore(
              assetPath: b,
              yearToken: yearToken,
              profileTokens: profileTokens,
              sessionTokens: sessionTokens,
              subjectTokens: subjectTokens,
            ).compareTo(
              _assetScore(
                assetPath: a,
                yearToken: yearToken,
                profileTokens: profileTokens,
                sessionTokens: sessionTokens,
                subjectTokens: subjectTokens,
              ),
            ),
      );

    final defaultAsset = fallbackBest.first;
    final subjectAsset = bestSubiect?.path ?? defaultAsset;
    final answerAsset = bestBarem?.path ?? subjectAsset;

    return ExamPdfAssets(
      subjectPdfAsset: subjectAsset,
      answerPdfAsset: answerAsset,
    );
  }

  static Future<ExamPdfAssets?> _resolveDirectByConvention({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) async {
    final folder = _subjectFolder(subject);
    final subjectPrefix = _subjectPrefixForProfile(profile, subject);
    final sessionSuffix = _sessionSuffix(session);
    final yearToken = year.trim();

    final directCandidates = <String>[
      'assets/subiecte/$folder/$subjectPrefix${yearToken}_$sessionSuffix.pdf',
      'assets/subiecte/$folder/$subjectPrefix${yearToken}_${sessionSuffix.toLowerCase()}.pdf',
      'assets/subiecte/$folder/$subjectPrefix${yearToken}_${_sessionSuffixAlt(session)}.pdf',
    ];

    for (final assetPath in directCandidates) {
      if (await _assetExists(assetPath)) {
        return ExamPdfAssets(
          subjectPdfAsset: assetPath,
          answerPdfAsset: assetPath,
        );
      }
    }

    return null;
  }

  static int _assetScore({
    required String assetPath,
    required String yearToken,
    required List<String> profileTokens,
    required List<String> sessionTokens,
    required List<String> subjectTokens,
  }) {
    final name = assetPath.split('/').last.replaceAll('.pdf', '');
    final normalized = _normalize(name);
    var score = 0;
    if (normalized.contains(yearToken)) score += 120;
    for (final token in profileTokens) {
      if (normalized.contains(token)) score += 30;
    }
    for (final token in sessionTokens) {
      if (normalized.contains(token)) score += 24;
    }
    for (final token in subjectTokens) {
      if (normalized.contains(token)) score += 16;
    }
    return score;
  }

  static String _subjectFolder(String subject) {
    final normalized = _normalize(subject);
    if (normalized.contains('matematic')) return 'matematica';
    if (normalized.contains('informat')) return 'informatica';
    if (normalized.contains('roman')) return 'romana';
    if (normalized.contains('istor')) return 'istorie';
    if (normalized.contains('biolog')) return 'biologie';
    if (normalized.contains('chim')) return 'chimie';
    if (normalized.contains('fizic')) return 'fizica';
    if (normalized.contains('geograf')) return 'geografie';
    if (normalized.contains('logic')) return 'logica';
    if (normalized.contains('psiholog')) return 'psihologie';
    if (normalized.contains('econom')) return 'economie';
    if (normalized.contains('sociolog')) return 'sociologie';
    if (normalized.contains('filosof')) return 'filosofie';
    return 'matematica';
  }

  static List<String> _subjectTokens(String subject) {
    final normalized = _normalize(subject);
    if (normalized.contains('matematic')) {
      return ['mate', 'matematica', 'm1', 'm2'];
    }
    if (normalized.contains('informat')) {
      return ['info', 'informatica', 'mi', 'm2'];
    }
    if (normalized.contains('roman')) return ['romana', 'lbromana', 'rom'];
    if (normalized.contains('istor')) return ['istorie', 'ist'];
    if (normalized.contains('biolog')) return ['biologie', 'bio'];
    if (normalized.contains('chim')) return ['chimie', 'chim'];
    if (normalized.contains('fizic')) return ['fizica', 'fiz'];
    return [normalized];
  }

  static List<String> _profileTokens(String profile, String subject) {
    final p = _normalize(profile);
    final s = _normalize(subject);

    if (p.contains('mateinfo')) return ['mateinfo', 'mi', 'm1'];
    if (p.contains('stiintelenaturii') || p.contains('stiintenaturii')) {
      return ['stiintenaturii', 'sn', 'm2'];
    }
    if (p.contains('tehnologic')) return ['tehnologic', 'tehno', 'm2'];
    if (p.contains('filologie')) return ['filologie', 'filo', 'uman'];
    if (p.contains('stiintesociale')) return ['stiintesociale', 'ss', 'uman'];
    if (p.contains('pedagogic')) return ['pedagogic', 'ped'];
    if (p.contains('economic')) return ['economic', 'eco', 'm2'];

    if (s.contains('matematic') && s.contains('m1')) return ['m1', 'mateinfo'];
    if (s.contains('matematic') && s.contains('m2')) {
      return ['m2', 'tehno', 'sn'];
    }
    if (s.contains('informat')) return ['mi', 'info'];

    return [p];
  }

  static List<String> _sessionTokens(String session) {
    final normalized = _normalize(session);
    if (normalized.contains('iunie')) return ['iunie', 'vara'];
    if (normalized.contains('aug') || normalized.contains('sept')) {
      return ['aug', 'august', 'sept', 'septembrie', 'toamna'];
    }
    if (normalized.contains('simulare')) return ['simulare'];
    if (normalized.contains('special')) {
      return ['speciala', 'special', 'olimpici', 'militar'];
    }
    if (normalized.contains('model')) return ['model', 'modele'];
    return [normalized];
  }

  static String _subjectPrefixForProfile(String profile, String subject) {
    final p = _normalize(profile);
    final s = _normalize(subject);

    if (s.contains('matematic')) {
      if (p.contains('mateinfo')) return 'MateInfo';
      if (p.contains('tehnologic')) return 'MateTehno';
      if (p.contains('stiintelenaturii') || p.contains('stiintenaturii')) {
        return 'MateSN';
      }
      if (p.contains('economic')) return 'MateEco';
      return 'Mate';
    }

    if (s.contains('informat')) {
      if (p.contains('mateinfo')) return 'InformaticaMI';
      if (p.contains('stiintelenaturii') || p.contains('stiintenaturii')) {
        return 'InformaticaM2';
      }
      return 'Informatica';
    }

    if (s.contains('roman')) return 'Romana';
    if (s.contains('istor')) return 'Istorie';
    if (s.contains('biolog')) return 'Biologie';
    if (s.contains('chim')) return 'Chimie';
    if (s.contains('fizic')) return 'Fizica';
    if (s.contains('geograf')) return 'Geografie';
    if (s.contains('logic')) return 'Logica';
    if (s.contains('psiholog')) return 'Psihologie';
    if (s.contains('econom')) return 'Economie';
    if (s.contains('sociolog')) return 'Sociologie';
    if (s.contains('filosof')) return 'Filosofie';

    return 'Subiect';
  }

  static String _sessionSuffix(String session) {
    final normalized = _normalize(session);
    if (normalized.contains('iunie')) return 'Iunie';
    if (normalized.contains('aug') || normalized.contains('sept')) {
      return 'August';
    }
    if (normalized.contains('simulare')) return 'Simulare';
    if (normalized.contains('special')) return 'Speciala';
    if (normalized.contains('model')) return 'Model';
    return 'Iunie';
  }

  static String _sessionSuffixAlt(String session) {
    final normalized = _normalize(session);
    if (normalized.contains('aug') || normalized.contains('sept')) {
      return 'AugSept';
    }
    return _sessionSuffix(session);
  }

  static Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _normalize(String input) {
    final lower = input.toLowerCase();
    final replaced = lower
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ş', 's')
        .replaceAll('ț', 't')
        .replaceAll('ţ', 't');
    return replaced.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _Candidate {
  final String path;
  final int score;
  final bool isBarem;

  const _Candidate({
    required this.path,
    required this.score,
    required this.isBarem,
  });
}
