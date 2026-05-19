import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:eglise_labe/core/models/member_model.dart';

class CardPdfService {
  static const double cardWidth = 86 * PdfPageFormat.mm;
  static const double cardHeight = 40 * PdfPageFormat.mm;

  Future<void> generateMemberCard(MemberModel member) async {
    final doc = pw.Document();

    final logoImage = await _loadLogo();
    final profileImage = await _loadProfileImage(member.imagePath);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: _buildCard(member, logoImage, profileImage));
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> generateAllMemberCards(List<MemberModel> members) async {
    final doc = pw.Document();
    final logoImage = await _loadLogo();

    // 4 cards per page
    for (var i = 0; i < members.length; i += 4) {
      final chunk = members.sublist(
        i,
        (i + 4) > members.length ? members.length : (i + 4),
      );

      final profileImages = <String, pw.MemoryImage?>{};
      for (var m in chunk) {
        profileImages[m.id.toString()] = await _loadProfileImage(m.imagePath);
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(10 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (chunk.isNotEmpty)
                      _buildCard(
                        chunk[0],
                        logoImage,
                        profileImages[chunk[0].id.toString()],
                      ),
                    if (chunk.length > 1)
                      _buildCard(
                        chunk[1],
                        logoImage,
                        profileImages[chunk[1].id.toString()],
                      ),
                  ],
                ),
                pw.SizedBox(height: 10 * PdfPageFormat.mm),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (chunk.length > 2)
                      _buildCard(
                        chunk[2],
                        logoImage,
                        profileImages[chunk[2].id.toString()],
                      ),
                    if (chunk.length > 3)
                      _buildCard(
                        chunk[3],
                        logoImage,
                        profileImages[chunk[3].id.toString()],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<void> exportMembersList(List<MemberModel> members) async {
    final doc = pw.Document();
    final logoImage = await _loadLogo();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
        header: (pw.Context context) => _buildReportHeader(logoImage),
        footer: (pw.Context context) => _buildReportFooter(context),
        build: (pw.Context context) => [
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1A433A),
            ),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.centerRight,
            },
            data: <List<String>>[
              <String>[
                'ID',
                'Nom Complet',
                'Sexe',
                'Naissance',
                'Adhésion',
                'Groupe',
                'Statut',
                'Téléphone',
              ],
              ...members.map(
                (m) => [
                  "PEL-${m.id.toString().padLeft(5, '0')}",
                  _clean(m.fullName),
                  _clean(m.gender),
                  m.birthDate?.substring(0, 10) ?? "",
                  m.joinedAt.substring(0, 10),
                  _clean(m.groupName),
                  _clean(m.memberStatus),
                  _clean(m.phone),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
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

  pw.Widget _buildReportHeader(pw.MemoryImage? logo) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null) pw.Image(logo, width: 50, height: 50),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "PROTESTANTE EVANGELIQUE DE LABE",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Liste Générale des Membres",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Date: ${DateTime.now().toString().substring(0, 10)}",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
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

  pw.Widget _buildReportFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Page ${context.pageNumber} sur ${context.pagesCount}",
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              "Eglise Protestante Evangélique de Labé",
              style: pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCard(
    MemberModel member,
    pw.MemoryImage? logo,
    pw.MemoryImage? profile,
  ) {
    return pw.Container(
      width: cardWidth,
      height: cardHeight,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      child: pw.Stack(
        children: [
          // Background accents (Blue/Gold waves)
          _buildBackgroundPatterns(),

          pw.Row(
            children: [
              // Left Panel (Primary Blue)
              _buildLeftPanel(logo),

              // Right Content Area
              pw.Expanded(child: _buildRightPanel(member, profile)),
            ],
          ),

          // Footer
          pw.Align(alignment: pw.Alignment.bottomCenter, child: _buildFooter()),
        ],
      ),
    );
  }

  pw.Widget _buildBackgroundPatterns() {
    return pw.Positioned.fill(
      child: pw.Stack(
        children: [
          // Placeholder for the curvy shapes
          // In a real implementation with more time, I'd use pw.ClipPath and pw.Graphics
        ],
      ),
    );
  }

  pw.Widget _buildLeftPanel(pw.MemoryImage? logo) {
    return pw.Container(
      width: cardWidth * 0.28,
      height: cardHeight,
      color: PdfColor.fromInt(0xFF1A433A), // Dark Church Green/Blue
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          if (logo != null)
            pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: PdfColors.white,
              ),
              padding: const pw.EdgeInsets.all(2),
              child: pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover)),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            "PROTESTANTE",
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            "EVANGELIQUE",
            style: pw.TextStyle(
              color: PdfColors.orange,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            "DE LABE",
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(
            color: PdfColors.orange,
            thickness: 1,
            indent: 5,
            endIndent: 5,
          ),
          pw.Text(
            "CARTE DE MEMBRE",
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 5,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          pw.Spacer(),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: pw.Text(
              "Unis en Christ",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 4,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
        ],
      ),
    );
  }

  pw.Widget _buildRightPanel(MemberModel member, pw.MemoryImage? profile) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "PROTESTANTE EVANGELIQUE DE LABE",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF1A433A),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "\"Car nous sommes son ouvrage, ayant été créés en Jésus-Christ...\"",
                    style: pw.TextStyle(
                      fontSize: 4,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                child: pw.Text(
                  member.memberStatus.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 4,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Photo
              pw.Container(
                width: 45,
                height: 55,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: profile != null
                    ? pw.Image(profile, fit: pw.BoxFit.cover)
                    : pw.Center(
                        child: pw.Text(
                          "PHOTO",
                          style: pw.TextStyle(fontSize: 6),
                        ),
                      ),
              ),
              pw.SizedBox(width: 8),
              // Info
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("NOM COMPLET", member.fullName),
                    _buildInfoRow(
                      "DATE DE NAISSANCE",
                      member.birthDate?.substring(0, 10) ?? "",
                    ),
                    _buildInfoRow(
                      "DATE D'ADHÉSION",
                      member.joinedAt.substring(0, 10),
                    ),
                    _buildInfoRow("GROUPE / MOUVEMENT", member.groupName),
                    _buildInfoRow("TÉLÉPHONE", member.phone),
                    _buildInfoRow(
                      "ID MEMBRE",
                      "PEL-${member.id.toString().padLeft(5, '0')}",
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Le Pasteur Responsable",
                    style: pw.TextStyle(fontSize: 4),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(width: 40, height: 1, color: PdfColors.black),
                ],
              ),
              pw.Column(
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: "PEL-${member.id.toString().padLeft(5, '0')}",
                    width: 60,
                    height: 15,
                    drawText: false,
                  ),
                  pw.Text(
                    "PEL-${member.id.toString().padLeft(5, '0')}",
                    style: pw.TextStyle(fontSize: 4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 55,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 4.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(":", style: pw.TextStyle(fontSize: 4.5)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      width: cardWidth,
      height: 8,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF0F172A),
        borderRadius: pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(8),
          bottomRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          "LA FOI  •  L'AMOUR  •  L'UNITÉ  •  LE SERVICE",
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 4,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/eglise.jpeg');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  Future<pw.MemoryImage?> _loadProfileImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (await file.exists()) {
        return pw.MemoryImage(await file.readAsBytes());
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
}
