import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/finance_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FinanceModel> _transactions = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  int _monthlyTransactionCount = 0;
  double _largestDonation = 0;
  String? _bestMonth;
  double _donationVariation = 0;
  List<Map<String, dynamic>> _monthlyTrend = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final dao = await DatabaseHelper().financeDao;
    final transactions = await dao.getAllTransactions();

    final income = await dao.getTotalIncome();
    final expenses = await dao.getTotalExpenses();

    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final mIncome = await dao.getTotalIncome(startDate: startOfMonth);
    final mExpenses = await dao.getTotalExpenses(startDate: startOfMonth);

    final mCount = await dao.getMonthlyTransactionCount(DateTime.now());
    final maxDon = await dao.getLargestDonation();
    final bestM = await dao.getBestMonthName();

    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final currentMonthDons = await dao.getMonthlyTotalByType(
      'Don',
      DateTime.now(),
    );
    final lastMonthDons = await dao.getMonthlyTotalByType('Don', lastMonth);

    double variation = 0;
    if (lastMonthDons > 0) {
      variation = ((currentMonthDons - lastMonthDons) / lastMonthDons) * 100;
    }

    final trend = await dao.getMonthlyTrend(6);

    setState(() {
      _transactions = transactions;
      _totalIncome = income;
      _totalExpenses = expenses;
      _monthlyIncome = mIncome;
      _monthlyExpenses = mExpenses;
      _monthlyTransactionCount = mCount;
      _largestDonation = maxDon;
      _bestMonth = bestM;
      _donationVariation = variation;
      _monthlyTrend = trend;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
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
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 24,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestion Financière",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Suivi des dîmes, offrandes et dépenses de l'église",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildHeaderAction(Icons.download_rounded, "Rapport PDF", () {}),
            _buildSpecialActionButton(
              onPressed: () => _showTransactionForm(isExpense: false),
              icon: Icons.add_circle_outline_rounded,
              label: "Nouvelle Entrée",
              color: Colors.green,
            ),
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
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: context.iconColor,
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
    final balance = _totalIncome - _totalExpenses;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (constraints.maxWidth < 800)
          crossAxisCount = 2;
        else if (constraints.maxWidth < 1200)
          crossAxisCount = 3;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2.2, // Adjust to keep cards readable
          children: [
            _buildFinancialStat(
              "Total Entrées",
              _isLoading ? "..." : "${_totalIncome.toInt()} GNF",
              Icons.arrow_upward_rounded,
              Colors.green,
            ),
            _buildFinancialStat(
              "Total Sorties",
              _isLoading ? "..." : "${_totalExpenses.toInt()} GNF",
              Icons.arrow_downward_rounded,
              Colors.red,
            ),
            _buildFinancialStat(
              "Solde Actuel",
              _isLoading ? "..." : "${balance.toInt()} GNF",
              Icons.account_balance_wallet_rounded,
              Colors.blue,
            ),
            _buildFinancialStat(
              "Entrées (Mois)",
              _isLoading ? "..." : "+ ${_monthlyIncome.toInt()} GNF",
              Icons.trending_up_rounded,
              Colors.teal,
            ),
            _buildFinancialStat(
              "Sorties (Mois)",
              _isLoading ? "..." : "- ${_monthlyExpenses.toInt()} GNF",
              Icons.trending_down_rounded,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFinancialStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(color: context.subtitleColor, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
    double maxY = 1;
    for (var m in _monthlyTrend) {
      if (m['income'] > maxY) maxY = m['income'] as double;
      if (m['expense'] > maxY) maxY = m['expense'] as double;
    }
    // Scale maxY to millions for the axis, or keep it raw?
    // The current UI shows "5M", so I'll scale by 1,000,000.
    final displayMaxY = (maxY / 1000000).ceil().toDouble() + 1;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Text(
                "Flux Financiers (6 derniers mois)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Indicator(color: Colors.green, text: "Entrées"),
                  const SizedBox(width: 16),
                  _Indicator(color: Colors.redAccent, text: "Sorties"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _monthlyTrend.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LineChart(
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
                              final int idx = value.toInt();
                              if (idx >= 0 && idx < _monthlyTrend.length) {
                                final months = [
                                  "Jan",
                                  "Fév",
                                  "Mar",
                                  "Avr",
                                  "Mai",
                                  "Juin",
                                  "Juil",
                                  "Août",
                                  "Sep",
                                  "Oct",
                                  "Nov",
                                  "Déc",
                                ];
                                final monthNum = _monthlyTrend[idx]['month'];
                                return Text(
                                  months[monthNum - 1],
                                  style: TextStyle(
                                    color: context.subtitleColor,
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
                                style: TextStyle(
                                  color: context.subtitleColor,
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
                      maxY: displayMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _monthlyTrend.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              (e.value['income'] as double) / 1000000,
                            );
                          }).toList(),
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
                          spots: _monthlyTrend.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              (e.value['expense'] as double) / 1000000,
                            );
                          }).toList(),
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
    final balance = _totalIncome - _totalExpenses;
    final bool isLowBalance = balance < 1000000; // Alerte si moins de 1M GNF

    return Column(
      children: [
        if (isLowBalance)
          _buildAlertCard(
            "⚠️ Solde Faible",
            "Le solde global de l'église est actuellement de ${balance.toInt()} GNF.",
            Colors.orange,
          ),
        const SizedBox(height: 16),
        _buildAlertCard(
          "📉 Variation des dons",
          _donationVariation >= 0
              ? "Les dons ont augmenté de ${_donationVariation.toInt()}% par rapport au mois dernier."
              : "Les dons ont diminué de ${_donationVariation.abs().toInt()}% par rapport au mois dernier.",
          _donationVariation >= 0 ? Colors.teal : Colors.redAccent,
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
            style: TextStyle(fontSize: 13, color: context.subtitleColor),
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
          _buildReportRow(
            "Transactions ce mois",
            _isLoading ? "..." : _monthlyTransactionCount.toString(),
          ),
          _buildReportRow(
            "Plus gros don",
            _isLoading
                ? "..."
                : "${(_largestDonation / 1000000).toStringAsFixed(1)}M GNF",
          ),
          _buildReportRow(
            "Meilleur Mois",
            _isLoading ? "..." : (_bestMonth ?? "Néant"),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    "Voir plus de détails",
                    style: TextStyle(color: AppColors.primaryOrange),
                    overflow: TextOverflow.ellipsis,
                  ),
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
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Text(
                  "Registre des Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaceHighlightColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Recherche...",
            hintStyle: TextStyle(color: context.iconColor, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, size: 20, color: context.iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_transactions.isEmpty)
      return const Center(child: Text("Aucune transaction enregistrée."));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
        rows: _transactions.map((t) {
          final typeColor = t.type == 'Dépense'
              ? Colors.redAccent
              : t.type == 'Dîme'
              ? Colors.green
              : t.type == 'Offrande'
              ? Colors.teal
              : t.type == 'Don'
              ? Colors.amber
              : Colors.blue;
          return _buildTransactionRow(
            t.date,
            t.entity,
            t.amount,
            t.type,
            t.description,
            typeColor,
          );
        }).toList(),
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
            style: TextStyle(color: context.subtitleColor, fontSize: 13),
          ),
        ),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: context.borderColor,
                child: Text(
                  entity[0],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entity,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
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
                  : context.textColor,
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
              style: TextStyle(color: context.subtitleColor, fontSize: 13),
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

  void _showTransactionForm({required bool isExpense}) async {
    final dao = await DatabaseHelper().financeDao;
    final memberDao = await DatabaseHelper().memberDao;
    final List<MemberModel> members = await memberDao.getAllMembers();

    if (!mounted) return;

    final entityCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = isExpense ? "Dépense" : "Dîme";
    int? selectedMemberId;
    bool isManualEntry = false;

    final List<String> incomeTypes = ["Dîme", "Offrande", "Don", "Projet"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense
                        ? "Nouvelle Dépense"
                        : "Nouvelle Entrée Financière",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildFormLabel("Type de Transaction"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: context.surfaceColor,
                        items: (isExpense ? ["Dépense"] : incomeTypes)
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: TextStyle(color: context.textColor),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormLabel("Source / Bénéficiaire"),
                  if (!isManualEntry)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.surfaceHighlightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedMemberId,
                          hint: Text(
                            "Sélectionner un membre (optionnel)",
                            style: TextStyle(color: context.subtitleColor),
                          ),
                          isExpanded: true,
                          dropdownColor: context.surfaceColor,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                "Saisir manuellement...",
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                            ...members.map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(
                                  m.fullName,
                                  style: TextStyle(color: context.textColor),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) {
                              setDialogState(() => isManualEntry = true);
                            } else {
                              setDialogState(() {
                                selectedMemberId = val;
                                // Automatically pre-fill entity name for record keeping
                                final m = members.firstWhere(
                                  (e) => e.id == val,
                                );
                                entityCtrl.text = m.fullName;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  if (isManualEntry)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.surfaceHighlightColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: TextField(
                              controller: entityCtrl,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "Nom du membre ou tiers",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setDialogState(() {
                            isManualEntry = false;
                            selectedMemberId = null;
                            entityCtrl.clear();
                          }),
                          icon: const Icon(Icons.list_alt_rounded),
                          tooltip: "Choisir un membre enregistré",
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  _buildFormLabel("Montant (GNF)"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Ex: 150000",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormLabel("Description / Motif"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Détail de la transaction...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amountCtrl.text.isEmpty) return;
                        final transaction = FinanceModel(
                          date: DateTime.now().toString().split(' ').first,
                          entity: entityCtrl.text.isNotEmpty
                              ? entityCtrl.text
                              : 'Anonyme',
                          amount: '${amountCtrl.text} GNF',
                          type: selectedType,
                          description: descCtrl.text,
                          memberId: selectedMemberId,
                        );
                        await dao.insertTransaction(transaction);
                        _loadTransactions();
                        if (context.mounted) Navigator.pop(context);
                      },
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
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: context.subtitleColor,
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
          style: TextStyle(
            fontSize: 12,
            color: context.subtitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
