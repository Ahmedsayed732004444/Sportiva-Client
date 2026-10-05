import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/date_time_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../catalog/data/sport_type.dart';
import '../../tournaments/data/tournament_models.dart';

final ownerTournamentRepositoryProvider = Provider<OwnerTournamentRepository>(
  (ref) => OwnerTournamentRepository(ref.watch(apiClientProvider)),
);

class TournamentForm {
  const TournamentForm({
    required this.name,
    required this.sport,
    required this.format,
    required this.isIndividual,
    required this.playersPerTeam,
    required this.substitutesPerTeam,
    required this.maxTeams,
    required this.feePiasters,
    required this.registrationClosesAt,
    required this.startDate,
    required this.endDate,
    required this.dailyStartTime,
    required this.dailyEndTime,
    required this.matchMinutes,
    required this.courtIds,
    this.description,
    this.rules,
    this.prizes,
    this.groupsCount,
    this.qualifiersPerGroup,
  });

  final String name;
  final SportType sport;
  final TournamentFormat format;
  final bool isIndividual;
  final int playersPerTeam;
  final int substitutesPerTeam;
  final int maxTeams;
  final int feePiasters;
  final DateTime registrationClosesAt;
  final DateTime startDate;
  final DateTime endDate;
  final String dailyStartTime;
  final String dailyEndTime;
  final int matchMinutes;
  final List<String> courtIds;
  final String? description;
  final String? rules;
  final String? prizes;
  final int? groupsCount;
  final int? qualifiersPerGroup;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'rules': rules,
    'prizes': prizes,
    'sportType': sport.apiName,
    'format': switch (format) {
      TournamentFormat.knockout => 'Knockout',
      TournamentFormat.league => 'League',
      TournamentFormat.groupsKnockout => 'GroupsKnockout',
    },
    'isIndividual': isIndividual,
    'playersPerTeam': isIndividual ? 1 : playersPerTeam,
    'substitutesPerTeam': isIndividual ? 0 : substitutesPerTeam,
    'maxTeams': maxTeams,
    'groupsCount': format == TournamentFormat.groupsKnockout ? groupsCount : null,
    'qualifiersPerGroup': format == TournamentFormat.groupsKnockout ? qualifiersPerGroup : null,
    'feePiasters': feePiasters,
    'registrationClosesAt': registrationClosesAt.toUtc().toIso8601String(),
    'startDate': apiDay(startDate),
    'endDate': apiDay(endDate),
    'dailyStartTime': dailyStartTime,
    'dailyEndTime': dailyEndTime,
    'matchMinutes': matchMinutes,
    'courtIds': courtIds,
  };
}

// The tournaments of the owner's club, and what the organizer does with them.
class OwnerTournamentRepository {
  OwnerTournamentRepository(this._dio);

  final Dio _dio;

  static const _base = '/clubs/me/tournaments';

  Future<PagedResult<TournamentListItem>> list({required int page, int pageSize = 10}) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {'pageNumber': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(response.data!, TournamentListItem.fromJson);
  });

  Future<Tournament> get(String id) =>
      _call(() async => Tournament.fromJson((await _dio.get<Map<String, dynamic>>('$_base/$id')).data!));

  Future<List<Team>> teams(String id) => _call(() async {
    final response = await _dio.get<List<dynamic>>('$_base/$id/teams');
    return response.data!.cast<Map<String, dynamic>>().map(Team.fromJson).toList();
  });

  Future<String> create(TournamentForm form) =>
      _call(() async => (await _dio.post<Map<String, dynamic>>(_base, data: form.toJson())).data!['id'] as String);

  Future<void> publish(String id) => _call(() => _dio.post<void>('$_base/$id/publish'));
  Future<void> closeRegistration(String id) => _call(() => _dio.post<void>('$_base/$id/close-registration'));
  Future<void> approve(String id, String teamId) => _call(() => _dio.post<void>('$_base/$id/teams/$teamId/approve'));
  Future<void> reject(String id, String teamId, String reason) =>
      _call(() => _dio.post<void>('$_base/$id/teams/$teamId/reject', data: {'reason': reason}));
  Future<void> draw(String id) => _call(() => _dio.post<void>('$_base/$id/draw', data: <String, dynamic>{}));
  Future<void> cancel(String id, String reason) =>
      _call(() => _dio.post<void>('$_base/$id/cancel', data: {'reason': reason, 'refundFees': true}));

  Future<void> setResult(String matchId, {required int home, required int away, String? winnerTeamId}) => _call(
    () => _dio.post<void>(
      '$_base/matches/$matchId/result',
      data: {'homeScore': home, 'awayScore': away, 'winnerTeamId': winnerTeamId},
    ),
  );

  Future<void> setPoster(String id, String path) => _call(
    () async =>
        _dio.put<void>('$_base/$id/poster', data: FormData.fromMap({'file': await MultipartFile.fromFile(path)})),
  );

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
