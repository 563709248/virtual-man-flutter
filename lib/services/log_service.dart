import 'dart:developer' as developer;

class LogService {
  void log(String msg) {
    developer.log(msg, name: 'ai.friend.network', level: 800, error: null);
  }

  void errorLog(String msg, int level, String error) {
    developer.log(msg, name: 'ai.friend.network', level: level, error: error);
  }
}
