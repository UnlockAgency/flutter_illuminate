import 'package:illuminate/tracking.dart';

abstract class TrackingService {
  Future<void> updateUserProperty({required UserPropertyable property, String? value});

  Future<void> screenView(
    Screenable screen, {
    String? screenClass,
    Map<String, String>? parameters,
  });

  Future<void> logEvent(Event event);
}
