import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/services/reporting_pdf_service.dart';

class ReportingPage extends StatefulWidget {
  const ReportingPage({super.key});

  @override
  State<ReportingPage> createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
  bool _isLoading = true;
  int _totalMembers = 0;
  double _memberGrowth = 0;
  Map<String, int> _statusDistribution = {};
  List<Map<String, dynamic>> _financialTrend = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dbHelper = DatabaseHelper();
    final memberDao = await dbHelper.memberDao;
    final financeDao = await dbHelper.financeDao;

    final currentYear = DateTime.now().year;
    final total = await memberDao.getMemberCount();
    final growthThisYear = await memberDao.getYearlyGrowth(currentYear);
    final growthLastYear = await memberDao.getYearlyGrowth(currentYear - 1);

    double growthPerc = 0;
    if (growthLastYear > 0) {
      growthPerc = ((growthThisYear - growthLastYear) / growthLastYear) * 100;
    } else if (growthThisYear > 0) {
      growthPerc = 100;
    }

    final distribution = await memberDao.getMemberStatusDistribution();
    final trend = await financeDao.getYearlyTrend(currentYear);

    double totalInc = await financeDao.getTotalIncome();
    double totalExp = await financeDao.getTotalExpenses();

    setState(() {
      _totalMembers = total;
      _memberGrowth = growthPerc;
      _statusDistribution = distribution;
      _financialTrend = trend;
      _totalIncome = totalInc;
      _totalExpenses = totalExp;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildExecutiveSummary()),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildDistributionChart()),
            ],
          ),
          const SizedBox(height: 32),
          _buildFinancialTrendsChart(),
          const SizedBox(height: 32),
          _buildReportTemplates(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rapports & Statistiques",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Analyses consolidées et rapports de performance culturelle",
                style: TextStyle(color: context.subtitleColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildHeaderAction(
              icon: Icons.date_range_rounded,
              label: "Année 2024",
              onTap: () {},
              color: context.surfaceColor,
              textColor: context.textColor,
            ),
            const SizedBox(width: 16),
            _buildHeaderAction(
              icon: Icons.picture_as_pdf_rounded,
              label: "Rapport Annuel PDF",
              onTap: () {
                if (_isLoading) return;
                ReportingPdfService().generateAnnualReport(
                  totalMembers: _totalMembers,
                  memberGrowth: _memberGrowth,
                  statusDistribution: _statusDistribution,
                  financialTrend: _financialTrend,
                  totalIncome: _totalIncome,
                  totalExpenses: _totalExpenses,
                );
              },
              color: AppColors.primaryOrange,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: color == context.surfaceColor
              ? BorderSide(color: context.borderColor)
              : BorderSide.none,
        ),
        elevation: color == context.surfaceColor ? 0 : 4,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Croissance Membres",
          _isLoading ? "..." : "${_memberGrowth.toStringAsFixed(1)}%",
          "Année ${DateTime.now().year}",
          Icons.trending_up_rounded,
          Colors.green,
        ),
        _buildStatCard(
          "Membres Totaux",
          _isLoading ? "..." : _totalMembers.toString(),
          "Inscrits en base",
          Icons.people_alt_rounded,
          Colors.blue,
        ),
        _buildStatCard(
          "Santé Financière",
          _isLoading
              ? "..."
              : (_totalIncome > _totalExpenses ? "Excellent" : "Critique"),
          "Budget vs Réel",
          Icons.health_and_safety_rounded,
          (_totalIncome > _totalExpenses ? Colors.green : Colors.red),
        ),
        _buildStatCard(
          "Taux de Complétion",
          "100%",
          "Données à jour",
          Icons.verified_user_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveSummary() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Résumé Exécutif",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSummaryItem(
            "Membres",
            "La base de données compte désormais ${_totalMembers} membres actifs. La croissance cette année est estimée à ${_memberGrowth.toStringAsFixed(1)}%.",
            Icons.people_alt_rounded,
            Colors.blue,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            "Finances",
            "Le solde global est de ${(_totalIncome - _totalExpenses).toInt()} GNF. Les revenus totaux s'élèvent à ${_totalIncome.toInt()} GNF.",
            Icons.account_balance_wallet_rounded,
            Colors.green,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            "Analyse",
            "Les rapports consolidés indiquent une stabilité opérationnelle positive pour l'année en cours.",
            Icons.assignment_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(color: context.subtitleColor, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Répartition par Statut",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: _isLoading || _statusDistribution.isEmpty
                ? const Center(child: Text("Pas de données"))
                : PieChart(
                    PieChartData(
                      sections: _statusDistribution.entries.map((entry) {
                        final colorMap = {
                          'Actif': Colors.blue,
                          'Nouveau': Colors.green,
                          'Visiteur': Colors.orange,
                          'Inactif': Colors.red,
                        };
                        return PieChartSectionData(
                          color: colorMap[entry.key] ?? Colors.grey,
                          value: entry.value.toDouble(),
                          title: '${entry.value}',
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          _buildChartLegend("Actifs", Colors.blue),
          _buildChartLegend("Nouveaux", Colors.green),
          _buildChartLegend("Visiteurs", Colors.orange),
          _buildChartLegend("Inactifs", Colors.red),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: context.subtitleColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tendance Mensuelle des Revenus (vs Année Précedente)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 300,
            child: _isLoading || _financialTrend.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5000000,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: context.borderColor, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (val, meta) => Text(
                              "${(val / 1000000).toInt()}M",
                              style: TextStyle(
                                color: context.iconColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const months = [
                                'Jan',
                                'Fev',
                                'Mar',
                                'Avr',
                                'Mai',
                                'Jun',
                                'Jul',
                                'Aou',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec',
                              ];
                              int idx = val.toInt();
                              if (idx >= 0 && idx < months.length) {
                                return Text(
                                  months[idx],
                                  style: TextStyle(
                                    color: context.iconColor,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const Text("");
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.primaryOrange,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          spots: _financialTrend.map((e) {
                            return FlSpot(
                              (e['month'] - 1).toDouble(),
                              e['income'] as double,
                            );
                          }).toList(),
                        ),
                        LineChartBarData(
                          isCurved: true,
                          color: context.iconColor.withOpacity(0.2),
                          barWidth: 2,
                          dashArray: [5, 5],
                          dotData: const FlDotData(show: false),
                          spots: _financialTrend.map((e) {
                            return FlSpot(
                              (e['month'] - 1).toDouble(),
                              e['expense'] as double,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Modèles de Rapports",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2.5,
          children: [
            _buildReportCard(
              "Bilan Financier Mensuel",
              "Synthèse des entrées et sorties du mois",
              Icons.account_balance_rounded,
            ),
            _buildReportCard(
              "Rapport de Croissance",
              "Analyse de l'évolution des membres",
              Icons.person_add_rounded,
            ),
            _buildReportCard(
              "Audit des Activités",
              "Performance et participation aux cultes",
              Icons.analytics_rounded,
            ),
            _buildReportCard(
              "Registre des Baptêmes",
              "Historique complet des baptêmes",
              Icons.waves_rounded,
            ),
            _buildReportCard(
              "Inventaire Équipement",
              "État global du matériel de l'église",
              Icons.inventory_2_rounded,
            ),
            _buildReportCard(
              "Planning Trimestriel",
              "Prévisions des événements à venir",
              Icons.calendar_view_month_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surfaceHighlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(color: context.subtitleColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
