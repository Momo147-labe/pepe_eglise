import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/finance_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';

class TransactionFormDialog extends StatefulWidget {
  final bool isExpense;
  final VoidCallback onSaved;

  const TransactionFormDialog({
    super.key,
    required this.isExpense,
    required this.onSaved,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final entityCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  
  late String selectedType;
  int? selectedMemberId;
  bool isManualEntry = false;
  List<MemberModel> members = [];
  bool isLoading = true;

  final List<String> incomeTypes = ["Dîme", "Offrande", "Don", "Projet"];

  @override
  void initState() {
    super.initState();
    selectedType = widget.isExpense ? "Dépense" : "Dîme";
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final memberDao = await DatabaseHelper().memberDao;
    final list = await memberDao.getAllMembers();
    if (mounted) {
      setState(() {
        members = list;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Dialog(
        backgroundColor: context.surfaceColor,
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isExpense
                    ? "Nouvelle Dépense"
                    : "Nouvelle Entrée Financière",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 24),

              _buildFormLabel("Type de Transaction"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.surfaceHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    dropdownColor: context.surfaceColor,
                    items: (widget.isExpense ? ["Dépense"] : incomeTypes)
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              style: TextStyle(color: context.textColor),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildFormLabel("Source / Bénéficiaire"),
              if (!isManualEntry)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.surfaceHighlightColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedMemberId,
                      hint: Text(
                        "Sélectionner un membre (optionnel)",
                        style: TextStyle(color: context.subtitleColor),
                      ),
                      isExpanded: true,
                      dropdownColor: context.surfaceColor,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            "Saisir manuellement...",
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                        ...members.map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              m.fullName,
                              style: TextStyle(color: context.textColor),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) {
                          setState(() => isManualEntry = true);
                        } else {
                          setState(() {
                            selectedMemberId = val;
                            final m = members.firstWhere(
                              (e) => e.id == val,
                            );
                            entityCtrl.text = m.fullName;
                          });
                        }
                      },
                    ),
                  ),
                ),
              if (isManualEntry)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.surfaceHighlightColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: TextField(
                          controller: entityCtrl,
                          autofocus: true,
                          style: TextStyle(color: context.textColor),
                          decoration: const InputDecoration(
                            hintText: "Nom du membre ou tiers",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => setState(() {
                        isManualEntry = false;
                        selectedMemberId = null;
                        entityCtrl.clear();
                      }),
                      icon: const Icon(Icons.list_alt_rounded),
                      tooltip: "Choisir un membre enregistré",
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              _buildFormLabel("Montant (GNF)"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.surfaceHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.textColor),
                  decoration: const InputDecoration(
                    hintText: "Ex: 150000",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildFormLabel("Description / Motif"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.surfaceHighlightColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: TextStyle(color: context.textColor),
                  decoration: const InputDecoration(
                    hintText: "Détail de la transaction...",
                    border: InputBorder.none,
                  ),
                ),
              ),
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
                    onPressed: () async {
                      if (amountCtrl.text.isEmpty) return;
                      final dao = await DatabaseHelper().financeDao;
                      final transaction = FinanceModel(
                        date: DateTime.now().toString().split(' ').first,
                        entity: entityCtrl.text.isNotEmpty
                            ? entityCtrl.text
                            : 'Anonyme',
                        amount: '${amountCtrl.text} GNF',
                        type: selectedType,
                        description: descCtrl.text,
                        memberId: selectedMemberId,
                      );
                      await dao.insertTransaction(transaction);
                      widget.onSaved();
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isExpense
                          ? Colors.redAccent
                          : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isExpense
                          ? "Enregistrer la dépense"
                          : "Enregistrer la transaction",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: context.subtitleColor,
        ),
      ),
    );
  }
}
