import 'dart:io';
import 'package:flutter/material.dart';
import 'package:illuminate/ui/src/controls/simple_gesture_detector.dart';

class Tappable extends StatefulWidget {
  const Tappable({
    required this.child,
    this.onTap,
    this.gestureDetectorConfig,
    super.key,
  });

  final Widget child;
  final void Function()? onTap;

  /// Specific configuration for iOS
  final GestureDetectorConfig? gestureDetectorConfig;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool get _enabled {
    return widget.onTap != null;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return SimpleGestureDetector(
        onTap: widget.onTap,
        enabled: _enabled,
        config: widget.gestureDetectorConfig ?? const GestureDetectorConfig(),
        child: widget.child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}
