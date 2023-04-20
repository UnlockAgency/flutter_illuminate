import 'package:flutter/scheduler.dart';
import 'package:illuminate/utils.dart';

class AppLifecycleStateManager extends AppLifecycleStateObserver {
  static const _tag = '[AppLifecycleStateManager] =>';

  @override
  AppLifecycleState get current => _current;
  AppLifecycleState _current = AppLifecycleState.resumed;

  @override
  bool get inForeground => _current == AppLifecycleState.resumed;

  @override
  void didChange(AppLifecycleState state) {
    logger.i('$_tag didChange to: $state');
    _current = state;
  }
}

abstract class AppLifecycleStateObserver {
  AppLifecycleState get current;
  bool get inForeground;

  void didChange(AppLifecycleState state);
}
