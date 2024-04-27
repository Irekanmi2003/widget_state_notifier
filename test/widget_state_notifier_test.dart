import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  test('WidgetStateNotifier sends new state', () {
    // Create a WidgetStateNotifier instance
    WidgetStateNotifier<int> notifier = WidgetStateNotifier<int>();

    // Expect that the received state matches the sent state
    expectLater(notifier.stream, emits(42));

    // Send a new state
    notifier.sendNewState(42);
  });
}
