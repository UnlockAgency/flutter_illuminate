// Try casting an object and return null if it fails
T? tryCast<T>(dynamic object) => object is T ? object : null;
