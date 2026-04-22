import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/features/dashboard/widgets/stat_card.dart';
import 'package:eglise_labe/features/dashboard/widgets/chart_card.dart';
import 'package:eglise_labe/features/dashboard/widgets/line_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ÉGLISE DE LABÉ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryOrange,
                letterSpacing: 2,
              ),
            ),
            const Text(
              "Tableau de Bord Administratif",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Colors.black26,
                ),
                const SizedBox(width: 4),
                const Text(
                  "Labé, Guinée",
                  style: TextStyle(color: Colors.black45, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.black26,
                ),
                const SizedBox(width: 4),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        _buildAdminInfo(),
      ],
    );
  }

  Widget _buildAdminInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Administrateur Momo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Dernière connexion: 10:45",
                style: TextStyle(color: Colors.black26, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
            child: const Text(
              "M",
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _QuickActionButton(
          icon: Icons.person_add_rounded,
          label: "Ajouter Membre",
          color: Colors.blue,
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _QuickActionButton(
          icon: Icons.account_balance_wallet_rounded,
          label: "Ajouter Offrande",
          color: Colors.green,
          onTap: () {},
        ),
        const SizedBox(width: 16),
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
          crossAxisCount: constraints.maxWidth > 1200 ? 6 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: const [
            StatCard(
              title: "Total Membres",
              value: "250",
              icon: Icons.people_rounded,
              bgColor: Color(0xFF6366F1),
            ),
            StatCard(
              title: "Nouveaux (Mois)",
              value: "12",
              icon: Icons.person_add_alt_1_rounded,
              bgColor: Color(0xFF8B5CF6),
            ),
            StatCard(
              title: "Offrandes (Total)",
              value: "1,2M GNF",
              icon: Icons.volunteer_activism_rounded,
              bgColor: Color(0xFF10B981),
            ),
            StatCard(
              title: "Dîmes (Total)",
              value: "800K GNF",
              icon: Icons.menu_book_rounded,
              bgColor: Color(0xFF059669),
            ),
            StatCard(
              title: "Dépenses",
              value: "350K GNF",
              icon: Icons.trending_down_rounded,
              bgColor: Color(0xFFF43F5E),
            ),
            StatCard(
              title: "Activités",
              value: "5",
              icon: Icons.event_note_rounded,
              bgColor: Color(0xFFF59E0B),
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
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD97706)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Résumé Intelligent",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  "Les offrandes ont augmenté de 15% par rapport à la semaine dernière. Aucune activité prévue demain.",
                  style: TextStyle(color: Color(0xFFD97706), fontSize: 13),
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
      title: "Dernières Activités",
      height: 350,
      child: ListView(
        shrinkWrap: true,
        children: [
          _ActivityTile(
            icon: Icons.person_add_rounded,
            color: Colors.blue,
            title: "Nouveau membre ajouté",
            subtitle: "Momo a été inscrit",
            time: "Il y a 2h",
          ),
          _ActivityTile(
            icon: Icons.payments_rounded,
            color: Colors.green,
            title: "Offrande enregistrée",
            subtitle: "50 000 GNF par Paul",
            time: "Il y a 5h",
          ),
          _ActivityTile(
            icon: Icons.event_note_rounded,
            color: Colors.orange,
            title: "Culte programmé",
            subtitle: "Pour dimanche prochain",
            time: "Il y a 1j",
          ),
        ],
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
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final names = [
            "Paul Keita",
            "Marie Sylla",
            "Jean Diallo",
            "Aissatou Barry",
            "Ousmane Camara",
          ];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.backgroundDark.withOpacity(0.05),
              child: Text(
                names[index][0],
                style: const TextStyle(fontSize: 12),
              ),
            ),
            title: Text(
              names[index],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              "622 00 00 00",
              style: TextStyle(fontSize: 11),
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
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final items = [
            {"name": "Paul", "type": "Dîme", "amount": "100K"},
            {"name": "Marie", "type": "Offrande", "amount": "50K"},
            {"name": "Église", "type": "Dépense", "amount": "20K"},
            {"name": "Jean", "type": "Dîme", "amount": "200K"},
            {"name": "Anonyme", "type": "Offrande", "amount": "10K"},
          ];
          final isExpense = items[index]["type"] == "Dépense";
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              items[index]["name"]!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: Text(
              items[index]["type"]!,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Text(
              "${isExpense ? '-' : '+'}${items[index]["amount"]} GNF",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.redAccent : Colors.green,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingActivitiesFull() {
    return ChartCard(
      title: "Prochaines Activités",
      height: 250,
      child: Row(
        children: [
          _buildEventCard("DÉC", "24", "Culte de Noël", "18:00 - 20:00"),
          const SizedBox(width: 16),
          _buildEventCard("DÉC", "31", "Veillée de Nouvel An", "22:00 - 00:00"),
          const SizedBox(width: 16),
          _buildEventCard("JAN", "05", "Étude Biblique", "17:00 - 18:30"),
        ],
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
                    style: const TextStyle(color: Colors.black26, fontSize: 12),
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
                  style: const TextStyle(color: Colors.black45, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.black26, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
