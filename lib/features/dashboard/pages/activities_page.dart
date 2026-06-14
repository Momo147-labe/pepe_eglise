import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/activity_model.dart';
import 'package:eglise_labe/core/models/attendance_model.dart';
import 'package:eglise_labe/core/services/activity_pdf_service.dart';
import 'package:eglise_labe/features/dashboard/widgets/activity_form_dialog.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> _activityTypes = {};
  int _totalActivities = 0;

  ActivityModel? _historySelectedActivity;
  List<Map<String, dynamic>> _detailedAttendanceHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final dao = await DatabaseHelper().activityDao;
    final activities = _searchQuery.isEmpty
        ? await dao.getAllActivities()
        : await dao.searchActivities(_searchQuery);
    final countByType = await dao.getCountByType();
    final total = await dao.getActivityCount();
    setState(() {
      _activities = activities;
      _activityTypes = countByType;
      _totalActivities = total;
      _isLoading = false;
      
      // If we previously selected an activity for history, try to find it in the updated list
      if (_historySelectedActivity != null) {
        final found = _activities.any((a) => a.id == _historySelectedActivity!.id);
        if (!found) {
          _historySelectedActivity = null;
          _detailedAttendanceHistory = [];
        }
      }
    });
  }

  Future<void> _loadAttendanceHistory(ActivityModel activity) async {
    setState(() {
      _historySelectedActivity = activity;
      _isLoadingHistory = true;
    });
    if (activity.id != null) {
      final dao = await DatabaseHelper().attendanceDao;
      final history = await dao.getAttendanceHistoryDetailed(activity.id!);
      setState(() {
        _detailedAttendanceHistory = history;
        _isLoadingHistory = false;
      });
    } else {
      setState(() {
        _detailedAttendanceHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('culte')) return Colors.orange;
    if (t.contains('répétition') || t.contains('repetition')) return Colors.teal;
    if (t.contains('prière') || t.contains('priere')) return Colors.blue;
    if (t.contains('réunion') || t.contains('reunion')) return Colors.purple;
    if (t.contains('formation')) return Colors.indigo;
    if (t.contains('évangélisation') || t.contains('evangelisation')) return Colors.green;
    return Colors.blueGrey;
  }

  IconData _getTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('culte')) return Icons.church_rounded;
    if (t.contains('répétition') || t.contains('repetition')) return Icons.music_note_rounded;
    if (t.contains('prière') || t.contains('priere')) return Icons.self_improvement_rounded;
    if (t.contains('réunion') || t.contains('reunion')) return Icons.groups_rounded;
    if (t.contains('formation')) return Icons.school_rounded;
    if (t.contains('évangélisation') || t.contains('evangelisation')) return Icons.campaign_rounded;
    return Icons.event_note_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 32,
              left: 32,
              right: 32,
              bottom: 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroHeader(),
                const SizedBox(height: 32),
                _buildStatsGrid(),
                const SizedBox(height: 32),
                _buildTabSystem(),
              ]),
            ),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        child: TabBarView(
          controller: _tabController,
          children: [_buildActivityList(), _buildAttendanceHistory()],
        ),
      ),
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
                child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Activités & Planning",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Gérez les cultes, répétitions et présences",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 250,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _loadActivities();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
              _buildHeroAction(
                Icons.print_rounded,
                "Imprimer",
                () async {
                  final pdfService = ActivityPdfService();
                  await pdfService.generateActivityReport(_activities);
                },
                isOutlined: true,
              ),
              ElevatedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ActivityFormDialog(onSaved: _loadActivities),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Nouvelle Activité"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAction(IconData icon, String label, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    int culteCount = _activityTypes.entries
        .where((e) => e.key.toLowerCase().contains("culte"))
        .fold(0, (a, b) => a + b.value);
    int repetitionCount = _activityTypes.entries
        .where((e) => e.key.toLowerCase().contains("répétition"))
        .fold(0, (a, b) => a + b.value);
    int priereCount = _activityTypes.entries
        .where((e) => e.key.toLowerCase().contains("prière"))
        .fold(0, (a, b) => a + b.value);

    return Row(
      children: [
        _buildStatCard(
          "Total Activités",
          _totalActivities.toString(),
          Icons.event_note_rounded,
          Colors.purple,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Cultes",
          culteCount.toString(),
          Icons.church_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Répétitions",
          repetitionCount.toString(),
          Icons.music_note_rounded,
          Colors.teal,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Prières / Réunions",
          priereCount.toString(),
          Icons.self_improvement_rounded,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 13,
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

  Widget _buildTabSystem() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryOrange,
        indicatorWeight: 3,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: context.subtitleColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: const [
          Tab(text: "Liste des Activités"),
          Tab(text: "Historique des Présences"),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: context.iconColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              "Aucune activité enregistrée.",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildActivityCard(_activities[index]);
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    final color = _getTypeColor(activity.type);
    final icon = _getTypeIcon(activity.type);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          activity.name,
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
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 13, color: context.subtitleColor),
                const SizedBox(width: 4),
                Text(
                  activity.time,
                  style: TextStyle(color: context.subtitleColor, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Icon(Icons.repeat_rounded, size: 13, color: context.subtitleColor),
                const SizedBox(width: 4),
                Text(
                  activity.freq,
                  style: TextStyle(color: context.subtitleColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    activity.type,
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.surfaceHighlightColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_rounded, size: 11, color: context.subtitleColor),
                      const SizedBox(width: 4),
                      Text(
                        activity.lead,
                        style: TextStyle(color: context.subtitleColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.how_to_reg_rounded, size: 20),
              onPressed: () => _showAttendanceDialog(activity),
              color: Colors.green,
              tooltip: "Pointer les présences",
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ActivityFormDialog(
                  activity: activity,
                  onSaved: _loadActivities,
                ),
              ),
              color: context.subtitleColor,
              tooltip: "Modifier",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () => _deleteActivity(activity),
              color: Colors.redAccent.withValues(alpha: 0.6),
              tooltip: "Supprimer",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteActivity(ActivityModel activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Supprimer", style: TextStyle(color: context.textColor)),
        content: Text(
          "Voulez-vous supprimer l'activité \"${activity.name}\" ?",
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && activity.id != null) {
      final dao = await DatabaseHelper().activityDao;
      await dao.deleteActivity(activity.id!);
      _loadActivities();
    }
  }

  Widget _buildAttendanceHistory() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sélectionner l'activité",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.surfaceHighlightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ActivityModel>(
                          value: _historySelectedActivity,
                          hint: Text(
                            "Sélectionner une activité...",
                            style: TextStyle(color: context.subtitleColor),
                          ),
                          isExpanded: true,
                          dropdownColor: context.surfaceColor,
                          items: _activities.map((ActivityModel act) {
                            return DropdownMenuItem<ActivityModel>(
                              value: act,
                              child: Text(
                                "${act.name} (${act.type})",
                                style: TextStyle(color: context.textColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (ActivityModel? newVal) {
                            if (newVal != null) {
                              _loadAttendanceHistory(newVal);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _historySelectedActivity == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: context.iconColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Historique des présences",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sélectionnez une activité pour voir les détails des présences",
                          style: TextStyle(color: context.subtitleColor),
                        ),
                      ],
                    ),
                  )
                : _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : _detailedAttendanceHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 64,
                                  color: context.iconColor.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Aucune présence enregistrée",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Pointez les présences depuis la liste des activités",
                                  style: TextStyle(color: context.subtitleColor),
                                ),
                              ],
                            ),
                          )
                        : _buildHistoryGroupedByDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryGroupedByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _detailedAttendanceHistory) {
      final date = item['date'] as String;
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final dateStr = dates[index];
        final records = grouped[dateStr]!;
        
        DateTime? parsedDate = DateTime.tryParse(dateStr);
        String formattedDate = dateStr;
        if (parsedDate != null) {
          final months = [
            "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
            "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
          ];
          formattedDate = "${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}";
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: context.surfaceHighlightColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.borderColor),
          ),
          child: ExpansionTile(
            shape: const Border(),
            title: Text(
              formattedDate,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            subtitle: Text(
              "${records.length} membre(s) présent(s)",
              style: TextStyle(color: context.subtitleColor, fontSize: 13),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => Divider(color: context.borderColor, height: 1),
                  itemBuilder: (context, idx) {
                    final record = records[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: context.surfaceColor,
                                child: Icon(Icons.person, size: 16, color: context.iconColor),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record['member_name'] ?? 'Inconnu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.textColor,
                                    ),
                                  ),
                                  if (record['member_phone'] != null && (record['member_phone'] as String).isNotEmpty)
                                    Text(
                                      record['member_phone'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.subtitleColor,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Présent",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttendanceDialog(ActivityModel activity) async {
    final memberDao = await DatabaseHelper().memberDao;
    final allMembers = await memberDao.getAllMembers();
    Map<int, bool> attendanceMap = {};
    for (var m in allMembers) {
      if (m.id != null) {
        attendanceMap[m.id!] = false;
      }
    }

    if (!context.mounted) return;
    
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredMembers = allMembers
              .where((m) => m.fullName.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
              
          return AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text("Présences : ${activity.name}", style: TextStyle(color: context.textColor)),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) {
                      setDialogState(() {
                        searchQuery = val;
                      });
                    },
                    style: TextStyle(color: context.textColor),
                    decoration: InputDecoration(
                      hintText: "Rechercher un membre...",
                      hintStyle: TextStyle(color: context.subtitleColor),
                      prefixIcon: Icon(Icons.search, color: context.iconColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.surfaceHighlightColor,
                            child: Icon(Icons.person, color: context.iconColor),
                          ),
                          title: Text(member.fullName, style: TextStyle(color: context.textColor)),
                          subtitle: Text("ID: LABE-00${member.id}", style: TextStyle(color: context.subtitleColor)),
                          trailing: Checkbox(
                            value: attendanceMap[member.id!],
                            onChanged: (val) {
                              setDialogState(() {
                                attendanceMap[member.id!] = val ?? false;
                              });
                            },
                          ),
                        );
                      },
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
                onPressed: () async {
                  final dao = await DatabaseHelper().attendanceDao;
                  String today = DateTime.now().toIso8601String().substring(0, 10);
                  for (var member in allMembers) {
                    if (member.id != null && attendanceMap[member.id!] == true) {
                      await dao.insertAttendance(
                        AttendanceModel(
                          activityId: activity.id!,
                          memberId: member.id!,
                          date: today,
                          status: 'Présent',
                        ),
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Présences enregistrées")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Enregistrer"),
              ),
            ],
          );
        },
      ),
    );
  }

}
