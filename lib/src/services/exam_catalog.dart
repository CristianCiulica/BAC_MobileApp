import 'firestore_service.dart';

/// A subject PDF + its scoring rubric (barem).
class ExamDoc {
  final String subject;
  final String barem;

  const ExamDoc(this.subject, this.barem);
}

/// Curated catalog of official BAC exam papers hosted on e3.ro
/// (mirror of the Ministry of Education / CNPEE documents).
///
/// Coverage: Matematică — all four M-profiles (mate-info, științele naturii,
/// tehnologic, pedagogic), years 2020–2025, sessions iunie / august-sept /
/// simulare / sesiune specială / model oficial. Every URL in this catalog has
/// been verified to resolve (HTTP 200).
class ExamCatalog {
  ExamCatalog._();

  static const String _base = 'https://www.e3.ro/wp-content/uploads';

  /// Standard ministry naming: E_c_matematica_M_{p}_{year}_var|bar_{tag}_LRO.pdf
  static ExamDoc _std(String folder, String p, String year, String tag) =>
      ExamDoc(
        '$_base/$folder/E_c_matematica_M_${p}_${year}_var_${tag}_LRO.pdf',
        '$_base/$folder/E_c_matematica_M_${p}_${year}_bar_${tag}_LRO.pdf',
      );

  /// Official model papers (no _LRO suffix).
  static ExamDoc _model(String folder, String p, String year) => ExamDoc(
    '$_base/$folder/E_c_matematica_M_${p}_${year}_var_model.pdf',
    '$_base/$folder/E_c_matematica_M_${p}_${year}_bar_model.pdf',
  );

  /// 2023 naming scheme: 2023_E_c_Matematica_{S}_M_{p}_Subiect|Barem_{n}_LRO.pdf
  static ExamDoc _s23(String p, String sess, String n) => ExamDoc(
    '$_base/2023/11/2023_E_c_Matematica_${sess}_M_${p}_Subiect_${n}_LRO.pdf',
    '$_base/2023/11/2023_E_c_Matematica_${sess}_M_${p}_Barem_${n}_LRO.pdf',
  );

  /// 2023 national simulation naming.
  static ExamDoc _sim23(String p) => ExamDoc(
    '$_base/2023/11/2023_E_c_Matematica_SM_M_${p}_Simulare_XII_Subiect_LRO.pdf',
    '$_base/2023/11/2023_E_c_Matematica_SM_M_${p}_Simulare_XII_Barem_LRO.pdf',
  );

  /// Short-name re-uploads used for the aug 2022 / mar 2022 papers.
  static ExamDoc _short(String folder, String stem) => ExamDoc(
    '$_base/$folder/$stem.pdf',
    '$_base/$folder/${stem}barem.pdf',
  );

