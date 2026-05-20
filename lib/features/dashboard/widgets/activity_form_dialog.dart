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
  final typeCtrl = TextEditingController();
  final heureCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
  final leadCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? selectedImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      final a = widget.activity!;
      nameCtrl.text = a.name;
      typeCtrl.text = a.type;
      heureCtrl.text = a.time;
      freqCtrl.text = a.freq;
      leadCtrl.text = a.lead;
      locationCtrl.text = a.location ?? '';
      descCtrl.text = a.description ?? '';
      selectedImagePath = a.imagePath;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    typeCtrl.dispose();
    heureCtrl.dispose();
    freqCtrl.dispose();
    leadCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Widget _buildControlledTextField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        widget.activity == null ? "Nouvelle Activité" : "Modifier Activité",
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
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
                    setState(() {
                      selectedImagePath = savedImage.path;
                    });
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
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
                              color: Theme.of(context).iconTheme.color,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Ajouter une image",
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
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
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(
                    Icons.description_rounded,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
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
            final activity = ActivityModel(
              id: widget.activity?.id,
              name: nameCtrl.text,
              type: typeCtrl.text.isNotEmpty ? typeCtrl.text : 'Général',
              freq: freqCtrl.text.isNotEmpty ? freqCtrl.text : 'Hebdomadaire',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(widget.activity == null ? "Créer l'activité" : "Enregistrer"),
        ),
      ],
    );
  }
}
