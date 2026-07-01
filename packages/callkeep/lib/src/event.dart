import 'package:flutter/cupertino.dart';

import 'package:logger/web.dart';

abstract class EventType {
  const EventType();
  void sanityCheck() {}
}

/// This class serves as a Typed event bus.
///
/// Events can be subscribed to by calling the "on" method.
///
/// Events are distributed by calling the "emit" method.
///
/// Subscribers my unsubscrive by calling "remove" with both the EventType and the callback function that was
/// originally subscribed with.
///
/// Subscribers will implement a callback function taking exactly one argument of the same type as the
/// Event they wish to receive.
///
/// Thus:
///
/// on(EventCallState(),(EventCallState event){
///  -- do something here
/// });
class EventManager {
  Logger logger = Logger();
  Map<Type, List<Function>> listeners = <Type, List<Function>>{};

  /// returns true if there are any listeners associated with the EventType for this instance of EventManager
  bool hasListeners(EventType event) {
    final targets = listeners[event.runtimeType];
    if (targets != null) {
      return targets.isNotEmpty;
    }
    return false;
  }

  /// call "on" to subscribe to events of a particular type
  ///
  /// Subscribers will implement a callback function taking exactly one argument of the same type as the
  /// Event they wish to receive.
  ///
  /// Thus:
  ///
  /// on<EventCallState>((EventCallState event){
  ///  -- do something here
  /// });
  void on<T extends EventType>(ValueChanged<T> listener) {
    _addListener(T, listener);
  }

  /// It isn't possible to have type constraints here on the listener,
  /// BUT very importantly this method is private and
  /// all the methods that call it enforce the types!!!!
  void _addListener<T>(Type runtimeType, Function listener) {
    try {
      var targets = listeners[runtimeType];
      if (targets == null) {
        targets = <Function>[];
        listeners[runtimeType] = targets;
      }
      targets.remove(listener);
      targets.add(listener);
    } catch (e) {
      rethrow;
    }
  }

  /// add all event handlers from an other instance of EventManager to this one.
  void addAllEventHandlers(EventManager other) {
    other.listeners.forEach((Type runtimeType, List<Function> otherListeners) {
      // ignore: avoid_function_literals_in_foreach_calls
      otherListeners.forEach((dynamic otherListener) {
        _addListener(runtimeType, otherListener);
      });
    });
  }

  void remove<T extends EventType>(ValueChanged<T> listener) {
    final targets = listeners[T];
    if (targets == null) return;
    if (!targets.remove(listener)) {
      logger.d('Failed to remove any listeners for EventType $T');
    }
  }

  /// send the supplied event to all of the listeners that are subscribed to that EventType
  void emit<T extends EventType>(T event) {
    event.sanityCheck();
    // ignore: always_specify_types
    final targets = listeners[event.runtimeType];

    if (targets != null) {
      // avoid concurrent modification
      // ignore: avoid_function_literals_in_foreach_calls
      targets.toList(growable: false).forEach((dynamic target) {
        try {
          //   logger.warn("invoking $event on $target");
          target(event);
        } catch (e) {
          rethrow;
        }
      });
    }
  }
}
