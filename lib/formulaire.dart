import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dannexpress/connectivity_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Formulaire extends StatefulWidget {
  const Formulaire({super.key});

  @override
  State<Formulaire> createState() => _FormulaireState();
}

class _SavedIdentity {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;

  const _SavedIdentity({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
  });

  String get label => [nom, prenom].where((s) => s.trim().isNotEmpty).join(' ');

  String get normalizedKey =>
      '${nom.trim().toLowerCase()}|${prenom.trim().toLowerCase()}|${telephone.trim().toLowerCase()}|${email.trim().toLowerCase()}';

  Map<String, String> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
      };
}

class _FormulaireState extends State<Formulaire> {
  static const _kKnownEmailsKey = 'login.known_emails';
  static const _kSavedIdentitiesKey = 'formulaire.saved_identities';
  static const _kMaxSavedIdentities = 20;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  final _nomFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  String? _typePanne;
  bool _localisationEnvoyee = false;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;
  List<String> _knownEmails = const [];
  List<_SavedIdentity> _savedIdentities = const [];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();

    _chargerEmailsConnus();
    _chargerIdentitesSauvegardees();
  }

  Future<void> _chargerEmailsConnus() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList(_kKnownEmailsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _knownEmails = emails);
  }

  Future<void> _chargerIdentitesSauvegardees() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSavedIdentitiesKey) ?? const <String>[];
    final parsed = <_SavedIdentity>[];
    for (final s in raw) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        parsed.add(
          _SavedIdentity(
            nom: (m['nom'] as String? ?? '').trim(),
            prenom: (m['prenom'] as String? ?? '').trim(),
            email: (m['email'] as String? ?? '').trim(),
            telephone: (m['telephone'] as String? ?? '').trim(),
          ),
        );
      } catch (_) {
        // ignore corrupted entry
      }
    }
    if (!mounted) return;
    setState(() {
      _savedIdentities = parsed.where((p) => p.nom.isNotEmpty).toList();
    });
  }

  Future<void> _rememberIdentityProfile() async {
    final profile = _SavedIdentity(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _phoneController.text.trim(),
    );
    if (profile.nom.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final currentRaw =
        prefs.getStringList(_kSavedIdentitiesKey) ?? <String>[];

    final normalizedKey = profile.normalizedKey;
    final kept = <String>[];
    for (final s in currentRaw) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        final existing = _SavedIdentity(
          nom: (m['nom'] as String? ?? '').trim(),
          prenom: (m['prenom'] as String? ?? '').trim(),
          email: (m['email'] as String? ?? '').trim(),
          telephone: (m['telephone'] as String? ?? '').trim(),
        );
        if (existing.normalizedKey != normalizedKey) kept.add(s);
      } catch (_) {
        // ignore
      }
    }

    final encoded = jsonEncode(profile.toJson());
    kept.insert(0, encoded);
    if (kept.length > _kMaxSavedIdentities) {
      kept.removeRange(_kMaxSavedIdentities, kept.length);
    }
    await prefs.setStringList(_kSavedIdentitiesKey, kept);

    if (!mounted) return;
    setState(() {
      final next = _savedIdentities
          .where((p) => p.normalizedKey != normalizedKey)
          .toList();
      next.insert(0, profile);
      _savedIdentities = next;
    });
  }

  @override
  void dispose() {
    _nomFocusNode.dispose();
    _emailFocusNode.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _obtenirLocalisation() async {
    bool serviceActive = await Geolocator.isLocationServiceEnabled();
    if (!serviceActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Redirection vers les paramètres...'),
          duration: Duration(seconds: 2),
        ),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('⚠️ Permission de localisation refusée')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Redirection vers les paramètres...'),
          duration: Duration(seconds: 2),
        ),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _localisationEnvoyee = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Localisation enregistrée'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _envoyerFormulaire() async {
    if (_formKey.currentState!.validate() &&
        _localisationEnvoyee &&
        _typePanne != null) {
      setState(() => _isLoading = true);

      try {
        await _rememberIdentityProfile();
        await FirebaseFirestore.instance.collection('pannes').add({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'email': _emailController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'typePanne': _typePanne,
          'description': _descriptionController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
          'statut': 'en attente',
          'dateEnvoi': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Demande envoyée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _formKey.currentState!.reset();
        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _phoneController.clear();
        _descriptionController.clear();
        setState(() {
          _typePanne = null;
          _localisationEnvoyee = false;
          _latitude = null;
          _longitude = null;
          _isLoading = false;
        });

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (!_localisationEnvoyee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez envoyer votre localisation'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (_typePanne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez sélectionner un type de panne'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        appBar: const MyAppBar(title: 'Contact', showBack: true),
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
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.support_agent,
                                  color: Colors.blue, size: 26),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Formulaire de contact',
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
                            'Merci de renseigner les informations ci-dessous afin de faciliter votre prise en charge.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Informations personnelles',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return RawAutocomplete<_SavedIdentity>(
                                textEditingController: _nomController,
                                focusNode: _nomFocusNode,
                                optionsBuilder: (textEditingValue) {
                                  final q = textEditingValue.text
                                      .trim()
                                      .toLowerCase();
                                  if (q.isEmpty) {
                                    return const Iterable<_SavedIdentity>.empty();
                                  }
                                  return _savedIdentities.where(
                                    (p) => p.nom.toLowerCase().startsWith(q),
                                  );
                                },
                                displayStringForOption: (o) => o.label,
                                onSelected: (selection) {
                                  _nomController.text = selection.nom;
                                  _prenomController.text = selection.prenom;
                                  _emailController.text = selection.email;
                                  _phoneController.text = selection.telephone;
                                  _nomFocusNode.unfocus();
                                },
                                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
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
                                    onFieldSubmitted: (_) => onFieldSubmitted(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Le nom est obligatoire';
                                      }
                                      if (value.length < 2) {
                                        return 'Le nom doit contenir au moins 2 caractères';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          constraints: const BoxConstraints(maxHeight: 240),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.black.withOpacity(0.08),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
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
                                                        color: Color(0xFF64748B),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              option.label,
                                                              style: const TextStyle(
                                                                color: Color(0xFF0F172A),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            if (option.telephone.isNotEmpty || option.email.isNotEmpty)
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2),
                                                                child: Text(
                                                                  [
                                                                    if (option.telephone.isNotEmpty) option.telephone,
                                                                    if (option.email.isNotEmpty) option.email,
                                                                  ].join(' · '),
                                                                  style: const TextStyle(
                                                                    color: Color(0xFF64748B),
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
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
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                              labelText: 'Prénom *',
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Le prénom est obligatoire';
                              if (value.length < 2)
                                return 'Le prénom doit contenir au moins 2 caractères';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
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
                                decoration: InputDecoration(
                                  labelText: 'Adresse mail',
                                  prefixIcon: const Icon(Icons.email),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F7FB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onFieldSubmitted: (_) => onFieldSubmitted(),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!value.contains('@')) {
                                      return 'Veuillez entrer une adresse email valide';
                                    }
                                  }
                                  return null;
                                },
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Contact téléphone *',
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Le téléphone est obligatoire';
                              if (value.length < 8)
                                return 'Le numéro doit contenir au moins 8 chiffres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Détails de la panne',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _typePanne,
                            decoration: InputDecoration(
                              labelText: 'Type de panne *',
                              prefixIcon: const Icon(Icons.build),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'electricite',
                                  child: Text('Electricité')),
                              DropdownMenuItem(
                                  value: 'mecanique',
                                  child: Text('Mécanique')),
                              DropdownMenuItem(
                                  value: 'voiture',
                                  child: Text('Voiture')),
                            ],
                            onChanged: (value) =>
                                setState(() => _typePanne = value),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez sélectionner un type de panne';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Description de la panne',
                              alignLabelWithHint: true,
                              prefixIcon:
                                  const Icon(Icons.description),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                _localisationEnvoyee
                                    ? Icons.location_on
                                    : Icons.location_on_outlined,
                                color: _localisationEnvoyee
                                    ? Colors.white
                                    : null,
                              ),
                              onPressed: _obtenirLocalisation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _localisationEnvoyee
                                    ? Colors.green
                                    : Colors.blue.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: Text(
                                _localisationEnvoyee
                                    ? 'Localisation enregistrée ✓'
                                    : 'Envoyer ma localisation *',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : _envoyerFormulaire,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Envoyer ma demande',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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