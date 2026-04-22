import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dannexpress/connectivity_wrapper.dart';

class Formulaire extends StatefulWidget {
  const Formulaire({super.key});

  @override
  State<Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends State<Formulaire> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  String? _typePanne;
  bool _localisationEnvoyee = false;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
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
                          TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              labelText: 'Nom *',
                              prefixIcon:
                                  const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Le nom est obligatoire';
                              if (value.length < 2)
                                return 'Le nom doit contenir au moins 2 caractères';
                              return null;
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
                          TextFormField(
                            controller: _emailController,
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
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!value.contains('@'))
                                  return 'Veuillez entrer une adresse email valide';
                              }
                              return null;
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