import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/finance_model.dart';
import 'package:eglise_labe/features/dashboard/widgets/transaction_form_dialog.dart';
import 'package:eglise_labe/core/services/finance_pdf_service.dart';

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

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _ledgerKey = GlobalKey();

  String _formatCurrency(dynamic amount) {
    if (amount == null) return "0";
    final formatter = NumberFormat('#,##0', 'fr_FR'); // Will output "250 000"
    if (amount is String) {
      final parsed = double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (parsed != null) return formatter.format(parsed).replaceAll(',', ' ');
      return amount;
    }
    return formatter.format(amount).replaceAll(',', ' ');
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTransactions);
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterTransactions() {
    setState(() {}); // trigger rebuild to filter list based on text
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
          controller: _scrollController,
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 32),
                _buildStatsGrid(),
                const SizedBox(height: 32),
                _buildChartsSection(),
                const SizedBox(height: 32),
                Container(key: _ledgerKey, child: _buildTransactionLedger()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 24,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gestion Financière",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Suivi des dîmes, offrandes et dépenses de l'église",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildHeaderAction(
                Icons.download_rounded,
                "Rapport PDF",
                () {
                  FinancePdfService().generateFinanceReport(_transactions, "Rapport Financier Complet");
                },
                isOutlined: true,
              ),
              _buildSpecialActionButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => TransactionFormDialog(
                    isExpense: false,
                    onSaved: _loadTransactions,
                  ),
                ),
                icon: Icons.add_circle_outline_rounded,
                label: "Nouvelle Entrée",
                color: Colors.green,
              ),
              _buildSpecialActionButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => TransactionFormDialog(
                    isExpense: true,
                    onSaved: _loadTransactions,
                  ),
                ),
                icon: Icons.remove_circle_outline_rounded,
                label: "Nouvelle Dépense",
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : Colors.white,
          border: isOutlined ? Border.all(color: Colors.white.withValues(alpha: 0.5)) : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isOutlined ? Colors.white : AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? Colors.white : AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
        elevation: 6,
        shadowColor: color.withValues(alpha: 0.4),
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
          childAspectRatio: 2.0,
          children: [
            _buildWalletCard(
              "Solde Actuel",
              _isLoading ? "..." : "${_formatCurrency(balance)} GNF",
              Icons.account_balance_wallet_rounded,
              Colors.blue,
            ),
            _buildWalletCard(
              "Total Entrées",
              _isLoading ? "..." : "${_formatCurrency(_totalIncome)} GNF",
              Icons.trending_up_rounded,
              Colors.green,
            ),
            _buildWalletCard(
              "Total Sorties",
              _isLoading ? "..." : "${_formatCurrency(_totalExpenses)} GNF",
              Icons.trending_down_rounded,
              Colors.redAccent,
            ),
            _buildWalletCard(
              "Entrées (Mois)",
              _isLoading ? "..." : "+ ${_formatCurrency(_monthlyIncome)} GNF",
              Icons.monetization_on_rounded,
              Colors.teal,
            ),
            _buildWalletCard(
              "Sorties (Mois)",
              _isLoading ? "..." : "- ${_formatCurrency(_monthlyExpenses)} GNF",
              Icons.money_off_rounded,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWalletCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(color: context.subtitleColor, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
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
    final displayMaxY = (maxY / 1000000).ceil().toDouble() + 1;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)}M GNF',
                                TextStyle(
                                  color: spot.barIndex == 0 ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.black.withValues(alpha: 0.05),
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
                                  "Jan", "Fév", "Mar", "Avr", "Mai", "Juin",
                                  "Juil", "Août", "Sep", "Oct", "Nov", "Déc"
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
                            gradient: LinearGradient(
                              colors: [Colors.green.withValues(alpha: 0.3), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
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
                            gradient: LinearGradient(
                              colors: [Colors.redAccent.withValues(alpha: 0.3), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
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
    final bool isLowBalance = balance < 1000000; 

    return Column(
      children: [
        if (isLowBalance)
          _buildAlertCard(
            "⚠️ Solde Faible",
            "Le solde global de l'église est actuellement de ${_formatCurrency(balance)} GNF.",
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
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
          _buildTransactionList(),
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
            hintText: "Rechercher une transaction...",
            hintStyle: TextStyle(color: context.iconColor, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(Icons.search, size: 20, color: context.iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    final query = _searchController.text.toLowerCase();
    final filteredTransactions = _transactions.where((t) {
      return t.entity.toLowerCase().contains(query) ||
             t.description.toLowerCase().contains(query) ||
             t.type.toLowerCase().contains(query);
    }).toList();

    if (filteredTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: 48, color: context.iconColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                "Aucune transaction trouvée.",
                style: TextStyle(color: context.subtitleColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(filteredTransactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(FinanceModel t) {
    final bool isExpense = t.type == 'Dépense';
    final Color typeColor = isExpense
        ? Colors.redAccent
        : t.type == 'Dîme'
        ? Colors.green
        : t.type == 'Offrande'
        ? Colors.teal
        : t.type == 'Don'
        ? Colors.amber
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: typeColor,
            size: 24,
          ),
        ),
        title: Text(
          t.entity,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.textColor,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${t.date} • ${t.paymentMethod ?? 'Non spécifié'}",
              style: TextStyle(color: context.subtitleColor, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    t.type,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (t.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Text(
                      t.category!,
                      style: TextStyle(
                        color: context.subtitleColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${isExpense ? '-' : '+'}${_formatCurrency(t.amount)} GNF",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isExpense ? Colors.redAccent : Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: context.surfaceColor,
                    title: Text("Supprimer", style: TextStyle(color: context.textColor)),
                    content: Text("Voulez-vous supprimer cette transaction ?", style: TextStyle(color: context.subtitleColor)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Supprimer"),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final dao = await DatabaseHelper().financeDao;
                  if (t.id != null) {
                    await dao.deleteTransaction(t.id!);
                    _loadTransactions();
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
            ),
          ],
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
