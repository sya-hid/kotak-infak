import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class NetworkService {
  StreamController<NetworkStatus> controller = StreamController();
  NetworkService() {
    Connectivity().onConnectivityChanged.listen((event) {
      controller.add(_networkstatus(event));
    });
  }
  NetworkStatus _networkstatus(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi
        ? NetworkStatus.online
        : NetworkStatus.offline;
  }
}
