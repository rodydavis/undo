import 'dart:async';

import 'package:flutter/foundation.dart';

import '../undo.dart';

class TrackedStreamController<T> implements StreamSink<T> {
  TrackedStreamController(this._value,
      {int maxUndoStack,
      this.debounce,
      this.onRedo,
      this.onUndo,
      void Function() onListen,
      void Function() onPause,
      void Function() onResume,
      FutureOr<void> Function() onCancel,
      bool sync = false}) {
    _controller = StreamController<T>(
      onListen: onListen,
      onPause: onPause,
      onResume: onResume,
      onCancel: onCancel,
      sync: sync,
    );
    _changeStack = ChangeStack(max: maxUndoStack);
    debounce ??= Duration.zero;
    _controller.add(_value);
  }

  /// Debounce delay to commit changes to a group
  Duration debounce;

  final ValueChanged<T> onUndo, onRedo;

  ChangeStack _changeStack;
  StreamController<T> _controller;
  Timer _debounce;
  T _value;

  @override
  Future get done => _controller.done;

  @override
  void add(T event) {
    if (_debounce == null || !_debounce.isActive) {
      _changeStack.group();
    }
    _changeStack.add(Change.property(_value, () {
      _controller.add(event);
    }, (oldValue) {
      _controller.add(oldValue);
    }));
    _value = event;
    _debounce?.cancel();
    _debounce = Timer(debounce, () => _changeStack.commit());
  }

  @override
  void addError(Object event, [StackTrace stackTrace]) {
    _controller.addError(event, stackTrace);
  }

  @override
  Future addStream(Stream<T> event, {bool cancelOnError}) {
    return _controller.addStream(
      event,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future close() => _controller.close();

  /// Undo the last change
  void undo() {
    _changeStack.undo();
    if (onUndo != null) {
      onUndo(_value);
    }
  }

  // Redo the previous change
  void redo() {
    _changeStack.redo();
    if (onRedo != null) {
      onRedo(_value);
    }
  }

  // Checks whether the undo/redo stack is empty
  bool get canUndo => _changeStack.canUndo;

  // Checks wether the undo/redo stack is at the current change
  bool get canRedo => _changeStack.canRedo;

  Stream<T> get stream => _controller.stream;

  /// Clear undo history
  void clear() {
    _changeStack.clear();
  }
}
