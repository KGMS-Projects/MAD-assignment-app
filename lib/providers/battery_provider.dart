// lib/providers/battery_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import '../services/battery_service.dart';

class BatteryProvider extends ChangeNotifier {
  BatteryInfo? _batteryInfo;
  bool _isMonitoring = false;
  StreamSubscription<BatteryInfo>? _batterySubscription;
  DateTime? _lastWarningTime;

  // Getters
  BatteryInfo? get batteryInfo => _batteryInfo;
  bool get isMonitoring => _isMonitoring;
  int get batteryLevel => _batteryInfo?.level ?? 100;
  BatteryState get batteryState => _batteryInfo?.state ?? BatteryState.unknown;
  bool get isBatteryLow => _batteryInfo?.isLow ?? false;

  // Check if we should show warning (don't spam warnings)
  bool get shouldShowWarning {
    if (!isBatteryLow) return false;

    // Don't show warning if we showed one in the last 5 minutes
    if (_lastWarningTime != null) {
      final timeSinceLastWarning = DateTime.now().difference(_lastWarningTime!);
      if (timeSinceLastWarning.inMinutes < 5) {
        return false;
      }
    }

    return true;
  }

  /// Initialize battery monitoring
  Future<void> initialize() async {
    if (_isMonitoring) return;

    try {
      await BatteryService.initialize();
      _isMonitoring = true;

      // Listen to battery updates
      _batterySubscription = BatteryService.batteryStream?.listen(
        (batteryInfo) {
          _batteryInfo = batteryInfo;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Battery provider error: $error');
        },
      );

      // Get initial battery info
      final level = await BatteryService.getCurrentBatteryLevel();
      final state = await BatteryService.getCurrentBatteryState();
      _batteryInfo = BatteryInfo(
        level: level,
        state: state,
        isLow: level <= 20 && state != BatteryState.charging,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing battery provider: $e');
    }
  }

  /// Mark that warning was shown
  void markWarningShown() {
    _lastWarningTime = DateTime.now();
  }

  /// Check if battery is critical (needs immediate action)
  bool get isCriticallyLow =>
      batteryLevel <= 10 && batteryState != BatteryState.charging;

  /// Get battery icon based on level and state
  IconData getBatteryIcon() {
    if (batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }

    if (batteryLevel >= 90) return Icons.battery_full;
    if (batteryLevel >= 70) return Icons.battery_5_bar;
    if (batteryLevel >= 50) return Icons.battery_4_bar;
    if (batteryLevel >= 30) return Icons.battery_3_bar;
    if (batteryLevel >= 20) return Icons.battery_2_bar;
    if (batteryLevel >= 10) return Icons.battery_1_bar;
    return Icons.battery_0_bar;
  }

  /// Get battery color based on level
  Color getBatteryColor() {
    if (batteryState == BatteryState.charging) {
      return Colors.green;
    }

    if (batteryLevel >= 50) return Colors.green;
    if (batteryLevel >= 30) return Colors.orange;
    if (batteryLevel >= 20) return Colors.red;
    return Colors.red.shade800;
  }

  /// Get status message
  String getStatusMessage() {
    if (_batteryInfo == null) return 'Battery status unknown';
    return BatteryService.getBatteryStatusMessage(_batteryInfo!);
  }

  /// Force refresh battery info
  Future<void> refreshBatteryInfo() async {
    try {
      final level = await BatteryService.getCurrentBatteryLevel();
      final state = await BatteryService.getCurrentBatteryState();
      _batteryInfo = BatteryInfo(
        level: level,
        state: state,
        isLow: level <= 20 && state != BatteryState.charging,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing battery info: $e');
    }
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    BatteryService.dispose();
    super.dispose();
  }
}
