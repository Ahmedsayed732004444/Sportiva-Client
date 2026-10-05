import 'dart:math' as math;

import 'coordinates.dart';

// The straight-line distance in kilometres between two places (haversine).
double distanceKm(Coordinates from, double latitude, double longitude) {
  const earthRadiusKm = 6371.0;
  double rad(double degrees) => degrees * math.pi / 180;

  final dLat = rad(latitude - from.latitude);
  final dLon = rad(longitude - from.longitude);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(from.latitude)) * math.cos(rad(latitude)) * math.pow(math.sin(dLon / 2), 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

// "450 m" is shown as 0.5, "3.24 km" as 3.2, a long way as a whole number.
String kmLabel(double km) => km < 10 ? km.toStringAsFixed(1) : km.round().toString();
