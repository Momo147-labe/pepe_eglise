import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/features/dashboard/widgets/stat_card.dart';
import 'package:eglise_labe/features/dashboard/widgets/chart_card.dart';
import 'package:eglise_labe/features/dashboard/widgets/line_chart.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/core/models/finance_model.dart';
import 'package:eglise_labe/core/models/activity_model.dart';
import 'package:eglise_labe/core/widgets/typewriter_text.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalMembers = 0;
  int _newMembersMonth = 0;
  double _totalOfferings = 0;
  double _totalTithes = 0;
  double _totalExpenses = 0;
  int _activityCount = 0;
  int _mouvementCount = 0;
  bool _isLoading = true;

  List<MemberModel> _recentMembers = [];
  List<FinanceModel> _recentTransactions = [];
  List<ActivityModel> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final memberDao = await DatabaseHelper().memberDao;
    final financeDao = await DatabaseHelper().financeDao;
    final activityDao = await DatabaseHelper().activityDao;
    final mouvementDao = await DatabaseHelper().mouvementDao;

    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    final totalMembers = await memberDao.getMemberCount();
    final newMembers = await memberDao.getNewMembersCount(startOfMonth);
    final offerings = await financeDao.getTotalByType('Offrande');
    final tithes = await financeDao.getTotalByType('Dîme');
    final expenses = await financeDao.getTotalExpenses();
    final activities = await activityDao.getActivityCount();
    final mouvements = await mouvementDao.getMouvementCount();

    // Fetch real lists for the dashboard
    final recentMembers = await memberDao.getRecentMembers(5);
    final recentTransactions = await financeDao.getRecentTransactions(5);
    final recentActivities = await activityDao.getRecentActivities(3);

    if (mounted) {
      setState(() {
        _totalMembers = totalMembers;
        _newMembersMonth = newMembers;
        _totalOfferings = offerings;
        _totalTithes = tithes;
        _totalExpenses = expenses;
        _activityCount = activities;
        _mouvementCount = mouvements;
        _recentMembers = recentMembers;
        _recentTransactions = recentTransactions;
        _recentActivities = recentActivities;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildAlertsSection(),
          const SizedBox(height: 32),
          _buildMiddleRow(),
          const SizedBox(height: 32),
          _buildBottomRow(),
          const SizedBox(height: 32),
          _buildUpcomingActivitiesFull(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TypewriterText(
                text: "PROTESTANTE EVANGELIQUE DE LABE",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryOrange,
                  letterSpacing: 2,
                ),
                duration: Duration(seconds: 4),
              ),
              Text(
                "Tableau de Bord Administratif",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Labé, Guinée",
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // const SizedBox(width: 16),
        // _buildAdminInfo(),
      ],
    );
  }

  // Widget _buildAdminInfo() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: context.surfaceColor,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: context.borderColor),
  //     ),
  //     child: Row(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             const Text(
  //               "Administrateur",
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //             ),
  //             Text(
  //               "Dernière connexion: ${_getFormattedDate()}",
  //               style: TextStyle(color: context.iconColor, fontSize: 11),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(width: 12),
  //         CircleAvatar(
  //           backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
  //           child: const Text(
  //             "M",
  //             style: TextStyle(
  //               color: AppColors.primaryOrange,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _QuickActionButton(
          icon: Icons.person_add_rounded,
          label: "Ajouter Membre",
          color: Colors.blue,
          onTap: () {},
        ),
        _QuickActionButton(
          icon: Icons.account_balance_wallet_rounded,
          label: "Ajouter Offrande",
          color: Colors.green,
          onTap: () {},
        ),
        _QuickActionButton(
          icon: Icons.event_available_rounded,
          label: "Programmer Activité",
          color: Colors.purple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth > 1400
              ? 7
              : (constraints.maxWidth > 900 ? 4 : 2),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: "Total Membres",
              value: _isLoading ? "..." : _totalMembers.toString(),
              icon: Icons.people_rounded,
              bgColor: const Color(0xFF6366F1),
            ),
            StatCard(
              title: "Nouveaux (Mois)",
              value: _isLoading ? "..." : _newMembersMonth.toString(),
              icon: Icons.person_add_alt_1_rounded,
              bgColor: const Color(0xFF8B5CF6),
            ),
            StatCard(
              title: "Offrandes (Total)",
              value: _isLoading
                  ? "..."
                  : "${(_totalOfferings / 1000000).toStringAsFixed(1)}M GNF",
              icon: Icons.volunteer_activism_rounded,
              bgColor: const Color(0xFF10B981),
            ),
            StatCard(
              title: "Dîmes (Total)",
              value: _isLoading
                  ? "..."
                  : "${(_totalTithes / 100).toStringAsFixed(0)}K GNF",
              icon: Icons.menu_book_rounded,
              bgColor: const Color(0xFF059669),
            ),
            StatCard(
              title: "Dépenses",
              value: _isLoading
                  ? "..."
                  : "${(_totalExpenses / 1000).toStringAsFixed(0)}K GNF",
              icon: Icons.trending_down_rounded,
              bgColor: const Color(0xFFF43F5E),
            ),
            StatCard(
              title: "Activités",
              value: _isLoading ? "..." : _activityCount.toString(),
              icon: Icons.event_note_rounded,
              bgColor: const Color(0xFFF59E0B),
            ),
            StatCard(
              title: "Mouvements",
              value: _isLoading ? "..." : _mouvementCount.toString(),
              icon: Icons.hub_rounded,
              bgColor: const Color(0xFFEC4899),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFFD97706,
        ).withOpacity(context.isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD97706)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Résumé Intelligent",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? const Color(0xFFFFB347)
                        : const Color(0xFF92400E),
                  ),
                ),
                Text(
                  _isLoading
                      ? "Chargement du résumé..."
                      : "Vous avez $_totalMembers membres inscrits et $_activityCount activités au programme. "
                            "${_newMembersMonth > 0 ? '$_newMembersMonth nouveaux membres ce mois-ci.' : 'Gérez votre église en toute simplicité.'}",
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Voir plus",
              style: TextStyle(color: Color(0xFFD97706)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ChartCard(
            title: "Revenus Mensuels (Dîmes + Offrandes)",
            height: 350,
            child: AnalyticsLineChart(
              // Assuming AnalyticsLineChart can take data if needed,
              // for now using its internal mock.
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildLatestActivities()),
      ],
    );
  }

  Widget _buildLatestActivities() {
    return ChartCard(
      title: "Activités Récentes",
      height: 350,
      child: _recentActivities.isEmpty
          ? const Center(child: Text("Aucune activité récente"))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];
                return _ActivityTile(
                  icon: Icons.event_note_rounded,
                  color: AppColors.primaryOrange,
                  title: activity.name,
                  subtitle: activity.type,
                  time: activity.time,
                );
              },
            ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRecentMembers()),
        const SizedBox(width: 24),
        Expanded(child: _buildRecentTransactions()),
      ],
    );
  }

  Widget _buildRecentMembers() {
    return ChartCard(
      title: "Membres Récents",
      height: 400,
      child: _recentMembers.isEmpty
          ? const Center(child: Text("Aucun membre récent"))
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _recentMembers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = _recentMembers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.backgroundDark.withOpacity(0.05),
                    child: Text(
                      member.fullName.isNotEmpty ? member.fullName[0] : '?',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(
                    member.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    member.phone,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 16),
                );
              },
            ),
    );
  }

  Widget _buildRecentTransactions() {
    return ChartCard(
      title: "Dernières Transactions",
      height: 400,
      child: _recentTransactions.isEmpty
          ? const Center(child: Text("Aucune transaction récente"))
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _recentTransactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = _recentTransactions[index];
                final isExpense = transaction.type == 'Dépense';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    transaction.type,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    "${isExpense ? '-' : '+'}${transaction.amount} GNF",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUpcomingActivitiesFull() {
    if (_recentActivities.isEmpty) {
      return const SizedBox.shrink();
    }
    return ChartCard(
      title: "Activités Programmées",
      height: 250,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _recentActivities.take(3).map((activity) {
            return SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildEventCard(
                  activity.type.substring(0, 3).toUpperCase(),
                  activity.id.toString(),
                  activity.name,
                  activity.time,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventCard(String month, String day, String title, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const VerticalDivider(width: 1, indent: 10, endIndent: 10),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
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
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: context.subtitleColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: context.iconColor, fontSize: 11)),
        ],
      ),
    );
  }
}
