import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionController {
  var uuid = const Uuid();

  Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    if (sessionId == null) {
      sessionId = uuid.v4();
      await prefs.setString('sessionId', sessionId);
    }
    return sessionId;
  }

  // Xóa sessionId khỏi SharedPreferences
  Future<void> clearSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
  }

  String getRandomSessionId() {
    return uuid.v4();
  }
}
