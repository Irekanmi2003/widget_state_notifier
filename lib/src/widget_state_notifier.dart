import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Enum defining control signals for managing state in [WidgetStateNotifier].
enum WidgetStateControl {
  /// Signals to resume state processing.
  resume,

  /// Signals to start state processing.
  start,

  /// Signals to end state processing.
  end,

  /// Signals to stop state processing.
  stop,

  /// Signals an error in state processing.
  error,

  /// Signals data availability in state processing.
  data,

  /// Signals to pause state processing.
  pause,

  /// Signals a lag in state processing.
  lag,

  /// Signals state processing is over.
  over,

  /// Signals a custom state control.
  custom,

  /// Signals the initial state.
  initial
}

/// A generic class for managing state and broadcasting changes to listeners.
class WidgetStateNotifier<T> {
  /// The current value of the state.
  T? currentValue;
  WidgetStateControl currentStateControl = WidgetStateControl.initial;

  /// Private [StreamController] for broadcasting state changes.
  final StreamController<T?> _streamController =
      StreamController<T?>.broadcast();

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
  Stream<T?> get stream => _streamController.stream;

  /// Sends a new state to the [WidgetStateNotifier] and notifies listeners.
  ///
  /// This method updates the current state of the notifier to [state] and broadcasts
  /// the state change to all registered listeners. Any widgets consuming the state
  /// through the notifier's stream will be rebuilt with the new state.
  ///
  /// Parameters:
  ///   - state: The new state to be sent to listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendNewState(newValue);
  /// ```
  void sendNewState(T? state) {
    currentValue = state;
    _streamController.add(state);
  }

  /// Method for sending a new state with control and notifying listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendNewState(newValue,stateControl);
  /// ```
  void sendNewStateWithControl(
      T? state, WidgetStateControl widgetStateControl) {
    currentValue = state;
    currentStateControl = widgetStateControl;
    _streamController.add(state);
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

/// A function signature for the builder function used in WidgetStateConsumer.
typedef WidgetControlStateBuilder<D> = Widget Function(
    BuildContext context, D? data, WidgetStateControl widgetStateControl);

/// A widget for consuming state changes from a [WidgetStateNotifier] and rebuilding its child widget in response to state changes.
class WidgetStateConsumer<T> extends StatefulWidget {
  /// [WidgetStateNotifier] instances to consume state changes.
  final WidgetStateNotifier<T> widgetStateNotifier;

  /// The builder function that returns the child widget to be rebuilt in response to state changes.
  final WidgetStateBuilder<T>? widgetStateBuilder;

  /// The builder function that returns the child widget with controls to be rebuilt in response to state changes.
  final WidgetControlStateBuilder<T>? widgetControlStateBuilder;

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
      this.widgetStateBuilder,
      this.widgetControlStateBuilder})
      : assert(widgetControlStateBuilder != null &&
                widgetStateBuilder == null ||
            widgetControlStateBuilder == null && widgetStateBuilder != null),
        assert(widgetControlStateBuilder != null || widgetStateBuilder != null);

  @override
  State<WidgetStateConsumer<T>> createState() => _WidgetStateConsumerState<T>();
}

class _WidgetStateConsumerState<T> extends State<WidgetStateConsumer<T>> {
  T? stateValue;
  WidgetStateControl stateControl = WidgetStateControl.initial;
  StreamSubscription? streamSubscription;

  @override
  void didUpdateWidget(covariant WidgetStateConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    streamSubscription?.cancel();
    streamSubscription = null;
    sendState(widget.widgetStateNotifier.currentValue,
        widget.widgetStateNotifier.currentStateControl);
    manageState();
  }

  @override
  void initState() {
    super.initState();
    sendState(widget.widgetStateNotifier.currentValue,
        widget.widgetStateNotifier.currentStateControl);
    manageState();
  }

  void sendState(T? value, WidgetStateControl widgetStateControl) {
    setState(() {
      stateControl = widgetStateControl;
      stateValue = value;
    });
  }

  void manageState() {
    streamSubscription ??= widget.widgetStateNotifier.stream.listen((event) {
      final stateControl = widget.widgetStateNotifier.currentStateControl;
      sendState(event, stateControl);
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
    streamSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.widgetStateBuilder != null) {
      return widget.widgetStateBuilder!(context, stateValue);
    } else {
      return widget.widgetControlStateBuilder!(
          context, stateValue, stateControl);
    }
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
      return WidgetStateConsumer<dynamic>(
          widgetStateNotifier: thisWidgetStateNotifier,
          widgetControlStateBuilder: null,
          widgetStateBuilder: (context, snapshot) {
            return widgetStateListBuilder(context);
          });
    } else {
      /// Getting the indexed [WidgetStateNotifier] since it is valid
      WidgetStateNotifier thisWidgetStateNotifier =
          widgetStateListNotifiers[index];
      return WidgetStateConsumer<dynamic>(
          widgetStateNotifier: thisWidgetStateNotifier,
          widgetStateBuilder: (context, snapshot) {
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
