import 'package:illuminate/foundation/src/platform/platform_identifiable.dart';

class PlatformIdentifier extends PlatformIdentifiable {
  @override
  Platform get current {
    throw UnimplementedError('The current platform is not supported');
  }
}
