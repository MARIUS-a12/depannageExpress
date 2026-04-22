import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dannexpress/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dannexpress/connectivity_wrapper.dart';

class _Colors {
  static const bg = Color(0xFF0A0F1E);
  static const card = Color(0xFF111827);
  static const cardBorder = Color(0xFF1F2937);
  static const accent = Color(0xFF3B82F6);
  static const accentLight = Color(0xFF60A5FA);
  static const orange = Color(0xFFF59E0B);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const chipBg = Color(0xFF1F2937);
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _filtreStatut = 'Tous';

  Future<void> _deconnecter() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _changerStatut(String docId, String nouveauStatut) async {
    await FirebaseFirestore.instance
        .collection('pannes')
        .doc(docId)
        .update({'statut': nouveauStatut});
  }

  Future<void> _supprimerPanne(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _Colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la suppression',
            style: TextStyle(color: _Colors.textPrimary)),
        content: const Text('Voulez-vous vraiment supprimer cette demande ?',
            style: TextStyle(color: _Colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: _Colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: _Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('pannes')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Demande supprimée'),
            backgroundColor: _Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _repondreAUnePanne(
      String docId, String userId, String userEmail) async {
    bool reponseEnvoyee = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => _RepondreDialog(
        onEnvoyer: (texte) async {
          await FirebaseFirestore.instance.collection('reponses').add({
            'panneId': docId,
            'userId': userId,
            'userEmail': userEmail,
            'reponse': texte,
            'dateEnvoi': Timestamp.now(),
            'adminId': FirebaseAuth.instance.currentUser?.uid,
          });
          reponseEnvoyee = true;
        },
      ),
    );

    if (reponseEnvoyee && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Réponse envoyée'),
          backgroundColor: _Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _appellerClient(String telephone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _Colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Appeler le client',
            style: TextStyle(color: _Colors.textPrimary)),
        content: Text('Appeler $telephone ?',
            style: const TextStyle(color: _Colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: _Colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Appeler',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final url = Uri(scheme: 'tel', path: telephone);
      if (await canLaunchUrl(url)) await launchUrl(url);
    }
  }

  Future<void> _envoyerEmail(String email) async {
    final url = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'en attente':
        return _Colors.orange;
      case 'en cours':
        return _Colors.accent;
      case 'résolu':
        return _Colors.green;
      default:
        return _Colors.textSecondary;
    }
  }

  PopupMenuItem<String> _buildMenuItem(String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(color: _Colors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: _Colors.bg,
        appBar: AppBar(
          backgroundColor: _Colors.card,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _Colors.cardBorder),
          ),
          title: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _Colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Espace Administration',
                style: TextStyle(
                  color: _Colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: _Colors.textSecondary),
              onPressed: _deconnecter,
              tooltip: 'Déconnexion',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filtres
            Container(
              color: _Colors.card,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Tous', 'en attente', 'en cours', 'résolu']
                      .map((statut) {
                    final isSelected = _filtreStatut == statut;
                    final color = statut == 'Tous'
                        ? _Colors.accent
                        : _couleurStatut(statut);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _filtreStatut = statut),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : _Colors.chipBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _Colors.cardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            statut,
                            style: TextStyle(
                              color: isSelected
                                  ? color
                                  : _Colors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Compteur
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pannes')
                  .orderBy('dateEnvoi', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final total = snapshot.data!.docs.length;
                final filtrees = _filtreStatut == 'Tous'
                    ? total
                    : snapshot.data!.docs
                        .where((d) => d['statut'] == _filtreStatut)
                        .length;
                return Container(
                  color: _Colors.bg,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '$filtrees demande${filtrees > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: _Colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_filtreStatut != 'Tous') ...[
                        const Text(' · ',
                            style:
                                TextStyle(color: _Colors.textSecondary)),
                        Text(
                          _filtreStatut,
                          style: TextStyle(
                            color: _couleurStatut(_filtreStatut),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            // Liste
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pannes')
                    .orderBy('dateEnvoi', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: _Colors.accent),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 64,
                              color: _Colors.textSecondary
                                  .withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune demande pour le moment',
                            style: TextStyle(
                                color: _Colors.textSecondary,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = _filtreStatut == 'Tous'
                      ? snapshot.data!.docs
                      : snapshot.data!.docs
                          .where((d) =>
                              d['statut'] == _filtreStatut)
                          .toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucune demande "$_filtreStatut"',
                        style: const TextStyle(
                            color: _Colors.textSecondary,
                            fontSize: 15),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final statut =
                          data['statut'] ?? 'en attente';
                      final statutColor = _couleurStatut(statut);
                      final date = data['dateEnvoi'] != null
                          ? (data['dateEnvoi'] as Timestamp)
                              .toDate()
                          : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _Colors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statutColor.withOpacity(0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${data['nom'] ?? ''} ${data['prenom'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _Colors.textPrimary,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statutColor
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statutColor
                                              .withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      statut,
                                      style: TextStyle(
                                        color: statutColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                  height: 1,
                                  color: _Colors.cardBorder),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _envoyerEmail(
                                    data['email'] ?? ''),
                                child: _InfoRow(
                                  icon: Icons.email_outlined,
                                  text: data['email'] ?? '-',
                                  color: _Colors.accentLight,
                                  underline: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _appellerClient(
                                    data['telephone'] ?? ''),
                                child: _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: data['telephone'] ?? '-',
                                  color: _Colors.green,
                                  underline: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.build_outlined,
                                text: data['typePanne'] ?? '-',
                                bold: true,
                                color: _Colors.orange,
                              ),
                              if (data['description'] != null &&
                                  data['description']
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.description_outlined,
                                  text: data['description'],
                                ),
                              ],
                              if (data['latitude'] != null) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final lat = data['latitude'];
                                    final lng = data['longitude'];
                                    final url = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode
                                              .externalApplication);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.location_on_rounded,
                                          size: 15,
                                          color: _Colors.accentLight),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Voir sur Google Maps',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _Colors.accentLight,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor: _Colors
                                              .accentLight
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (date != null) ...[
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.access_time_rounded,
                                  text:
                                      '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}',
                                  color: _Colors.textSecondary,
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) =>
                                          _changerStatut(
                                              doc.id, value),
                                      color: _Colors.card,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: _Colors.cardBorder),
                                      ),
                                      itemBuilder: (context) => [
                                        _buildMenuItem('en attente',
                                            _Colors.orange),
                                        _buildMenuItem(
                                            'en cours', _Colors.accent),
                                        _buildMenuItem(
                                            'résolu', _Colors.green),
                                      ],
                                      child: Container(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _Colors.accent
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: _Colors.accent
                                                  .withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.tune_rounded,
                                                size: 15,
                                                color:
                                                    _Colors.accentLight),
                                            SizedBox(width: 6),
                                            Text(
                                              'Changer statut',
                                              style: TextStyle(
                                                color: _Colors.accentLight,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionIconButton(
                                    icon: Icons.reply_rounded,
                                    color: _Colors.accent,
                                    onPressed: () => _repondreAUnePanne(
                                      doc.id,
                                      data['userId'] ?? '',
                                      data['email'] ?? '',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionIconButton(
                                    icon: Icons.delete_outline_rounded,
                                    color: _Colors.red,
                                    onPressed: () =>
                                        _supprimerPanne(doc.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepondreDialog extends StatefulWidget {
  final Future<void> Function(String texte) onEnvoyer;
  const _RepondreDialog({required this.onEnvoyer});

  @override
  State<_RepondreDialog> createState() => _RepondreDialogState();
}

class _RepondreDialogState extends State<_RepondreDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _Colors.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Répondre à la demande',
          style: TextStyle(color: _Colors.textPrimary)),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        style: const TextStyle(color: _Colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Écrivez votre réponse...',
          hintStyle: const TextStyle(color: _Colors.textSecondary),
          filled: true,
          fillColor: _Colors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _Colors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _Colors.accent),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Annuler',
              style: TextStyle(color: _Colors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_controller.text.isNotEmpty) {
                    setState(() => _loading = true);
                    await widget.onEnvoyer(_controller.text);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _Colors.accent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Envoyer',
                  style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  final bool underline;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.bold = false,
    this.underline = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? _Colors.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: textColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
              decoration: underline
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: textColor.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}