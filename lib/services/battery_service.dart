// lib/services/battery_service.dart
import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

class BatteryService {
  static final Battery _battery = Battery();
  static StreamSubscription<BatteryState>? _batteryStateSubscription;
  static StreamController<BatteryInfo>? _batteryController;

  /// Initialize battery monitoring
  static Future<void> initialize() async {
    _batteryController = StreamController<BatteryInfo>.broadcast();
    await _startBatteryMonitoring();
  }

  /// Get current battery level (0-100)
  static Future<int> getCurrentBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      debugPrint('Error getting battery level: $e');
      return 100; // Default to 100% if error
    }
  }

  /// Get current battery state (charging, discharging, etc.)
  static Future<BatteryState> getCurrentBatteryState() async {
    try {
      return await _battery.batteryState;
    } catch (e) {
      debugPrint('Error getting battery state: $e');
      return BatteryState.unknown;
    }
  }

  /// Check if battery is low (less than specified percentage)
  static Future<bool> isBatteryLow({int threshold = 20}) async {
    final level = await getCurrentBatteryLevel();
    final state = await getCurrentBatteryState();

    // Don't warn if charging
    if (state == BatteryState.charging) {
      return false;
    }

    return level <= threshold;
  }

  /// Start monitoring battery changes
  static Future<void> _startBatteryMonitoring() async {
    try {
      // Listen to battery state changes
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
        (BatteryState state) async {
          final level = await getCurrentBatteryLevel();
          _batteryController?.add(BatteryInfo(
            level: level,
            state: state,
            isLow: level <= 20 && state != BatteryState.charging,
          ));
        },
      );

      // Get initial battery info
      final level = await getCurrentBatteryLevel();
      final state = await getCurrentBatteryState();
      _batteryController?.add(BatteryInfo(
        level: level,
        state: state,
        isLow: level <= 20 && state != BatteryState.charging,
      ));
    } catch (e) {
      debugPrint('Error starting battery monitoring: $e');
    }
  }

  /// Get battery stream for real-time updates
  static Stream<BatteryInfo>? get batteryStream => _batteryController?.stream;

  /// Stop battery monitoring
  static void dispose() {
    _batteryStateSubscription?.cancel();
    _batteryController?.close();
  }

  /// Get battery status message
  static String getBatteryStatusMessage(BatteryInfo info) {
    if (info.isLow) {
      return 'Your battery is low (${info.level}%). Save your cart to avoid losing items.';
    } else if (info.state == BatteryState.charging) {
      return 'Battery charging (${info.level}%)';
    } else {
      return 'Battery: ${info.level}%';
    }
  }
}

/// Battery information class
class BatteryInfo {
  final int level;
  final BatteryState state;
  final bool isLow;

  BatteryInfo({
    required this.level,
    required this.state,
    required this.isLow,
  });

  @override
  String toString() =>
      'BatteryInfo(level: $level%, state: $state, isLow: $isLow)';
}
