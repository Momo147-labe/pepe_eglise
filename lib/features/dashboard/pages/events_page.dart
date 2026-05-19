import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/event_model.dart';
import 'package:eglise_labe/core/services/event_pdf_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<EventModel> _events = [];
  bool _isLoading = true;
  int _totalEvents = 0;
  int _upcomingEvents = 0;
  double _totalBudget = 0.0;
  int _totalAttendees = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents([String? query]) async {
    setState(() => _isLoading = true);
    final dao = await DatabaseHelper().eventDao;
    final events = query == null || query.isEmpty
        ? await dao.getAllEvents()
        : await dao.searchEvents(query);

    final total = events.length;
    final upcoming = await dao.getUpcomingEventsCount(DateTime.now());
    final budget = await dao.getTotalBudget();
    final attendees = await dao.getTotalAttendees();

    setState(() {
      _events = events;
      _totalEvents = total;
      _upcomingEvents = upcoming;
      _totalBudget = budget;
      _totalAttendees = attendees;
      _isLoading = false;
    });
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
                _buildFilters(),
              ]),
            ),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        child: _buildEventsGrid(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Événements Spéciaux",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.textColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Conférences, Concerts et Célébrations",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => EventPdfService().generateEventReport(_events),
              icon: const Icon(Icons.print_rounded, size: 20),
              label: const Text("Imprimer Rapport"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEventDialog(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text("Planifier un événement"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryOrange.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Total Événements",
          _totalEvents.toString(),
          "Global",
          Icons.event_available_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "À Venir",
          _upcomingEvents.toString(),
          "Prochainement",
          Icons.access_time_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Participants Est.",
          _totalAttendees.toString(),
          "Total",
          Icons.groups_rounded,
          Colors.teal,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Budget Global",
          "${(_totalBudget / 1000000).toStringAsFixed(1)}M",
          "GNF",
          Icons.monetization_on_rounded,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => _loadEvents(value),
              decoration: InputDecoration(
                hintText: "Rechercher un événement...",
                hintStyle: TextStyle(color: context.iconColor),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: context.iconColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFilterItem(Icons.filter_list_rounded, "Statut"),
        const SizedBox(width: 12),
        _buildFilterItem(Icons.calendar_today_rounded, "Date"),
      ],
    );
  }

  Widget _buildFilterItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_events.isEmpty)
      return const Center(child: Text("Aucun événement planifié."));

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(index);
      },
    );
  }

  Widget _buildEventCard(int index) {
    if (index >= _events.length) return const SizedBox.shrink();
    final e = _events[index];

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              e.imagePath != null && File(e.imagePath!).existsSync()
                  ? Image.file(
                      File(e.imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: context.surfaceHighlightColor,
                      child: Icon(
                        Icons.image_rounded,
                        size: 48,
                        color: context.iconColor.withOpacity(0.3),
                      ),
                    ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    e.frequency != 'once'
                        ? e.frequency!.toUpperCase()
                        : "À venir",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.date,
                      style: TextStyle(
                        color: context.subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_rounded,
                          size: 16,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${e.expectedAttendees ?? 0} inscrits",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () => _deleteEvent(e.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(int id) async {
    final dao = await DatabaseHelper().eventDao;
    await dao.deleteEvent(id);
    _loadEvents();
  }

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final attendeesCtrl = TextEditingController();
    String? selectedImagePath;
    String frequency = 'once';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text("Planifier un événement"),
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
                    child: _buildPlaceholderImagePicker(selectedImagePath),
                  ),
                  const SizedBox(height: 24),
                  _buildControlledTextField(
                    "Titre de l'événement",
                    Icons.title_rounded,
                    titleCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlledTextField(
                          "Date",
                          Icons.calendar_today_rounded,
                          dateCtrl,
                          hint: "YYYY-MM-DD",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildControlledTextField(
                          "Lieu",
                          Icons.location_on_rounded,
                          locationCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlledTextField(
                          "Budget (GNF)",
                          Icons.monetization_on_rounded,
                          budgetCtrl,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildControlledTextField(
                          "Participants Est.",
                          Icons.people_rounded,
                          attendeesCtrl,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: _inputDecoration(
                      "Récurrence",
                      Icons.repeat_rounded,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'once',
                        child: Text("Une seule fois"),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text("Hebdomadaire"),
                      ),
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text("Mensuel"),
                      ),
                      DropdownMenuItem(value: 'yearly', child: Text("Annuel")),
                    ],
                    onChanged: (val) => setDialogState(() => frequency = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildControlledTextField(
                    "Description",
                    Icons.description_rounded,
                    descCtrl,
                    maxLines: 3,
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
                if (titleCtrl.text.isEmpty) return;

                final baseEvent = EventModel(
                  title: titleCtrl.text,
                  date: dateCtrl.text.isNotEmpty
                      ? dateCtrl.text
                      : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  location: locationCtrl.text.isNotEmpty
                      ? locationCtrl.text
                      : 'Non spécifié',
                  description: descCtrl.text,
                  imagePath: selectedImagePath,
                  budget: double.tryParse(budgetCtrl.text) ?? 0,
                  expectedAttendees: int.tryParse(attendeesCtrl.text) ?? 0,
                  frequency: frequency,
                );

                final dao = await DatabaseHelper().eventDao;

                // Add first instance
                await dao.insertEvent(baseEvent);

                // For recurring events, we could add more instances here or handle them in the UI
                if (frequency != 'once') {
                  // Optional: Logic to generate recurring instances
                }

                _loadEvents();
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Planifier"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }

  Widget _buildPlaceholderImagePicker(String? imagePath) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        image: imagePath != null
            ? DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imagePath == null
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
                  "Ajouter une image de couverture",
                  style: TextStyle(color: context.iconColor),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildControlledTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
    );
  }
}

class Position8 extends StatelessWidget {
  final double? top;
  final double? right;
  final Widget child;
  const Position8({super.key, this.top, this.right, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, right: right, child: child);
  }
}
