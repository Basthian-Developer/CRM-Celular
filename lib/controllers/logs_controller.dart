import 'package:flutter/foundation.dart';

import '../models/app_log.dart';

class LogsController extends ChangeNotifier {
  final List<AppLog> _logs = [];

  List<AppLog> get logs => List.unmodifiable(_logs.reversed);

  void add(String message) {
    _logs.add(AppLog(message: message, createdAt: DateTime.now()));
    if (_logs.length > 100) _logs.removeAt(0);
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}