  /// math[mathProfile][year][sessionKey]
  static final Map<String, Map<String, Map<String, ExamDoc>>> _math = {
    'mate-info': {
      '2025': {
        'iunie': _std('2025/06', 'mate-info', '2025', '01'),
        'august': _std('2025/08', 'mate-info', '2025', '09'),
        'speciala': _std('2025/05', 'mate-info', '2025', '03'),
        'simulare': _std('2025/03', 'mate-info', '2025', 'simulare'),
        'model': _model('2024/11', 'mate-info', '2025'),
      },
      '2024': {
        'iunie': _std('2024/07', 'mate-info', '2024', '10'),
        'august': _std('2024/08', 'mate-info', '2024', '03'),
        'speciala': _std('2024/05', 'mate-info', '2024', '09'),
        'simulare': _std('2024/03', 'mate-info', '2024', 'simulare'),
      },
      '2023': {
        'iunie': _s23('mate-info', 'S1', '01'),
        'august': _s23('mate-info', 'S2', '07'),
        'speciala': _s23('mate-info', 'SS', '06'),
        'simulare': _sim23('mate-info'),
        'model': _short('2023/12', 'modelBAC2023MI'),
      },
      '2022': {
        'iunie': _std('2022/06', 'mate-info', '2022', '01'),
        'august': _short('2023/12', 'exBACaug2022MI'),
        'speciala': _std('2022/05', 'mate-info', '2022', '03'),
        'simulare': _short('2023/12', 'simBACmar2022MI'),
        'model': _model('2021/11', 'mate-info', '2022'),
      },
      '2021': {
        'iunie': _std('2021/07', 'mate-info', '2021', '02'),
        'august': _std('2021/08', 'mate-info', '2021', '04'),
        'simulare': ExamDoc(
          '$_base/2021/12/E_c_matematica_M_mate-info_2021_var_simulare_LRO.pdf',
          '$_base/2021/08/E_c_matematica_M_mate-info_2021_bar_simulare_LRO.pdf',
        ),
        'model': _model('2020/12', 'mate-info', '2021'),
      },
      '2020': {
        'iunie': _std('2020/06', 'mate-info', '2020', '06'),
        'august': _std('2020/10', 'mate-info', '2020', '03'),
      },
    },
    'st-nat': {
      '2025': {
        'iunie': _std('2025/06', 'st-nat', '2025', '01'),
        'august': _std('2025/08', 'st-nat', '2025', '09'),
        'speciala': _std('2025/05', 'st-nat', '2025', '03'),
        'simulare': _std('2025/03', 'st-nat', '2025', 'simulare'),
        'model': _model('2024/11', 'st-nat', '2025'),
      },
      '2024': {
        'iunie': _std('2024/07', 'st-nat', '2024', '10'),
        'august': _std('2024/08', 'st-nat', '2024', '03'),
        'speciala': _std('2024/05', 'st-nat', '2024', '09'),
        'simulare': _std('2024/03', 'st-nat', '2024', 'simulare'),
      },
      '2023': {
        'iunie': _s23('st-nat', 'S1', '01'),
        'august': _s23('st-nat', 'S2', '07'),
        'speciala': _s23('st-nat', 'SS', '06'),
        'simulare': _sim23('st-nat'),
        'model': _short('2023/12', 'modelBAC2023SN'),
      },
      '2022': {
        'iunie': ExamDoc(
          '$_base/2022/06/E_c_matematica_M_st-nat_2022_var_01_LRO.pdf',
          '$_base/2022/09/E_c_matematica_M_st-nat_2022_bar_01_LRO.pdf',
        ),
        'august': _short('2023/12', 'exBACaug2022SN'),
        'speciala': _std('2022/05', 'st-nat', '2022', '03'),
        'simulare': _short('2023/12', 'simBACmar2022SN'),
        'model': _model('2021/11', 'st-nat', '2022'),
      },
      '2021': {
        'iunie': _std('2021/07', 'st-nat', '2021', '02'),
        'august': _std('2021/08', 'st-nat', '2021', '04'),
        'simulare': _std('2021/03', 'st-nat', '2021', 'simulare'),
        'model': _model('2020/12', 'st-nat', '2021'),
      },
      '2020': {
        'iunie': _std('2020/06', 'st-nat', '2020', '06'),
        'august': _std('2020/10', 'st-nat', '2020', '03'),
      },
    },
    'tehnologic': {
      '2025': {
        'iunie': _std('2025/06', 'tehnologic', '2025', '01'),
        'august': _std('2025/08', 'tehnologic', '2025', '09'),
        'speciala': _std('2025/05', 'tehnologic', '2025', '03'),
        'simulare': _std('2025/03', 'tehnologic', '2025', 'simulare'),
        'model': _model('2024/11', 'tehnologic', '2025'),
      },
      '2024': {
        'iunie': _std('2024/07', 'tehnologic', '2024', '10'),
        'august': _std('2024/08', 'tehnologic', '2024', '03'),
        'speciala': _std('2024/05', 'tehnologic', '2024', '09'),
        'simulare': _std('2024/03', 'tehnologic', '2024', 'simulare'),
      },
      '2023': {
        'iunie': _s23('tehnologic', 'S1', '01'),
        'august': _s23('tehnologic', 'S2', '07'),
        'speciala': _s23('tehnologic', 'SS', '06'),
        'simulare': _sim23('tehnologic'),
        'model': _short('2023/12', 'modelBAC2023TEHNO'),
      },
      '2022': {
        'iunie': _std('2022/06', 'tehnologic', '2022', '01'),
        'august': _short('2023/12', 'exBACaug2022TEHNO'),
        'speciala': _std('2022/05', 'tehnologic', '2022', '03'),
        'simulare': _short('2023/12', 'simBACmar2022TEHNO'),
        'model': _model('2021/11', 'tehnologic', '2022'),
      },
      '2021': {
        'iunie': _std('2021/07', 'tehnologic', '2021', '02'),
        'august': _std('2021/08', 'tehnologic', '2021', '04'),
        'simulare': _std('2021/08', 'tehnologic', '2021', 'simulare'),
        'model': _model('2020/12', 'tehnologic', '2021'),
      },
      '2020': {
        'iunie': _std('2020/06', 'tehnologic', '2020', '06'),
        'august': _std('2020/10', 'tehnologic', '2020', '03'),
      },
    },
    'pedagogic': {
      '2025': {
        'iunie': _std('2025/06', 'pedagogic', '2025', '01'),
        'august': _std('2025/08', 'pedagogic', '2025', '09'),
        'speciala': _std('2025/05', 'pedagogic', '2025', '03'),
        'simulare': _std('2025/03', 'pedagogic', '2025', 'simulare'),
        'model': _model('2024/11', 'pedagogic', '2025'),
      },
      '2024': {
        'iunie': _std('2024/07', 'pedagogic', '2024', '10'),
        'august': _std('2024/08', 'pedagogic', '2024', '03'),
        'simulare': _std('2024/03', 'pedagogic', '2024', 'simulare'),
        'model': _model('2023/11', 'pedagogic', '2024'),
      },
      '2023': {
        'iunie': _s23('pedagogic', 'S1', '01'),
        'august': _s23('pedagogic', 'S2', '07'),
        'simulare': _sim23('pedagogic'),
        'model': _short('2023/12', 'modelBAC2023PEDA'),
      },
      '2022': {
        'iunie': ExamDoc(
          '$_base/2022/06/E_c_matematica_M_pedagogic_2022_var_01_LRO.pdf',
          '$_base/2022/06/E_c_matematica_M_pedagogic_2022_bar_01.pdf',
        ),
        'august': _short('2023/12', 'exBACaug2022PEDA'),
        'speciala': ExamDoc(
          '$_base/2022/05/E_c_matematica_M_pedagogic_2022_var_03.pdf',
          '$_base/2022/05/E_c_matematica_M_pedagogic_2022_bar_03.pdf',
        ),
        'simulare': _short('2023/12', 'simBACmar2022PEDA'),
        'model': ExamDoc(
          '$_base/2021/11/E_c_Matematica_M_pedagogic_2022_var_model.pdf',
          '$_base/2021/11/E_c_Matematica_M_pedagogic_2022_bar_model.pdf',
        ),
      },
      '2021': {
        'iunie': _std('2021/07', 'pedagogic', '2021', '02'),
        'august': _std('2021/08', 'pedagogic', '2021', '04'),
        'simulare': _std('2021/08', 'pedagogic', '2021', 'simulare'),
        'model': _model('2020/12', 'pedagogic', '2021'),
      },
      '2020': {
        'iunie': _std('2020/06', 'pedagogic', '2020', '06'),
        'august': _std('2020/10', 'pedagogic', '2020', '03'),
      },
    },
  };

