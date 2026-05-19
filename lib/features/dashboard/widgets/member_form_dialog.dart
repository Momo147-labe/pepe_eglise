import 'dart:io' show Platform, File, Directory;
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/databases/database_path.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class MemberFormDialog extends StatefulWidget {
  final MemberModel? member;
  final VoidCallback onSaved;

  const MemberFormDialog({super.key, this.member, required this.onSaved});

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final nomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final lieuNaissanceCtrl = TextEditingController();
  final quartierCtrl = TextEditingController();
  final conjointCtrl = TextEditingController();
  final childrenCountCtrl = TextEditingController(text: '0');
  final joiningYearCtrl = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final customGroupeCtrl = TextEditingController();

  String selectedGender = 'M';
  String selectedMaritalStatus = 'Célibataire';
  String selectedGroup = '👥 Jeunesse';
  bool isCustomGroup = false;
  DateTime? selectedBirthDate;
  XFile? pickedImage;

  final List<String> groupOptions = [
    '🎶 Louange',
    '🙏 Prière',
    '👥 Jeunesse',
    '👩 Femmes',
    '👨 Hommes',
    '🧒 Enfants',
    '📖 Évangélisation',
    '🛡️ Sécurité',
    '💻 Technique',
    'Autre...',
  ];

  final List<String> genderOptions = ['M', 'F'];
  final Map<String, String> genderLabels = {'M': 'Masculin', 'F': 'Féminin'};
  final List<String> martialStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf/Veuve',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      final m = widget.member!;
      // Split full name if possible, or just put it in Nom
      final names = m.fullName.split(' ');
      if (names.length > 1) {
        nomCtrl.text = names[0];
        prenomCtrl.text = names.sublist(1).join(' ');
      } else {
        nomCtrl.text = m.fullName;
      }
      phoneCtrl.text = m.phone;
      selectedGender = m.gender;
      selectedMaritalStatus = m.maritalStatus;
      lieuNaissanceCtrl.text = m.birthPlace ?? '';
      quartierCtrl.text = m.quartier ?? '';
      childrenCountCtrl.text = (m.childrenCount ?? 0).toString();
      joiningYearCtrl.text =
          (m.joiningYear ??
                  (m.joinedAt.length >= 4
                      ? int.tryParse(m.joinedAt.substring(0, 4))
                      : DateTime.now().year))
              .toString();
      if (m.birthDate != null) {
        selectedBirthDate = DateTime.tryParse(m.birthDate!);
      }
      if (m.imagePath != null) {
        pickedImage = XFile(m.imagePath!);
      }

      // Handle group selection matching
      if (groupOptions.contains(m.groupName)) {
        selectedGroup = m.groupName;
        isCustomGroup = false;
      } else {
        selectedGroup = 'Autre...';
        isCustomGroup = true;
        customGroupeCtrl.text = m.groupName;
      }
    }
  }

  @override
  void dispose() {
    nomCtrl.dispose();
    prenomCtrl.dispose();
    phoneCtrl.dispose();
    lieuNaissanceCtrl.dispose();
    quartierCtrl.dispose();
    conjointCtrl.dispose();
    childrenCountCtrl.dispose();
    joiningYearCtrl.dispose();
    customGroupeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(32),
        color: context.surfaceColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.member == null ? "Nouveau Membre" : "Modifier Membre",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: context.borderColor),
              const SizedBox(height: 24),

              // Section: Identité & Localisation
              _buildFormSection(
                "Identité & Localisation",
                Icons.person_outline_rounded,
                [
                  // Photo et champs principaux
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo à gauche
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: context.surfaceHighlightColor,
                                  borderRadius: BorderRadius.circular(16),
                                  image: pickedImage != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(pickedImage!.path),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: pickedImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: context.iconColor.withOpacity(
                                          0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryOrange,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (pickedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 120,
                                ),
                                child: Text(
                                  p.basename(pickedImage!.path),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Champs à droite de la photo
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormTextField(
                                    "Nom",
                                    "Ex: Mansaré",
                                    nomCtrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormTextField(
                                    "Prénoms",
                                    "Ex: Paul",
                                    prenomCtrl,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sexe",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.subtitleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: selectedGender,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: context.borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.primaryOrange,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                        ),
                                        dropdownColor: context.surfaceColor,
                                        style: TextStyle(
                                          color: context.textColor,
                                        ),
                                        items: genderOptions.map((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(genderLabels[value]!),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedGender = newValue!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date de Naissance",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.subtitleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectBirthDate,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 11,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: context.borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                selectedBirthDate == null
                                                    ? "Choisir"
                                                    : DateFormat(
                                                        'dd/MM/yyyy',
                                                      ).format(
                                                        selectedBirthDate!,
                                                      ),
                                                style: TextStyle(
                                                  color:
                                                      selectedBirthDate == null
                                                      ? context.iconColor
                                                            .withOpacity(0.5)
                                                      : context.textColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: context.iconColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormTextField(
                          "Lieu de Naissance",
                          "Ex: Labé",
                          lieuNaissanceCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormTextField(
                          "Quartier",
                          "Ex: Kouroula",
                          quartierCtrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Vie Sociale & Engagement
              _buildFormSection(
                "Vie Sociale & Engagement",
                Icons.church_outlined,
                [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Situation Matrimoniale",
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedMaritalStatus,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              dropdownColor: context.surfaceColor,
                              style: TextStyle(color: context.textColor),
                              items: martialStatusOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedMaritalStatus = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormTextField(
                          "Nom du Conjoint",
                          "Si marié(e)",
                          conjointCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormTextField(
                          "Nombre d'Enfants",
                          "0",
                          childrenCountCtrl,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Groupe (Mouvement)",
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedGroup,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: context.borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              dropdownColor: context.surfaceColor,
                              style: TextStyle(color: context.textColor),
                              items: groupOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedGroup = newValue!;
                                  isCustomGroup = newValue == 'Autre...';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isCustomGroup) ...[
                    const SizedBox(height: 16),
                    _buildFormTextField(
                      "Nom du groupe personnalisé",
                      "Ex: Chorale des Aînés",
                      customGroupeCtrl,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormTextField(
                          "Année d'adhésion",
                          "Ex: 2020",
                          joiningYearCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()), // Spacer
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Contact
              _buildFormSection("Contact", Icons.phone_outlined, [
                Row(
                  children: [
                    Expanded(
                      child: _buildFormTextField(
                        "Numéro de Téléphone",
                        "Ex: 620 00 00 00",
                        phoneCtrl,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: SizedBox()), // Spacer
                  ],
                ),
              ]),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Enregistrer"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        XFile? pickedFile;
        if (source == ImageSource.gallery &&
            (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
          final result = await FilePicker.pickFiles(type: FileType.image);
          if (result != null && result.files.single.path != null) {
            pickedFile = XFile(result.files.single.path!);
          }
        } else {
          pickedFile = await picker.pickImage(source: source);
        }

        if (pickedFile != null) {
          setState(() {
            pickedImage = pickedFile;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur d'accès à l'image: $e")),
          );
        }
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveMember() async {
    final fullName = "${nomCtrl.text} ${prenomCtrl.text}".trim();
    if (fullName.isEmpty || phoneCtrl.text.isEmpty) return;

    String? finalImagePath;
    if (pickedImage != null &&
        (widget.member == null ||
            pickedImage!.path != widget.member!.imagePath)) {
      final basePath = await getAppStorageDirectory();
      final imagesDir = Directory(p.join(basePath, 'member_photos'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          "member_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedImage!.path)}";
      final targetPath = p.join(imagesDir.path, fileName);
      await File(pickedImage!.path).copy(targetPath);
      finalImagePath = targetPath;
    } else if (widget.member != null) {
      finalImagePath = widget.member!.imagePath;
    }

    final dao = await DatabaseHelper().memberDao;

    if (widget.member == null) {
      final newMember = MemberModel(
        fullName: fullName,
        phone: phoneCtrl.text,
        gender: selectedGender,
        groupName: isCustomGroup ? customGroupeCtrl.text : selectedGroup,
        maritalStatus: selectedMaritalStatus,
        memberStatus: 'Actif',
        joinedAt: DateTime.now().toIso8601String(),
        birthDate: selectedBirthDate?.toIso8601String(),
        birthPlace: lieuNaissanceCtrl.text,
        joiningYear: int.tryParse(joiningYearCtrl.text),
        childrenCount: int.tryParse(childrenCountCtrl.text),
        imagePath: finalImagePath,
        quartier: quartierCtrl.text,
      );
      await dao.insertMember(newMember);
    } else {
      final updatedMember = MemberModel(
        id: widget.member!.id,
        fullName: fullName,
        phone: phoneCtrl.text,
        gender: selectedGender,
        groupName: isCustomGroup ? customGroupeCtrl.text : selectedGroup,
        maritalStatus: selectedMaritalStatus,
        memberStatus: widget.member!.memberStatus,
        joinedAt: widget.member!.joinedAt,
        birthDate: selectedBirthDate?.toIso8601String(),
        birthPlace: lieuNaissanceCtrl.text,
        joiningYear: int.tryParse(joiningYearCtrl.text),
        childrenCount: int.tryParse(childrenCountCtrl.text),
        imagePath: finalImagePath,
        quartier: quartierCtrl.text,
      );
      await dao.updateMember(updatedMember);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.subtitleColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: context.textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.iconColor.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.transparent,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
