import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rental_ps/main.dart';
import 'package:rental_ps/providers/admin_provider.dart';
import 'package:rental_ps/providers/booking_provider.dart';
import 'package:rental_ps/providers/clock_service.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
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
        child: const TimelessApp(),
      ),
    );

    // Verify the app title is rendered
    expect(find.text('TIMELESS'), findsWidgets);
  });
}
