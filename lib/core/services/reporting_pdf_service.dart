import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportingPdfService {
  Future<void> generateAnnualReport({
    required int totalMembers,
    required double memberGrowth,
    required Map<String, int> statusDistribution,
    required List<Map<String, dynamic>> financialTrend,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    final pdf = pw.Document();

    // Try loading logo
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/eglise.jpeg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'GNF',
    );
    final months = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "PROTESTANTE EVANGELIQUE DE LABE",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Rapport Exécutif Annuel - ${DateTime.now().year}",
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        "Généré le : ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  if (logoImage != null)
                    pw.Container(
                      height: 50,
                      width: 50,
                      child: pw.Image(logoImage),
                    ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 24),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Text(
              "Résumé Synthétique",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 16),
            _buildSummaryRow(
              "Membres Totaux",
              totalMembers.toString(),
              "Croissance Annuelle",
              "${memberGrowth > 0 ? '+' : ''}${memberGrowth.toStringAsFixed(1)}%",
            ),
            pw.SizedBox(height: 12),
            _buildSummaryRow(
              "Revenus Totaux",
              currencyFormat.format(totalIncome),
              "Dépenses Totales",
              currencyFormat.format(totalExpenses),
            ),
            pw.SizedBox(height: 32),

            _buildSectionTitle("Répartition des Membres (Statut)"),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Statut', 'Nombre de Membres', 'Pourcentage'],
              data: statusDistribution.entries.map((e) {
                final percentage = totalMembers > 0
                    ? (e.value / totalMembers * 100).toStringAsFixed(1)
                    : "0.0";
                return [e.key, e.value.toString(), "$percentage%"];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
            pw.SizedBox(height: 32),

            _buildSectionTitle("Analyse Financière Mensuelle"),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Mois', 'Revenus', 'Dépenses'],
              data: financialTrend.map((e) {
                return [
                  months[(e['month'] as int) - 1],
                  currencyFormat.format(e['income'] ?? 0),
                  currencyFormat.format(
                    e['expense'] ?? 0,
                  ), // Use 'expense' matching getYearlyTrend
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.teal800,
              ),
              cellAlignment: pw.Alignment.centerRight,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Confidentiel - Usage Interne",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    "Page ${context.pageNumber} / ${context.pagesCount}",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rapport_Executif_Annuel_${DateTime.now().year}.pdf',
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(child: _buildSummaryBox(label1, value1)),
        pw.SizedBox(width: 16),
        pw.Expanded(child: _buildSummaryBox(label2, value2)),
      ],
    );
  }

  pw.Widget _buildSummaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
