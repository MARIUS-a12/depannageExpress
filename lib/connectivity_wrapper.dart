import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dannexpress/connectivity_service.dart';
import 'package:dannexpress/no_connection.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  late StreamSubscription<bool> _subscription;
 
  @override
  void initState() {
    super.initState();
    // Vérification initiale
    ConnectivityService.isConnected().then(
      (connected) {
        if (mounted) setState(() => _isConnected = connected);
      },
    );
    // Écoute en temps réel
    _subscription = ConnectivityService.connectionStream.listen(
      (connected) {
        if (mounted) setState(() => _isConnected = connected);
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return NoConnectionPage(
        onRetry: () async {
          final connected = await ConnectivityService.isConnected();
          if (mounted) setState(() => _isConnected = connected);
        },
      );
    }
    return widget.child;
  }
}