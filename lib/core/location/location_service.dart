import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'coordinates.dart';

enum LocationAccess { granted, denied, deniedForever, serviceOff }

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());

// The only place that talks to the phone's location: permission, the position, and the settings screens.
class LocationService {
  const LocationService();

  // Reads the current state without asking the user anything.
  Future<LocationAccess> access() => _guarded(() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    return _map(await Geolocator.checkPermission());
  });

  // Shows the system permission dialog (when it can).
  Future<LocationAccess> request() => _guarded(() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    return _map(permission);
  });

  // A location problem (a missing plugin, a platform error) must never block the app: it counts as "no location".
  Future<LocationAccess> _guarded(Future<LocationAccess> Function() action) async {
    try {
      return await action();
    } on Object {
      return LocationAccess.denied;
    }
  }

  // Null when the position can't be read in time; the home then simply has no distances.
  Future<Coordinates?> position() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)),
      );
      return Coordinates(position.latitude, position.longitude);
    } on Object {
      try {
        final last = await Geolocator.getLastKnownPosition();
        return last == null ? null : Coordinates(last.latitude, last.longitude);
      } on Object {
        return null;
      }
    }
  }

  Future<void> openSettings(LocationAccess access) async {
    if (access == LocationAccess.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  LocationAccess _map(LocationPermission permission) => switch (permission) {
    LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
    LocationPermission.deniedForever => LocationAccess.deniedForever,
    _ => LocationAccess.denied,
  };
}
