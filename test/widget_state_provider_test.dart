import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  group('WidgetStateProvider Tests', () {
    testWidgets('provides and updates state', (WidgetTester tester) async {
      final notifier = WidgetStateNotifier<int>(currentValue: 0);

      await tester.pumpWidget(
        WidgetStateProvider<int>(
          notifier: notifier,
          child: const MaterialApp(
            home: Scaffold(
              body: CounterWidget(),
            ),
          ),
        ),
      );

      // Initial state check
      expect(find.text('Counter: 0'), findsOneWidget);

      // Update state
      notifier.sendNewState(1);
      await tester.pump();

      // Check updated state
      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('accesses state from the context', (WidgetTester tester) async {
      final notifier = WidgetStateNotifier<int>(currentValue: 42);

      await tester.pumpWidget(
        WidgetStateProvider<int>(
          notifier: notifier,
          child: const MaterialApp(
            home: Scaffold(
              body: CounterWidget(),
            ),
          ),
        ),
      );

      // Check if the widget tree accesses the correct state value
      expect(find.text('Counter: 42'), findsOneWidget);
    });
  });
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = WidgetStateProvider.of<int>(context)!;

    return Center(
      child: StreamBuilder<int?>(
        stream: notifier.stream,
        initialData: notifier.currentValue,
        builder: (context, snapshot) {
          return Text('Counter: ${snapshot.data}');
        },
      ),
    );
  }
}
