import 'package:illuminate/foundation/src/platform/platform_identifiable.dart';

class PlatformIdentifier extends PlatformIdentifiable {
  @override
  Platform get current {
    return Platform.web;
  }

  @override
  bool get isWeb => true;
}
