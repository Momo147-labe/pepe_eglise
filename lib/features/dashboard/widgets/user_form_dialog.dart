import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/core/models/user_model.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onSaved;

  const UserFormDialog({super.key, this.user, required this.onSaved});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _selectedRole = 'admin';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fullNameCtrl.text = widget.user!.fullName;
      _emailCtrl.text = widget.user!.email ?? '';
      _phoneCtrl.text = widget.user!.phone ?? '';
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper();
      final userDao = await dbHelper.userDao;

      // Check email uniqueness on new user or if email changed
      if (widget.user == null || widget.user!.email != _emailCtrl.text) {
        final existing = await userDao.getUserByEmail(_emailCtrl.text);
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cette adresse e-mail est déjà utilisée")),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (widget.user == null) {
        // Create new user
        final newUser = UserModel(
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          role: _selectedRole,
          passwordHash: _hashPassword(_passwordCtrl.text),
        );
        await userDao.insertUser(newUser);
      } else {
        // Update user
        final updatedUser = UserModel(
          id: widget.user!.id,
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          role: _selectedRole,
          passwordHash: _passwordCtrl.text.isNotEmpty
              ? _hashPassword(_passwordCtrl.text)
              : widget.user!.passwordHash,
          avatar: widget.user!.avatar,
          isBlocked: widget.user!.isBlocked,
          status: widget.user!.status,
          loginCount: widget.user!.loginCount,
          lastLogin: widget.user!.lastLogin,
          lastActivity: widget.user!.lastActivity,
          createdAt: widget.user!.createdAt,
          updatedAt: DateTime.now(),
        );
        await userDao.updateUser(updatedUser);
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? "Modifier Collaborateur" : "Ajouter Collaborateur",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.iconColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel("Nom Complet *"),
                TextFormField(
                  controller: _fullNameCtrl,
                  style: TextStyle(color: context.textColor),
                  decoration: _buildInputDecoration("Ex: Jean Diallo"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Le nom complet est obligatoire";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel("Adresse E-mail *"),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: context.textColor),
                  decoration: _buildInputDecoration("Ex: jean.diallo@gmail.com"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "L'adresse e-mail est obligatoire";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return "Veuillez entrer un e-mail valide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel("Téléphone"),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: context.textColor),
                  decoration: _buildInputDecoration("Ex: +224 622 00 00 00"),
                ),
                const SizedBox(height: 16),
                _buildLabel("Rôle dans le système *"),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: context.surfaceColor,
                  style: TextStyle(color: context.textColor),
                  decoration: _buildInputDecoration(""),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                    DropdownMenuItem(value: 'moderateur', child: Text('Modérateur')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel(isEdit ? "Nouveau Mot de Passe (optionnel)" : "Mot de Passe *"),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: context.textColor),
                  decoration: _buildInputDecoration("Mot de passe").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: context.iconColor,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (!isEdit && (value == null || value.isEmpty)) {
                      return "Le mot de passe est obligatoire";
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return "Le mot de passe doit faire au moins 6 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: context.subtitleColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: const Text("Annuler"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEdit ? "Mettre à jour" : "Ajouter"),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: context.textColor,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.iconColor.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: context.surfaceHighlightColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
