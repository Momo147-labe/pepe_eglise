import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/church_model.dart';
import 'package:eglise_labe/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eglise_labe/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = "Français";

  bool _isLoading = true;
  ChurchModel? _churchProfile;
  List<UserModel> _admins = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final churchDao = await DatabaseHelper().churchDao;
    _churchProfile = await churchDao.getChurchProfile();

    if (_churchProfile != null) {
      _nameController.text = _churchProfile!.name;
      _addressController.text = _churchProfile!.address;
      _emailController.text = _churchProfile!.email;
      _phoneController.text = _churchProfile!.phone;
    }

    final userDao = await DatabaseHelper().userDao;
    _admins = await userDao.getAllUsers();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChurchProfile() async {
    final churchDao = await DatabaseHelper().churchDao;
    final updatedProfile = ChurchModel(
      name: _nameController.text,
      address: _addressController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
    await churchDao.updateChurchProfile(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil de l\'église mis à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildChurchProfile(),
          const SizedBox(height: 32),
          _buildUserManagement(),
          const SizedBox(height: 32),
          _buildSystemConfig(),
          const SizedBox(height: 48),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Paramètres & Administration",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Gérez les configurations de l'église et les accès système",
          style: TextStyle(color: Colors.black45, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildChurchProfile() {
    return _buildSectionCard(
      title: "Profil de l'Église",
      icon: Icons.church_rounded,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: AssetImage('assets/eglise.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildSettingsTextField("Nom de l'Église", _nameController),
                const SizedBox(height: 16),
                _buildSettingsTextField("Adresse", _addressController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSettingsTextField(
                        "Email Contact",
                        _emailController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSettingsTextField(
                        "Téléphone",
                        _phoneController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _saveChurchProfile,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text("Enregistrer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return _buildSectionCard(
      title: "Gestion des Administrateurs",
      icon: Icons.admin_panel_settings_rounded,
      child: Column(
        children: [
          ..._admins.map(
            (user) => Column(
              children: [
                _buildAdminItem(
                  user.fullName,
                  user.role,
                  false,
                ), // Or determine if it's the current user
                const Divider(height: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text("Ajouter un collaborateur"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminItem(String name, String role, bool isYou) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.backgroundDark,
          child: Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isYou)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Vous",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              role,
              style: const TextStyle(color: Colors.black45, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: Colors.redAccent,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSystemConfig() {
    return _buildSectionCard(
      title: "Préférences Système",
      icon: Icons.settings_suggest_rounded,
      child: Column(
        children: [
          _buildToggleItem(
            "Mode Sombre",
            "Activer l'interface à contraste élevé",
            themeNotifier.value == ThemeMode.dark,
            (val) async {
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isDarkMode', val);
              setState(() {});
            },
          ),
          const Divider(height: 32),
          _buildDropdownItem(
            "Langue du Système",
            "Sélectionnez votre langue préférée",
            _selectedLanguage,
            ["Français", "English", "Pular"],
          ),
          const Divider(height: 32),
          _buildReadOnlyItem("Monnaie par défaut", "Guinean Franc (GNF)"),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsTextField(
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String sub,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                sub,
                style: TextStyle(color: context.subtitleColor, fontSize: 13),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryOrange,
        ),
      ],
    );
  }

  Widget _buildDropdownItem(
    String title,
    String sub,
    String value,
    List<String> options,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                sub,
                style: TextStyle(color: context.subtitleColor, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLanguage = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.subtitleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/eglise.jpeg',
            height: 40,
            width: 40,
          ), // Placeholder for logo
          const SizedBox(height: 16),
          Text(
            "Version 1.0.0 (Build 20240501)",
            style: TextStyle(color: context.iconColor, fontSize: 12),
          ),
          Text(
            "© 2024 PROTESTANTE EVANGELIQUE DE LABE - Tous droits réservés",
            style: TextStyle(color: context.iconColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
