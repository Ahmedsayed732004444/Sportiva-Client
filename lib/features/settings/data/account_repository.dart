import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) => AccountRepository(ref.watch(apiClientProvider)));

class AccountProfile {
  const AccountProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.languageCode,
    required this.roles,
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String languageCode;
  final List<String> roles;
  final String? phone;

  // A club's owner or staff: they get the club management section.
  bool get managesClub => roles.contains('Owner') || roles.contains('Staff');
  bool get isOwner => roles.contains('Owner');

  factory AccountProfile.fromJson(Map<String, dynamic> json) => AccountProfile(
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    languageCode: json['preferredLanguage'].toString() == 'Arabic' ? 'ar' : 'en',
    roles: (json['roles'] as List? ?? const []).cast<String>(),
    phone: json['phoneNumber'] as String?,
  );
}

// One kind of notification and where it is wanted.
class NotificationPreference {
  const NotificationPreference({required this.type, required this.inApp, required this.email});

  final String type;
  final bool inApp;
  final bool email;

  NotificationPreference copyWith({bool? inApp, bool? email}) =>
      NotificationPreference(type: type, inApp: inApp ?? this.inApp, email: email ?? this.email);

  factory NotificationPreference.fromJson(Map<String, dynamic> json) => NotificationPreference(
    type: json['type'].toString(),
    inApp: json['inAppEnabled'] as bool? ?? true,
    email: json['emailEnabled'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {'type': type, 'inAppEnabled': inApp, 'emailEnabled': email};
}

class AccountRepository {
  AccountRepository(this._dio);

  final Dio _dio;

  Future<AccountProfile> profile() =>
      _call(() async => AccountProfile.fromJson((await _dio.get<Map<String, dynamic>>('/account/profile')).data!));

  Future<void> updateProfile({required String firstName, required String lastName, String? phone}) => _call(
    () =>
        _dio.put<void>('/account/profile', data: {'firstName': firstName, 'lastName': lastName, 'phoneNumber': phone}),
  );

  Future<void> setLanguage(String languageCode) => _call(
    () => _dio.put<void>(
      '/account/preferences',
      data: {'preferredLanguage': languageCode == 'ar' ? 'Arabic' : 'English'},
    ),
  );

  Future<void> changePassword(String current, String next) =>
      _call(() => _dio.post<void>('/account/change-password', data: {'currentPassword': current, 'newPassword': next}));

  Future<void> requestDeletion() => _call(() => _dio.post<void>('/account/deletion-request'));

  Future<List<NotificationPreference>> notificationPreferences() => _call(() async {
    final data = (await _dio.get<Map<String, dynamic>>('/notifications/preferences')).data!;
    return (data['preferences'] as List).cast<Map<String, dynamic>>().map(NotificationPreference.fromJson).toList();
  });

  Future<void> saveNotificationPreferences(List<NotificationPreference> preferences) => _call(
    () => _dio.put<void>(
      '/notifications/preferences',
      data: {
        'preferences': [for (final p in preferences) p.toJson()],
      },
    ),
  );

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
