import '../../catalog/data/catalog_models.dart';
import '../../catalog/data/sport_type.dart';
import '../../social/data/social_models.dart';

enum TournamentStatus {
  draft,
  registrationOpen,
  registrationClosed,
  inProgress,
  completed,
  cancelled;

  static TournamentStatus fromApi(Object? value) => switch (value.toString()) {
    'RegistrationOpen' => registrationOpen,
    'RegistrationClosed' => registrationClosed,
    'InProgress' => inProgress,
    'Completed' => completed,
    'Cancelled' => cancelled,
    _ => draft,
  };
}

enum TournamentFormat {
  knockout,
  league,
  groupsKnockout;

  static TournamentFormat fromApi(Object? value) => switch (value.toString()) {
    'League' => league,
    'GroupsKnockout' => groupsKnockout,
    _ => knockout,
  };
}

enum TeamStatus {
  forming,
  pendingPayment,
  pendingApproval,
  approved,
  rejected,
  withdrawn,
  cancelled;

  static TeamStatus fromApi(Object? value) => switch (value.toString()) {
    'PendingPayment' => pendingPayment,
    'PendingApproval' => pendingApproval,
    'Approved' => approved,
    'Rejected' => rejected,
    'Withdrawn' => withdrawn,
    'Cancelled' => cancelled,
    _ => forming,
  };

  // A team that can still be paid for, changed or withdrawn by its captain.
  bool get isActive => this == forming || this == pendingPayment || this == pendingApproval || this == approved;
}

enum MemberStatus {
  invited,
  accepted,
  declined,
  removed;

  static MemberStatus fromApi(Object? value) => switch (value.toString()) {
    'Accepted' => accepted,
    'Declined' => declined,
    'Removed' => removed,
    _ => invited,
  };
}

enum TournamentStage {
  league,
  group,
  knockout;

  static TournamentStage fromApi(Object? value) => switch (value.toString()) {
    'Group' => group,
    'Knockout' => knockout,
    _ => league,
  };
}

enum TournamentMatchStatus {
  waiting,
  scheduled,
  completed,
  cancelled;

  static TournamentMatchStatus fromApi(Object? value) => switch (value.toString()) {
    'Scheduled' => scheduled,
    'Completed' => completed,
    'Cancelled' => cancelled,
    _ => waiting,
  };
}

class TeamSummary {
  const TeamSummary({required this.id, required this.name, this.logoUrl});

  final String id;
  final String name;
  final String? logoUrl;

  factory TeamSummary.fromJson(Map<String, dynamic> json) =>
      TeamSummary(id: json['id'] as String, name: json['name'] as String? ?? '', logoUrl: json['logoUrl'] as String?);
}

class TournamentListItem {
  const TournamentListItem({
    required this.id,
    required this.name,
    required this.sport,
    required this.format,
    required this.isIndividual,
    required this.status,
    required this.club,
    required this.isPlatformTournament,
    required this.feePiasters,
    required this.maxTeams,
    required this.approvedTeams,
    required this.startDate,
    required this.endDate,
    this.posterUrl,
  });

  final String id;
  final String name;
  final SportType sport;
  final TournamentFormat format;
  final bool isIndividual;
  final TournamentStatus status;
  final ClubRef club;
  final bool isPlatformTournament;
  final int feePiasters;
  final int maxTeams;
  final int approvedTeams;
  final String startDate;
  final String endDate;
  final String? posterUrl;

  factory TournamentListItem.fromJson(Map<String, dynamic> json) => TournamentListItem(
    id: json['id'] as String,
    name: json['name'] as String,
    sport: SportType.fromApi(json['sportType']),
    format: TournamentFormat.fromApi(json['format']),
    isIndividual: json['isIndividual'] as bool? ?? false,
    status: TournamentStatus.fromApi(json['status']),
    club: ClubRef.fromJson(json['club'] as Map<String, dynamic>),
    isPlatformTournament: json['isPlatformTournament'] as bool? ?? false,
    feePiasters: (json['feePiasters'] as num).toInt(),
    maxTeams: json['maxTeams'] as int,
    approvedTeams: json['approvedTeams'] as int,
    startDate: json['startDate'] as String,
    endDate: json['endDate'] as String,
    posterUrl: json['posterUrl'] as String?,
  );
}

