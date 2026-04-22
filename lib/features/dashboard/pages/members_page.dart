import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();

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
          _buildFiltersAndActions(),
          const SizedBox(height: 24),
          Expanded(child: _buildMembersTable()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Répertoire des Membres",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Gérez les fidèles, leurs groupes et leur engagement",
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(Icons.download_rounded, "Exporter", () {}),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddMemberForm(),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text("Nouveau Membre"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatItem(
          "Total Membres",
          "1,284",
          Icons.people_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          "Nouveaux (Mois)",
          "+42",
          Icons.trending_up_rounded,
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildStatItem("Hommes", "580", Icons.male_rounded, Colors.indigo),
        const SizedBox(width: 24),
        _buildStatItem("Femmes", "704", Icons.female_rounded, Colors.pink),
      ],
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black45, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
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

  Widget _buildFiltersAndActions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Rechercher par nom, téléphone ou groupe...",
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black26),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFilterChip("Tous les Statuts", true),
        const SizedBox(width: 8),
        _buildFilterChip("Chorale", false),
        const SizedBox(width: 8),
        _buildFilterChip("Jeunesse", false),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryOrange.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryOrange
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryOrange : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMembersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          dataRowMaxHeight: 80,
          dividerThickness: 1,
          horizontalMargin: 24,
          columns: const [
            DataColumn(label: Text("MEMBRE")),
            DataColumn(label: Text("CONTACT")),
            DataColumn(label: Text("GROUPE")),
            DataColumn(label: Text("SITUATION")),
            DataColumn(label: Text("STATUT")),
            DataColumn(label: Text("ACTIONS")),
          ],
          rows: [
            _buildMemberRow(
              "Momo Labé",
              "620 00 00 00",
              "Jeunesse",
              "Célibataire",
              "Actif",
              Colors.green,
            ),
            _buildMemberRow(
              "Amadou Diallo",
              "621 11 11 11",
              "Chorale",
              "Marié(e)",
              "Actif",
              Colors.green,
            ),
            _buildMemberRow(
              "Marie Camara",
              "622 22 22 22",
              "Femmes",
              "Marié(e)",
              "Inactif",
              Colors.red,
            ),
            _buildMemberRow(
              "Paul Mansaré",
              "623 33 33 33",
              "Anciens",
              "Marié(e)",
              "Actif",
              Colors.green,
            ),
            _buildMemberRow(
              "Fatoumata Barry",
              "624 44 44 44",
              "Jeunesse",
              "Célibataire",
              "Actif",
              Colors.green,
            ),
            _buildMemberRow(
              "Pierre Traoré",
              "625 55 55 55",
              "Chorale",
              "Marié(e)",
              "Actif",
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildMemberRow(
    String name,
    String phone,
    String group,
    String situation,
    String status,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    "Membre depuis 2023",
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(phone)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group,
              style: const TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
        ),
        DataCell(Text(situation)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 20),
                onPressed: () => _showMemberDetails(name),
                color: Colors.blueAccent.withOpacity(0.7),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                color: Colors.black38,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () {},
                color: Colors.redAccent.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddMemberForm() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ajouter un Nouveau Membre",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Saisissez les informations complètes du fidèle."),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Section: Informations Personnelles
                _buildFormSection("Informations Personnelles", [
                  _buildFormField("Nom", "Ex: Mansaré"),
                  _buildFormField("Prénom", "Ex: Paul"),
                  _buildFormField("Sexe", "Homme / Femme"),
                  _buildFormField("Téléphone", "Ex: 620 00 00 00"),
                ]),

                const SizedBox(height: 24),

                // Section: Adresse
                _buildFormSection("Adresse & Localisation", [
                  _buildFormField("Quartier", "Ex: Daka"),
                  _buildFormField("Ville", "Labé", isEnabled: false),
                ]),

                const SizedBox(height: 24),

                // Section: Infos Église
                _buildFormSection("Vie Sociale & Église", [
                  _buildFormField("Groupe", "Chorale, Jeunesse..."),
                  _buildFormField("Fonction", "Fidèle, Diacre..."),
                  _buildFormField("Situation", "Marié(e) / Célibataire"),
                  _buildFormField("Enfants", "Nombre d'enfants"),
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
                      onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryOrange,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 4,
          children: fields,
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String hint, {bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
          ),
          child: TextField(
            enabled: isEnabled,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _showMemberDetails(String name) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Details",
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 500,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          ),
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profil du Membre",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryOrange.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            name[0],
                            style: const TextStyle(
                              fontSize: 40,
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Membre Actif • Groupe Jeunesse",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildDetailSection("Contact & Adresse", {
                    "Téléphone": "620 00 00 00",
                    "Email": "momo@eglise.gn",
                    "Adresse": "Quartier Daka, Labé",
                  }),
                  const SizedBox(height: 24),
                  _buildDetailSection("Engagement Église", {
                    "Date adhésion": "12 Mars 2023",
                    "Fonction": "Membre Titulaire",
                    "Situation": "Célibataire",
                  }),
                  const SizedBox(height: 24),
                  const Text(
                    "Historique Financier",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildFinancialRow(
                    "Dîme - Avril 2026",
                    "200,000 GNF",
                    "10 Avril",
                  ),
                  _buildFinancialRow(
                    "Offrande - Culte Dimanche",
                    "50,000 GNF",
                    "05 Avril",
                  ),
                  _buildFinancialRow(
                    "Dîme - Mars 2026",
                    "200,000 GNF",
                    "12 Mars",
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Modifier le profil"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, Map<String, String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ...items.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(color: Colors.black45)),
                Text(
                  e.value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String title, String amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
