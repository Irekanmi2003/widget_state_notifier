import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  testWidgets(
      'MultiWidgetStateConsumer rebuilds child widget for multiple notifiers',
      (WidgetTester tester) async {
    // Create WidgetStateNotifier instances
    WidgetStateNotifier<int> notifier1 = WidgetStateNotifier<int>();
    WidgetStateNotifier<int> notifier2 = WidgetStateNotifier<int>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiWidgetStateConsumer(
            widgetStateListNotifiers: [notifier1, notifier2],
            widgetStateListBuilder: (context) {
              return Text(
                  'Multiple notifiers ${notifier1.currentValue} ${notifier2.currentValue}');
            },
          ),
        ),
      ),
    );

    // Send a new state to notifier1
    notifier1.sendNewState(42);
    // Send a new state to notifier2
    notifier2.sendNewState(100);

    // Expect that the Text widget displays the correct content
    await tester.pump(); // Wait for the widget to rebuild
    expect(find.text('Multiple notifiers 42 100'), findsOneWidget);
  });
}
