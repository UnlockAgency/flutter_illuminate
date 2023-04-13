extension IterableExtension<E> on Iterable<E> {
  E? firstOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ListExtension<E> on List<E> {
  List<E> insertBetween(E element) {
    return fold<List<E>>(
      [],
      (result, widget) {
        if (result.isNotEmpty) {
          result.add(element);
        }

        result.add(widget);
        return result;
      },
    );
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
