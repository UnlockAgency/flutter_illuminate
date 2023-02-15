import 'package:flutter/material.dart';

class SimpleGestureDetector extends StatefulWidget {
  const SimpleGestureDetector({
    required this.onTap,
    required this.child,
    this.enabled = true,
    super.key,
  });

  final bool enabled;
  final Widget child;
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
        child: AnimatedOpacity(
          opacity: _heldDown ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
