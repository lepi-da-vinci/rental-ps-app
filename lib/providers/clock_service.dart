import 'dart:async';
import 'package:flutter/foundation.dart';

/// Provides a reactive wall-clock time that updates every minute.
///
/// Uses [Stream.periodic] instead of [Timer.periodic] for safer
/// memory management — the [StreamSubscription] is automatically
/// cleaned up on [dispose].
class ClockService extends ChangeNotifier {
  DateTime _now = DateTime.now();
  late final StreamSubscription<DateTime> _subscription;

  ClockService() {
    _subscription = Stream.periodic(
      const Duration(seconds: 60),
      (_) => DateTime.now(),
    ).listen((tick) {
      _now = tick;
      notifyListeners();
    });
  }

  /// Current wall-clock time, updated every ~60 seconds.
  DateTime get now => _now;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
