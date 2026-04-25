import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/activity_model.dart';
import 'package:eglise_labe/core/models/attendance_model.dart';
import 'package:eglise_labe/core/services/activity_pdf_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

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
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activités & Planning",
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
                "Gérez les cultes, répétitions et présences",
                style: TextStyle(color: context.subtitleColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _loadActivities();
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher une activité...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildHeaderAction(
              icon: Icons.print_rounded,
              label: "Imprimer Planning",
              onTap: () async {
                final pdfService = ActivityPdfService();
                await pdfService.generateActivityReport(_activities);
              },
              color: context.surfaceColor,
              textColor: context.textColor,
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
          side: color == context.surfaceColor
              ? BorderSide(color: context.borderColor)
              : BorderSide.none,
        ),
        elevation: color == context.surfaceColor ? 0 : 4,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStatsGrid() {
    // Find count of specific activities for display
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
          "Actif",
          Icons.event_note_rounded,
          Colors.purple,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Cultes Dominical",
          culteCount.toString(),
          "Hebdomadaire",
          Icons.people_alt_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Répétitions",
          repetitionCount.toString(),
          "Régulier",
          Icons.music_note_rounded,
          Colors.teal,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Prières / Réunions",
          priereCount.toString(),
          "Hebdomadaire",
          Icons.flare_rounded,
          Colors.blue,
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
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor),
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
                        : context.surfaceHighlightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trend.contains('+')
                          ? Colors.green
                          : context.subtitleColor,
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
    if (_activities.isEmpty)
      return const Center(child: Text("Aucune activité enregistrée."));

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 64,
          dataRowMaxHeight: 80,
          horizontalMargin: 32,
          dividerThickness: 1,
          headingRowColor: WidgetStateProperty.all(
            context.surfaceHighlightColor,
          ),
          columns: const [
            DataColumn(label: Text("ACTIVITÉ")),
            DataColumn(label: Text("TYPE")),
            DataColumn(label: Text("FRÉQUENCE")),
            DataColumn(label: Text("HEURE")),
            DataColumn(label: Text("RESPONSABLE")),
            DataColumn(label: Text("ACTIONS")),
          ],
          rows: _activities.map((activity) {
            final color = Colors.blue;
            return _buildActivityRow(activity, color);
          }).toList(),
        ),
      ),
    );
  }

  DataRow _buildActivityRow(ActivityModel activity, Color color) {
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
              Text(
                activity.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
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
              activity.type,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(Text(activity.freq)),
        DataCell(Text(activity.time)),
        DataCell(Text(activity.lead)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                onPressed: () => _showAttendanceDialog(activity),
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: context.iconColor.withOpacity(0.3),
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
              "Sélectionnez une activité pour voir les détails",
              style: TextStyle(color: context.subtitleColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActivityDialog() {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final heureCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final leadCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Nouvelle Activité"),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        final file = File(image.path);
                        final appDir = await getApplicationDocumentsDirectory();
                        final fileName = path.basename(file.path);
                        final savedImage = await file.copy(
                          '${appDir.path}/$fileName',
                        );
                        setDialogState(
                          () => selectedImagePath = savedImage.path,
                        );
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.surfaceHighlightColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                        image: selectedImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImagePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 40,
                                  color: context.iconColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Ajouter une image",
                                  style: TextStyle(
                                    color: context.subtitleColor,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlledTextField(
                          "Nom de l'activité",
                          Icons.title_rounded,
                          nameCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildControlledTextField(
                          "Type (ex: Culte)",
                          Icons.category_rounded,
                          typeCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlledTextField(
                          "Lieu",
                          Icons.location_on_rounded,
                          locationCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildControlledTextField(
                          "Heure",
                          Icons.access_time_rounded,
                          heureCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlledTextField(
                          "Fréquence",
                          Icons.repeat_rounded,
                          freqCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildControlledTextField(
                          "Responsable",
                          Icons.person_rounded,
                          leadCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: const Icon(
                        Icons.description_rounded,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final newActivity = ActivityModel(
                  name: nameCtrl.text,
                  type: typeCtrl.text.isNotEmpty ? typeCtrl.text : 'Général',
                  freq: freqCtrl.text.isNotEmpty
                      ? freqCtrl.text
                      : 'Hebdomadaire',
                  time: heureCtrl.text.isNotEmpty ? heureCtrl.text : '00:00',
                  lead: leadCtrl.text.isNotEmpty
                      ? leadCtrl.text
                      : 'Non assigné',
                  location: locationCtrl.text,
                  description: descCtrl.text,
                  imagePath: selectedImagePath,
                );
                final dao = await DatabaseHelper().activityDao;
                await dao.insertActivity(newActivity);
                _loadActivities();
                if (context.mounted) Navigator.pop(context);
              },
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
      ),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text("Présences : ${activity.name}"),
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
                    itemCount: allMembers.length,
                    itemBuilder: (context, index) {
                      final member = allMembers[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(member.fullName),
                        subtitle: Text("ID: LABE-00${member.id}"),
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
                String today = DateTime.now().toIso8601String().substring(
                  0,
                  10,
                );
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
        ),
      ),
    );
  }

  Widget _buildControlledTextField(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
    );
  }
}
