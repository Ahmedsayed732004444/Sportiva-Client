import 'package:dio/dio.dart';

import 'maps_key.dart';

class PlaceHit {
  const PlaceHit({required this.name, required this.address, required this.latitude, required this.longitude});

  final String name;
  final String address;
  final double latitude;
  final double longitude;
}

// Finding a place by its name for the map picker: Google Places (text search) first, the Geocoding API if Places is
// not enabled for the key. Results are biased to Egypt.
class PlacesService {
  PlacesService([Dio? dio])
    : _dio =
          dio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));

  final Dio _dio;

  Future<List<PlaceHit>> search(String text, {required String language}) async {
    final key = await mapsKey();
    if (key.isEmpty || text.trim().isEmpty) return const [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://places.googleapis.com/v1/places:searchText',
        data: {'textQuery': text.trim(), 'languageCode': language, 'regionCode': 'EG', 'maxResultCount': 8},
        options: Options(
          headers: {
            'X-Goog-Api-Key': key,
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location',
          },
        ),
      );
      final places = (response.data?['places'] as List? ?? const []).cast<Map<String, dynamic>>();
      return [
        for (final place in places)
          PlaceHit(
            name: (place['displayName'] as Map?)?['text'] as String? ?? '',
            address: place['formattedAddress'] as String? ?? '',
            latitude: ((place['location'] as Map)['latitude'] as num).toDouble(),
            longitude: ((place['location'] as Map)['longitude'] as num).toDouble(),
          ),
      ];
    } on DioException {
      return _geocode({'address': text.trim(), 'region': 'eg', 'language': language, 'key': key});
    }
  }

  // The address of a point, to fill the address field when the person did not type one.
  Future<String?> addressOf(double latitude, double longitude, {required String language}) async {
    final key = await mapsKey();
    if (key.isEmpty) return null;
    final hits = await _geocode({'latlng': '$latitude,$longitude', 'language': language, 'key': key});
    return hits.isEmpty ? null : hits.first.address;
  }

  Future<List<PlaceHit>> _geocode(Map<String, dynamic> query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: query,
      );
      final results = (response.data?['results'] as List? ?? const []).cast<Map<String, dynamic>>();
      return [
        for (final result in results.take(8))
          PlaceHit(
            name: ((result['address_components'] as List?)?.firstOrNull as Map?)?['long_name'] as String? ?? '',
            address: result['formatted_address'] as String? ?? '',
            latitude: (((result['geometry'] as Map)['location'] as Map)['lat'] as num).toDouble(),
            longitude: (((result['geometry'] as Map)['location'] as Map)['lng'] as num).toDouble(),
          ),
      ];
    } on DioException {
      return const [];
    }
  }
}
