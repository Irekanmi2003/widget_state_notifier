import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late WidgetStateNotifier<int> counterStateNotifier;

  @override
  void initState() {
    super.initState();
    // Initialize the counter state notifier with an initial value of 0
    counterStateNotifier = WidgetStateNotifier<int>(currentValue: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // WidgetStateConsumer listens to changes in counterStateNotifier
            WidgetStateConsumer<int>(
              widgetStateNotifier: counterStateNotifier,
              // Rebuilds the Text widget whenever the counter value changes
              widgetStateBuilder: (context, data) {
                return Text(
                  'Counter Value: ${data ?? 0}',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Increment the counter value
                    counterStateNotifier
                        .sendNewState(counterStateNotifier.currentValue! + 1);
                  },
                  child: const Text('Increment'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Decrement the counter value
                    counterStateNotifier
                        .sendNewState(counterStateNotifier.currentValue! - 1);
                  },
                  child: const Text('Decrement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
