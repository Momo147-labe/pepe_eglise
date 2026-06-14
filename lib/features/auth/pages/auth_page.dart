import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/features/auth/widgets/auth_text_field.dart';
import 'package:eglise_labe/features/auth/widgets/auth_button.dart';
import 'package:eglise_labe/features/dashboard/pages/main_layout.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';
import 'package:eglise_labe/core/models/user_model.dart';

enum AuthMode { login, register, forgotPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthMode _mode = AuthMode.login;

  void _setMode(AuthMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          return Row(
            children: [
              if (isDesktop)
                const Expanded(flex: 1, child: _HeaderIllustration()),
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    // Subtle glowing background orbs
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange.withValues(alpha: 0.12),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withValues(alpha: 0.08),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                    Container(
                      color: context.sidebarColor.withValues(alpha: 0.4),
                    ),
                    // Form Content
                    Positioned.fill(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.05,
                                vertical: 40,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 460),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 48,
                                ),
                                child: _PersistentAuthContent(
                                  mode: _mode,
                                  onModeChange: _setMode,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PersistentAuthContent extends StatelessWidget {
  final AuthMode mode;
  final Function(AuthMode) onModeChange;

  const _PersistentAuthContent({
    required this.mode,
    required this.onModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(mode),
        child: _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    switch (mode) {
      case AuthMode.login:
        return _LoginForm(onModeChange: onModeChange);
      case AuthMode.register:
        return _RegisterForm(onModeChange: onModeChange);
      case AuthMode.forgotPassword:
        return _ForgotPasswordForm(onModeChange: onModeChange);
    }
  }
}

class _LoginForm extends StatefulWidget {
  final Function(AuthMode) onModeChange;
  const _LoginForm({required this.onModeChange});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final userDao = await dbHelper.userDao;
      final user = await userDao.getUserByEmail(_emailController.text);

      if (user != null) {
        final hashedPassword = _hashPassword(_passwordController.text);

        if (user.passwordHash == hashedPassword) {
          if (_rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userEmail', _emailController.text);
          }

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mot de passe incorrect")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Utilisateur non trouvé")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientTitle("Connexion"),
        const SizedBox(height: 12),
        Text(
          "Gestion administrative simplifiée pour votre église",
          style: _getSubtitleStyle(context),
        ),
        const SizedBox(height: 40),
        AuthTextField(
          label: "Adresse e-mail",
          controller: _emailController,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          label: "Mot de passe",
          isPassword: true,
          controller: _passwordController,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                    activeColor: AppColors.primaryOrange,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Se souvenir",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
            TextButton(
              onPressed: () => widget.onModeChange(AuthMode.forgotPassword),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Mot de passe oublié ?",
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthButton(text: "Se connecter", onPressed: _handleLogin),
        const SizedBox(height: 32),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                "Nouveau ici ? ",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => widget.onModeChange(AuthMode.register),
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final Function(AuthMode) onModeChange;
  const _RegisterForm({required this.onModeChange});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final userDao = await dbHelper.userDao;

      // Check if user already exists
      final existingUser = await userDao.getUserByEmail(_emailController.text);
      if (existingUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cette adresse e-mail est déjà utilisée"),
          ),
        );
        return;
      }

      final user = UserModel(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        passwordHash: _hashPassword(_passwordController.text),
        role: 'admin',
      );

      await userDao.insertUser(user);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès ! Veuillez vous connecter."),
          backgroundColor: Colors.green,
        ),
      );
      widget.onModeChange(AuthMode.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur d'inscription: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientTitle("Inscription"),
        const SizedBox(height: 12),
        Text(
          "Créez votre compte pour commencer la gestion de votre église",
          style: _getSubtitleStyle(context),
        ),
        const SizedBox(height: 32),
        AuthTextField(
          label: "Nom complet",
          controller: _nameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: "Adresse e-mail",
          controller: _emailController,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: "Téléphone",
          controller: _phoneController,
          prefixIcon: Icons.phone_android_rounded,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: "Mot de passe",
          isPassword: true,
          controller: _passwordController,
          prefixIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 36),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthButton(text: "Créer le compte", onPressed: _handleRegister),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Déjà un compte ? ",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => widget.onModeChange(AuthMode.login),
              child: const Text(
                "Se connecter",
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  final Function(AuthMode) onModeChange;
  const _ForgotPasswordForm({required this.onModeChange});

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> _handleResetPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final userDao = await dbHelper.userDao;

      final existingUser = await userDao.getUserByEmail(_emailController.text);
      if (existingUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucun compte avec cette adresse e-mail"),
          ),
        );
        return;
      }

      final hashedPassword = _hashPassword(_passwordController.text);
      await userDao.updatePasswordByEmail(
        _emailController.text,
        hashedPassword,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mot de passe mis à jour avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      widget.onModeChange(AuthMode.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientTitle("Récupération"),
        const SizedBox(height: 12),
        Text(
          "Entrez votre e-mail et votre nouveau mot de passe pour le réinitialiser",
          style: _getSubtitleStyle(context),
        ),
        const SizedBox(height: 36),
        AuthTextField(
          label: "Adresse e-mail",
          controller: _emailController,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: "Nouveau mot de passe",
          isPassword: true,
          controller: _passwordController,
          prefixIcon: Icons.lock_reset_rounded,
        ),
        const SizedBox(height: 32),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthButton(
                text: "Réinitialiser",
                onPressed: _handleResetPassword,
              ),
        const SizedBox(height: 28),
        Center(
          child: TextButton(
            onPressed: () => widget.onModeChange(AuthMode.login),
            child: const Text(
              "Retour à la connexion",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildGradientTitle(String text) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Colors.white, Color(0xFFFFB366)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 38,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    ),
  );
}

TextStyle _getSubtitleStyle(BuildContext context) =>
    const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5);

class _HeaderIllustration extends StatefulWidget {
  const _HeaderIllustration();

  @override
  State<_HeaderIllustration> createState() => _HeaderIllustrationState();
}

class _HeaderIllustrationState extends State<_HeaderIllustration> {
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _logoPath = prefs.getString('church_logo_path');
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomLogo = _logoPath != null && File(_logoPath!).existsSync();

    return Stack(
      children: [
        Container(
          color: AppColors.backgroundDark,
          child: const SizedBox.expand(
            child: Image(
              image: AssetImage('assets/eglise.jpeg'),
              fit: BoxFit.fitHeight,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(color: AppColors.backgroundDark.withValues(alpha: 0.45)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: hasCustomLogo
                              ? ClipOval(
                                  child: Image.file(
                                    File(_logoPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.church_outlined,
                                  size: 48,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 24),
                        Container(height: 1, width: 60, color: Colors.white24),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "PROTESTANTE",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                  letterSpacing: 6,
                                ),
                              ),
                              TextSpan(
                                text: "\nEVANGELIQUE DE LABE",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
