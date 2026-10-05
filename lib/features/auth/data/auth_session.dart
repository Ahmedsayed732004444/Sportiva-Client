class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.token,
    required this.refreshToken,
    required this.refreshTokenExpiration,
  });

  final String userId;
  final String? email;
  final String firstName;
  final String lastName;
  final String token;
  final String refreshToken;
  final DateTime refreshTokenExpiration;

  String get fullName => '$firstName $lastName'.trim();

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    userId: json['id'] as String,
    email: json['email'] as String?,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    token: json['token'] as String,
    refreshToken: json['refreshToken'] as String,
    refreshTokenExpiration: DateTime.parse(json['refreshTokenExpiration'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': userId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'token': token,
    'refreshToken': refreshToken,
    'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
  };
}
