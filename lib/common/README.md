# Common

## Usage 

```dart
import 'package:illuminate/common.dart';

// Check if an object is of a specific type and then assign it:
String? name = json['name'] is String ? json['name'] : null;

// Becomes:
String? name = tryCast<String?>(json['name']);
```

## All examples:

```dart
// Try casting an object and return null if it fails
T? tryCast<T>(dynamic object);

// Try cast a dynamic list to a specific type
List<T> tryCastList<T>(dynamic object);

/// Open the link externally, like the system browser
Future<void> openExternally(String urlString);

extension IterableExtension<E> on Iterable<E> {
  // First element in the array to pass the check
  E? firstOrNull(bool Function(E element) test);

  // [].first throws an error, use [].optionalFirst
  E? get optionalFirst;

  // [].last throws an error, use [].optionalLast
  E? get optionalLast;
}

extension ListExtension<E> on List<E> {
  // Insert an element in between all elements
  List<E> insertBetween(E element);
}

extension StringExtension on String {
  String capitalize();

  String removeLeading(String characters);
  
  String removeTrailing(String characters);
}

extension ColorExtension on Color {
  // Create a swatch from a single Color value
  // { 50: <x>, 100: <x>, 200: <x>, 300: <x>, 400: <x>, 500: <x>, 600: <x>, 700: <x>, 800: <x>, 900: <x> }
  Map<int, Color> swatch();
}

```