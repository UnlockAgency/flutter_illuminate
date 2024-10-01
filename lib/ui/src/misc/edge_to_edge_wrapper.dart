import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A quick and easy way to style the navigation bar bar in Android
/// to be transparent and edge-to-edge, like iOS is by default.
SystemUiOverlayStyle customOverlayStyle({final bool transparentStatusBar = false, SystemUiOverlayStyle? customStyle}) {
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  final statusBarColor = transparentStatusBar ? Colors.transparent : null;
  return customStyle ??
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      );
}

class EdgeToEdgeWrapper extends StatelessWidget {
  final Widget child;
  final bool transparentStatusBar;
  final SystemUiOverlayStyle? customStyle;

  const EdgeToEdgeWrapper({
    super.key,
    this.transparentStatusBar = false,
    this.customStyle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: customOverlayStyle(
        transparentStatusBar: transparentStatusBar,
        customStyle: customStyle,
      ),
      child: child,
    );
  }
}
