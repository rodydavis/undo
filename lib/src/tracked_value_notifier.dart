import 'dart:async';

import 'package:flutter/foundation.dart';

import '../undo.dart';

class TrackedValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  /// Creates a [ChangeNotifier] that wraps this value.
  TrackedValueNotifier(
    this._value, {
    int maxUndoStack,
    this.debounce,
  }) {
    _changeStack = ChangeStack(max: maxUndoStack);
    debounce ??= Duration.zero;
  }

  /// Debounce delay to commit changes to a group
  Duration debounce;

  ChangeStack _changeStack;
  Timer _debounce;
  T _value;

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  ///
  /// Every new change will be added to the undo stack.
  /// Committing a change will clear the redo stack.
  @override
  T get value => _value;

  @override
  void dispose() {
    _changeStack.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($value)';
  }

  set value(T newValue) {
    if (_value == newValue) return;
    if (_debounce == null || !_debounce.isActive) {
      _changeStack.group();
    }
    _changeStack.add(Change.property(_value, () {
      _value = newValue;
      notifyListeners();
    }, (oldValue) {
      _value = oldValue;
      notifyListeners();
    }));
    _debounce?.cancel();
    _debounce = Timer(debounce, () => _changeStack.commit());
  }

  /// Undo the last change
  void undo() => _changeStack.undo();

  // Redo the previous change
  void redo() => _changeStack.redo();

  // Checks whether the undo/redo stack is empty
  bool get canUndo => _changeStack.canUndo;

  // Checks wether the undo/redo stack is at the current change
  bool get canRedo => _changeStack.canRedo;

  /// Clear undo history
  void clear() {
    _changeStack.clear();
  }
}
