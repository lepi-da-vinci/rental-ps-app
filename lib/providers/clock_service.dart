import 'dart:async';
import 'package:flutter/widgets.dart';

class ClockService extends ChangeNotifier {
  DateTime _now = DateTime.now();
  Timer? _timer;

  ClockService() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final tick = DateTime.now();
      _now = tick;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  DateTime get now => _now;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