  static const String _blog =
      'https://profesorjitaruionel.com/wp-content/uploads';

  /// Official ministry papers for the non-math disciplines, mirrored on the
  /// aggregator CDN. All verified (HTTP 200). Keyed by the main-session paper
  /// for each of the three most recent years — used for every session, since
  /// it's the reference written variant for that year.
  static ExamDoc _b(String folder, String varName, String barName) =>
      ExamDoc('$_blog/$folder/$varName', '$_blog/$folder/$barName');

  /// Limba Română — differs by track (real/tehnologic vs uman/pedagogic).
  static final Map<String, Map<String, ExamDoc>> _romana = {
    'real': {
      '2025': _b(
        '2025/06',
        'E_a_romana_real_tehn_2025_var_07.pdf',
        'E_a_romana_real_tehn_2025_bar_07.pdf',
      ),
      '2024': _b(
        '2024/07',
        'E_a_romana_real_tehn_2024_var_02.pdf',
        'E_a_romana_real_tehn_2024_bar_02.pdf',
      ),
      '2023': _b(
        '2023/06',
        'E_a_romana_real_tehn_2023_var_06.pdf',
        'E_a_romana_real_tehn_2023_bar_06.pdf',
      ),
    },
    'uman': {
      '2025': _b(
        '2025/06',
        'E_a_romana_uman_ped_2025_var_07.pdf',
        'E_a_romana_uman_ped_2025_bar_07.pdf',
      ),
      '2024': _b(
        '2024/07',
        'E_a_romana_uman_ped_2024_var_02.pdf',
        'E_a_romana_uman_ped_2024_bar_02.pdf',
      ),
      '2023': _b(
        '2023/06',
        'E_a_romana_uman_ped_2023_var_06.pdf',
        'E_a_romana_uman_ped_2023_bar_06.pdf',
      ),
    },
  };

