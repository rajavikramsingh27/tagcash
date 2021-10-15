import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityManager {
  /// Singleton
  static ConnectivityManager shared = ConnectivityManager._();

  /// Stream Controller
  // ignore: close_sinks
  final _streamController = BehaviorSubject<ConnectivityStatus>.seeded(ConnectivityStatus.Unknown);
  Stream<ConnectivityStatus> get connectionStatus => _streamController.stream;

  final Connectivity _connectivity = Connectivity();

  /// Private Constructor
  ConnectivityManager._() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) => _setConnectivityStatus(result));
  }

  /// Helper Method - [doInitialCheck]
  /// Get the connectivity status and set it to stream.
  void doInitialCheck() async {
    final result = await _connectivity.checkConnectivity();
    _setConnectivityStatus(result);
  }

  /// Helper Method - [_setConnectivityStatus]
  void _setConnectivityStatus(ConnectivityResult result) {
    if (result == null) return;
    final status = _getStatusFromResult(result);
    print("Connectivity Status : ${status.toString()}");
    _streamController.sink.add(status);
  }

  /// Helper Method - [getRawStatus]
  /// Return the Connectivity Status in Raw String format
  String getRawStatus() => _streamController.value.toString().split('.').last.toLowerCase();

  /// Helper Method - [isAvailable]
  /// Return true if network is available, Otherwise false.
  bool isAvailable() =>
      (_streamController.value == ConnectivityStatus.WiFi || _streamController.value == ConnectivityStatus.Cellular);

  /// Helper Method - [isNotAvailable]
  /// Return true if network is not available. Otherwise false.
  bool isNotAvailable() => !isAvailable();

  /// Helper Method - [_getStatusFromResult]
  /// Convert from the third part enum to our own enum
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.WiFi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}

/// Helper Enum - [ConnectivityStatus]
enum ConnectivityStatus { WiFi, Cellular, Offline, Unknown }
