import 'package:flutter/material.dart';
import '../models/ps_unit.dart';
import '../models/booking.dart';
import 'clay_console_card.dart';

/// A card widget that displays a live 3D Claymorphism card with countdown timer for an active PS unit session.
class SessionTimerCard extends StatelessWidget {
  final UnitStatus unit;
  final Booking? activeBooking;
  final int? remainingSeconds;
  final SessionTimerStatus timerStatus;
  final VoidCallback? onExtend;
  final VoidCallback? onFinish;
  final VoidCallback? onChangeGame;

  const SessionTimerCard({
    super.key,
    required this.unit,
    required this.activeBooking,
    required this.remainingSeconds,
    required this.timerStatus,
    this.onExtend,
    this.onFinish,
    this.onChangeGame,
  });

  @override
  Widget build(BuildContext context) {
    return ClayConsoleCard(
      unit: unit,
      activeBooking: activeBooking,
      remainingSeconds: remainingSeconds,
      timerStatus: timerStatus,
      onExtend: onExtend,
      onFinish: onFinish,
      onChangeGame: onChangeGame,
    );
  }
}
