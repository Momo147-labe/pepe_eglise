import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/core/databases/daos/member_dao.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/features/dashboard/widgets/member_form_dialog.dart';
import 'package:eglise_labe/features/dashboard/widgets/member_details_dialog.dart';
import 'package:eglise_labe/features/dashboard/widgets/members_table.dart';
import 'package:eglise_labe/core/services/card_pdf_service.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MemberModel> _members = [];
  int _totalMembers = 0;
  int _newMembersMonth = 0;
  int _menCount = 0;
  int _womenCount = 0;
  List<MemberModel> _filteredMembers = [];
  String _searchQuery = "";
  String _selectedGroup = "Tous les Groupes";
  String _selectedStatus = "Tous les Statuts";
  List<String> _allGroups = ["Tous les Groupes"];
  bool _isLoading = true;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  int? _calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return null;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final MemberDao dao = await DatabaseHelper().memberDao;
    final members = await dao.getAllMembers();
    final total = await dao.getMemberCount();
    final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final newcomers = await dao.getNewMembersCount(startOfMonth);
    final men = await dao.getGenderCount('M');
    final women = await dao.getGenderCount('F');

    // Extract unique groups
    final groups = members.map((m) => m.groupName).toSet().toList();
    groups.sort();

    setState(() {
      _members = members;
      _filteredMembers = members;
      _totalMembers = total;
      _newMembersMonth = newcomers;
      _menCount = men;
      _womenCount = women;
      _allGroups = ["Tous les Groupes", ...groups];
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredMembers = _members.where((member) {
        // Search Filter
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          matchesSearch =
              member.fullName.toLowerCase().contains(query) ||
              member.phone.toLowerCase().contains(query) ||
              member.groupName.toLowerCase().contains(query);
        }

        // Group Filter
        bool matchesGroup = true;
        if (_selectedGroup != "Tous les Groupes") {
          matchesGroup = member.groupName == _selectedGroup;
        }

        // Status Filter
        bool matchesStatus = true;
        if (_selectedStatus != "Tous les Statuts") {
          matchesStatus = member.memberStatus == _selectedStatus;
        }

        return matchesSearch && matchesGroup && matchesStatus;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceHighlightColor,
      body: SingleChildScrollView(
        controller: _verticalController,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildFiltersAndActions(),
            const SizedBox(height: 24),
            _buildMembersTable(),
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
              "Répertoire des Membres",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Gérez les fidèles, leurs groupes et leur engagement",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(Icons.print_rounded, "Imprimer Tout", () {
              CardPdfService().generateAllMemberCards(_filteredMembers);
            }),
            const SizedBox(width: 16),
            _buildHeaderAction(Icons.download_rounded, "Exporter", () {
              CardPdfService().exportMembersList(_filteredMembers);
            }),
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
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: context.subtitleColor,
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
          _isLoading ? "..." : _totalMembers.toString(),
          Icons.people_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          "Nouveaux (Mois)",
          _isLoading ? "..." : "+ ${_newMembersMonth}",
          Icons.trending_up_rounded,
          Colors.green,
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          "Hommes",
          _isLoading ? "..." : _menCount.toString(),
          Icons.male_rounded,
          Colors.indigo,
        ),
        const SizedBox(width: 24),
        _buildStatItem(
          "Femmes",
          _isLoading ? "..." : _womenCount.toString(),
          Icons.female_rounded,
          Colors.pink,
        ),
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
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
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
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
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
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: "Rechercher par nom, téléphone ou groupe...",
                hintStyle: TextStyle(color: context.iconColor),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: context.iconColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdownFilter(_selectedGroup, _allGroups, (val) {
          setState(() {
            _selectedGroup = val!;
            _applyFilters();
          });
        }),
        const SizedBox(width: 12),
        _buildDropdownFilter(
          _selectedStatus,
          ["Tous les Statuts", "Actif", "Inactif"],
          (val) {
            setState(() {
              _selectedStatus = val!;
              _applyFilters();
            });
          },
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            setState(() {
              _searchController.clear();
              _searchQuery = "";
              _selectedGroup = "Tous les Groupes";
              _selectedStatus = "Tous les Statuts";
              _applyFilters();
            });
          },
          icon: const Icon(Icons.refresh_rounded),
          tooltip: "Réinitialiser les filtres",
          style: IconButton.styleFrom(
            backgroundColor: context.surfaceColor,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.borderColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: context.surfaceColor,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 14,
                  fontWeight: item == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMembersTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredMembers.isEmpty) {
      return const Center(child: Text("Aucun membre trouvé."));
    }

    return MembersTable(
      members: _filteredMembers,
      onView: _showMemberDetails,
      onEdit: (member) => _showAddMemberForm(member: member),
      onDelete: _deleteMember,
      onPrint: (member) => CardPdfService().generateMemberCard(member),
      horizontalController: _horizontalController,
    );
  }

  void _showAddMemberForm({MemberModel? member}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MemberFormDialog(
        member: member,
        onSaved: () {
          _loadMembers();
        },
      ),
    );

    if (result == true) {
      _loadMembers();
    }
  }

  void _showMemberDetails(MemberModel member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailsDialog(
        member: member,
        onEdit: () {
          Navigator.pop(context);
          _showAddMemberForm(member: member);
        },
      ),
    );
  }

  Future<void> _deleteMember(MemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer ${member.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final MemberDao dao = await DatabaseHelper().memberDao;
      await dao.deleteMember(member.id!);
      _loadMembers();
    }
  }
}
