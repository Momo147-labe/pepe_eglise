import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/mouvement_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/core/databases/daos/mouvement_dao.dart';
import 'package:eglise_labe/core/services/mouvement_pdf_service.dart';
import 'package:eglise_labe/features/dashboard/widgets/stat_card.dart';
import 'package:eglise_labe/features/dashboard/pages/mouvement_detail_page.dart';

class MouvementsPage extends StatefulWidget {
  const MouvementsPage({super.key});

  @override
  State<MouvementsPage> createState() => _MouvementsPageState();
}

class _MouvementsPageState extends State<MouvementsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MouvementModel> _mouvements = [];
  bool _isLoading = true;
  String _searchQuery = "";
  MouvementDao? _mouvementDao;

  int _totalMouvements = 0;
  String _largestMouvement = "N/A";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dao = await _dbHelper.mouvementDao;
      _mouvementDao = dao;
      final mouvements = _searchQuery.isEmpty
          ? await dao.getAllMouvements()
          : await dao.searchMouvements(_searchQuery);

      final count = await dao.getMouvementCount();
      final largest = await dao.getLargestMouvement();

      setState(() {
        _mouvements = mouvements;
        _totalMouvements = count;
        _largestMouvement = largest['nom'] ?? "N/A";
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading mouvements: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStats(),
            const SizedBox(height: 32),
            _isLoading
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  )
                : _buildMouvementList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mouvements",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            Text(
              "Gérez les groupes et départements de l'église",
              style: TextStyle(fontSize: 16, color: context.subtitleColor),
            ),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSearchBar(),
            _buildExportButton(),
            _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _loadData();
        },
        style: TextStyle(color: context.textColor),
        decoration: InputDecoration(
          hintText: "Rechercher un mouvement...",
          hintStyle: TextStyle(color: context.iconColor),
          prefixIcon: Icon(Icons.search, color: context.iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: () {
        MouvementPdfService().generateMouvementsReport(_mouvements);
      },
      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
      label: const Text(
        "Exporter",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _showAddMouvementDialog,
      icon: const Icon(Icons.add_rounded),
      label: const Text("Nouveau Mouvement"),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.borderColor),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Total Mouvements",
            value: _totalMouvements.toString(),
            icon: Icons.groups_rounded,
            bgColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Plus Grand Groupe",
            value: _largestMouvement,
            icon: Icons.star_rounded,
            bgColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 24),
        const Spacer(),
      ],
    );
  }

  Widget _buildMouvementList() {
    if (_mouvements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 64,
              color: context.iconColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Aucun mouvement trouvé",
              style: TextStyle(color: context.subtitleColor, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mouvements.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200
            ? 3
            : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 330,
      ),
      itemBuilder: (context, index) {
        final mouvement = _mouvements[index];
        return _buildMouvementCard(mouvement);
      },
    );
  }

  Widget _buildMouvementCard(MouvementModel mouvement) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MouvementDetailPage(
            mouvement: mouvement,
            onChanged: _loadData,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceHighlightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.hub_rounded, color: AppColors.primaryOrange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mouvement.nom,
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Resp: ${mouvement.responsableName ?? 'Non assigné'}",
                        style: TextStyle(color: context.subtitleColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteMouvement(mouvement.id!),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  tooltip: "Supprimer",
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              mouvement.description ?? "Aucune description.",
              style: TextStyle(color: context.subtitleColor, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Divider(color: context.dividerColor, height: 1),
            const SizedBox(height: 12),
            // Dynamic Posts (Up to 5)
            SizedBox(
              height: 140,
              child: FutureBuilder<List<MemberModel>>(
                future: _mouvementDao?.getMouvementMembers(mouvement.id!) ?? Future.value([]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonLoader();
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return Center(
                      child: Text(
                        "Aucun poste assigné",
                        style: TextStyle(
                          color: context.subtitleColor.withOpacity(0.6),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }
                  
                  // Only display these 5 specific roles
                  final targetRoles = [
                    'Président',
                    'Vice-président',
                    'Secrétaire',
                    'Chargé des affaires sociales',
                    'Trésorière'
                  ];
                  
                  var filteredMembers = members
                      .where((m) => m.poste != null && targetRoles.contains(m.poste))
                      .toList();
                      
                  filteredMembers.sort((a, b) {
                    return targetRoles.indexOf(a.poste!).compareTo(targetRoles.indexOf(b.poste!));
                  });

                  final displayMembers = filteredMembers.take(5).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: displayMembers.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            _buildMiniAvatar(m.fullName),
                            const SizedBox(width: 8),
                            Text(
                              "${m.poste ?? 'Membre'}: ",
                              style: TextStyle(
                                color: context.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                m.fullName,
                                style: TextStyle(
                                  color: context.subtitleColor,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${mouvement.memberCount ?? 0} membres",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      color: Colors.redAccent,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final dao = await _dbHelper.mouvementDao;
                        final members = await dao.getMouvementMembers(mouvement.id!);
                        MouvementPdfService().generateSingleMouvementReport(mouvement, members);
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: context.textColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniAvatar(String name) {
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
    final colors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.teal.shade300,
      Colors.red.shade300,
      Colors.indigo.shade300,
    ];
    final color = colors[name.hashCode.abs() % colors.length];
    
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.6), width: 0.8),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: context.surfaceHighlightColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 70,
              height: 10,
              decoration: BoxDecoration(
                color: context.surfaceHighlightColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 90,
              height: 10,
              decoration: BoxDecoration(
                color: context.surfaceHighlightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _showAddMouvementDialog() async {
    final memberDao = await _dbHelper.memberDao;
    final members = await memberDao.getAllMembers();

    if (!mounted) return;

    final nomController = TextEditingController();
    final descController = TextEditingController();
    int? selectedResponsableId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            "Nouveau Mouvement",
            style: TextStyle(color: context.textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                style: TextStyle(color: context.textColor),
                decoration: _dialogInputDecoration("Nom du mouvement"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: TextStyle(color: context.textColor),
                decoration: _dialogInputDecoration("Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                dropdownColor: context.surfaceColor,
                style: TextStyle(color: context.textColor),
                decoration: _dialogInputDecoration("Responsable"),
                items: members
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedResponsableId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isEmpty) return;
                final dao = await _dbHelper.mouvementDao;
                await dao.insertMouvement(
                  MouvementModel(
                    nom: nomController.text,
                    description: descController.text,
                    responsableId: selectedResponsableId,
                  ),
                );
                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
              },
              child: const Text("Créer"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.subtitleColor),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.borderColor),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryOrange),
      ),
    );
  }

  void _deleteMouvement(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(
          "Confirmer la suppression",
          style: TextStyle(color: context.textColor),
        ),
        content: Text(
          "Voulez-vous vraiment supprimer ce mouvement ?",
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dao = await _dbHelper.mouvementDao;
      await dao.deleteMouvement(id);
      _loadData();
    }
  }
}
