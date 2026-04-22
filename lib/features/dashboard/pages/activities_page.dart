import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildTabSystem(),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildActivityList(), _buildAttendanceHistory()],
            ),
          ),
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
                "Activités & Planning",
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
                "Gérez les cultes, répétitions et présences",
                style: const TextStyle(color: Colors.black45, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildHeaderAction(
              icon: Icons.calendar_month_rounded,
              label: "Voir Calendrier",
              onTap: () {},
              color: Colors.white,
              textColor: AppColors.backgroundDark,
            ),
            const SizedBox(width: 16),
            _buildHeaderAction(
              icon: Icons.add_rounded,
              label: "Nouvelle Activité",
              onTap: () => _showAddActivityDialog(),
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
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Taux de Présence",
          "84%",
          "+5.2%",
          Icons.trending_up_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Activités / Semaine",
          "12",
          "Stable",
          Icons.event_note_rounded,
          Colors.purple,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Moyenne Culte",
          "342",
          "+12",
          Icons.people_alt_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Dernière Activité",
          "Répétition Chorale",
          "Hier",
          Icons.history_rounded,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String trend,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trend.contains('+')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trend.contains('+')
                          ? Colors.green
                          : Colors.black45,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildTabSystem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryOrange,
        indicatorWeight: 3,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: Colors.black45,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: const [
          Tab(text: "Liste des Activités"),
          Tab(text: "Historique des Présences"),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 64,
          dataRowMaxHeight: 80,
          horizontalMargin: 32,
          dividerThickness: 1,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text("ACTIVITÉ")),
            DataColumn(label: Text("TYPE")),
            DataColumn(label: Text("FRÉQUENCE")),
            DataColumn(label: Text("HEURE")),
            DataColumn(label: Text("RESPONSABLE")),
            DataColumn(label: Text("ACTIONS")),
          ],
          rows: [
            _buildActivityRow(
              "Culte Dominical",
              "Service",
              "Hebdomadaire",
              "09:00",
              "Pasteur Samuel",
              Colors.blue,
            ),
            _buildActivityRow(
              "Étude Biblique",
              "Enseignement",
              "Mardi",
              "18:30",
              "Ancien Jean",
              Colors.orange,
            ),
            _buildActivityRow(
              "Répétition Chorale",
              "Musique",
              "Samedi",
              "16:00",
              "M. Kouyaté",
              Colors.teal,
            ),
            _buildActivityRow(
              "Réunion de Jeunes",
              "Groupe",
              "Vendredi",
              "17:00",
              "Frère Moussa",
              Colors.purple,
            ),
            _buildActivityRow(
              "Prière Intercession",
              "Spirituel",
              "Quotidien",
              "05:30",
              "Mme Camara",
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildActivityRow(
    String name,
    String type,
    String freq,
    String time,
    String lead,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_note_rounded, size: 18, color: color),
              ),
              const SizedBox(width: 16),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(Text(freq)),
        DataCell(Text(time)),
        DataCell(Text(lead)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                onPressed: () => _showAttendanceDialog(name),
                color: Colors.green,
                tooltip: "Pointer les présences",
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: Colors.black12,
            ),
            SizedBox(height: 16),
            Text(
              "Historique des présences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Sélectionnez une activité pour voir les détails",
              style: TextStyle(color: Colors.black26),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Nouvelle Activité"),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Nom de l'activité", Icons.title_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Type", Icons.category_rounded),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField("Heure", Icons.access_time_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Responsable", Icons.person_rounded),
              const SizedBox(height: 16),
              _buildTextField(
                "Description",
                Icons.description_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Créer l'activité"),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(String activityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Présences : $activityName"),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un membre...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Membre #$index"),
                    subtitle: Text("ID: LABE-00$index"),
                    trailing: Checkbox(value: false, onChanged: (val) {}),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Enregistrer les présences"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
    );
  }
}
