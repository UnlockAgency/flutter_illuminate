enum Platform {
  android,
  ios,
  web;

  @override
  String toString() {
    return '<Platform.$name>';
  }
}

abstract class PlatformIdentifiable {
  Platform get current;
  String? get localeName;

  bool get isAndroid => false;
  bool get isIOS => false;
  bool get isWeb => false;
}
