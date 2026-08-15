import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static CacheService? _instance;
  static SharedPreferences? _preferences;

  CacheService._();
  factory CacheService() => _instance ?? CacheService._();

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // handle store API user token in cache
  Future<void> setToken(String token) async =>
      await _preferences?.setString(_Keys.token, token);

  bool get hasToken => _preferences?.containsKey(_Keys.token) ?? false;

  Future<void> removeToken() async => await _preferences?.remove(_Keys.token);

  String get token => _preferences?.getString(_Keys.token) ?? "no token";

  Future<void> setRefreshToken(String refreshToken) async =>
      await _preferences?.setString(_Keys.refreshToken, refreshToken);

  bool get hasRefreshToken =>
      _preferences?.containsKey(_Keys.refreshToken) ?? false;

  Future<void> removeRefreshToken() async =>
      await _preferences?.remove(_Keys.refreshToken);

  String get refreshToken =>
      _preferences?.getString(_Keys.refreshToken) ?? "no refresh token";

  // Theme
  Future<void> setTheme(bool theme) async =>
      await _preferences?.setBool(_Keys.theme, theme);

  Future<void> removeTheme() async => await _preferences?.remove(_Keys.theme);

  bool get hasTheme => _preferences?.containsKey(_Keys.theme) ?? false;

  bool get theme => _preferences?.getBool(_Keys.theme) ?? false;

  Future<void> initCacheTheme() async {
    if (hasTheme) return;
    await setTheme(false);
  }

  //language
  Future<void> setLanguage(bool language) async =>
      await _preferences?.setBool(_Keys.language, language);

  Future<void> removeLanguage() async =>
      await _preferences?.remove(_Keys.language);

  bool get hasLanguage => _preferences?.containsKey(_Keys.language) ?? false;

  bool get language => _preferences?.getBool(_Keys.language) ?? false;

  Future<void> initCacheLanguage() async {
    if (hasLanguage) return;
    await setLanguage(false);
  }

  // User info
  Future<void> setUser(String userJson) async =>
      await _preferences?.setString(_Keys.user, userJson);

  bool get hasUser => _preferences?.containsKey(_Keys.user) ?? false;

  Future<void> removeUser() async => await _preferences?.remove(_Keys.user);

  String get user => _preferences?.getString(_Keys.user) ?? "";

  Future<void> setUserRole(String role) async =>
      await _preferences?.setString(_Keys.userRole, role);

  bool get hasUserRole => _preferences?.containsKey(_Keys.userRole) ?? false;

  Future<void> removeUserRole() async =>
      await _preferences?.remove(_Keys.userRole);

  String get userRole => _preferences?.getString(_Keys.userRole) ?? "";

  // Backend account id (Parse `objectId`) of the logged-in user. Needed to
  // derive the supervisor's BLE identifier for Live Co-Sign advertising —
  // not persisted anywhere else in the app before this.
  Future<void> setUserId(String userId) async =>
      await _preferences?.setString(_Keys.userId, userId);

  bool get hasUserId => _preferences?.containsKey(_Keys.userId) ?? false;

  Future<void> removeUserId() async =>
      await _preferences?.remove(_Keys.userId);

  String get userId => _preferences?.getString(_Keys.userId) ?? "";

  Future<void> clearAuth() async {
    await removeToken();
    await removeRefreshToken();
    await removeUser();
    await removeUserRole();
    await removeUserId();
  }
}

class _Keys {
  static const String token = "token";
  static const String refreshToken = "refresh_token";
  static const String theme = "theme";
  static const String language = "language";
  static const String user = "user";
  static const String userRole = "user_role";
  static const String userId = "user_id";
}
