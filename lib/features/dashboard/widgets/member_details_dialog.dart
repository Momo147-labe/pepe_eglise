import 'dart:io' show File;
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/models/member_model.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/databases/daos/finance_dao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eglise_labe/core/services/card_pdf_service.dart';

class MemberDetailsDialog extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onEdit;

  const MemberDetailsDialog({
    super.key,
    required this.member,
    required this.onEdit,
  });

  Future<List<dynamic>> _getMemberTransactions(String fullName) async {
    final FinanceDao dao = await DatabaseHelper().financeDao;
    return await dao.getTransactionsByEntity(fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 500,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(32),
          ),
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
                    Text(
                      "Profil du Membre",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
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
                        backgroundImage: member.imagePath != null
                            ? FileImage(File(member.imagePath!))
                            : null,
                        child: member.imagePath == null
                            ? Text(
                                member.fullName.isNotEmpty
                                    ? member.fullName[0]
                                    : "?",
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        member.fullName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: member.memberStatus.toLowerCase() == "actif"
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          member.memberStatus,
                          style: TextStyle(
                            color: member.memberStatus.toLowerCase() == "actif"
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildDetailSection(context, "Engagement & Famille", {
                  "Année Adhésion":
                      member.joiningYear?.toString() ??
                      member.joinedAt.substring(0, 4),
                  "Date d'inscription": member.joinedAt.substring(0, 10),
                  "Groupe": member.groupName,
                  "Situation": member.maritalStatus,
                  "Nombre d'enfants": member.childrenCount?.toString() ?? "0",
                }),
                const SizedBox(height: 24),
                Text(
                  "Historique Financier",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<dynamic>>(
                  future: _getMemberTransactions(member.fullName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Text(
                        "Erreur lors du chargement de l'historique.",
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    final transactions = snapshot.data ?? [];
                    if (transactions.isEmpty) {
                      return Text(
                        "Aucun historique financier trouvé.",
                        style: TextStyle(color: context.subtitleColor),
                      );
                    }

                    return Column(
                      children: transactions
                          .take(5)
                          .map(
                            (t) => _buildFinancialRow(
                              context,
                              "${t.type}${t.description.isNotEmpty ? ' - ${t.description}' : ''}",
                              "${t.amount} GNF",
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(DateTime.parse(t.date)),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        CardPdfService().generateMemberCard(member),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text("Imprimer la carte"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      side: BorderSide(
                        color: AppColors.primaryOrange.withOpacity(0.5),
                      ),
                      foregroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close details
                      onEdit(); // Show edit form
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surfaceHighlightColor,
                      foregroundColor: context.textColor,
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
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    Map<String, String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...items.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: TextStyle(color: context.subtitleColor)),
                Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(
    BuildContext context,
    String title,
    String amount,
    String date,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceHighlightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: context.subtitleColor),
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
