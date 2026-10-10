import 'package:flutter/services.dart';

class HapticService {
  static Future<void> init() async {
    // No-op: Flutter built-in haptic feedback doesn't need initialization
  }

  static void tap() {
    HapticFeedback.lightImpact();
  }

  static void equals() {
    HapticFeedback.mediumImpact();
  }

  static void error() {
    HapticFeedback.heavyImpact();
  }
}