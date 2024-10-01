import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:illuminate/tracking.dart';
import 'package:illuminate/utils.dart';

class TrackingManager implements TrackingService {
  bool? _firebaseDefaultAppExists;
  bool get _configuredFirebase {
    if (_firebaseDefaultAppExists != null) {
      return _firebaseDefaultAppExists!;
    }

    try {
      // Try to get the default app
      Firebase.app();
      _firebaseDefaultAppExists = true;
    } catch (error) {
      _firebaseDefaultAppExists = false;
    }

    return _firebaseDefaultAppExists!;
  }

  @override
  Future<void> updateUserProperty({
    required UserPropertyable property,
    String? value,
  }) async {
    if (!_configuredFirebase) {
      logger.e('[Tracking] Firebase isn\'t configured for this project');
      return;
    }

    logger.d('[Tracking] <UserProperty>: ${property.name}, parameters: $value');

    await FirebaseAnalytics.instance.setUserProperty(name: property.name, value: value);
  }

  @override
  Future<void> screenView(
    Screenable screen, {
    String? screenClass,
    Map<String, String>? parameters,
  }) async {
    if (!_configuredFirebase) {
      logger.e('[Tracking] Firebase isn\'t configured for this project');
      return;
    }

    Map<String, dynamic> screenViewParameters = Map.from({
      'screen_name': screen.name,
      'screen_class': screenClass,
    }..addAll(parameters ?? {}))
      // Analytics only accepts values as String or number
      ..removeWhere((key, value) => value == null);

    logger.d('[Tracking] <Screen>: ${screen.name}, parameters: ${jsonEncode(screenViewParameters)}');

    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: screenViewParameters.map((key, value) => MapEntry(key, value as Object)),
    );
  }

  @override
  Future<void> logEvent(Event event) async {
    if (!_configuredFirebase) {
      logger.e('[Tracking] Firebase isn\'t configured for this project');
      return;
    }

    final parameters = (event.parameters ?? {})..removeWhere((key, value) => value == null);

    logger.d('[Tracking] <Event>: ${event.name}, parameters: ${jsonEncode(parameters)}');
    await FirebaseAnalytics.instance.logEvent(
      name: event.name.value,
      parameters: parameters.map((key, value) => MapEntry(key, value as Object)),
    );
  }
}
