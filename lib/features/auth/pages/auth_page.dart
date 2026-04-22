import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
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
      backgroundColor: AppColors.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          return Row(
            children: [
              if (isDesktop)
                const Expanded(flex: 1, child: _HeaderIllustration()),
              Expanded(
                flex: 1,
                child: Container(
                  color: AppColors.backgroundDark,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.08,
                        vertical: 40,
                      ),
                      child: _PersistentAuthContent(
                        mode: _mode,
                        onModeChange: _setMode,
                      ),
                    ),
                  ),
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
        constraints: const BoxConstraints(maxWidth: 450),
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
        const Text("Connexion", style: _titleStyle),
        const SizedBox(height: 12),
        const Text(
          "Gestion administrative simplifiée pour votre église",
          style: _subtitleStyle,
        ),
        const SizedBox(height: 48),
        AuthTextField(label: "Adresse e-mail", controller: _emailController),
        const SizedBox(height: 28),
        AuthTextField(
          label: "Mot de passe",
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => widget.onModeChange(AuthMode.forgotPassword),
            child: const Text(
              "Mot de passe oublié ?",
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ),
        const SizedBox(height: 40),
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
                style: TextStyle(color: Colors.white60),
              ),
              GestureDetector(
                onTap: () => widget.onModeChange(AuthMode.register),
                child: const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
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
        const Text("Inscription", style: _titleStyle),
        const SizedBox(height: 12),
        const Text(
          "Créez votre compte pour commencer la gestion de votre église",
          style: _subtitleStyle,
        ),
        const SizedBox(height: 48),
        AuthTextField(label: "Nom complet", controller: _nameController),
        const SizedBox(height: 24),
        AuthTextField(label: "Adresse e-mail", controller: _emailController),
        const SizedBox(height: 24),
        AuthTextField(label: "Téléphone", controller: _phoneController),
        const SizedBox(height: 24),
        AuthTextField(
          label: "Mot de passe",
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 48),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthButton(text: "Créer le compte", onPressed: _handleRegister),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Déjà un compte ? ",
              style: TextStyle(color: Colors.white60),
            ),
            TextButton(
              onPressed: () => widget.onModeChange(AuthMode.login),
              child: const Text(
                "Se connecter",
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
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
        const Text("Récupération", style: _titleStyle),
        const SizedBox(height: 12),
        const Text(
          "Entrez votre e-mail et votre nouveau mot de passe pour le réinitialiser",
          style: _subtitleStyle,
        ),
        const SizedBox(height: 48),
        AuthTextField(label: "Adresse e-mail", controller: _emailController),
        const SizedBox(height: 24),
        AuthTextField(
          label: "Nouveau mot de passe",
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 40),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthButton(
                text: "Réinitialiser",
                onPressed: _handleResetPassword,
              ),
        const SizedBox(height: 32),
        Center(
          child: TextButton(
            onPressed: () => widget.onModeChange(AuthMode.login),
            child: const Text(
              "Retour à la connexion",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

const _titleStyle = TextStyle(
  color: Colors.white,
  fontSize: 48,
  fontWeight: FontWeight.bold,
  letterSpacing: -1,
  fontFamily: 'serif', // System serif fallback for slightly more classic look
);

const _subtitleStyle = TextStyle(
  color: Colors.white60,
  fontSize: 18,
  height: 1.5,
);

class _HeaderIllustration extends StatelessWidget {
  const _HeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/eglise.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: AppColors.backgroundDark.withOpacity(0.4)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.church_outlined,
                          size: 70,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Container(height: 1, width: 40, color: Colors.white24),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "ÉGLISE",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white70,
                                  letterSpacing: 6,
                                ),
                              ),
                              TextSpan(
                                text: "\nDE LABÉ",
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.2,
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
