import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppLock extends StatefulWidget {
  final Widget child;
  final GoRouter router;
  final String lockScreenRoute;
  final String lockScreenRouteName;
  final Future<bool> Function() shouldTriggerLockScreen;

  final bool enabled;
  final Duration backgroundLockLatency;

  const AppLock({
    Key? key,
    required this.child,
    required this.router,
    required this.lockScreenRoute,
    required this.lockScreenRouteName,
    required this.shouldTriggerLockScreen,
    this.enabled = true,
    this.backgroundLockLatency = const Duration(seconds: 5),
  }) : super(key: key);

  static _AppLockState? of(BuildContext context) => context.findAncestorStateOfType<_AppLockState>();

  @override
  _AppLockState createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  late bool _isUnlocked;
  late bool _enabled;
  AppLifecycleState? _previousState;

  Timer? _backgroundLockLatencyTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _isUnlocked = false;
    _enabled = widget.enabled;

    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _triggerLockscreen();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!_enabled) {
      return;
    }

    if (_previousState == state) {
      return;
    }

    print("[Lifecycle] $state");

    if (state == AppLifecycleState.paused) {
      print("[AppLock] going to lock app after ${widget.backgroundLockLatency.inSeconds} seconds");

      _backgroundLockLatencyTimer = Timer(widget.backgroundLockLatency, () {
        print("[AppLock] _isUnlocked = false");
        _isUnlocked = false;
      });
    }

    if (state == AppLifecycleState.resumed) {
      await _triggerLockscreen();
    }

    _previousState = state;

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _backgroundLockLatencyTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _triggerLockscreen() async {
    _backgroundLockLatencyTimer?.cancel();

    print("[AppLock] _isUnlocked: $_isUnlocked");

    bool shouldTriggerLockScreen = await widget.shouldTriggerLockScreen();
    print("[AppLock] Should trigger lockScreen: $shouldTriggerLockScreen");

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
    if (widget.router.location == widget.lockScreenRoute) {
      return;
    }

    _isUnlocked = false;
    widget.router.pushNamed(widget.lockScreenRouteName);
  }

  void didUnlock() {
    if (widget.router.location != widget.lockScreenRoute) {
      return;
    }

    print("[AppLock] _isUnlocked = true");
    _isUnlocked = true;
    widget.router.pop();
  }
}
