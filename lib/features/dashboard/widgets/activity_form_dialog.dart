import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/activity_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ActivityFormDialog extends StatefulWidget {
  final ActivityModel? activity;
  final VoidCallback onSaved;

  const ActivityFormDialog({super.key, this.activity, required this.onSaved});

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final nameCtrl = TextEditingController();
  final heureCtrl = TextEditingController();
  final leadCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? selectedImagePath;

  String selectedType = 'Culte';
  String selectedFreq = 'Hebdomadaire';

  final List<String> activityTypes = [
    'Culte',
    'Répétition',
    'Prière',
    'Réunion',
    'Formation',
    'Évangélisation',
    'Autre',
  ];

  final List<String> frequencies = [
    'Quotidienne',
    'Hebdomadaire',
    'Bi-mensuelle',
    'Mensuelle',
    'Trimestrielle',
    'Annuelle',
    'Ponctuelle',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      final a = widget.activity!;
      nameCtrl.text = a.name;
      heureCtrl.text = a.time;
      leadCtrl.text = a.lead;
      locationCtrl.text = a.location ?? '';
      descCtrl.text = a.description ?? '';
      selectedImagePath = a.imagePath;
      // Try to match existing type/freq to our lists
      if (activityTypes.contains(a.type)) {
        selectedType = a.type;
      } else {
        // If the type doesn't match, add it temporarily
        if (!activityTypes.contains(a.type)) {
          activityTypes.add(a.type);
        }
        selectedType = a.type;
      }
      if (frequencies.contains(a.freq)) {
        selectedFreq = a.freq;
      } else {
        if (!frequencies.contains(a.freq)) {
          frequencies.add(a.freq);
        }
        selectedFreq = a.freq;
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    heureCtrl.dispose();
    leadCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.surfaceColor,
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
                      color: AppColors.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_note_rounded, color: AppColors.primaryOrange),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.activity == null ? "Nouvelle Activité" : "Modifier Activité",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Image picker
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
                    setState(() => selectedImagePath = savedImage.path);
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
                            Icon(Icons.add_photo_alternate_rounded, size: 40, color: context.iconColor),
                            const SizedBox(height: 8),
                            Text("Ajouter une image", style: TextStyle(color: context.subtitleColor)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Nom
              _buildFormLabel("Nom de l'activité"),
              _buildTextField(nameCtrl, "Ex: Culte du Dimanche"),
              const SizedBox(height: 20),

              // Type + Fréquence (Dropdowns)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Type"),
                        _buildDropdown(
                          value: selectedType,
                          items: activityTypes,
                          onChanged: (val) => setState(() => selectedType = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Fréquence"),
                        _buildDropdown(
                          value: selectedFreq,
                          items: frequencies,
                          onChanged: (val) => setState(() => selectedFreq = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lieu + Heure
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Lieu"),
                        _buildTextField(locationCtrl, "Ex: Temple principal"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Heure"),
                        _buildTextField(heureCtrl, "Ex: 09:00"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Responsable
              _buildFormLabel("Responsable"),
              _buildTextField(leadCtrl, "Ex: Pasteur Diallo"),
              const SizedBox(height: 20),

              // Description
              _buildFormLabel("Description"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.surfaceHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: TextStyle(color: context.textColor),
                  decoration: const InputDecoration(
                    hintText: "Description de l'activité...",
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
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler", style: TextStyle(color: context.subtitleColor)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) return;
                      final activity = ActivityModel(
                        id: widget.activity?.id,
                        name: nameCtrl.text,
                        type: selectedType,
                        freq: selectedFreq,
                        time: heureCtrl.text.isNotEmpty ? heureCtrl.text : '00:00',
                        lead: leadCtrl.text.isNotEmpty ? leadCtrl.text : 'Non assigné',
                        location: locationCtrl.text,
                        description: descCtrl.text,
                        imagePath: selectedImagePath,
                      );
                      final dao = await DatabaseHelper().activityDao;
                      if (widget.activity == null) {
                        await dao.insertActivity(activity);
                      } else {
                        await dao.updateActivity(activity);
                      }
                      widget.onSaved();
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                      shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.activity == null ? "Créer l'activité" : "Enregistrer",
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
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: context.textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.subtitleColor.withValues(alpha: 0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: context.surfaceColor,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: context.textColor)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
