// Try casting an object and return null if it fails
T? tryCast<T>(dynamic object) => object is T ? object : null;

// Try cast a dynamic list to a specific type
List<T> tryCastList<T>(dynamic object) {
  final list = tryCast<List<dynamic>>(object) ?? [];
  return list
      .map(
        (element) => tryCast<T>(element),
      )
      .where(
        (element) => element != null,
      )
      .cast<T>()
      .toList();
}
