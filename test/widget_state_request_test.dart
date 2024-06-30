import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  group('WidgetStateRequest Tests', () {
    late WidgetStateRequest<String, String> widgetStateRequest;

    setUp(() {
      // Initialize WidgetStateRequest before each test
      widgetStateRequest = WidgetStateRequest<String, String>();
    });

    // tearDown(() {
    //   // Clean up after each test
    //   widgetStateRequest.dispose();
    // });

    test('Test sending and receiving request', () {
      // Create a Completer to wait for the response
      Completer<String?> completer = Completer<String?>();

      // Add a listener for a specific state
      widgetStateRequest.addRequestListener('fetchData', (data) {
        completer.complete(data);
      });

      // Send a request
      widgetStateRequest.sendRequest('fetchData', data: 'Request payload');

      // Wait for the response and assert the result
      expect(completer.future, completion('Request payload'));
    });

    test('Test removing request listener', () {
      // Create a Completer to wait for the response
      Completer<String?> completer = Completer<String?>();

      // Add a listener for a specific state
      listener(data) {
        completer.complete(data);
      }
      widgetStateRequest.addRequestListener('fetchData', listener);

      // Remove the listener
      widgetStateRequest.removeRequestListener('fetchData');

      // Send a request (the listener should not receive it)
      widgetStateRequest.sendRequest('fetchData', data: 'Request payload');

      // Ensure the completer doesn't complete (i.e., listener wasn't called)
      expect(completer.future, doesNotComplete);
    });

    // Add more tests as needed for other functionalities
  });
}
