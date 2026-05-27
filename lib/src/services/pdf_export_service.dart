import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

import 'firestore_service.dart';

class PdfExportService {
  static Future<File> exportUserData({
    required UserProfileData profile,
    required List<StudySession> sessions,
  }) async {
    final document = pw.Document();
    final totalMinutes =
        sessions.fold<int>(
          0,
          (sum, session) => sum + session.durationSeconds,
        ) ~/
        60;
    final averageGrade = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(
                0,
                (sum, session) => sum + session.estimatedGrade,
              ) /
              sessions.length;

    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Bac Pro - raport personal')),
          pw.Text('Nume: ${_pdfText(profile.name)}'),
          pw.Text('Email: ${_pdfText(profile.email)}'),
          pw.Text('Scoala: ${_pdfText(profile.school)}'),
          pw.Text('Profil: ${_pdfText(profile.selectedProfile)}'),
          pw.SizedBox(height: 18),
          pw.Header(level: 1, child: pw.Text('Rezumat')),
          pw.Text('Subiecte rezolvate: ${sessions.length}'),
          pw.Text('Timp total: $totalMinutes minute'),
          pw.Text(
            'Media estimata: ${averageGrade == 0 ? '-' : averageGrade.toStringAsFixed(1)}',
          ),
          pw.SizedBox(height: 18),
          pw.Header(level: 1, child: pw.Text('Istoric sesiuni')),
          if (sessions.isEmpty)
            pw.Text('Nu exista sesiuni salvate inca.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Subiect', 'An', 'Sesiune', 'Nota', 'Minute'],
              data: sessions
                  .map(
                    (session) => [
                      _pdfText(session.subjectName),
                      session.year,
                      _pdfText(session.sessionName),
                      session.estimatedGrade.toStringAsFixed(1),
                      '${session.durationSeconds ~/ 60}',
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return _save(document, 'bac_pro_raport.pdf');
  }

  static Future<File> exportSubjectPdf({required String assetPath}) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final fileName = assetPath.split('/').last;
    return _saveBytes(bytes, fileName);
  }

  static Future<File> _save(pw.Document document, String fileName) async {
    final directory = await Directory.systemTemp.createTemp('bac_pro_pdf_');
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(await document.save(), flush: true);
  }

  static Future<File> _saveBytes(Uint8List bytes, String fileName) async {
    final directory = await Directory.systemTemp.createTemp('bac_pro_pdf_');
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(bytes, flush: true);
  }

  static String _pdfText(String value) {
    return value
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ş', 's')
        .replaceAll('ț', 't')
        .replaceAll('ţ', 't')
        .replaceAll('Ă', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Î', 'I')
        .replaceAll('Ș', 'S')
        .replaceAll('Ş', 'S')
        .replaceAll('Ț', 'T')
        .replaceAll('Ţ', 'T');
  }
}
