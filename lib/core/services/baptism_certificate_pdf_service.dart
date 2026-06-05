import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaptismCertificatePdfService {
  Future<Uint8List> generateCertificate(MemberModel member) async {
    final doc = pw.Document();

    final logoImage = await _loadLogo();
    final profileImage = await _loadProfileImage(member.imagePath);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logos and title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null)
                      pw.Image(logoImage, width: 80, height: 80)
                    else
                      pw.SizedBox(width: 80, height: 80),
                    
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            "EGLISE PROTESTANTE EVANGELIQUE DE GUINEE",
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            "EPE DE LABE",
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            "ALLIANCE CHRETIENNE ET MISSIONNAIRE",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontStyle: pw.FontStyle.italic,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            "Certificat de Baptême",
                            style: pw.TextStyle(
                              fontSize: 20,
                              color: PdfColors.blue800,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 15),
                          pw.RichText(
                            textAlign: pw.TextAlign.center,
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: "Marc 16 : 16 ", // Image says Matthieu but text is Marc 16:16. Let's use image's text "Matthieu 16 : 16" to match strictly.
                                  style: pw.TextStyle(color: PdfColors.red, fontSize: 14),
                                ),
                                pw.TextSpan(
                                  text: "« Celui qui croira et qui sera baptisé sera sauvé,\nmais celui qui ne croira pas sera condamné. »",
                                  style: pw.TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Container(
                      width: 80,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue200, width: 1),
                      ),
                      child: profileImage != null
                          ? pw.Image(profileImage, fit: pw.BoxFit.cover)
                          : null,
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 15),

                // Body text
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
                          children: [
                            pw.TextSpan(text: "Je soussigné Rév. Pasteur FEINDOUNO Samuel, certifie que le nommé "),
                            pw.TextSpan(
                              text: member.fullName,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.RichText(
                        text: pw.TextSpan(
                          style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
                          children: [
                            pw.TextSpan(text: "Né le "),
                            pw.TextSpan(
                              text: member.birthDate?.substring(0, 10) ?? "...........................",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(text: " à "),
                            pw.TextSpan(
                              text: member.birthPlace ?? "........................................",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Fils de ................................................................ et de ................................................................",
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.SizedBox(height: 10),
                      pw.RichText(
                        text: pw.TextSpan(
                          style: pw.TextStyle(fontSize: 14, lineSpacing: 5),
                          children: [
                            pw.TextSpan(text: "Domiciliés au quartier de : "),
                            pw.TextSpan(
                              text: member.quartier ?? "........................................",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(text: ", Commune Urbaine de Labé"),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Profession : ........................................................",
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "A reçu le baptême le ......../......../................",
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Signatures
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Le Formateur", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.SizedBox(height: 40),
                          pw.Text("M. David Fara YOMBOUNO", style: pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Le Révérend Pasteur", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.SizedBox(height: 40),
                          pw.Text("FEINDOUNO Samuel", style: pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
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
