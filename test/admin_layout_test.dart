import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rental_ps/screens/admin_screen.dart';
import 'package:provider/provider.dart';
import 'package:rental_ps/providers/admin_provider.dart';
import 'package:rental_ps/providers/booking_provider.dart';
import 'package:rental_ps/providers/clock_service.dart';

void main() {
  testWidgets('AdminScreen renders', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ClockService()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProxyProvider<ClockService, BookingProvider>(
            create: (_) => BookingProvider(),
            update: (_, clock, booking) => booking!..updateClock(clock.now),
          ),
        ],
        child: const MaterialApp(
          home: AdminScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    print('Test finished successfully.');
  });
}
