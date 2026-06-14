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
  Map<int, String> memberMouvement = {}; // memberId -> nom du mouvement
  bool isLoading = true;

  final List<String> incomeTypes = ["Dîme", "Offrande", "Don", "Projet"];
  
  DateTime selectedDate = DateTime.now();
  String selectedPaymentMethod = "Espèces";
  final List<String> paymentMethods = [
    "Espèces",
    "Chèque",
    "Virement bancaire",
    "Orange Money",
    "Mobile Money"
  ];
  
  String? selectedCategory;
  final List<String> expenseCategories = [
    "Loyer",
    "Électricité/Eau",
    "Œuvres sociales",
    "Salaire/Honoraires",
    "Matériel",
    "Entretien",
    "Autre"
  ];

  @override
  void initState() {
    super.initState();
    selectedType = widget.isExpense ? "Dépense" : "Dîme";
    if (widget.isExpense) {
      selectedCategory = expenseCategories.first;
    }
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery('''
      SELECT m.*, mov.nom as mouvement_nom
      FROM members m
      LEFT JOIN mouvement_members mr ON m.id = mr.membre_id
      LEFT JOIN mouvements mov ON mr.mouvement_id = mov.id
      ORDER BY m.full_name ASC
    ''');
    final List<MemberModel> loadedMembers = [];
    final Map<int, String> loadedMouvement = {};
    for (final row in rows) {
      final member = MemberModel.fromMap(row);
      loadedMembers.add(member);
      if (member.id != null && row['mouvement_nom'] != null) {
        loadedMouvement[member.id!] = row['mouvement_nom'] as String;
      }
    }
    if (mounted) {
      setState(() {
        members = loadedMembers;
        memberMouvement = loadedMouvement;
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.isExpense ? Colors.redAccent : Colors.green,
              onPrimary: Colors.white,
              surface: context.surfaceColor,
              onSurface: context.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
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
        width: 600,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (widget.isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: widget.isExpense ? Colors.redAccent : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Date de la transaction"),
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: context.surfaceHighlightColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                                  style: TextStyle(color: context.textColor),
                                ),
                                Icon(Icons.calendar_today_rounded, size: 18, color: context.iconColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Mode de paiement"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.surfaceHighlightColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPaymentMethod,
                              isExpanded: true,
                              dropdownColor: context.surfaceColor,
                              items: paymentMethods
                                  .map(
                                    (pm) => DropdownMenuItem(
                                      value: pm,
                                      child: Text(
                                        pm,
                                        style: TextStyle(color: context.textColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedPaymentMethod = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Type de Transaction"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      ],
                    ),
                  ),
                  if (widget.isExpense) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel("Catégorie"),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.surfaceHighlightColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                isExpanded: true,
                                dropdownColor: context.surfaceColor,
                                items: expenseCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: TextStyle(color: context.textColor),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => selectedCategory = val!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              _buildFormLabel("Source / Bénéficiaire"),
              if (!isManualEntry)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  m.fullName,
                                  style: TextStyle(
                                    color: context.textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.phone_rounded, size: 11, color: context.subtitleColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      m.phone,
                                      style: TextStyle(color: context.subtitleColor, fontSize: 11),
                                    ),
                                    if (memberMouvement.containsKey(m.id)) ...
                                    [
                                      const SizedBox(width: 8),
                                      Icon(Icons.group_rounded, size: 11, color: AppColors.primaryOrange),
                                      const SizedBox(width: 4),
                                      Text(
                                        memberMouvement[m.id]!,
                                        style: TextStyle(
                                          color: AppColors.primaryOrange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
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
                      icon: Icon(Icons.list_alt_rounded, color: context.iconColor),
                      tooltip: "Choisir un membre enregistré",
                    ),
                  ],
                ),
              const SizedBox(height: 24),

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
                  style: TextStyle(
                    color: widget.isExpense ? Colors.redAccent : Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Ex: 150000",
                    hintStyle: TextStyle(color: context.subtitleColor.withValues(alpha: 0.5), fontSize: 16),
                    border: InputBorder.none,
                    icon: Icon(Icons.money_rounded, color: widget.isExpense ? Colors.redAccent : Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildFormLabel("Description / Motif"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: Text("Annuler", style: TextStyle(color: context.subtitleColor)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (amountCtrl.text.isEmpty) return;
                      final dao = await DatabaseHelper().financeDao;
                      final transaction = FinanceModel(
                        date: selectedDate.toIso8601String().split('T').first,
                        entity: entityCtrl.text.isNotEmpty
                            ? entityCtrl.text
                            : 'Anonyme',
                        amount: amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                        type: selectedType,
                        description: descCtrl.text,
                        memberId: selectedMemberId,
                        paymentMethod: selectedPaymentMethod,
                        category: widget.isExpense ? selectedCategory : null,
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: (widget.isExpense ? Colors.redAccent : Colors.green).withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.isExpense ? Icons.check_circle_outline_rounded : Icons.check_circle_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.isExpense
                              ? "Enregistrer la dépense"
                              : "Enregistrer la transaction",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 8, left: 4),
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
