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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  String _formatBudget(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toInt().toString();
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
                _buildSearchBar(),
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

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple,
            Colors.deepPurple.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
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
                child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Événements Spéciaux",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Conférences, Concerts et Célébrations",
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
              InkWell(
                onTap: () => EventPdfService().generateEventReport(_events),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Rapport PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showEventDialog(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Planifier un événement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
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

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          "Total Événements",
          _totalEvents.toString(),
          Icons.event_available_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "À Venir",
          _upcomingEvents.toString(),
          Icons.access_time_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Participants Est.",
          _totalAttendees.toString(),
          Icons.groups_rounded,
          Colors.teal,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          "Budget Global",
          "${_formatBudget(_totalBudget)} GNF",
          Icons.monetization_on_rounded,
          Colors.purple,
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
                      fontSize: 22,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (value) => _loadEvents(value),
        style: TextStyle(color: context.textColor),
        decoration: InputDecoration(
          hintText: "Rechercher un événement...",
          hintStyle: TextStyle(color: context.iconColor),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: context.iconColor),
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: context.iconColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              "Aucun événement planifié.",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 1;
        else if (constraints.maxWidth < 1200) crossAxisCount = 2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 0.85,
          ),
          itemCount: _events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(_events[index]);
          },
        );
      },
    );
  }

  Widget _buildEventCard(EventModel e) {
    // Determine status
    String statusLabel = "À venir";
    Color statusColor = Colors.green;
    try {
      final eventDate = DateTime.parse(e.date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      if (eventDay.isBefore(today)) {
        statusLabel = "Passé";
        statusColor = Colors.grey;
      } else if (eventDay.isAtSameMomentAs(today)) {
        statusLabel = "Aujourd'hui";
        statusColor = AppColors.primaryOrange;
      }
    } catch (_) {}

    return InkWell(
      onTap: () => _showEventDialog(event: e),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                          color: context.iconColor.withValues(alpha: 0.3),
                        ),
                      ),
                // Status badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Frequency badge
                if (e.frequency != null && e.frequency != 'once')
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        e.frequency!.toUpperCase(),
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
            Expanded(
              child: Padding(
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
                        Icon(Icons.calendar_today_rounded, size: 14, color: context.iconColor),
                        const SizedBox(width: 8),
                        Text(
                          e.date,
                          style: TextStyle(color: context.subtitleColor, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: context.iconColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.subtitleColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_rounded, size: 16, color: AppColors.primaryOrange),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _showEventDialog(event: e),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined, size: 18, color: context.subtitleColor),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _deleteEvent(e),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent.withValues(alpha: 0.6)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEvent(EventModel event) async {
    if (event.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Supprimer", style: TextStyle(color: context.textColor)),
        content: Text(
          "Voulez-vous supprimer l'événement \"${event.title}\" ?",
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
    if (confirm == true) {
      final dao = await DatabaseHelper().eventDao;
      await dao.deleteEvent(event.id!);
      _loadEvents();
    }
  }

  void _showEventDialog({EventModel? event}) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final locationCtrl = TextEditingController(text: event?.location ?? '');
    final descCtrl = TextEditingController(text: event?.description ?? '');
    final budgetCtrl = TextEditingController(text: event?.budget?.toInt().toString() ?? '');
    final attendeesCtrl = TextEditingController(text: event?.expectedAttendees?.toString() ?? '');
    String? selectedImagePath = event?.imagePath;
    String frequency = event?.frequency ?? 'once';
    DateTime selectedDate = DateTime.now();
    try {
      if (event != null && event.date.isNotEmpty) {
        selectedDate = DateTime.parse(event.date);
      }
    } catch (_) {}

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: dialogContext.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.celebration_rounded, color: Colors.deepPurple),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        event == null ? "Planifier un événement" : "Modifier l'événement",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: dialogContext.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Image
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        final file = File(image.path);
                        final appDir = await getApplicationDocumentsDirectory();
                        final fileName = path.basename(file.path);
                        final savedImage = await file.copy('${appDir.path}/$fileName');
                        setDialogState(() => selectedImagePath = savedImage.path);
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: dialogContext.surfaceHighlightColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dialogContext.borderColor),
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
                                Icon(Icons.add_photo_alternate_rounded, size: 40, color: dialogContext.iconColor),
                                const SizedBox(height: 8),
                                Text("Ajouter une image de couverture", style: TextStyle(color: dialogContext.subtitleColor)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  _buildDialogLabel(dialogContext, "Titre de l'événement"),
                  _buildDialogTextField(dialogContext, titleCtrl, "Ex: Concert de Noël"),
                  const SizedBox(height: 20),

                  // Date + Location
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel(dialogContext, "Date"),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (ctx, child) {
                                    return Theme(
                                      data: Theme.of(ctx).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Colors.deepPurple,
                                          onPrimary: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setDialogState(() => selectedDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: dialogContext.surfaceHighlightColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: dialogContext.borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(selectedDate),
                                      style: TextStyle(color: dialogContext.textColor),
                                    ),
                                    Icon(Icons.calendar_today_rounded, size: 18, color: dialogContext.iconColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel(dialogContext, "Lieu"),
                            _buildDialogTextField(dialogContext, locationCtrl, "Ex: Temple principal"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Budget + Attendees
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel(dialogContext, "Budget (GNF)"),
                            _buildDialogTextField(dialogContext, budgetCtrl, "Ex: 5000000", isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDialogLabel(dialogContext, "Participants estimés"),
                            _buildDialogTextField(dialogContext, attendeesCtrl, "Ex: 200", isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Frequency
                  _buildDialogLabel(dialogContext, "Récurrence"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: dialogContext.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dialogContext.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: frequency,
                        isExpanded: true,
                        dropdownColor: dialogContext.surfaceColor,
                        items: const [
                          DropdownMenuItem(value: 'once', child: Text("Une seule fois")),
                          DropdownMenuItem(value: 'weekly', child: Text("Hebdomadaire")),
                          DropdownMenuItem(value: 'monthly', child: Text("Mensuel")),
                          DropdownMenuItem(value: 'yearly', child: Text("Annuel")),
                        ],
                        onChanged: (val) => setDialogState(() => frequency = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildDialogLabel(dialogContext, "Description"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: dialogContext.surfaceHighlightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dialogContext.borderColor),
                    ),
                    child: TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      style: TextStyle(color: dialogContext.textColor),
                      decoration: const InputDecoration(
                        hintText: "Description de l'événement...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("Annuler", style: TextStyle(color: dialogContext.subtitleColor)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.isEmpty) return;

                          final newEvent = EventModel(
                            id: event?.id,
                            title: titleCtrl.text,
                            date: DateFormat('yyyy-MM-dd').format(selectedDate),
                            location: locationCtrl.text.isNotEmpty ? locationCtrl.text : 'Non spécifié',
                            description: descCtrl.text,
                            imagePath: selectedImagePath,
                            budget: double.tryParse(budgetCtrl.text) ?? 0,
                            expectedAttendees: int.tryParse(attendeesCtrl.text) ?? 0,
                            frequency: frequency,
                          );

                          final dao = await DatabaseHelper().eventDao;
                          if (event == null) {
                            await dao.insertEvent(newEvent);
                          } else {
                            await dao.updateEvent(newEvent);
                          }

                          _loadEvents();
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                          shadowColor: Colors.deepPurple.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              event == null ? "Planifier" : "Enregistrer",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogLabel(BuildContext ctx, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: ctx.subtitleColor,
        ),
      ),
    );
  }

  Widget _buildDialogTextField(BuildContext ctx, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ctx.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ctx.borderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: ctx.textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ctx.subtitleColor.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
