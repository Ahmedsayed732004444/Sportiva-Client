import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/locale_controller.dart';
import 'coordinates.dart';
import 'location_service.dart';

class LocationState {
  const LocationState({required this.access, required this.decided, this.position});

  final LocationAccess access;
  // The user has answered the location question (allowed it, or chose to go on without it): the home can open.
  final bool decided;
  final Coordinates? position;

  bool get hasPosition => position != null;
}

final locationProvider = AsyncNotifierProvider<LocationController, LocationState>(LocationController.new);

class LocationController extends AsyncNotifier<LocationState> {
  static const _skippedKey = 'locationSkipped';

  LocationService get _service => ref.read(locationServiceProvider);

  @override
  Future<LocationState> build() async {
    final access = await _service.access();
    final skipped = ref.read(sharedPreferencesProvider).getBool(_skippedKey) ?? false;
    return _state(access, decided: access == LocationAccess.granted || skipped);
  }

  // The "Allow location" button: asks the system and, when allowed, reads where the user is.
  Future<void> allow() async {
    final current = state.valueOrNull;
    if (current != null &&
        (current.access == LocationAccess.deniedForever || current.access == LocationAccess.serviceOff)) {
      await _service.openSettings(current.access);
    }

    final access = await _service.request();
    state = AsyncData(await _state(access, decided: access == LocationAccess.granted));
  }

  Future<void> skip() async {
    await ref.read(sharedPreferencesProvider).setBool(_skippedKey, true);
    state = AsyncData(LocationState(access: state.valueOrNull?.access ?? LocationAccess.denied, decided: true));
  }

  // Pull to refresh on the home: where the user is now.
  Future<void> refreshPosition() async {
    final current = state.valueOrNull;
    if (current == null || current.access != LocationAccess.granted) return;
    state = AsyncData(await _state(current.access, decided: true));
  }

  Future<LocationState> _state(LocationAccess access, {required bool decided}) async => LocationState(
    access: access,
    decided: decided,
    position: access == LocationAccess.granted ? await _service.position() : null,
  );
}
