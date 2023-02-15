import 'package:flutter/material.dart';

enum SafeAreaEdge {
  top,
  right,
  bottom,
  left;
}

mixin ContextAwareSafeAreaMixin<T extends StatefulWidget> on State<T> {
  double safeArea(SafeAreaEdge edge) {
    return _safeArea(context, edge: edge);
  }
}

mixin SafeAreaMixin {
  double safeArea(BuildContext context, {required SafeAreaEdge edge}) {
    return _safeArea(context, edge: edge);
  }
}

double _safeArea(BuildContext context, {required SafeAreaEdge edge}) {
  if (edge == SafeAreaEdge.top) {
    return MediaQuery.of(context).padding.top;
  }

  if (edge == SafeAreaEdge.right) {
    return MediaQuery.of(context).padding.right;
  }

  if (edge == SafeAreaEdge.bottom) {
    return MediaQuery.of(context).padding.bottom;
  }

  return MediaQuery.of(context).padding.left;
}
