import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:eglise_labe/core/models/mouvement_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';

class MouvementPdfService {
  Future<void> generateMouvementsReport(List<MouvementModel> mouvements) async {
    final doc = pw.Document();
    final logoImage = await _loadLogo();
    
    final db = DatabaseHelper();
    final mvtDao = await db.mouvementDao;
    
    // Pre-fetch all members for all movements
    final Map<int, List<MemberModel>> mouvementMembers = {};
    for (var m in mouvements) {
      if (m.id != null) {
        mouvementMembers[m.id!] = await mvtDao.getMouvementMembers(m.id!);
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
        header: (pw.Context context) => _buildHeader(logoImage),
        footer: (pw.Context context) => _buildFooter(context),
        build: (pw.Context context) {
          final List<pw.Widget> content = [
            pw.SizedBox(height: 10),
            pw.Text(
              "Liste des Mouvements et de leurs Membres",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1A433A)),
            ),
            pw.SizedBox(height: 20),
          ];

          for (var mvt in mouvements) {
            content.add(_buildMouvementSection(mvt, mouvementMembers[mvt.id] ?? []));
            content.add(pw.SizedBox(height: 15));
          }

          return content;
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> generateSingleMouvementReport(MouvementModel mvt, List<MemberModel> members) async {
    final doc = pw.Document();
    final logoImage = await _loadLogo();
    
    // Sort members: leaders first, then 'Membre'
    final targetRoles = [
      'Président',
      'Vice-président',
      'Secrétaire',
      'Chargé des affaires sociales',
      'Trésorière',
      'Membre'
    ];
    
    final sortedMembers = List<MemberModel>.from(members);
    sortedMembers.sort((a, b) {
      int idxA = targetRoles.indexOf(a.poste ?? 'Membre');
      int idxB = targetRoles.indexOf(b.poste ?? 'Membre');
      if (idxA == -1) idxA = 999;
      if (idxB == -1) idxB = 999;
      return idxA.compareTo(idxB);
    });

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
        header: (pw.Context context) => _buildHeader(logoImage, title: "Rapport du Mouvement: ${mvt.nom}"),
        footer: (pw.Context context) => _buildFooter(context),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),
            pw.Text(
              "Liste complète des membres",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1A433A)),
            ),
            pw.SizedBox(height: 20),
            
            // Re-use _buildMouvementSection logic but without filtering
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        _clean(mvt.nom),
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                      ),
                      pw.Text(
                        "${sortedMembers.length} membres",
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ]
                  ),
                  if (mvt.description != null && mvt.description!.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _clean(mvt.description!),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                  pw.SizedBox(height: 8),
                  pw.Divider(color: PdfColors.grey200, thickness: 1),
                  pw.SizedBox(height: 8),
                  
                  if (sortedMembers.isEmpty)
                    pw.Text("Aucun membre", style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500))
                  else
                    pw.TableHelper.fromTextArray(
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2C5E4E)),
                      cellStyle: const pw.TextStyle(fontSize: 10),
                      cellHeight: 20,
                      cellAlignments: {
                        0: pw.Alignment.centerLeft,
                        1: pw.Alignment.centerLeft,
                        2: pw.Alignment.centerLeft,
                      },
                      data: <List<String>>[
                        <String>['Nom complet', 'Poste', 'Téléphone'],
                        ...sortedMembers.map(
                          (m) => [
                            _clean(m.fullName),
                            _clean(m.poste ?? 'Membre'),
                            _clean(m.phone),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _buildMouvementSection(MouvementModel mvt, List<MemberModel> members) {
    // Sort members: leaders first
    final targetRoles = [
      'Président',
      'Vice-président',
      'Secrétaire',
      'Chargé des affaires sociales',
      'Trésorière'
    ];
    
    final filteredMembers = members
        .where((m) => m.poste != null && targetRoles.contains(m.poste))
        .toList();
        
    filteredMembers.sort((a, b) {
      return targetRoles.indexOf(a.poste!).compareTo(targetRoles.indexOf(b.poste!));
    });

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _clean(mvt.nom),
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
              pw.Text(
                "${filteredMembers.length} dirigeants",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ]
          ),
          if (mvt.description != null && mvt.description!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              _clean(mvt.description!),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey200, thickness: 1),
          pw.SizedBox(height: 8),
          
          if (filteredMembers.isEmpty)
            pw.Text("Aucun dirigeant défini", style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2C5E4E)),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
              },
              data: <List<String>>[
                <String>['Nom complet', 'Poste', 'Téléphone'],
                ...filteredMembers.map(
                  (m) => [
                    _clean(m.fullName),
                    _clean(m.poste ?? 'Membre'),
                    _clean(m.phone),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _buildHeader(pw.MemoryImage? logo, {String title = "Rapport des Mouvements"}) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null) pw.Image(logo, width: 60, height: 60),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "PROTESTANTE EVANGELIQUE DE LABE",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  title,
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  "Généré le: ${DateTime.now().toString().substring(0, 10)}",
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColor.fromInt(0xFF1A433A)),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Page ${context.pageNumber} sur ${context.pagesCount}",
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              "© Eglise Protestante Evangélique de Labé",
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  String _clean(String? s) {
    if (s == null) return "";
    return s.replaceAll(
      RegExp(
        r'[\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{1f700}-\u{1f77f}\u{1f780}-\u{1f7ff}\u{1f800}-\u{1f8ff}\u{1f900}-\u{1f9ff}\u{1fa00}-\u{1fa6f}\u{1fa70}-\u{1faff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}]',
        unicode: true,
      ),
      '',
    );
  }

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logoPath = prefs.getString('church_logo_path');
      if (logoPath != null && logoPath.isNotEmpty) {
        final file = File(logoPath);
        if (await file.exists()) {
          return pw.MemoryImage(await file.readAsBytes());
        }
      }
      final data = await rootBundle.load('assets/eglise.jpeg');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }
}
