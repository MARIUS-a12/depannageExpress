import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:dannexpress/connectivity_wrapper.dart';
import 'package:dannexpress/formulaire.dart';

class Apropos extends StatelessWidget {
  const Apropos({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        appBar: const MyAppBar(
          title: 'À propos',
          showBack: true,
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF21405F), Color.fromARGB(255, 32, 101, 117)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MES-Afrique',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Votre partenaire de confiance pour la maintenance et les services techniques en Afrique.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Qui sommes-nous
              _SectionCard(
                icon: Icons.business_rounded,
                iconColor: const Color(0xFF21405F),
                title: 'Qui sommes-nous ?',
                child: const Text(
                  'Nous sommes une entreprise spécialisée dans la maintenance automobile, la maintenance industrielle, les travaux de bâtiment (BT), ainsi que les installations électriques, les caméras de surveillance et les panneaux solaires. Nous accompagnons particuliers et entreprises avec des solutions fiables, modernes et durables.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 7, 7, 8),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Mission
              _SectionCard(
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFF6dd5ed),
                title: 'Notre mission',
                child: const Text(
                  'Notre mission est de fournir des services de qualité, rapides et sécurisés dans tous nos domaines d\'intervention, tout en garantissant la satisfaction de nos clients et la durabilité des installations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 7, 7, 8),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Services
              _SectionCard(
                icon: Icons.build_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Nos services',
                child: Column(
                  children: [
                    _ServiceItem(icon: '🔧', text: 'Maintenance automobile'),
                    _ServiceItem(icon: '🏭', text: 'Maintenance industrielle'),
                    _ServiceItem(icon: '🏗️', text: 'Travaux de bâtiment (BT)'),
                    _ServiceItem(icon: '⚡', text: 'Électricité générale'),
                    _ServiceItem(icon: '📹', text: 'Installation de caméras de surveillance'),
                    _ServiceItem(icon: '☀️', text: 'Installation de panneaux solaires', isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pourquoi nous choisir
              _SectionCard(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Pourquoi nous choisir ?',
                child: Column(
                  children: [
                    _AvantageItem(text: 'Équipe qualifiée et expérimentée'),
                    _AvantageItem(text: 'Intervention rapide et efficace'),
                    _AvantageItem(text: 'Utilisation de matériel professionnel'),
                    _AvantageItem(text: 'Respect des normes de sécurité'),
                    _AvantageItem(text: 'Service client réactif et à l\'écoute', isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Valeurs
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF21405F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: Color(0xFF6dd5ed), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Nos valeurs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nous plaçons la qualité, la sécurité, la transparence et la satisfaction client au cœur de toutes nos actions.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Qualité', 'Sécurité', 'Transparence', 'Satisfaction']
                          .map((v) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Text(
                                  v,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton Contact
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Formulaire()),
                    );
                  },
                  icon: const Icon(Icons.contact_mail_rounded, color: Colors.white),
                  label: const Text(
                    'Contactez-nous',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF21405F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2B3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String icon;
  final String text;
  final bool isLast;

  const _ServiceItem({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}

class _AvantageItem extends StatelessWidget {
  final String text;
  final bool isLast;

  const _AvantageItem({
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}