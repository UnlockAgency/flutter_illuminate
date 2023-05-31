import 'dart:math';

class Tuple<T1, T2> {
  final T1 a;
  final T2 b;

  Tuple(this.a, this.b);
}

class Coordinates {
  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: double.parse((json['latitude'] ?? json['lat']).toString()),
      longitude: double.parse((json['longitude'] ?? json['long']).toString()),
    );
  }

  final double latitude;
  final double longitude;

  double distanceTo({
    required Coordinates coordinates,
  }) {
    // Implementation of the Haversine formula to calculate geographic distance on earth
    // see https://en.wikipedia.org/wiki/Haversine_formula
    // Accuracy: This offer calculations on the basis of a spherical earth (ignoring ellipsoidal effects)
    const earthRadius = 6378137.0;

    return 2 *
        earthRadius *
        asin(
          sqrt(
            pow(sin(coordinates.latitude - latitude) / 2, 2) +
                cos(latitude) * cos(coordinates.latitude) * pow(sin(coordinates.longitude - longitude) / 2, 2),
          ),
        );
  }
}
