import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/mouvement_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/features/dashboard/widgets/stat_card.dart';
import 'package:eglise_labe/core/services/card_pdf_service.dart';
import 'package:eglise_labe/features/dashboard/widgets/pdf_preview_dialog.dart';

class MouvementDetailPage extends StatefulWidget {
  final MouvementModel mouvement;
  final VoidCallback onChanged;

  const MouvementDetailPage({
    super.key,
    required this.mouvement,
    required this.onChanged,
  });

  @override
  State<MouvementDetailPage> createState() => _MouvementDetailPageState();
}

class _MouvementDetailPageState extends State<MouvementDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MemberModel> _currentMembers = [];
  List<MemberModel> _allMembers = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dao = await _dbHelper.mouvementDao;
      final memberDao = await _dbHelper.memberDao;

      final current = await dao.getMouvementMembers(widget.mouvement.id!);
      final all = await memberDao.getAllMembers();

      setState(() {
        _currentMembers = current;
        _allMembers = all;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading movement members: $e");
      setState(() => _isLoading = false);
    }
  }

  List<MemberModel> get _filteredMembers {
    if (_searchQuery.isEmpty) return _currentMembers;
    return _currentMembers
        .where((m) => m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (m.poste ?? "Membre").toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceHighlightColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textColor),
          onPressed: () {
            widget.onChanged();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.mouvement.nom,
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  _buildMembersSectionHeader(),
                  const SizedBox(height: 16),
                  _buildMembersList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.surfaceHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hub_rounded, color: AppColors.primaryOrange, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mouvement.nom,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Créé le : ${widget.mouvement.dateCreation != null ? widget.mouvement.dateCreation!.split('T')[0] : 'N/A'}",
                      style: TextStyle(color: context.subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: context.dividerColor, height: 1),
          const SizedBox(height: 16),
          Text(
            widget.mouvement.description ?? "Aucune description fournie.",
            style: TextStyle(color: context.textColor, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Membres Actifs",
            value: _currentMembers.length.toString(),
            icon: Icons.people_rounded,
            bgColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: StatCard(
            title: "Responsable",
            value: widget.mouvement.responsableName ?? "Non assigné",
            icon: Icons.person_rounded,
            bgColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Membres et Rôles",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            Text(
              "Affectez des membres et gérez leurs postes",
              style: TextStyle(fontSize: 14, color: context.subtitleColor),
            ),
          ],
        ),
        Row(
          children: [
            _buildSearchBar(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final pdfData = await CardPdfService().generateAllMemberCards(_currentMembers);
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => PdfPreviewDialog(
                      pdfData: pdfData,
                      title: "Cartes de Membre - ${widget.mouvement.nom}",
                    ),
                  );
                }
              },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text("Imprimer les Cartes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Affecter un Membre"),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surfaceColor,
                foregroundColor: context.textColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.borderColor),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: TextStyle(color: context.textColor),
        decoration: InputDecoration(
          hintText: "Rechercher un membre...",
          hintStyle: TextStyle(color: context.iconColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: context.iconColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    final members = _filteredMembers;
    if (members.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: context.iconColor.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "Aucun membre dans ce groupe",
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        separatorBuilder: (context, index) => Divider(color: context.dividerColor, height: 1),
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: context.surfaceHighlightColor,
              child: Text(
                member.fullName.substring(0, 1).toUpperCase(),
                style: TextStyle(color: context.textColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              member.fullName,
              style: TextStyle(color: context.textColor, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(member.phone, style: TextStyle(color: context.subtitleColor, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member.poste ?? "Membre",
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                  onPressed: () => _showEditRoleDialog(member),
                  tooltip: "Modifier le poste",
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _removeMember(member),
                  tooltip: "Retirer du groupe",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMemberDialog() {
    final availableMembers = _allMembers
        .where((m) => !_currentMembers.any((cm) => cm.id == m.id))
        .toList();

    int? selectedId;
    String selectedRole = 'Membre';
    final formKey = GlobalKey<FormState>();
    
    final roles = [
      'Président',
      'Vice-président',
      'Secrétaire',
      'Chargé des affaires sociales',
      'Trésorière',
      'Membre'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text("Affecter un membre", style: TextStyle(color: context.textColor)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  dropdownColor: context.surfaceColor,
                  style: TextStyle(color: context.textColor),
                  decoration: _dialogInputDecoration("Sélectionner le membre"),
                  items: availableMembers
                      .map((m) => DropdownMenuItem(value: m.id, child: Text(m.fullName)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedId = val),
                  validator: (value) => value == null ? "Sélection requise" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: context.surfaceColor,
                  style: TextStyle(color: context.textColor),
                  decoration: _dialogInputDecoration("Poste / Rôle"),
                  items: roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val ?? 'Membre'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() && selectedId != null) {
                  final dao = await _dbHelper.mouvementDao;
                  
                  if (selectedRole != 'Membre') {
                    MemberModel? existingMember;
                    try {
                      existingMember = _currentMembers.firstWhere((m) => m.poste == selectedRole);
                    } catch (_) {}

                    if (existingMember != null) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: context.surfaceColor,
                          title: Text("Remplacer ?", style: TextStyle(color: context.textColor)),
                          content: Text("${existingMember!.fullName} est déjà $selectedRole. Voulez-vous le remplacer ?", style: TextStyle(color: context.subtitleColor)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                              child: const Text("Remplacer"),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      // Rétrograder l'ancien membre
                      await dao.updateMemberPosteInMouvement(
                        existingMember.id!,
                        widget.mouvement.id!,
                        'Membre',
                      );
                    }
                  }

                  await dao.addMemberToMouvement(
                    selectedId!,
                    widget.mouvement.id!,
                    poste: selectedRole,
                  );
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text("Affecter"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoleDialog(MemberModel member) {
    final roles = [
      'Président',
      'Vice-président',
      'Secrétaire',
      'Chargé des affaires sociales',
      'Trésorière',
      'Membre'
    ];
    
    String selectedRole = roles.contains(member.poste) ? member.poste! : 'Membre';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text("Modifier le rôle de ${member.fullName}", style: TextStyle(color: context.textColor)),
          content: Form(
            key: formKey,
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              dropdownColor: context.surfaceColor,
              style: TextStyle(color: context.textColor),
              decoration: _dialogInputDecoration("Nouveau poste / Rôle"),
              items: roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setDialogState(() => selectedRole = val ?? 'Membre'),
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final dao = await _dbHelper.mouvementDao;

                if (selectedRole != 'Membre') {
                  MemberModel? existingMember;
                  try {
                    existingMember = _currentMembers.firstWhere((m) => m.poste == selectedRole && m.id != member.id);
                  } catch (_) {}

                  if (existingMember != null) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: context.surfaceColor,
                        title: Text("Remplacer ?", style: TextStyle(color: context.textColor)),
                        content: Text("${existingMember!.fullName} est déjà $selectedRole. Voulez-vous le remplacer ?", style: TextStyle(color: context.subtitleColor)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                            child: const Text("Remplacer"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    // Rétrograder l'ancien membre
                    await dao.updateMemberPosteInMouvement(
                      existingMember.id!,
                      widget.mouvement.id!,
                      'Membre',
                    );
                  }
                }

                await dao.updateMemberPosteInMouvement(
                  member.id!,
                  widget.mouvement.id!,
                  selectedRole,
                );
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
      ),
    );
  }

  void _removeMember(MemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text("Retirer du groupe", style: TextStyle(color: context.textColor)),
        content: Text(
          "Voulez-vous vraiment désassocier ${member.fullName} de ce groupe ?",
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
            child: const Text("Retirer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dao = await _dbHelper.mouvementDao;
      await dao.removeMemberFromMouvement(member.id!, widget.mouvement.id!);

      final memberDao = await _dbHelper.memberDao;
      final updatedMember = MemberModel(
        id: member.id,
        fullName: member.fullName,
        phone: member.phone,
        gender: member.gender,
        groupName: 'Autre...',
        maritalStatus: member.maritalStatus,
        memberStatus: member.memberStatus,
        joinedAt: member.joinedAt,
        birthDate: member.birthDate,
        joiningYear: member.joiningYear,
        childrenCount: member.childrenCount,
        imagePath: member.imagePath,
        quartier: member.quartier,
        birthPlace: member.birthPlace,
        poste: member.poste,
      );
      await memberDao.updateMember(updatedMember);

      _loadData();
    }
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
}
