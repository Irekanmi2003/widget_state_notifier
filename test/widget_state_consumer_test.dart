import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  testWidgets('WidgetStateConsumer rebuilds child widget',
      (WidgetTester tester) async {
    // Create a WidgetStateNotifier instance
    WidgetStateNotifier<int> notifier = WidgetStateNotifier<int>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetStateConsumer<int>(
            widgetStateNotifier: notifier,
            widgetStateBuilder: (context, data) {
              return Text(data.toString());
            },
          ),
        ),
      ),
    );

    // Send a new state
    notifier.sendNewState(42);

    // Expect that the Text widget displays the correct state
    await tester.pump(); // Wait for the widget to rebuild
    expect(find.text('42'), findsOneWidget);
  });
}
