import 'dart:io' show File;
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:flutter/material.dart';

class MembersTable extends StatelessWidget {
  final List<MemberModel> members;
  final Function(MemberModel) onView;
  final Function(MemberModel) onEdit;
  final Function(MemberModel) onDelete;
  final Function(MemberModel) onPrint;
  final ScrollController horizontalController;

  const MembersTable({
    super.key,
    required this.members,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onPrint,
    required this.horizontalController,
  });

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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        notificationPredicate: (notification) => notification.depth == 0,
        child: SingleChildScrollView(
          controller: horizontalController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              context.surfaceHighlightColor,
            ),
            dataRowMaxHeight: 80,
            dividerThickness: 1,
            horizontalMargin: 24,
            columnSpacing: 40,
            columns: [
              DataColumn(
                label: Text(
                  "MEMBRE",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "SEXE",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "AGE",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "LIEU NAISSANCE",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "QUARTIER",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "CONTACT",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "GROUPE",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "ENFANTS",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "SITUATION",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "STATUT",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "ACTIONS",
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            rows: members.map((member) {
              Color statusColor = member.memberStatus.toLowerCase() == 'actif'
                  ? Colors.green
                  : Colors.red;

              return _buildMemberRow(context, member, statusColor);
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildMemberRow(
    BuildContext context,
    MemberModel member,
    Color statusColor,
  ) {
    final age = _calculateAge(member.birthDate);

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 250,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
                  backgroundImage: member.imagePath != null
                      ? FileImage(File(member.imagePath!))
                      : null,
                  child: member.imagePath == null
                      ? Text(
                          member.fullName.isNotEmpty ? member.fullName[0] : "?",
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Adhésion: ${member.joiningYear ?? member.joinedAt.substring(0, 4)}",
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (member.gender == 'M' ? Colors.indigo : Colors.pink)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.gender,
              style: TextStyle(
                color: member.gender == 'M' ? Colors.indigo : Colors.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            age != null ? "$age ans" : "-",
            style: TextStyle(color: context.textColor),
          ),
        ),
        DataCell(
          Text(
            member.birthPlace ?? "-",
            style: TextStyle(color: context.textColor),
          ),
        ),
        DataCell(
          Text(
            member.quartier ?? "-",
            style: TextStyle(color: context.textColor),
          ),
        ),
        DataCell(
          Text(member.phone, style: TextStyle(color: context.textColor)),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.groupName,
              style: TextStyle(
                color: context.isDarkMode ? Colors.blue[200] : Colors.blue[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            member.childrenCount == null || member.childrenCount == 0
                ? "Pas d'enfant"
                : member.childrenCount.toString(),
            style: TextStyle(color: context.textColor),
          ),
        ),
        DataCell(
          Text(
            member.maritalStatus,
            style: TextStyle(color: context.textColor),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.memberStatus,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 20),
                onPressed: () => onView(member),
                color: context.isDarkMode ? Colors.blue[300] : Colors.blue[700],
                tooltip: "Détails",
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => onEdit(member),
                color: context.iconColor,
                tooltip: "Modifier",
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined, size: 20),
                onPressed: () => onPrint(member),
                color: AppColors.primaryOrange,
                tooltip: "Imprimer Carte",
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () => onDelete(member),
                color: context.isDarkMode ? Colors.red[300] : Colors.red[700],
                tooltip: "Supprimer",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
