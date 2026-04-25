import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/mouvement_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/features/dashboard/widgets/stat_card.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStats(),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : _buildMouvementList(),
            ),
          ],
        ),
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
        Row(
          children: [
            _buildSearchBar(),
            const SizedBox(width: 16),
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

    return ListView.separated(
      itemCount: _mouvements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mouvement = _mouvements[index];
        return _buildMouvementCard(mouvement);
      },
    );
  }

  Widget _buildMouvementCard(MouvementModel mouvement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.surfaceHighlightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.hub_rounded, color: context.textColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mouvement.nom,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mouvement.description ?? "",
                  style: TextStyle(color: context.subtitleColor, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildInfoColumn(
            "Responsable",
            mouvement.responsableName ?? "Non assigné",
          ),
          const SizedBox(width: 32),
          _buildInfoColumn("Membres", "${mouvement.memberCount ?? 0} membres"),
          const SizedBox(width: 32),
          _buildActionButtons(mouvement),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(MouvementModel mouvement) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _showMembersDialog(mouvement),
          icon: const Icon(
            Icons.people_outline_rounded,
            color: Colors.blueAccent,
          ),
          tooltip: "Gérer les membres",
        ),
        IconButton(
          onPressed: () => _deleteMouvement(mouvement.id!),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
          ),
          tooltip: "Supprimer",
        ),
      ],
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

  void _showMembersDialog(MouvementModel mouvement) async {
    final dao = await _dbHelper.mouvementDao;
    final memberDao = await _dbHelper.memberDao;

    List<MemberModel> currentMembers = await dao.getMouvementMembers(
      mouvement.id!,
    );
    List<MemberModel> allMembers = await memberDao.getAllMembers();

    if (!mounted) return;

    int? selectedMemberId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            "Membres de : ${mouvement.nom}",
            style: TextStyle(color: context.textColor),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAddMemberToMouvementSection(
                    mouvement,
                    allMembers,
                    currentMembers,
                    selectedMemberId,
                    (val) => setDialogState(() => selectedMemberId = val),
                    () async {
                      currentMembers = await dao.getMouvementMembers(
                        mouvement.id!,
                      );
                      selectedMemberId = null; // Reset selection after adding
                      setDialogState(() {});
                      _loadData();
                    },
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentMembers.length,
                      itemBuilder: (context, index) {
                        final member = currentMembers[index];
                        return ListTile(
                          title: Text(
                            member.fullName,
                            style: TextStyle(color: context.textColor),
                          ),
                          subtitle: Text(
                            member.phone,
                            style: TextStyle(color: context.subtitleColor),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await dao.removeMemberFromMouvement(
                                member.id!,
                                mouvement.id!,
                              );
                              currentMembers = await dao.getMouvementMembers(
                                mouvement.id!,
                              );
                              setDialogState(() {});
                              _loadData();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberToMouvementSection(
    MouvementModel mouvement,
    List<MemberModel> allMembers,
    List<MemberModel> currentMembers,
    int? selectedMemberId,
    Function(int?) onMemberChanged,
    VoidCallback onAdded,
  ) {
    // Filter out already added members
    final availableMembers = allMembers
        .where((m) => !currentMembers.any((cm) => cm.id == m.id))
        .toList();

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            key: ValueKey('member_dropdown_${availableMembers.length}'),
            value: selectedMemberId,
            dropdownColor: context.surfaceColor,
            style: TextStyle(color: context.textColor),
            decoration: _dialogInputDecoration("Ajouter un membre"),
            items: availableMembers
                .map(
                  (m) => DropdownMenuItem(value: m.id, child: Text(m.fullName)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onMemberChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.primaryOrange),
          onPressed: () async {
            if (selectedMemberId == null) return;
            final dao = await _dbHelper.mouvementDao;
            await dao.addMemberToMouvement(selectedMemberId, mouvement.id!);
            onAdded();
          },
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ],
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