class Tournament {
  const Tournament({
    required this.item,
    required this.playersPerTeam,
    required this.substitutesPerTeam,
    required this.registrationClosesAt,
    required this.dailyStartTime,
    required this.dailyEndTime,
    required this.matchMinutes,
    required this.courts,
    this.courtRefs = const [],
    this.description,
    this.rules,
    this.prizes,
    this.groupsCount,
    this.qualifiersPerGroup,
    this.champion,
    this.cancellationReason,
    this.myTeamId,
  });

  final TournamentListItem item;
  final int playersPerTeam;
  final int substitutesPerTeam;
  final DateTime registrationClosesAt;
  final String dailyStartTime;
  final String dailyEndTime;
  final int matchMinutes;
  final List<String> courts;
  // The same courts with their ids, for rescheduling a match onto one of them.
  final List<({String id, String name})> courtRefs;
  final String? description;
  final String? rules;
  final String? prizes;
  final int? groupsCount;
  final int? qualifiersPerGroup;
  final TeamSummary? champion;
  final String? cancellationReason;
  final String? myTeamId;

  String get id => item.id;
  TournamentStatus get status => item.status;

  bool get canRegister =>
      status == TournamentStatus.registrationOpen && myTeamId == null && item.approvedTeams < item.maxTeams;

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    item: TournamentListItem.fromJson(json),
    playersPerTeam: json['playersPerTeam'] as int,
    substitutesPerTeam: json['substitutesPerTeam'] as int,
    registrationClosesAt: DateTime.parse(json['registrationClosesAt'] as String),
    dailyStartTime: json['dailyStartTime'] as String,
    dailyEndTime: json['dailyEndTime'] as String,
    matchMinutes: json['matchMinutes'] as int,
    courts: (json['courts'] as List? ?? const []).cast<Map<String, dynamic>>().map((c) => c['name'] as String).toList(),
    courtRefs: (json['courts'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((c) => (id: c['id'] as String, name: c['name'] as String))
        .toList(),
    description: json['description'] as String?,
    rules: json['rules'] as String?,
    prizes: json['prizes'] as String?,
    groupsCount: json['groupsCount'] as int?,
    qualifiersPerGroup: json['qualifiersPerGroup'] as int?,
    champion: json['champion'] == null ? null : TeamSummary.fromJson(json['champion'] as Map<String, dynamic>),
    cancellationReason: json['cancellationReason'] as String?,
    myTeamId: json['myTeamId'] as String?,
  );
}

class TeamMember {
  const TeamMember({required this.player, required this.isSubstitute, required this.status, required this.isCaptain});

  final Person player;
  final bool isSubstitute;
  final MemberStatus status;
  final bool isCaptain;

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    player: Person.fromJson(json['player'] as Map<String, dynamic>),
    isSubstitute: json['isSubstitute'] as bool? ?? false,
    status: MemberStatus.fromApi(json['status']),
    isCaptain: json['isCaptain'] as bool? ?? false,
  );
}

class Team {
  const Team({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.name,
    required this.captain,
    required this.status,
    required this.members,
    this.logoUrl,
    this.seed,
    this.groupNumber,
    this.rejectionReason,
  });

  final String id;
  final String tournamentId;
  final String tournamentName;
  final String name;
  final Person captain;
  final TeamStatus status;
  final List<TeamMember> members;
  final String? logoUrl;
  final int? seed;
  final int? groupNumber;
  final String? rejectionReason;

