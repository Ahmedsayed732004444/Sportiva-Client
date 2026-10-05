import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../catalog/data/sport_type.dart';
import 'owner_court_models.dart';

final ownerCourtRepositoryProvider = Provider<OwnerCourtRepository>(
  (ref) => OwnerCourtRepository(ref.watch(apiClientProvider)),
);

class OwnerCourtRepository {
  OwnerCourtRepository(this._dio);

  final Dio _dio;

  Future<List<OwnerCourt>> list() => _call(() async {
    final response = await _dio.get<dynamic>('/clubs/me/courts', queryParameters: {'pageSize': 50});
    final data = response.data;
    final items = (data is Map ? data['items'] : data) as List;
    return items.cast<Map<String, dynamic>>().map(OwnerCourt.fromJson).toList();
  });

  // The list answers with the short form; the single court has the settings and the price rules.
  Future<OwnerCourt> get(String id) =>
      _call(() async => OwnerCourt.fromJson((await _dio.get<Map<String, dynamic>>('/courts/$id')).data!));

  Future<void> create(CourtForm form) => _call(() => _dio.post<void>('/clubs/me/courts', data: form.toJson()));
  Future<void> update(String id, CourtForm form) =>
      _call(() => _dio.put<void>('/clubs/me/courts/$id', data: form.toJson()));
  Future<void> toggle(String id) => _call(() => _dio.patch<void>('/clubs/me/courts/$id/status'));
  Future<void> delete(String id) => _call(() => _dio.delete<void>('/clubs/me/courts/$id'));

  Future<void> setPriceRules(String id, List<PriceRule> rules) => _call(
    () => _dio.put<void>(
      '/clubs/me/courts/$id/price-rules',
      data: {
        'rules': [for (final r in rules) r.toJson()],
      },
    ),
  );

  Future<List<ManagedSlot>> slots(String id, DateTime day) => _call(() async {
    final response = await _dio.get<List<dynamic>>('/clubs/me/courts/$id/slots', queryParameters: {'day': apiDay(day)});
    return response.data!.cast<Map<String, dynamic>>().map(ManagedSlot.fromJson).toList();
  });

  Future<void> setSlotsClosed(String id, List<String> slotIds, {required bool closed}) =>
      _call(() => _dio.patch<void>('/clubs/me/courts/$id/slots', data: {'slotIds': slotIds, 'isClosed': closed}));

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class CourtForm {
  const CourtForm({
    required this.name,
    required this.sport,
    required this.confirmationMode,
    required this.pricePiasters,
    required this.allowsHalfCourt,
    this.description,
    this.responseTimeoutMinutes,
    this.halfCourtPiasters,
  });

  final String name;
  final SportType sport;
  final ConfirmationMode confirmationMode;
  final int pricePiasters;
  final bool allowsHalfCourt;
  final String? description;
  final int? responseTimeoutMinutes;
  final int? halfCourtPiasters;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'sportType': sport.apiName,
    'confirmationMode': confirmationMode.apiName,
    'responseTimeoutMinutes': confirmationMode == ConfirmationMode.manual ? responseTimeoutMinutes : null,
    'pricePerHourPiasters': pricePiasters,
    'allowsHalfCourt': allowsHalfCourt,
    'halfCourtPricePerHourPiasters': allowsHalfCourt ? halfCourtPiasters : null,
  };
}
