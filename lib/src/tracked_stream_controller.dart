import 'dart:async';

import '../undo.dart';

class TrackedStreamController<T> implements StreamSink<T> {
  TrackedStreamController({
    int maxUndoStack,
    this.debounce,
  }) {
    _controller = StreamController<T>();
    _changeStack = ChangeStack(max: maxUndoStack);
    debounce ??= Duration.zero;
  }
  StreamController<T> _controller;
  ChangeStack _changeStack;

  /// Debounce delay to commit changes to a group
  Duration debounce;

  Timer _debounce;
  T _lastEvent;

  @override
  void add(T event) {
    if (_debounce == null || !_debounce.isActive) {
      _changeStack.group();
    }
    _changeStack.add(Change.property(_lastEvent, () {
      _controller.add(event);
    }, (oldValue) {
      _controller.add(oldValue);
    }));
    _lastEvent = event;
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

  @override
  Future get done => _controller.done;

  /// Undo the last change
  void undo() => _changeStack.undo();

  // Redo the previous change
  void redo() => _changeStack.redo();

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
