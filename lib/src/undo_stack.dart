import 'dart:collection';

class ChangeStack<T> {
  /// Changes to keep track of
  ChangeStack({this.limit});

  /// Limit changes to store in the history
  int limit;

  final Queue<List<Change<T>>> _history = ListQueue();
  final Queue<List<Change<T>>> _redos = ListQueue();

  /// Can redo the previous change
  bool get canRedo => _redos.isNotEmpty;

  /// Can undo the previous change. If the history is equal to 1 this you cannot undo to null.
  bool get canUndo => _history.isNotEmpty && _history.length > 1;

  /// Add New Change and Clear Redo Stack
  void add(Change<T> change) {
    change.execute();
    _history.addLast([change]);
    _moveForward();
  }

  void _moveForward() {
    _redos.clear();

    if (limit != null && _history.length > limit + 1) {
      _history.removeFirst();
    }
  }

  /// Add New Group of Changes and Clear Redo Stack
  void addGroup(List<Change<T>> changes) {
    _applyChanges(changes);
    _history.addLast(changes);
    _moveForward();
  }

  void _applyChanges(List<Change> changes) {
    for (final change in changes) {
      change.execute();
    }
  }

  /// Clear Undo History
  @deprecated
  void clear() => clearHistory();

  /// Clear Undo History
  void clearHistory() {
    _history.clear();
    _redos.clear();
  }

  /// Redo Previous Undo
  void redo() {
    if (canRedo) {
      final changes = _redos.removeFirst();
      _applyChanges(changes);
      _history.addLast(changes);
    }
  }

  /// Undo Last Change
  void undo() {
    if (canUndo) {
      final changes = _history.removeLast();
      for (final change in changes) {
        change.undo();
      }
      _redos.addFirst(changes);
    }
  }
}

class Change<T> {
  Change(
    this._oldValue,
    this._execute(),
    this._undo(T oldValue), {
    this.description,
  });

  Change.method(
    this._execute(),
    void Function() undo, {
    this.description,
  })  : _oldValue = null,
        _undo = undo();

  final String description;

  final void Function() _execute;
  final T _oldValue;

  final void Function(T oldValue) _undo;

  void execute() {
    _execute();
  }

  void undo() {
    _undo(_oldValue);
  }
}
