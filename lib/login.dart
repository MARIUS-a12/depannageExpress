import 'package:flutter/material.dart';
import 'package:dannexpress/espaceAdmin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dannexpress/connectivity_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _knownEmails = const [];

  static const _kKnownEmailsKey = 'login.known_emails';
  static const _kMaxKnownEmails = 12;

  @override
  void initState() {
    super.initState();
    _loadKnownEmails();
  }

  Future<void> _loadKnownEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_kKnownEmailsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _knownEmails = emails);
  }

  Future<void> _rememberEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_kKnownEmailsKey) ?? <String>[];
    current.removeWhere((e) => e.trim().toLowerCase() == normalized);
    current.insert(0, normalized);
    if (current.length > _kMaxKnownEmails) {
      current.removeRange(_kMaxKnownEmails, current.length);
    }
    await prefs.setStringList(_kKnownEmailsKey, current);

    if (!mounted) return;
    setState(() => _knownEmails = current);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final uid = credential.user!.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!doc.exists || doc.data()?['role'] != 'admin') {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _errorMessage = "Accès refusé : vous n'êtes pas administrateur.";
            _isLoading = false;
          });
          return;
        }

        await _rememberEmail(_emailController.text);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _mapError(e.code);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Une erreur est survenue. Réessayez.";
          _isLoading = false;
        });
      }
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return "Email introuvable.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      case 'invalid-email':
        return "Email invalide.";
      case 'too-many-requests':
        return "Trop de tentatives. Réessayez plus tard.";
      default:
        return "Erreur de connexion.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F1E),
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(0.05),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF60A5FA),
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Bienvenue',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF9FAFB),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connectez-vous à votre espace admin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111827),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: const Color(0xFF1F2937)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adresse email',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RawAutocomplete<String>(
                              textEditingController: _emailController,
                              focusNode: _emailFocusNode,
                              optionsBuilder: (textEditingValue) {
                                final q =
                                    textEditingValue.text.trim().toLowerCase();
                                if (q.isEmpty) return const Iterable<String>.empty();
                                return _knownEmails.where(
                                  (e) => e.toLowerCase().startsWith(q),
                                );
                              },
                              displayStringForOption: (o) => o,
                              onSelected: (selection) {
                                _emailController.text = selection;
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                      color: Color(0xFFF9FAFB), fontSize: 14),
                                  decoration: _inputDecoration(
                                    hint: 'exemple@email.com',
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value!)) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => onFieldSubmitted(),
                                );
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      constraints: const BoxConstraints(maxHeight: 220),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF111827),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF1F2937),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.35),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final option = options.elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.history_rounded,
                                                    size: 16,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      option,
                                                      style: const TextStyle(
                                                        color: Color(0xFFF9FAFB),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Mot de passe',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                  color: Color(0xFFF9FAFB), fontSize: 14),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF6B7280),
                                    size: 18,
                                  ),
                                  onPressed: () => setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  }),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Veuillez entrer votre mot de passe';
                                }
                                if ((value?.length ?? 0) < 6) {
                                  return 'Au moins 6 caractères requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF3B82F6),
                                  disabledBackgroundColor:
                                      const Color(0xFF3B82F6)
                                          .withOpacity(0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Color(0xFFEF4444), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Accès réservé aux administrateurs',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0A0F1E),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2937)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2937)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle:
          const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
    );
  }
}