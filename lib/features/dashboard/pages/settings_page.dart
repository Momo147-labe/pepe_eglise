import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = "Français";

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 32),
          _buildSecuritySection(),
          const SizedBox(height: 32),
          _buildMaintenanceSection(),
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
                _buildSettingsTextField(
                  "Nom de l'Église",
                  "Église Protestante de Labé",
                ),
                const SizedBox(height: 16),
                _buildSettingsTextField(
                  "Adresse",
                  "Quartier Kouroula, Labé, Guinée",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSettingsTextField(
                        "Email Contact",
                        "contact@egliselabe.org",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSettingsTextField(
                        "Téléphone",
                        "+224 621 00 00 00",
                      ),
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

  Widget _buildUserManagement() {
    return _buildSectionCard(
      title: "Gestion des Administrateurs",
      icon: Icons.admin_panel_settings_rounded,
      child: Column(
        children: [
          _buildAdminItem("Mamadou Diallo", "Super Admin", true),
          const Divider(height: 32),
          _buildAdminItem("Jean Condé", "Comptable", false),
          const Divider(height: 32),
          _buildAdminItem("Marie Camara", "Secrétaire", false),
          const SizedBox(height: 24),
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
            "Notifications Push",
            "Recevoir les alertes financières et d'activités",
            _notificationsEnabled,
            (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(height: 32),
          _buildToggleItem(
            "Mode Sombre",
            "Activer l'interface à contraste élevé",
            _darkMode,
            (val) => setState(() => _darkMode = val),
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

  Widget _buildSecuritySection() {
    return _buildSectionCard(
      title: "Sécurité",
      icon: Icons.security_rounded,
      child: Column(
        children: [
          _buildActionItem(
            "Changer le mot de passe",
            "Dernière modification: il y a 3 mois",
            Icons.lock_reset_rounded,
            () {},
          ),
          const Divider(height: 32),
          _buildActionItem(
            "Double Authentification",
            "Non configuré",
            Icons.phonelink_lock_rounded,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    return _buildSectionCard(
      title: "Maintenance & Données",
      icon: Icons.storage_rounded,
      child: Row(
        children: [
          _buildMaintenanceButton(
            "Sauvegarder",
            "Backup Data",
            Icons.backup_rounded,
            Colors.green,
          ),
          const SizedBox(width: 16),
          _buildMaintenanceButton(
            "Vider le Cache",
            "Optimiser",
            Icons.delete_sweep_rounded,
            Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildMaintenanceButton(
            "Réinitialiser",
            "Danger Zone",
            Icons.refresh_rounded,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(
    String label,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                sub,
                style: TextStyle(color: color.withOpacity(0.5), fontSize: 10),
              ),
            ],
          ),
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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

  Widget _buildSettingsTextField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
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
                style: const TextStyle(color: Colors.black45, fontSize: 13),
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
                style: const TextStyle(color: Colors.black45, fontSize: 13),
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
          style: const TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    String sub,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.black38),
          const SizedBox(width: 16),
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
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        ],
      ),
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
          const Text(
            "Version 1.0.0 (Build 20240501)",
            style: TextStyle(color: Colors.black26, fontSize: 12),
          ),
          const Text(
            "© 2024 Église de Labé - Tous droits réservés",
            style: TextStyle(color: Colors.black26, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
