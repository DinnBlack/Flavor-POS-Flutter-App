import 'package:shared_preferences/shared_preferences.dart';

class AuthConfig {
  static const String _tokenKey = 'access_token';
  static const String _expiresAtKey = 'expires_at';

  // Lưu token và thời gian hết hạn vào SharedPreferences
  static Future<void> saveToken(String token, DateTime expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiresAtKey, expiresAt.toIso8601String());
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Lấy thời gian hết hạn từ SharedPreferences
  static Future<DateTime?> getExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtString = prefs.getString(_expiresAtKey);
    if (expiresAtString != null) {
      return DateTime.parse(expiresAtString);
    }
    return null;
  }

  // Kiểm tra token có hết hạn không
  static Future<bool> isTokenExpired() async {
    final expiresAt = await getExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  // Xóa token và thời gian hết hạn khỏi SharedPreferences
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiresAtKey);
  }

}
