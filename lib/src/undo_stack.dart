import 'dart:collection';

import 'change.dart';

class ChangeStack {
  /// Changes to keep track of
  ChangeStack({this.limit});

  /// Limit changes to store in the history
  int? limit;

  final Queue<List<Change>> _history = ListQueue();
  final Queue<List<Change>> _redos = ListQueue();

  /// List of changes in the history
  List<Change> get history => _history.last;

  /// List of changes in the redo stack
  List<Change> get redos => _redos.first;

  /// Can redo the previous change
  bool get canRedo => _redos.isNotEmpty;

  /// Can undo the previous change
  bool get canUndo => _history.isNotEmpty;

  /// Add New Change and Clear Redo Stack
  void add<T>(Change<T> change) {
    try {
      change.execute();
      _history.addLast([change]);
      _moveForward();
    } catch (e) {
      rethrow;
    }
  }

  void _moveForward() {
    _redos.clear();

    if (limit != null && _history.length > limit! + 1) {
      _history.removeFirst();
    }
  }

  /// Add New Group of Changes and Clear Redo Stack
  void addGroup<T>(List<Change<T>> changes) {
    try {
      _applyChanges(changes);
      _history.addLast(changes);
      _moveForward();
    } catch (e) {
      rethrow;
    }
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
