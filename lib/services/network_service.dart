// lib/services/network_service.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network connection types
enum NetworkConnectionType {
  wifi,
  mobile,
  ethernet,
  none,
}

/// Network connection quality
enum NetworkQuality {
  good, // Fast connection
  poor, // Slow connection
  none, // No connection
}

/// Network information class
class NetworkInfo {
  final NetworkConnectionType connectionType;
  final NetworkQuality quality;
  final bool isConnected;
  final String displayName;
  final DateTime lastChecked;

  NetworkInfo({
    required this.connectionType,
    required this.quality,
    required this.isConnected,
    required this.displayName,
    required this.lastChecked,
  });

  @override
  String toString() {
    return 'NetworkInfo(type: $connectionType, quality: $quality, connected: $isConnected)';
  }
}

/// Service to handle network connectivity monitoring
class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;
  static StreamController<NetworkInfo>? _networkController;

  static NetworkInfo? _currentNetworkInfo;

  /// Initialize network monitoring
  static Future<void> initialize() async {
    _networkController = StreamController<NetworkInfo>.broadcast();
    await _startNetworkMonitoring();
  }

  /// Get current network information
  static NetworkInfo? get currentNetworkInfo => _currentNetworkInfo;

  /// Get network stream for real-time updates
  static Stream<NetworkInfo>? get networkStream => _networkController?.stream;

  /// Check current connectivity status
  static Future<NetworkInfo> checkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResults =
          await _connectivity.checkConnectivity();
      return await _processConnectivityResult(connectivityResults);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return _createNetworkInfo(
          NetworkConnectionType.none, NetworkQuality.none, false);
    }
  }

  /// Start monitoring network changes
  static Future<void> _startNetworkMonitoring() async {
    try {
      // Get initial connection status
      final initialInfo = await checkConnectivity();
      _currentNetworkInfo = initialInfo;
      _networkController?.add(initialInfo);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          final networkInfo = await _processConnectivityResult(results);
          _currentNetworkInfo = networkInfo;
          _networkController?.add(networkInfo);

          if (kDebugMode) {
            print('📡 Network changed: ${networkInfo.displayName}');
          }
        },
        onError: (error) {
          debugPrint('Network monitoring error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting network monitoring: $e');
    }
  }

  /// Process connectivity result and determine network quality
  static Future<NetworkInfo> _processConnectivityResult(
      List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return _createNetworkInfo(
          NetworkConnectionType.none, NetworkQuality.none, false);
    }

    // Get the primary connection type
    final primaryResult = results.first;
    NetworkConnectionType connectionType;

    switch (primaryResult) {
      case ConnectivityResult.wifi:
        connectionType = NetworkConnectionType.wifi;
        break;
      case ConnectivityResult.mobile:
        connectionType = NetworkConnectionType.mobile;
        break;
      case ConnectivityResult.ethernet:
        connectionType = NetworkConnectionType.ethernet;
        break;
      default:
        connectionType = NetworkConnectionType.none;
    }

    // Test actual internet connectivity
    final hasInternet = await _testInternetConnection();

    if (!hasInternet) {
      return _createNetworkInfo(connectionType, NetworkQuality.none, false);
    }

    // Test connection quality for connected networks
    final quality = await _testConnectionQuality();

    return _createNetworkInfo(connectionType, quality, true);
  }

  /// Test if we have actual internet access
  static Future<bool> _testInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Test connection quality by measuring response time
  static Future<NetworkQuality> _testConnectionQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Test with a lightweight endpoint
      final socket = await Socket.connect('8.8.8.8', 53,
          timeout: const Duration(seconds: 3));
      socket.destroy();

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (responseTime < 500) {
        return NetworkQuality.good;
      } else {
        return NetworkQuality.poor;
      }
    } catch (e) {
      return NetworkQuality.poor;
    }
  }

  /// Create network info object
  static NetworkInfo _createNetworkInfo(
      NetworkConnectionType type, NetworkQuality quality, bool isConnected) {
    String displayName;

    switch (type) {
      case NetworkConnectionType.wifi:
        displayName =
            quality == NetworkQuality.good ? 'WiFi (Fast)' : 'WiFi (Slow)';
        break;
      case NetworkConnectionType.mobile:
        displayName = quality == NetworkQuality.good
            ? 'Mobile Data (Fast)'
            : 'Mobile Data (Slow)';
        break;
      case NetworkConnectionType.ethernet:
        displayName = quality == NetworkQuality.good
            ? 'Ethernet (Fast)'
            : 'Ethernet (Slow)';
        break;
      case NetworkConnectionType.none:
        displayName = 'No Internet';
        break;
    }

    if (!isConnected && type != NetworkConnectionType.none) {
      displayName = '${_getConnectionTypeName(type)} (No Internet)';
    }

    return NetworkInfo(
      connectionType: type,
      quality: quality,
      isConnected: isConnected,
      displayName: displayName,
      lastChecked: DateTime.now(),
    );
  }

  /// Get connection type name
  static String _getConnectionTypeName(NetworkConnectionType type) {
    switch (type) {
      case NetworkConnectionType.wifi:
        return 'WiFi';
      case NetworkConnectionType.mobile:
        return 'Mobile Data';
      case NetworkConnectionType.ethernet:
        return 'Ethernet';
      case NetworkConnectionType.none:
        return 'No Connection';
    }
  }

  /// Force refresh network status
  static Future<void> refreshNetworkStatus() async {
    final networkInfo = await checkConnectivity();
    _currentNetworkInfo = networkInfo;
    _networkController?.add(networkInfo);
  }

  /// Check if connected to WiFi
  static bool get isConnectedToWiFi {
    return _currentNetworkInfo?.connectionType == NetworkConnectionType.wifi &&
        _currentNetworkInfo?.isConnected == true;
  }

  /// Check if connected to mobile data
  static bool get isConnectedToMobile {
    return _currentNetworkInfo?.connectionType ==
            NetworkConnectionType.mobile &&
        _currentNetworkInfo?.isConnected == true;
  }

  /// Check if has internet connection
  static bool get hasInternetConnection {
    return _currentNetworkInfo?.isConnected == true;
  }

  /// Get connection quality message
  static String getConnectionMessage() {
    if (_currentNetworkInfo == null) {
      return 'Checking connection...';
    }

    final info = _currentNetworkInfo!;

    if (!info.isConnected) {
      return 'No internet connection. Some features may be limited.';
    }

    switch (info.quality) {
      case NetworkQuality.good:
        return 'Connected to ${info.displayName}. All features available.';
      case NetworkQuality.poor:
        return 'Connected to ${info.displayName}. Some features may be slow.';
      case NetworkQuality.none:
        return 'Connected but no internet access. Check your connection.';
    }
  }

  /// Dispose network monitoring
  static void dispose() {
    _connectivitySubscription?.cancel();
    _networkController?.close();
  }
}
