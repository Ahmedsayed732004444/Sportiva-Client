import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/paging/paged_result.dart';
import '../../catalog/data/sport_type.dart';
import '../../payments/data/payment_models.dart';
import 'tournament_models.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>(
  (ref) => TournamentRepository(ref.watch(apiClientProvider)),
);

class TournamentRepository {
  TournamentRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<TournamentListItem>> list({
    SportType? sport,
    bool openOnly = false,
    String? search,
    required int page,
    int pageSize = 10,
  }) => _call(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tournaments',
      queryParameters: {
        'Filter': [if (sport != null) 'sportType:eq:${sport.apiName}', if (openOnly) 'status:eq:RegistrationOpen'],
        'pageNumber': page,
        'pageSize': pageSize,
        if (search != null && search.trim().isNotEmpty) 'searchValue': search.trim(),
      },
      options: Options(extra: noAuth),
    );
    return PagedResult.fromJson(response.data!, TournamentListItem.fromJson);
  });

  Future<Tournament> get(String id) =>
      _call(() async => Tournament.fromJson((await _dio.get<Map<String, dynamic>>('/tournaments/$id')).data!));

  Future<List<Team>> teams(String id) => _list('/tournaments/$id/teams', Team.fromJson);
  Future<List<TournamentMatch>> matches(String id) => _list('/tournaments/$id/matches', TournamentMatch.fromJson);
  Future<List<GroupStandings>> standings(String id) => _list('/tournaments/$id/standings', GroupStandings.fromJson);

  Future<Team> createTeam(
    String tournamentId, {
    String? name,
    List<({String userId, bool isSubstitute})> members = const [],
  }) => _call(
    () async => Team.fromJson(
      (await _dio.post<Map<String, dynamic>>(
        '/tournaments/$tournamentId/teams',
        data: {
          'name': name,
          'members': [
            for (final m in members) {'userId': m.userId, 'isSubstitute': m.isSubstitute},
          ],
        },
      )).data!,
    ),
  );

  Future<List<Team>> myTeams() => _list('/tournament-teams/mine', Team.fromJson);
  Future<List<Invitation>> invitations() => _list('/tournament-teams/invitations', Invitation.fromJson);
  Future<Team> team(String id) =>
      _call(() async => Team.fromJson((await _dio.get<Map<String, dynamic>>('/tournament-teams/$id')).data!));

  Future<void> invite(String teamId, String userId, {required bool isSubstitute}) => _call(
    () => _dio.post<void>(
      '/tournament-teams/$teamId/members',
      data: {
        'members': [
          {'userId': userId, 'isSubstitute': isSubstitute},
        ],
      },
    ),
  );

  Future<void> removeMember(String teamId, String userId) =>
      _call(() => _dio.delete<void>('/tournament-teams/$teamId/members/$userId'));
  Future<void> acceptInvitation(String teamId) =>
      _call(() => _dio.post<void>('/tournament-teams/$teamId/invitation/accept'));
  Future<void> declineInvitation(String teamId) =>
      _call(() => _dio.post<void>('/tournament-teams/$teamId/invitation/decline'));
  Future<void> withdraw(String teamId) => _call(() => _dio.post<void>('/tournament-teams/$teamId/withdraw'));

  Future<PaymentSession> pay(String teamId, PayMethod method) => _call(
    () async => PaymentSession.fromJson(
      (await _dio.post<Map<String, dynamic>>('/tournament-teams/$teamId/pay', data: {'method': method.apiName})).data!,
    ),
  );

  Future<List<T>> _list<T>(String path, T Function(Map<String, dynamic>) parse) => _call(() async {
    final response = await _dio.get<List<dynamic>>(path);
    return response.data!.cast<Map<String, dynamic>>().map(parse).toList();
  });

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
