import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ta_mobile/main.dart';
import 'package:ta_mobile/providers/booking_provider.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BookingProvider(),
        child: const TimelessApp(),
      ),
    );

    // Verify the app title is rendered
    expect(find.text('TIMELESS'), findsWidgets);
  });
}
