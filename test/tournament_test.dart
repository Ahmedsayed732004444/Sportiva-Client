import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/features/tournaments/data/tournament_models.dart';

Map<String, dynamic> tournamentJson({String status = 'RegistrationOpen', int approved = 1, String? myTeamId}) => {
  'id': 't1',
  'name': 'Cup',
  'sportType': 'Football',
  'format': 'GroupsKnockout',
  'isIndividual': false,
  'status': status,
  'club': {'id': 'c1', 'name': 'Club', 'logoUrl': null, 'governorateName': 'G', 'city': 'C'},
  'isPlatformTournament': false,
  'feePiasters': 25000,
  'maxTeams': 4,
  'approvedTeams': approved,
  'startDate': '2026-11-01',
  'endDate': '2026-11-04',
  'playersPerTeam': 5,
  'substitutesPerTeam': 2,
  'registrationClosesAt': '2026-10-25T10:00:00Z',
  'dailyStartTime': '16:00:00',
  'dailyEndTime': '22:00:00',
  'matchMinutes': 60,
  'courts': [
    {'id': 'k1', 'name': 'Main'},
  ],
  'myTeamId': myTeamId,
};

void main() {
  test('a tournament parses its list part, its courts and its enums', () {
    final tournament = Tournament.fromJson(tournamentJson());
    expect(tournament.item.format, TournamentFormat.groupsKnockout);
    expect(tournament.status, TournamentStatus.registrationOpen);
    expect(tournament.courts, ['Main']);
    expect(tournament.item.feePiasters, 25000);
  });

  test('registering is possible only while open, with room, and without a team of mine', () {
    expect(Tournament.fromJson(tournamentJson()).canRegister, isTrue);
    expect(Tournament.fromJson(tournamentJson(approved: 4)).canRegister, isFalse);
    expect(Tournament.fromJson(tournamentJson(myTeamId: 'x')).canRegister, isFalse);
    expect(Tournament.fromJson(tournamentJson(status: 'InProgress')).canRegister, isFalse);
  });

  test('team statuses: active ones can still be changed, unknown falls back to forming', () {
    expect(TeamStatus.fromApi('PendingApproval').isActive, isTrue);
    expect(TeamStatus.fromApi('Withdrawn').isActive, isFalse);
    expect(TeamStatus.fromApi('Rejected').isActive, isFalse);
    expect(TeamStatus.fromApi('???'), TeamStatus.forming);
  });

  test('a match with no teams yet is a placeholder, a bye is flagged', () {
    final match = TournamentMatch.fromJson({
      'id': 'm1',
      'stage': 'Knockout',
      'round': 2,
      'number': 1,
      'status': 'Waiting',
      'isBye': false,
      'home': null,
      'away': null,
    });
    expect(match.home, isNull);
    expect(match.stage, TournamentStage.knockout);
    expect(match.status, TournamentMatchStatus.waiting);
  });
}
