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

  Color _getRoleColor(String? role) {
    if (role == null) return Colors.grey;
    final r = role.toLowerCase();
    if (r.contains('président') || r.contains('president') || r.contains('pasteur')) {
      return Colors.amber.shade700;
    }
    if (r.contains('secrétaire') || r.contains('secretaire')) {
      return Colors.blue.shade600;
    }
    if (r.contains('trésorièr') || r.contains('tresorier')) {
      return Colors.indigo.shade500;
    }
    if (r.contains('social')) {
      return Colors.teal.shade600;
    }
    if (r == 'membre') {
      return Colors.grey.shade600;
    }
    return AppColors.primaryOrange;
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.8),
            AppColors.primaryOrange.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mouvement.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "Responsable : ${widget.mouvement.responsableName ?? 'Non assigné'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.mouvement.description ?? "Aucune description fournie.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Créé le : ${widget.mouvement.dateCreation != null ? widget.mouvement.dateCreation!.split('T')[0] : 'N/A'}",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: StatCard(
              title: "Total Membres Actifs",
              value: _currentMembers.length.toString(),
              icon: Icons.groups_rounded,
              bgColor: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 24),
        const Spacer(),
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
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
                backgroundColor: context.surfaceHighlightColor,
                foregroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text("Affecter un Membre"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: const StadiumBorder(),
                elevation: 4,
                shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: TextStyle(color: context.textColor),
        decoration: InputDecoration(
          hintText: "Rechercher un membre...",
          hintStyle: TextStyle(color: context.iconColor, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            child: Icon(Icons.search, color: context.iconColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
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
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: AppColors.primaryOrange.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Ce groupe est vide",
              style: TextStyle(
                color: context.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez-y son premier membre pour commencer !",
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final roleColor = _getRoleColor(member.poste);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: roleColor.withValues(alpha: 0.1),
                child: Text(
                  member.fullName.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            title: Text(
              member.fullName,
              style: TextStyle(color: context.textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 14, color: context.subtitleColor),
                    const SizedBox(width: 6),
                    Text(member.phone, style: TextStyle(color: context.subtitleColor, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: roleColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    member.poste ?? "Membre",
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.surfaceHighlightColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                    onPressed: () => _showEditRoleDialog(member),
                    tooltip: "Modifier le poste",
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeMember(member),
                    tooltip: "Retirer du groupe",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final availableMembers = _allMembers
        .where((m) => !_currentMembers.any((cm) => cm.id == m.id))
        .toList();

    int? selectedId;
    String selectedRole = 'Membre';
    final formKey = GlobalKey<FormState>();
    
    final isCommissionLocale = widget.mouvement.nom == 'Commission Locale';
    final roles = isCommissionLocale 
      ? [
          'pasteur',
          'vice-president',
          'secretaire',
          'charger aux affaires sociales',
          'Le trésorier',
          'Membre'
        ]
      : [
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
    final isCommissionLocale = widget.mouvement.nom == 'Commission Locale';
    final roles = isCommissionLocale 
      ? [
          'pasteur',
          'vice-president',
          'secretaire',
          'charger aux affaires sociales',
          'Le trésorier',
          'Membre'
        ]
      : [
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
