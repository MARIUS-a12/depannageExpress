import 'package:flutter/material.dart';
import 'package:dannexpress/apropos.dart';
import 'package:dannexpress/formulaire.dart';
import 'package:dannexpress/partenaire.dart';
import 'package:dannexpress/login.dart';
import 'package:dannexpress/inscription_user.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  int _selectedIndex = 0;
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleLogoTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(100, 100, 165, 187), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: GestureDetector(
          onTap: _handleLogoTap,
          child: Image.asset(
            'issets/images/logo.png',
            height: 40,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 1),
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              color: const Color.fromARGB(255, 6, 6, 6),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.login_outlined),
            color: const Color.fromARGB(255, 6, 6, 6),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InscriptionUserPage(),
                ),
              );
            },
            tooltip: 'Connexion',
          ),
        ],
        
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carousel
            const SizedBox(height: 16),
            const CarouselBanner(),
            const SizedBox(height: 24),

            // Section titre avec ligne décorative
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6dd5ed), Color(0xFF21405F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Bienvenue sur DepannExpress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Sous-titre
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Vos solutions de dépannage partout en Cote d\'Ivoire ',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B8FA1), 
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cards
            const Cards(),

            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Apropos()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Formulaire()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PartenairePage(),
                ),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF21405F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'À propos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Dépanne',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: 'Partenaires',
          ),
        ],
      ),
    );
  }
}

// Carousel
class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final List<Map<String, String>> _slides = const [
    {
      'image': 'issets/images/electricite2.webp',
      'label': 'Électricité',
    },
    {
      'image': 'issets/images/electricite.webp',
      'label': 'Dépannage rapide',
    },
    {
      'image': 'issets/images/electro-mecanique2.jpg',
      'label': 'Électromécanique',
    },
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || _slides.isEmpty) return false;
      _currentPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _slides[index]['image']!,
                        fit: BoxFit.cover,
                      ),
                      // Dégradé bas
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Label
                      Positioned(
                        bottom: 14,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _slides[index]['label']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
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

        // Indicateurs de page
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6dd5ed)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// Cards
class Cards extends StatelessWidget {
  const Cards({super.key});

  final List<Map<String, String>> items = const [
    {
      'picture': 'issets/images/electricite.webp',
      'title': 'Électricité',
      'description': 'Dépannage et maintenance électrique partout en cote d\'Ivoire.Vous avez un problème d\'électricité chez vous, dans vos services, n\'hesitez pas à nous contacter pour une intervention rapide et efficace dans un bref delai.',
    },
    {
      'picture': 'issets/images/voiture.jpg',
      'title': 'Mécanique',
      'description': 'Depannage de véhicule. Nos experts en électro-mécanique sont disponible à vous dépanner partout où vous vous trouver. N\'hister par à nous contacter pour une intervention rapide et efficace sur votre véhicule.',
    },
    {
      'picture': 'issets/images/moteur-usine.jpg',
      'title': 'Industrie',
      'description': 'Vous avez besoin d\'une intervention ou d\'installer du matériel industrielle! Nous disposons d\'une équipe technique qualifié pour résoudre tout vos problèmes mécaniques de façon efficace et rapide..',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF21405F).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image avec overlay
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        item['picture']!,
                        height: screenHeight * 0.23,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      // Dégradé haut gauche
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Badge titre
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21405F).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6dd5ed), Color(0xFF21405F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3748),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF6dd5ed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}