  /// All other written disciplines, keyed by subject then year.
  static final Map<String, Map<String, ExamDoc>> _other = {
    'istorie': {
      '2025': _b('2025/06', 'E_c_istorie_2025_var_01_LRO.pdf',
          'E_c_istorie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_c_istorie_2024_var_10_LRO.pdf',
          'E_c_istorie_2024_bar_10_LRO.pdf'),
      '2023': _b('2023/06', 'E_c_istorie_2023_var_01_LRO.pdf',
          'E_c_istorie_2023_bar_01_LRO.pdf'),
    },
    'biologie': {
      '2025': _b('2025/06', 'E_d_bio_veg_anim_2025_var_01_LRO.pdf',
          'E_d_bio_veg_anim_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_bio_veg_anim_2024_var_03_LRO.pdf',
          'E_d_bio_veg_anim_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_bio_veg_anim_2023_var_05_LRO.pdf',
          'E_d_bio_veg_anim_2023_bar_05_LRO.pdf'),
    },
    'chimie': {
      '2025': _b('2025/06', 'E_d_chimie_organica_2025_var_01_LRO.pdf',
          'E_d_chimie_organica_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_chimie_organica_2024_var_03_LRO.pdf',
          'E_d_chimie_organica_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_chimie_organica_2023_var_05_LRO.pdf',
          'E_d_chimie_organica_2023_bar_05_LRO.pdf'),
    },
    'fizica': {
      '2025': _b('2025/06', 'E_d_fizica_tehnologic_2025_var_01_LRO.pdf',
          'E_d_fizica_tehnologic_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_fizica_teoretic-vocational_2024_var_03.pdf',
          'E_d_fizica_teoretic-vocational_2024_bar_03.pdf'),
      '2023': _b('2023/06', 'E_d_fizica_teoretic_vocational_2023_var_05_LRO.pdf',
          'E_d_fizica_teoretic_vocational_2023_bar_05_LRO.pdf'),
    },
    'informatica': {
      '2025': _b('2025/06', 'E_d_Informatica_2025_sp_MI_C_var_01_LRO.pdf',
          'E_d_informatica_2025_sp_MI_bar_01_LRO.pdf'),
      // 2024 barem not published separately on mirror — reuse the subject.
      '2024': _b('2024/07', 'E_d_Informatica_2024_sp_MI_C_var_03_LRO.pdf',
          'E_d_Informatica_2024_sp_MI_C_var_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_Informatica_2023_sp_MI_C_var_05_LRO.pdf',
          'E_d_Informatica_2023_sp_MI_bar_05_LRO.pdf'),
    },
    'geografie': {
      '2025': _b('2025/06', 'E_d_geografie_2025_var_01_LRO.pdf',
          'E_d_geografie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_geografie_2024_var_03_LRO.pdf',
          'E_d_geografie_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_geografie_2023_var_05_LRO.pdf',
          'E_d_geografie_2023_bar_05_LRO.pdf'),
    },
    'logica': {
      '2025': _b('2025/06', 'E_d_logica_2025_var_01_LRO.pdf',
          'E_d_logica_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_logica_2024_var_03_LRO.pdf',
          'E_d_logica_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_logica_2023_var_05_LRO.pdf',
          'E_d_logica_2023_bar_05_LRO.pdf'),
    },
    'psihologie': {
      '2025': _b('2025/06', 'E_d_psihologie_2025_var_01_LRO.pdf',
          'E_d_psihologie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_psihologie_2024_var_03_LRO.pdf',
          'E_d_psihologie_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_psihologie_2023_var_05_LRO.pdf',
          'E_d_psihologie_2023_bar_05_LRO.pdf'),
    },
    'economie': {
      '2025': _b('2025/06', 'E_d_economie_2025_var_01_LRO.pdf',
          'E_d_economie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_economie_2024_var_03_LRO.pdf',
          'E_d_economie_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_economie_2023_var_05_LRO.pdf',
          'E_d_economie_2023_bar_05_LRO.pdf'),
    },
    'sociologie': {
      '2025': _b('2025/06', 'E_d_sociologie_2025_var_01_LRO.pdf',
          'E_d_sociologie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_sociologie_2024_var_03_LRO.pdf',
          'E_d_sociologie_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_sociologie_2023_var_05_LRO.pdf',
          'E_d_sociologie_2023_bar_05_LRO.pdf'),
    },
    'filosofie': {
      '2025': _b('2025/06', 'E_d_filosofie_2025_var_01_LRO.pdf',
          'E_d_filosofie_2025_bar_01_LRO.pdf'),
      '2024': _b('2024/07', 'E_d_filosofie_2024_var_03_LRO.pdf',
          'E_d_filosofie_2024_bar_03_LRO.pdf'),
      '2023': _b('2023/06', 'E_d_filosofie_2023_var_05_LRO.pdf',
          'E_d_filosofie_2023_bar_05_LRO.pdf'),
    },
  };

