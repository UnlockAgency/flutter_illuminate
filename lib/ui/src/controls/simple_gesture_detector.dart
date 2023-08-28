import 'package:flutter/material.dart';

enum GestureDetectorMode {
  opacity,
  background;
}

class GestureDetectorConfig {
  const GestureDetectorConfig({
    this.mode = GestureDetectorMode.opacity,
    this.backgroundColor,
  });

  final GestureDetectorMode mode;
  final Color? backgroundColor;
}

class SimpleGestureDetector extends StatefulWidget {
  const SimpleGestureDetector({
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.config = const GestureDetectorConfig(),
    super.key,
  });

  final bool enabled;
  final Widget child;
  final GestureDetectorConfig config;
  final void Function()? onTap;

  @override
  State<SimpleGestureDetector> createState() => _SimpleGestureDetectorState();
}

class _SimpleGestureDetectorState extends State<SimpleGestureDetector> {
  bool _heldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_heldDown) {
      setState(() {
        _heldDown = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_heldDown) {
      setState(() {
        _heldDown = false;
      });
    }
  }

  void _handleTapCancel() {
    if (_heldDown) {
      setState(() {
        _heldDown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? _handleTapDown : null,
      onTapUp: widget.enabled ? _handleTapUp : null,
      onTapCancel: widget.enabled ? _handleTapCancel : null,
      onTap: () {
        if (widget.enabled && widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Semantics(
        button: true,
        child: _content(),
      ),
    );
  }

  Widget _content() {
    if (widget.config.mode == GestureDetectorMode.opacity) {
      return AnimatedOpacity(
        opacity: _heldDown ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: _heldDown ? widget.config.backgroundColor : Colors.transparent,
      ),
      child: widget.child,
    );
  }
}
