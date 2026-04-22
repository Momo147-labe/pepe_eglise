import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final TextEditingController _searchController = TextEditingController();

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
          _buildChartsSection(),
          const SizedBox(height: 32),
          _buildTransactionLedger(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestion Financière",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Suivi des dîmes, offrandes et dépenses de l'église",
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(Icons.download_rounded, "Rapport PDF", () {}),
            const SizedBox(width: 16),
            _buildSpecialActionButton(
              onPressed: () => _showTransactionForm(isExpense: false),
              icon: Icons.add_circle_outline_rounded,
              label: "Nouvelle Entrée",
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _buildSpecialActionButton(
              onPressed: () => _showTransactionForm(isExpense: true),
              icon: Icons.remove_circle_outline_rounded,
              label: "Nouvelle Dépense",
              color: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildFinancialStat(
          "Total Entrées",
          "4,850,000 GNF",
          Icons.account_balance_wallet_rounded,
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildFinancialStat(
          "Total Dépenses",
          "1,240,000 GNF",
          Icons.shopping_cart_checkout_rounded,
          Colors.redAccent,
        ),
        const SizedBox(width: 24),
        _buildFinancialStat(
          "Solde Actuel",
          "3,610,000 GNF",
          Icons.savings_rounded,
          AppColors.primaryOrange,
        ),
        const SizedBox(width: 24),
        _buildFinancialStat(
          "Moyenne/Membre",
          "3,770 GNF",
          Icons.analytics_rounded,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildFinancialStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black45, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMainFinancialChart()),
        const SizedBox(width: 32),
        Expanded(child: _buildFinancialAlerts()),
      ],
    );
  }

  Widget _buildMainFinancialChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Flux Financiers (6 derniers mois)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _Indicator(color: Colors.green, text: "Entrées"),
                  SizedBox(width: 16),
                  _Indicator(color: Colors.redAccent, text: "Sorties"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          "Nov",
                          "Déc",
                          "Jan",
                          "Fév",
                          "Mar",
                          "Avr",
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}M",
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3.2),
                      FlSpot(1, 4.8),
                      FlSpot(2, 3.5),
                      FlSpot(3, 4.2),
                      FlSpot(4, 3.8),
                      FlSpot(5, 4.9),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.05),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.2),
                      FlSpot(1, 1.8),
                      FlSpot(2, 0.5),
                      FlSpot(3, 1.2),
                      FlSpot(4, 0.8),
                      FlSpot(5, 1.5),
                    ],
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAlerts() {
    return Column(
      children: [
        _buildAlertCard(
          "⚠️ Solde Faible",
          "Votre budget pour les activités de jeunesse arrive à terme.",
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildAlertCard(
          "📉 Baisse des dons",
          "Les offrandes ont diminué de 12% par rapport au mois dernier.",
          Colors.redAccent,
        ),
        const SizedBox(height: 16),
        _buildQuickReport(),
      ],
    );
  }

  Widget _buildAlertCard(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReport() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rapport Rapide",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildReportRow("Transactions ce mois", "124"),
          _buildReportRow("Plus gros don", "2,5M GNF"),
          _buildReportRow("Meilleur Mois", "Décembre"),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Row(
              children: [
                Text(
                  "Voir plus de détails",
                  style: TextStyle(color: AppColors.primaryOrange),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryOrange,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionLedger() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Registre des Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildSearchField(),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildTransactionsTable(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Recherche...",
          hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, size: 20, color: Colors.black26),
        ),
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowHeight: 60,
        dataRowMaxHeight: 80,
        horizontalMargin: 24,
        columns: const [
          DataColumn(label: Text("DATE")),
          DataColumn(label: Text("MEMBRE / ENTITÉ")),
          DataColumn(label: Text("MONTANT")),
          DataColumn(label: Text("TYPE")),
          DataColumn(label: Text("DESCRIPTION")),
          DataColumn(label: Text("ACTIONS")),
        ],
        rows: [
          _buildTransactionRow(
            "22-04-2026",
            "Momo Labé",
            "200,000 GNF",
            "Dîme",
            "Participation mensuelle",
            Colors.green,
          ),
          _buildTransactionRow(
            "21-04-2026",
            "Quincaillerie Labé",
            "150,000 GNF",
            "Dépense",
            "Achat d'ampoules",
            Colors.redAccent,
          ),
          _buildTransactionRow(
            "20-04-2026",
            "Anonyme",
            "50,000 GNF",
            "Offrande",
            "Culte du Dimanche",
            Colors.green,
          ),
          _buildTransactionRow(
            "19-04-2026",
            "Diallo Amadou",
            "1,000,000 GNF",
            "Don",
            "Don pour la sono",
            Colors.blue,
          ),
          _buildTransactionRow(
            "18-04-2026",
            "EDG",
            "320,000 GNF",
            "Dépense",
            "Facture électricité",
            Colors.redAccent,
          ),
          _buildTransactionRow(
            "17-04-2026",
            "Sylla Fanta",
            "100,000 GNF",
            "Dîme",
            "Action de grâce",
            Colors.green,
          ),
        ],
      ),
    );
  }

  DataRow _buildTransactionRow(
    String date,
    String entity,
    String amount,
    String type,
    String desc,
    Color typeColor,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            date,
            style: const TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black.withOpacity(0.05),
                child: Text(
                  entity[0],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entity,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: typeColor == Colors.redAccent
                  ? Colors.redAccent
                  : Colors.black,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              desc,
              style: const TextStyle(color: Colors.black38, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.print_rounded, size: 18),
                onPressed: () {},
                color: Colors.blueAccent.withOpacity(0.5),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: () {},
                color: Colors.redAccent.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTransactionForm({required bool isExpense}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense
                    ? "Nouvelle Dépense"
                    : "Nouvelle Entrée (Dîme / Offrande)",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildFormLabel("Membre / Fournisseur"),
              _buildFormDropdown([
                "Sélectionner un nom",
                "Momo Labé",
                "Diallo Amadou",
                "Sylla Fanta",
                "Quincaillerie",
                "Boulangerie",
              ]),
              const SizedBox(height: 16),
              _buildFormLabel("Montant (GNF)"),
              _buildFormTextField("Ex: 150000"),
              const SizedBox(height: 16),
              _buildFormLabel("Description / Motif"),
              _buildFormTextField("Détail de la transaction...", maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpense
                        ? Colors.redAccent
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isExpense
                        ? "Enregistrer la dépense"
                        : "Enregistrer la transaction",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildFormTextField(String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFormDropdown(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items[0],
          items: items
              .map(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
