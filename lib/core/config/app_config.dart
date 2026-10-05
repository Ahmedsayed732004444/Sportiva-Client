abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://sportivaa.runasp.net');

  // The Web client ID of the Google project the API validates tokens for (Authentication:Google:ClientId).
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '380794323294-iv4dv1u15k677m1783n4s8ggv9j2mdtt.apps.googleusercontent.com',
  );
}
