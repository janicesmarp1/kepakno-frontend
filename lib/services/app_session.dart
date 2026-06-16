class AppSession {
  static String? accessToken;
  static String? refreshToken;
  static Map<String, dynamic>? user;

  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  static String get authorizationHeader => 'Bearer $accessToken';

  static void saveLoginData(Map<String, dynamic> data) {
    accessToken = data['accessToken']?.toString() ??
        data['access_token']?.toString() ??
        data['token']?.toString() ??
        data['jwt']?.toString();

    refreshToken = data['refreshToken']?.toString() ??
        data['refresh_token']?.toString();

    final rawUser = data['user'];

    if (rawUser is Map<String, dynamic>) {
      user = rawUser;
    } else if (rawUser is Map) {
      user = rawUser.map((key, value) => MapEntry(key.toString(), value));
    }
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
    user = null;
  }
}