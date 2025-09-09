import 'package:flutter/material.dart';
import 'dart:ui';

extension IterableExtension<E> on Iterable<E> {
  E? firstOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? get optionalFirst {
    if (isNotEmpty) {
      return first;
    }
    return null;
  }

  E? get optionalLast {
    if (isNotEmpty) {
      return last;
    }
    return null;
  }
}

extension ListExtension<E> on List<E> {
  List<E> insertBetween(E element) {
    return fold<List<E>>([], (result, widget) {
      if (result.isNotEmpty) {
        result.add(element);
      }

      result.add(widget);
      return result;
    });
  }

  List<T> mapList<T>(T Function(E e) toElement) {
    return map<T>(toElement).toList();
  }
}

extension ListNullableExtension<E> on List<E?> {
  List<E> compactMap() {
    return whereType<E>().toList();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String removeLeading(String characters) {
    if (!startsWith(characters)) {
      return this;
    }

    return substring(characters.length, length);
  }

  String removeTrailing(String characters) {
    if (!endsWith(characters)) {
      return this;
    }

    return substring(0, length - characters.length);
  }
}

extension ColorExtension on Color {
  Map<int, Color> swatch() {
    final map = <int, Color>{};
    for (var alpha in [0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]) {
      map[(alpha * 1000).toInt()] = Color.fromRGBO(
        (r * 255.0).round() & 0xff,
        (g * 255.0).round() & 0xff,
        (b * 255.0).round() & 0xff,
        alpha,
      );
    }

    return map;
  }
}

extension SafeOpacity on Color {
  Color withOpacitySafe(double opacity) {
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }
}
