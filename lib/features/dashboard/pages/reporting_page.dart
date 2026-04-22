import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportingPage extends StatefulWidget {
  const ReportingPage({super.key});

  @override
  State<ReportingPage> createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
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
              const Text(
                "Rapports & Statistiques",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Analyses consolidées et rapports de performance culturelle",
                style: const TextStyle(color: Colors.black45, fontSize: 16),
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
              color: Colors.white,
              textColor: AppColors.backgroundDark,
            ),
            const SizedBox(width: 16),
            _buildHeaderAction(
              icon: Icons.picture_as_pdf_rounded,
              label: "Rapport Annuel PDF",
              onTap: () {},
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
          side: color == Colors.white
              ? BorderSide(color: Colors.black.withOpacity(0.1))
              : BorderSide.none,
        ),
        elevation: color == Colors.white ? 0 : 4,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Croissance Membres",
          "+15.4%",
          "vs Année dernière",
          Icons.trending_up_rounded,
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Fidélité Moyenne",
          "78%",
          "Présence régulière",
          Icons.favorite_rounded,
          Colors.red,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Santé Financière",
          "Excellent",
          "Budget vs Réel",
          Icons.health_and_safety_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Impact Diversité",
          "Moderate",
          "Groupes actifs",
          Icons.auto_graph_rounded,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black45,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
            "La base de données compte désormais plus de 1,200 membres actifs, avec une forte croissance chez les jeunes (+25%).",
            Icons.people_alt_rounded,
            Colors.blue,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            "Finances",
            "Les contributions mensuelles sont en hausse de 12%. Les dépenses de construction du bâtiment sont sous contrôle.",
            Icons.account_balance_wallet_rounded,
            Colors.green,
          ),
          const Divider(height: 32),
          _buildSummaryItem(
            "Activités",
            "Le taux de participation aux activités hebdomadaires a augmenté grâce à la nouvelle application de gestion.",
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
                style: const TextStyle(color: Colors.black54, height: 1.5),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: 45,
                    title: '45%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 15,
                    title: '15%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: 10,
                    title: '10%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (val, meta) => Text(
                        "${(val / 1000000).toInt()}M",
                        style: const TextStyle(
                          color: Colors.black26,
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
                        ];
                        if (val.toInt() < months.length)
                          return Text(
                            months[val.toInt()],
                            style: const TextStyle(
                              color: Colors.black26,
                              fontSize: 10,
                            ),
                          );
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
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryOrange.withOpacity(0.1),
                    ),
                    spots: const [
                      FlSpot(0, 3500000),
                      FlSpot(1, 4200000),
                      FlSpot(2, 3800000),
                      FlSpot(3, 5000000),
                      FlSpot(4, 5500000),
                      FlSpot(5, 6200000),
                    ],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.black12,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                    spots: const [
                      FlSpot(0, 3000000),
                      FlSpot(1, 3100000),
                      FlSpot(2, 3500000),
                      FlSpot(3, 3200000),
                      FlSpot(4, 4000000),
                      FlSpot(5, 4200000),
                    ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.backgroundDark, size: 24),
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
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
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
