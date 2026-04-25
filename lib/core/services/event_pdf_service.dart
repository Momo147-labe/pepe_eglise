import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:eglise_labe/core/models/event_model.dart';

class EventPdfService {
  Future<void> generateEventReport(List<EventModel> events) async {
    final doc = pw.Document();
    final logoImage = await _loadLogo();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(15 * PdfPageFormat.mm),
        header: (pw.Context context) => _buildHeader(logoImage),
        footer: (pw.Context context) => _buildFooter(context),
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
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
            data: <List<String>>[
              <String>[
                'Titre de l\'Événement',
                'Date',
                'Lieu',
                'Fréquence',
                'Budget (GNF)',
              ],
              ...events.map(
                (e) => [
                  _clean(e.title),
                  e.date,
                  _clean(e.location),
                  _clean(e.frequency ?? 'Une fois'),
                  _formatCurrency(e.budget ?? 0),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          _buildSummary(events),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  pw.Widget _buildHeader(pw.MemoryImage? logo) {
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
                  "Rapport du Calendrier des Événements",
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

  pw.Widget _buildSummary(List<EventModel> events) {
    double totalBudget = events.fold(
      0,
      (sum, item) => sum + (item.budget ?? 0),
    );
    int totalAttendees = events.fold(
      0,
      (sum, item) => sum + (item.expectedAttendees ?? 0),
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Total Événements", events.length.toString()),
          _buildSummaryItem(
            "Budget Total",
            "${_formatCurrency(totalBudget)} GNF",
          ),
          _buildSummaryItem("Participants Attendus", totalAttendees.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
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
      final data = await rootBundle.load('assets/eglise.jpeg');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }
}
