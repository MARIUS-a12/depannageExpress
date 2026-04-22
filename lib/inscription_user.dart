import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:dannexpress/connectivity_wrapper.dart';

class InscriptionUserPage extends StatefulWidget {
  const InscriptionUserPage({super.key});

  @override
  State<InscriptionUserPage> createState() => _InscriptionUserPageState();
}

class _InscriptionUserPageState extends State<InscriptionUserPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _numeroController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);
    try {
      // Pour l’instant, on valide uniquement les champs côté UI.
      // Tu pourras ensuite brancher ici Firestore/FirebaseAuth selon ton besoin.
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Inscription enregistrée'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        appBar: const MyAppBar(title: 'Inscription', showBack: true),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF21405F), Color.fromARGB(221, 33, 64, 95)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person_add_alt_1_rounded,
                                  color: Colors.blue, size: 26),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Créer un compte',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Renseigne tes informations pour continuer.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nomController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Nom *',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Le nom est obligatoire';
                              if (v.length < 2) {
                                return 'Le nom doit contenir au moins 2 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _numeroController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Numéro *',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              final v = (value ?? '').replaceAll(' ', '').trim();
                              if (v.isEmpty) return 'Le numéro est obligatoire';
                              if (v.length < 8) {
                                return 'Le numéro doit contenir au moins 8 chiffres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe *',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                }),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onFieldSubmitted: (_) => _isSubmitting ? null : _submit(),
                            validator: (value) {
                              final v = value ?? '';
                              if (v.isEmpty) return 'Le mot de passe est obligatoire';
                              if (v.length < 6) {
                                return 'Au moins 6 caractères requis';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF21405F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _isSubmitting ? null : _submit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Créer mon compte',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
