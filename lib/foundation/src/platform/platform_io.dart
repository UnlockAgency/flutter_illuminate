import 'dart:io' as io;
import 'package:illuminate/foundation/src/platform/platform_identifiable.dart';

class PlatformIdentifier extends PlatformIdentifiable {
  @override
  Platform get current {
    if (io.Platform.isAndroid) return Platform.android;
    if (io.Platform.isIOS) return Platform.ios;
    throw UnimplementedError('Unsupported platform detected');
  }

  @override
  String? get localeName {
    return io.Platform.localeName;
  }

  @override
  bool get isAndroid => io.Platform.isAndroid;

  @override
  bool get isIOS => io.Platform.isIOS;
}