  /// Resolves the exam documents for a selection, or null when the catalog
  /// has no entry (falls back to bundled assets, then to an empty state).
  static ExamPdfAssets? resolve({
    required String profile,
    required String subject,
    required String year,
    required String session,
  }) {
    // 1. Mathematics — full per-session coverage across profiles.
    final mathProfile = _mathProfileFor(profile, subject);
    if (mathProfile != null) {
      final doc = _math[mathProfile]?[year.trim()]?[_sessionKey(session)];
      return doc == null ? null : _assets(doc);
    }

    // 2. Limba Română — real vs uman track.
    if (_isRomana(subject)) {
      final track = _isUmanProfile(profile) ? 'uman' : 'real';
      final doc = _nearestYear(_romana[track], year);
      return doc == null ? null : _assets(doc);
    }

    // 3. Other written disciplines. Only the reference written variant per
    // year exists, so it is returned for any chosen session.
    final key = _otherKey(subject);
    if (key != null) {
      final doc = _nearestYear(_other[key], year);
      return doc == null ? null : _assets(doc);
    }

    return null;
  }

  /// Returns the paper for [year], or the most recent available year when the
  /// exact year isn't covered — so a subject never ends up unavailable.
  static ExamDoc? _nearestYear(Map<String, ExamDoc>? byYear, String year) {
    if (byYear == null || byYear.isEmpty) return null;
    final exact = byYear[year.trim()];
    if (exact != null) return exact;
    final years = byYear.keys.toList()..sort();
    return byYear[years.last];
  }

  static ExamPdfAssets _assets(ExamDoc doc) =>
      ExamPdfAssets(subjectPdfAsset: doc.subject, answerPdfAsset: doc.barem);

  /// True when the catalog has at least one paper for this subject.
  static bool covers({required String profile, required String subject}) {
    return _mathProfileFor(profile, subject) != null ||
        _isRomana(subject) ||
        _otherKey(subject) != null;
  }

  static bool _isRomana(String subject) =>
      _normalize(subject).contains('romana');

  static bool _isUmanProfile(String profile) {
    final p = _normalize(profile);
    return p.contains('filologie') ||
        p.contains('stiintesociale') ||
        p.contains('pedagogic');
  }

  static String? _otherKey(String subject) {
    final s = _normalize(subject);
    if (s.contains('istor')) return 'istorie';
    if (s.contains('biolog')) return 'biologie';
    if (s.contains('chim')) return 'chimie';
    if (s.contains('fizic')) return 'fizica';
    if (s.contains('informat')) return 'informatica';
    if (s.contains('geograf')) return 'geografie';
    if (s.contains('logic')) return 'logica';
    if (s.contains('psiholog')) return 'psihologie';
    if (s.contains('econom')) return 'economie';
    if (s.contains('sociolog')) return 'sociologie';
    if (s.contains('filosof') || s.contains('filozof')) return 'filosofie';
    return null;
  }

  static String? _mathProfileFor(String profile, String subject) {
    final s = _normalize(subject);
    final isMath = s.contains('matematic') || s == 'm1' || s == 'm2';
    if (!isMath) return null;

    final p = _normalize(profile);
    if (p.contains('mateinfo')) return 'mate-info';
    if (p.contains('stiintelenaturii') || p.contains('stiintenaturii')) {
      return 'st-nat';
    }
    if (p.contains('tehnologic') || p.contains('economic')) {
      return 'tehnologic';
    }
    if (p.contains('pedagogic')) return 'pedagogic';

    // Fall back on the subject label when the profile is ambiguous.
    if (s.contains('m1')) return 'mate-info';
    if (s.contains('m2')) return 'tehnologic';
    if (s.contains('m3')) return 'pedagogic';
    return null;
  }

  static String _sessionKey(String session) {
    final n = _normalize(session);
    if (n.contains('iunie') || n.contains('vara')) return 'iunie';
    if (n.contains('aug') || n.contains('sept') || n.contains('toamna')) {
      return 'august';
    }
    if (n.contains('simulare')) return 'simulare';
    if (n.contains('special')) return 'speciala';
    if (n.contains('model')) return 'model';
    return 'iunie';
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
