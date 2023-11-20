import 'package:illuminate/foundation/src/platform/platform_identifiable.dart';

class PlatformIdentifier extends PlatformIdentifiable {
  @override
  Platform get current {
    throw UnimplementedError('The current getter is not supported');
  }

  @override
  String? get localeName {
    throw UnimplementedError('The localeName getter is not supported');
  }
}
