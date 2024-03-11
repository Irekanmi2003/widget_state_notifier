import 'dart:async';

import 'package:flutter/cupertino.dart';

/// A generic class for managing state and broadcasting changes to listeners.
class WidgetStateNotifier<T> {
  /// The current value of the state.
  T? currentValue;

  /// A [StreamController] for broadcasting state changes.
  StreamController<T?> streamController = StreamController<T?>.broadcast();

  /// A constructor for initializing the [WidgetStateNotifier] with an optional initial value.
  ///
  /// Example:
  /// ```dart
  /// WidgetStateNotifier<int> counterStateNotifier = WidgetStateNotifier<int>(currentValue: 0);
  /// ```
  WidgetStateNotifier({this.currentValue});

  /// Private variables to manage listeners and notifier state.
  Function(WidgetStateNotifier<T> stateNotifier)? _listener;
  bool _notifierAdded = false;
  Listenable? _notifier;

  /// Getter for accessing the state change stream.
  Stream<T?> get stream => streamController.stream;

  /// Method for sending a new state and notifying listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendNewState(newValue);
  /// ```
  void sendNewState(T? state) {
    currentValue = state;
    streamController.add(state);
  }

  /// Private listener function for internal use.
  void _listenerFunction() {
    _listener?.call(this);
  }

  /// Method for adding a [Listenable] as a controller to listen for state changes.
  ///
  /// Returns `true` if the controller was successfully added, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.addController(yourChangeNotifier, yourListenerFunction);
  /// ```
  bool addController<G>(Listenable notifier,
      Function(WidgetStateNotifier<T> stateNotifier) listener) {
    if (!_notifierAdded) {
      _notifier = notifier;
      _listener = listener;
      (notifier).addListener(_listenerFunction);
      _notifierAdded = true;
      return true;
    }
    return false;
  }

  /// Optional Method for disposing the controller and removing listeners.
  ///
  /// Returns `true` if the controller was successfully disposed and listener was removed, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.removeController();
  /// ```
  bool removeController({Function()? disposeMethod}) {
    if (_notifierAdded && _notifier != null) {
      _notifierAdded = false;
      _notifier?.removeListener(_listenerFunction);
      disposeMethod?.call();
      _notifier = null;
      return _notifier == null;
    }
    return false;
  }
}

/// A function signature for the builder function used in WidgetStateConsumer.
typedef WidgetStateBuilder<D> = Widget Function(BuildContext context, D? data);

/// A widget for consuming state changes from a [WidgetStateNotifier] and rebuilding its child widget in response to state changes.
class WidgetStateConsumer<T> extends StatelessWidget {
  /// [WidgetStateNotifier] instances to consume state changes.
  final WidgetStateNotifier<T> widgetStateNotifier;

  /// The builder function that returns the child widget to be rebuilt in response to state changes.
  final WidgetStateBuilder<T> widgetStateBuilder;

  /// Constructs a [WidgetStateConsumer] with the given [widgetStateNotifier] and [widgetStateBuilder].
  ///
  /// Example:
  /// ```dart
  /// WidgetStateConsumer<int>(
  ///   widgetStateNotifier: counterStateNotifier,
  ///   widgetStateBuilder: (context, data) {
  ///     return Text('Counter Value: $data');
  ///   },
  /// );
  /// ```
  const WidgetStateConsumer(
      {super.key,
      required this.widgetStateNotifier,
      required this.widgetStateBuilder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T?>(
      initialData: widgetStateNotifier.currentValue,
      stream: widgetStateNotifier.stream,
      builder: (context, snapshot) =>
          widgetStateBuilder(context, snapshot.data),
    );
  }
}

/// A function signature for the builder function used in MultiWidgetStateConsumer.
typedef WidgetStateListBuilder = Widget Function(BuildContext context);

/// A widget for consuming state changes from multiple [WidgetStateNotifier] instances
/// and rebuilding its child widget in response to state changes.
class MultiWidgetStateConsumer extends StatelessWidget {
  /// The list of [WidgetStateNotifier] instances to consume state changes from.
  final List<WidgetStateNotifier> widgetStateListNotifiers;

  /// The builder function that returns the child widget to be rebuilt in response to state changes.
  final WidgetStateListBuilder widgetStateListBuilder;

  /// Constructs a [MultiWidgetStateConsumer] with the given [widgetStateListNotifiers]
  /// and [widgetStateListBuilder].
  ///
  /// Example:
  /// ```dart
  /// MultiWidgetStateConsumer(
  ///   widgetStateListNotifiers: [notifier1, notifier2],
  ///   widgetStateListBuilder: (context) {
  ///     // Build your widget tree based on state changes from multiple notifiers
  ///   },
  /// );
  /// ```
  const MultiWidgetStateConsumer({
    super.key,
    required this.widgetStateListNotifiers,
    required this.widgetStateListBuilder,
  });

  /// Recursively builds nested [StreamBuilder] widgets for each [WidgetStateNotifier]
  /// in the [widgetStateListNotifiers] list, allowing for multiple state consumers
  /// within the same widget tree.
  Widget _buildNestedWidgets(int index) {
    if ((index + 1) == widgetStateListNotifiers.length) {
      /// Getting the last [WidgetStateNotifier] since it is valid
      WidgetStateNotifier thisWidgetStateNotifier =
          widgetStateListNotifiers[index];
      return StreamBuilder(
          initialData: thisWidgetStateNotifier.currentValue,
          stream: thisWidgetStateNotifier.stream,
          builder: (context, snapshot) {
            return widgetStateListBuilder(context);
          });
    } else {
      /// Getting the indexed [WidgetStateNotifier] since it is valid
      WidgetStateNotifier thisWidgetStateNotifier =
          widgetStateListNotifiers[index];
      return StreamBuilder(
          initialData: thisWidgetStateNotifier.currentValue,
          stream: thisWidgetStateNotifier.stream,
          builder: (context, snapshot) {
            return _buildNestedWidgets(index + 1);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widgetStateListNotifiers.isEmpty) {
      return widgetStateListBuilder(context);
    } else {
      return _buildNestedWidgets(0);
    }
  }
}
