import 'package:illuminate/foundation/src/platform/platform_identifiable.dart';

class PlatformIdentifier extends PlatformIdentifiable {
  @override
  Platform get current {
    return Platform.web;
  }

  @override
  String? get localeName {
    return null;
  }

  @override
  bool get isWeb => true;
}
