import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:illuminate/utils.dart';

class AppLock extends StatefulWidget {
  final Widget child;
  final GoRouter router;
  final String lockScreenRoute;
  final String lockScreenRouteName;
  final Future<bool> Function() shouldTriggerLockScreen;

  final bool triggerOnLaunch;
  final bool enabled;
  final Duration backgroundLockLatency;

  const AppLock({
    Key? key,
    required this.child,
    required this.router,
    required this.lockScreenRoute,
    required this.lockScreenRouteName,
    required this.shouldTriggerLockScreen,
    this.triggerOnLaunch = true,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 5),
  }) : super(key: key);

  // ignore: library_private_types_in_public_api
  static _AppLockState? of(BuildContext context) => context.findAncestorStateOfType<_AppLockState>();

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> {
  late bool _isUnlocked;
  late bool _enabled;
  AppLifecycleState? _previousState;

  Timer? _backgroundLockLatencyTimer;

  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();

    _isUnlocked = false;
    _enabled = widget.enabled;

    if (widget.triggerOnLaunch) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _triggerLockscreen();
      });
    }

    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onDetach: _onDetach,
      onHide: _onHide,
      onInactive: _onInactive,
      onPause: _onPause,
      onRestart: _onRestart,
      onResume: _onResume,
      onShow: _onShow,
      onStateChange: _onStateChanged,
    );

    super.initState();
  }

  @override
  void dispose() {
    _listener.dispose();

    _backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  /// A callback that is called when an application has exited, and detached all host views from the engine.
  void _onDetach() {
    //
  }

  /// A callback that is called when the application is hidden.
  void _onHide() {
    //
  }

  /// A callback that is called when the application loses input focus.
  void _onInactive() {
    //
  }

  /// A callback that is called when the application is paused.
  void _onPause() {
    if (!_enabled) {
      return;
    }

    logger.i("[AppLock] going to lock app after ${widget.backgroundLockLatency.inSeconds} seconds");

    _backgroundLockLatencyTimer = Timer(widget.backgroundLockLatency, () {
      logger.i("[AppLock] _isUnlocked = false");
      _isUnlocked = false;
    });
  }

  /// A callback that is called when the application is resumed after being paused.
  void _onRestart() {
    //
  }

  /// A callback that is called when a view in the application gains input focus.
  void _onResume() async {
    if (!_enabled) {
      return;
    }

    await _triggerLockscreen();
  }

  /// A callback that is called when the application is shown.
  void _onShow() {
    //
  }

  void _onStateChanged(AppLifecycleState state) async {
    if (_previousState == state) {
      return;
    }

    logger.i("[Lifecycle] $state");
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _triggerLockscreen() async {
    _backgroundLockLatencyTimer?.cancel();

    logger.i("[AppLock] _isUnlocked: $_isUnlocked");

    bool shouldTriggerLockScreen = await widget.shouldTriggerLockScreen();
    logger.i("[AppLock] Should trigger lockScreen: $shouldTriggerLockScreen");

    // Check if we need to show a lockscreen (for instance, when the user hasn't configured a code yet)
    if (shouldTriggerLockScreen == false) {
      _isUnlocked = true;
    }

    if (!_isUnlocked) {
      showLockScreen();
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses if
  /// [enabled] is true of makes sure it isn't shown on subsequent app pauses if
  /// [enabled] is false.
  ///
  /// This is a convenience method for calling the [enable] or [disable] method based
  /// on [enabled].
  void setEnabled(bool enabled) {
    if (enabled) {
      enable();
    } else {
      disable();
    }
  }

  /// Makes sure that [AppLock] shows the [lockScreen] on subsequent app pauses.
  void enable() {
    setState(() {
      _enabled = true;
    });
  }

  /// Makes sure that [AppLock] doesn't show the [lockScreen] on subsequent app pauses.
  void disable() {
    setState(() {
      _enabled = false;
    });
  }

  /// Manually show the [lockScreen].
  void showLockScreen() {
    // Check if we're already showing the lockscreen
    if (_routerLocation() == widget.lockScreenRoute) {
      return;
    }

    _isUnlocked = false;
    widget.router.pushNamed(widget.lockScreenRouteName);
  }

  void didUnlock() {
    if (_routerLocation() != widget.lockScreenRoute) {
      return;
    }

    logger.i("[AppLock] _isUnlocked = true");
    _isUnlocked = true;
    widget.router.pop();
  }

  String _routerLocation() {
    final RouteMatch lastMatch = widget.router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        lastMatch is ImperativeRouteMatch ? lastMatch.matches : widget.router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