  List<TeamMember> get activeMembers =>
      members.where((m) => m.status == MemberStatus.accepted || m.status == MemberStatus.invited).toList();

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'] as String,
    tournamentId: json['tournamentId'] as String,
    tournamentName: json['tournamentName'] as String? ?? '',
    name: json['name'] as String? ?? '',
    captain: Person.fromJson(json['captain'] as Map<String, dynamic>),
    status: TeamStatus.fromApi(json['status']),
    members: (json['members'] as List? ?? const []).cast<Map<String, dynamic>>().map(TeamMember.fromJson).toList(),
    logoUrl: json['logoUrl'] as String?,
    seed: json['seed'] as int?,
    groupNumber: json['groupNumber'] as int?,
    rejectionReason: json['rejectionReason'] as String?,
  );
}

class TournamentMatch {
  const TournamentMatch({
    required this.id,
    required this.stage,
    required this.round,
    required this.number,
    required this.status,
    required this.isBye,
    this.groupNumber,
    this.home,
    this.away,
    this.homeScore,
    this.awayScore,
    this.winnerTeamId,
    this.resultNote,
    this.courtName,
    this.day,
    this.startTime,
    this.endTime,
  });

  final String id;
  final TournamentStage stage;
  final int round;
  final int number;
  final TournamentMatchStatus status;
  final bool isBye;
  final int? groupNumber;
  final TeamSummary? home;
  final TeamSummary? away;
  final int? homeScore;
  final int? awayScore;
  final String? winnerTeamId;
  final String? resultNote;
  final String? courtName;
  final String? day;
  final String? startTime;
  final String? endTime;

  factory TournamentMatch.fromJson(Map<String, dynamic> json) => TournamentMatch(
    id: json['id'] as String,
    stage: TournamentStage.fromApi(json['stage']),
    round: json['round'] as int,
    number: json['number'] as int,
    status: TournamentMatchStatus.fromApi(json['status']),
    isBye: json['isBye'] as bool? ?? false,
    groupNumber: json['groupNumber'] as int?,
    home: json['home'] == null ? null : TeamSummary.fromJson(json['home'] as Map<String, dynamic>),
    away: json['away'] == null ? null : TeamSummary.fromJson(json['away'] as Map<String, dynamic>),
    homeScore: json['homeScore'] as int?,
    awayScore: json['awayScore'] as int?,
    winnerTeamId: json['winnerTeamId'] as String?,
    resultNote: json['resultNote'] as String?,
    courtName: (json['court'] as Map<String, dynamic>?)?['name'] as String?,
    day: json['day'] as String?,
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
  );
}

class StandingRow {
  const StandingRow({
    required this.rank,
    required this.team,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalDifference,
    required this.points,
  });

  final int rank;
  final TeamSummary team;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;

  factory StandingRow.fromJson(Map<String, dynamic> json) => StandingRow(
    rank: json['rank'] as int,
    team: TeamSummary.fromJson(json['team'] as Map<String, dynamic>),
    played: json['played'] as int,
    won: json['won'] as int,
    drawn: json['drawn'] as int,
    lost: json['lost'] as int,
    goalDifference: json['goalDifference'] as int,
    points: json['points'] as int,
  );
}

class GroupStandings {
  const GroupStandings({required this.groupNumber, required this.rows});

  final int? groupNumber;
  final List<StandingRow> rows;

  factory GroupStandings.fromJson(Map<String, dynamic> json) => GroupStandings(
    groupNumber: json['groupNumber'] as int?,
    rows: (json['rows'] as List).cast<Map<String, dynamic>>().map(StandingRow.fromJson).toList(),
  );
}

class Invitation {
  const Invitation({
    required this.teamId,
    required this.teamName,
    required this.tournamentName,
    required this.startDate,
    required this.captain,
    required this.isSubstitute,
  });

  final String teamId;
  final String teamName;
  final String tournamentName;
  final String startDate;
  final Person captain;
  final bool isSubstitute;

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
    teamId: json['teamId'] as String,
    teamName: json['teamName'] as String? ?? '',
    tournamentName: json['tournamentName'] as String? ?? '',
    startDate: json['startDate'] as String,
    captain: Person.fromJson(json['captain'] as Map<String, dynamic>),
    isSubstitute: json['isSubstitute'] as bool? ?? false,
  );
}

enum PayMethod {
  card('Card'),
  wallet('Wallet');

  const PayMethod(this.apiName);
  final String apiName;
}
