import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Vérification ponctuelle
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  // Stream temps réel
  static Stream<bool> get connectionStream {
    return Connectivity().onConnectivityChanged.map(
      (results) => results.first != ConnectivityResult.none,
    );
  }
}