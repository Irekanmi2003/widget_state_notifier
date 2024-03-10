# widget_state_notifier

A simple yet powerful state management library for Flutter applications. It provides the `WidgetStateNotifier` class for managing state and broadcasting changes to listeners, and the `WidgetStateConsumer` widget for consuming state changes in your UI.

## Getting Started

Add the `widget_state_notifier` package to your `pubspec.yaml` file:

```yaml
dependencies:
  widget_state_notifier: ^1.0.0
``` 
  
Usage
Using WidgetStateNotifier:

```dart
// Initialize a WidgetStateNotifier instance
WidgetStateNotifier<int> counterStateNotifier = WidgetStateNotifier<int>(currentValue: 0);

// Send a new state
counterStateNotifier.sendNewState(newValue);

// Add a controller to listen for state changes
counterStateNotifier.addController(yourChangeNotifier, yourListenerFunction);

// Dispose the controller when it's no longer needed
counterStateNotifier.removeController();
```

Using WidgetStateConsumer:

```dart
WidgetStateConsumer<int>(
  widgetStateNotifier: counterStateNotifier,
  widgetStateBuilder: (context, data) {
    return Text('Counter Value: $data');
  },
);
```


Example
Here's a simple example of how you can use WidgetStateNotifier and WidgetStateConsumer to manage and consume state in a Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  WidgetStateNotifier<int> counterStateNotifier = WidgetStateNotifier<int>(currentValue: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter Example'),
      ),
      body: Center(
        child: WidgetStateConsumer<int>(
          widgetStateNotifier: counterStateNotifier,
          widgetStateBuilder: (context, data) {
            return Text('Counter Value: $data');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterStateNotifier.sendNewState(counterStateNotifier.currentValue! + 1);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

Features and Limitations
* Efficiently manages state changes and updates UI components only when necessary.
* Provides a simple and lightweight solution for state management in Flutter applications.
* Supports consuming state changes in UI components using the WidgetStateConsumer widget.


Contributions and Feedback
Contributions and feedback are welcome! If you encounter any issues or have suggestions for improvement, please feel free to open an issue or submit a pull request on GitHub [https://github.com/Irekanmi2003/widget_state_notifier].