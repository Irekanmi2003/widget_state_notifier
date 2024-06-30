import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  testWidgets('WidgetStateConsumer rebuilds child widget with error text',
      (WidgetTester tester) async {
    // Create a WidgetStateNotifier instance
    WidgetStateNotifier<int> notifier = WidgetStateNotifier<int>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetStateConsumer<int>(
            widgetStateNotifier: notifier,
            widgetControlStateBuilder: (context, data, control) {
              // Conditionally display error text if control is error
              if (control == WidgetStateControl.error) {
                return const Text('Error');
              } else {
                return Text(data.toString());
              }
            },
          ),
        ),
      ),
    );

    // Send a new state with control signal error
    notifier.sendStateWithControl(WidgetStateControl.error);

    // Wait for the widget to rebuild
    await tester.pump();

    // Expect that the error text widget is displayed
    expect(find.text('Error'), findsOneWidget);
  });
}
