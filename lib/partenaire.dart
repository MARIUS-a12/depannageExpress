import 'package:flutter/material.dart';
import 'package:dannexpress/appBar.dart';
import 'package:dannexpress/connectivity_service.dart';
import 'package:dannexpress/no_connection.dart';

class PartenairePage extends StatefulWidget {
  const PartenairePage({super.key});

  @override
  State<PartenairePage> createState() => _PartenairePageState();
}

class _PartenairePageState extends State<PartenairePage> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnexion();
  }

  Future<void> _checkConnexion() async {
    final connected = await ConnectivityService.isConnected();
    setState(() => _isConnected = connected);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return NoConnectionPage(onRetry: _checkConnexion);
    }

    return Scaffold(
      appBar: const MyAppBar(
        title: 'Nos partenaires',
        showBack: true,
        showLogo: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Nos partenaires',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Aucun partenaire pour l\'instant',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}