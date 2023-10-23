import 'platform/platform_stub.dart'
    if (dart.library.io) 'platform/platform_io.dart'
    if (dart.library.html) 'platform/platform_web.dart';

class Foundation {
  static final platform = PlatformIdentifier();
}
