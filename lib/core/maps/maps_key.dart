import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('sportiva/config');
String? _cached;

// The Google Maps key: --dart-define=MAPS_API_KEY first, else what the Android build put in the manifest.
Future<String> mapsKey() async {
  if (_cached != null) return _cached!;
  const defined = String.fromEnvironment('MAPS_API_KEY');
  if (defined.isNotEmpty) return _cached = defined;
  if (defaultTargetPlatform != TargetPlatform.android) return _cached = '';
  try {
    return _cached = await _channel.invokeMethod<String>('mapsKey') ?? '';
  } on Object {
    return _cached = '';
  }
}
