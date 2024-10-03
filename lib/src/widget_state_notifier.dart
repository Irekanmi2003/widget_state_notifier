import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Class defining control signals for managing state in [WidgetStateNotifier].
class WidgetStateControl {
  final String value;

  const WidgetStateControl._(this.value);

  /// Signals to resume state processing.
  static const WidgetStateControl resume = WidgetStateControl._('resume');

  /// Signals to start state processing.
  static const WidgetStateControl start = WidgetStateControl._('start');

  /// Signals to end state processing.
  static const WidgetStateControl end = WidgetStateControl._('end');

  /// Signals to stop state processing.
  static const WidgetStateControl stop = WidgetStateControl._('stop');

  /// Signals an error in state processing.
  static const WidgetStateControl error = WidgetStateControl._('error');

  /// Signals data availability in state processing.
  static const WidgetStateControl data = WidgetStateControl._('data');

  /// Signals to pause state processing.
  static const WidgetStateControl pause = WidgetStateControl._('pause');

  /// Signals a lag in state processing.
  static const WidgetStateControl lag = WidgetStateControl._('lag');

  /// Signals state processing is over.
  static const WidgetStateControl over = WidgetStateControl._('over');

  /// Signals a custom state control.
  static const WidgetStateControl custom = WidgetStateControl._('custom');

  /// Signals the initial state.
  static const WidgetStateControl initial = WidgetStateControl._('initial');

  /// Signals the loading state.
  static const WidgetStateControl loading = WidgetStateControl._('loading');

