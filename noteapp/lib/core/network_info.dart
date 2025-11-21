import 'package:connectivity_plus/connectivity_plus.dart';


class NetworkInfo {
  // static or singleton so you don't need to pass Connectivity() everywhere
  static Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