  /// Factory [WidgetStateControl] to create a custom control signal.
  factory WidgetStateControl.customState(String value) {
    return WidgetStateControl._(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetStateControl &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'WidgetStateControl.$value';
}

/// A generic class for managing state and broadcasting changes to listeners.
class WidgetStateNotifier<T> {
  /// The current value of the state.
  T? currentValue;
  WidgetStateControl currentStateControl = WidgetStateControl.initial;

  /// Private [StreamController] for broadcasting state changes.
  final StreamController<T?> _streamController =
      StreamController<T?>.broadcast();

  /// Constructor for initializing the [WidgetStateNotifier] with an optional initial value.
  ///
  /// Example:
  /// ```dart
  /// WidgetStateNotifier<int> counterStateNotifier = WidgetStateNotifier<int>(currentValue: 0);
  /// ```
  WidgetStateNotifier(
      {this.currentValue,
      this.currentStateControl = WidgetStateControl.initial});

  /// Private variables to manage listeners and notifier state.
  Function(WidgetStateNotifier<T> stateNotifier)? _listener;
  bool _notifierAdded = false;
  Listenable? _notifier;

  /// Getter for accessing the state change stream.
  Stream<T?> get stream => _streamController.stream;

  /// Sends a new state to the [WidgetStateNotifier] and notifies listeners.
  ///
  /// Parameters:
  ///   - state: The new state to be sent to listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendNewState(newValue);
  /// ```
  void sendNewState(T? state) {
    if (state != currentValue) {
      currentValue = state;
      _streamController.add(state);
    }
  }

  /// Sends an update to the [WidgetStateNotifier] and notifies listeners.

  /// Example:
  /// ```dart
  /// counterStateNotifier.sendForUpdate(newValue);
  /// ```
  void sendForUpdate() {
    _streamController.add(currentValue);
  }

  /// Method for sending a new state with control and notifying listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendStateWithControl(stateControl, state: newValue);
  /// ```
  void sendStateWithControl(WidgetStateControl widgetStateControl, {T? state}) {
    if (currentValue != state) {
      currentValue = state;
    }
    currentStateControl = widgetStateControl;
    _streamController.add(state);
  }

  /// Method for sending an updated control and notifying listeners.
  ///
  /// Example:
  /// ```dart
  /// counterStateNotifier.sendUpdatedControl(stateControl);
  /// ```
  void sendUpdatedControl(WidgetStateControl widgetStateControl) {
    currentStateControl = widgetStateControl;
    _streamController.add(currentValue);
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

  /// Optional method for disposing the controller and removing listeners.
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

  /// Disposes the [WidgetStateNotifier] by closing the [StreamController]
  /// and removing any attached listeners.
  void dispose() {
    // Close the stream controller to release the stream.
    _streamController.close();

    // Remove any listener attached to the notifier, if present.
    if (_notifier != null && _notifierAdded) {
      _notifier?.removeListener(_listenerFunction);
    }

    // Reset the notifier and listener flags.
    _notifier = null;
    _notifierAdded = false;
    _listener = null;
  }
}

/// Exception to indicate restricted usage of state modification.
class RestrictedWidgetStateException implements Exception {
  /// The method called.
  final String method;

  /// Constructor for method value.
  RestrictedWidgetStateException(this.method);

  @override
  String toString() {
    return 'RestrictedWidgetStateException: $method call() is not available in the restricted class.';
  }
}

/// Extension on [WidgetStateNotifier] for restricting modification of state.
extension RestrictedWidgetStateExtention on WidgetStateNotifier {
  /// An extension of [WidgetStateNotifier] for restricting modification of
  /// state and only exposing read-only state.
  /// Blocked methods:
  /// 1. sendNewState()
  /// 2. sendForUpdate()
  /// 3. sendStateWithControl(WidgetStateControl widgetStateControl, {T? state})
  ///
  /// Unblocked exception methods:
  /// 1. sendUpdatedControl(WidgetStateControl widgetStateControl)
  WidgetStateNotifier restrictedWidgetStateNotifier() {
    return _RestrictedWidgetStateNotifier(this);
  }
}

/// A restricted version of [WidgetStateNotifier] that blocks certain methods.
class _RestrictedWidgetStateNotifier<T> extends WidgetStateNotifier<T> {
  final WidgetStateNotifier<T> widgetStateNotifier;

  _RestrictedWidgetStateNotifier(this.widgetStateNotifier);

  /// Blocks sending a new state to the [WidgetStateNotifier] and listeners.
  @override
  void sendNewState(T? state) =>
      throw RestrictedWidgetStateException("sendNewState");

  /// Blocks sending an update to the [WidgetStateNotifier] and listeners.
  @override
  void sendForUpdate() => throw RestrictedWidgetStateException("sendForUpdate");

  /// Blocks sending a new state and controls to the [WidgetStateNotifier] and listeners.
  @override
  void sendStateWithControl(WidgetStateControl widgetStateControl,
          {T? state}) =>
      throw RestrictedWidgetStateException(
          "sendStateWithControl($widgetStateControl,${(state != null) ? "state: $state" : ""})");

  @override
  Function(WidgetStateNotifier<T> stateNotifier)? get _listener =>
      widgetStateNotifier._listener;

  @override
  Listenable? get _notifier => widgetStateNotifier._notifier;

  @override
  bool get _notifierAdded => widgetStateNotifier._notifierAdded;

  @override
  WidgetStateControl get currentStateControl =>
      widgetStateNotifier.currentStateControl;

  @override
  T? get currentValue => widgetStateNotifier.currentValue;

  @override
  void _listenerFunction() => widgetStateNotifier._listenerFunction();

  @override
  StreamController<T?> get _streamController =>
      widgetStateNotifier._streamController;

  @override
  bool addController<G>(Listenable notifier,
          Function(WidgetStateNotifier<T> stateNotifier) listener) =>
      widgetStateNotifier.addController(notifier, listener);

  @override
  void dispose() => widgetStateNotifier.dispose();

  @override
  bool removeController({Function()? disposeMethod}) =>
      widgetStateNotifier.removeController(disposeMethod: disposeMethod);

  @override
  void sendUpdatedControl(WidgetStateControl widgetStateControl) =>
      widgetStateNotifier.sendUpdatedControl(widgetStateControl);
}

/// A function signature for the builder function used in [WidgetStateConsumer].
typedef WidgetStateBuilder<D> = Widget Function(BuildContext context, D? data);

/// A function signature for the builder function used in [WidgetStateConsumer].
typedef WidgetControlStateBuilder<D> = Widget Function(
    BuildContext context, D? data, WidgetStateControl widgetStateControl);

/// A widget for consuming state changes from a [WidgetStateNotifier] and rebuilding its child widget in response to state changes.
class WidgetStateConsumer<T> extends StatefulWidget {
  /// [WidgetStateNotifier] instance to consume state changes.
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
    if (oldWidget.widgetStateNotifier != widget.widgetStateNotifier) {
      _unsubscribe();
      sendState(widget.widgetStateNotifier.currentValue,
          widget.widgetStateNotifier.currentStateControl);
      _subscribe();
    }
  }

  @override
  void initState() {
    super.initState();
    sendState(widget.widgetStateNotifier.currentValue,
        widget.widgetStateNotifier.currentStateControl);
    _subscribe();
  }

  void sendState(T? value, WidgetStateControl widgetStateControl) {
    setState(() {
      stateControl = widgetStateControl;
      stateValue = value;
    });
  }

  void _subscribe() {
    streamSubscription ??= widget.widgetStateNotifier.stream.listen((event) {
      final stateControl = widget.widgetStateNotifier.currentStateControl;
      sendState(event, stateControl);
    });
  }

  void _unsubscribe() {
    streamSubscription?.cancel();
    streamSubscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
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

/// A function signature for the builder function used in [MultiWidgetStateConsumer].
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

/// An InheritedWidget that provides a [WidgetStateNotifier] down the widget tree.
class WidgetStateProvider<T> extends InheritedWidget {
  final WidgetStateNotifier<T> notifier;

  const WidgetStateProvider({
    super.key,
    required super.child,
    required this.notifier,
  });

  /// Retrieves the [WidgetStateNotifier] of type [T] from the context.
  ///
  /// Returns:
  ///   The notifier if found, or `null` if not found.
  static WidgetStateNotifier<T>? of<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WidgetStateProvider<T>>()
        ?.notifier;
  }

  @override
  bool updateShouldNotify(WidgetStateProvider oldWidget) =>
      notifier != oldWidget.notifier;
}

/// A class for managing requests and responses, allowing the sending and listening of requests based on specific states.
class WidgetStateRequest<R, D> {
  final Map<R, StreamController<D?>> _requests = {};
  final StreamController<D?> _generalRequest = StreamController<D?>.broadcast();

  /// Sends a request with an optional data payload.
  ///
  /// Parameters:
  ///   - state: The state for which the request is being sent.
  ///   - data: Optional data payload to be sent with the request.
  void sendRequest(R state, {D? data}) {
    if (_requests.containsKey(state)) {
      _requests[state]?.add(data);
    } else {
      _generalRequest.add(data);
    }
  }

  /// Adds a listener for a specific request state.
  ///
  /// Parameters:
  ///   - state: The state for which the listener is being added.
  ///   - onRequested: The function to be called when the request is made.
  void addRequestListener(R state, Function(D? data) onRequested) {
    if (!_requests.containsKey(state)) {
      _requests[state] = StreamController<D?>.broadcast();
      _requests[state]?.stream.listen(onRequested);
    }
  }

  /// Removes a listener for a specific request state.
  ///
  /// Parameters:
  ///   - state: The state for which the listener is being removed.
  void removeRequestListener(R state) {
    if (_requests.containsKey(state)) {
      _requests.remove(state);
    }
  }
}

/// A class to manage dependency injection into the widget tree
class WidgetStateDependency {
  WidgetStateDependency._privateConstructor();

  static final WidgetStateDependency _instance =
      WidgetStateDependency._privateConstructor();

  static WidgetStateDependency get instance => _instance;

  final Map<Type, dynamic> _services = {};

  /// Registers a service with the dependency manager.
  T register<T>(T service) {
    if (service == null) {
      throw ArgumentError("Service cannot be null");
    }
    _services[T] = service;
    return service;
  }

  /// Retrieves a registered service, lazily initializing if necessary.
  T get<T>({T Function()? create}) {
    if (!_services.containsKey(T)) {
      if (create != null) {
        _services[T] = create();
      } else {
        throw StateError("Service of type $T is not registered");
      }
    }
    return _services[T] as T;
  }

  /// Replaces an existing service, or throws an error if the service is not registered.
  T replace<T>(T service) {
    if (!_services.containsKey(T)) {
      throw StateError("Service of type $T is not registered, cannot replace");
    }
    _services[T] = service;
    return service;
  }

  /// Creates or replaces a service in the dependency manager.
  T createOrReplace<T>(T service) {
    if (service == null) {
      throw ArgumentError("Service cannot be null");
    }
    if (_services.containsKey(T)) {
      _services[T] = service;
    } else {
      _services[T] = service;
    }
    return service;
  }

  /// Unregisters a service by type.
  void unregister<T>() {
    if (_services.containsKey(T)) {
      _services.remove(T);
    } else {
      throw StateError("Service of type $T is not registered");
    }
  }

  /// Checks if a service is registered.
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clears all registered services.
  void clear() {
    _services.clear();
  }
}

/// A provider widget for injecting dependencies into the widget tree.
class WidgetDependencyProvider extends InheritedWidget {
  final WidgetStateDependency dependency;

  const WidgetDependencyProvider({
    super.key,
    required super.child,
    required this.dependency,
  });

  static WidgetStateDependency of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WidgetDependencyProvider>()!
        .dependency;
  }

  @override
  bool updateShouldNotify(WidgetDependencyProvider oldWidget) {
    return oldWidget.dependency != dependency;
  }
}

/// A mixin to easily access dependencies within a widget.
mixin WidgetDependencyMixin<T extends StatefulWidget> on State<T> {
  WidgetStateDependency get dependency => WidgetDependencyProvider.of(context);
}
