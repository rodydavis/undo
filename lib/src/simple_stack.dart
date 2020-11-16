import 'package:undo/undo.dart';

class SimpleStack<T> extends ChangeStack {
  /// Simple stack for keeping track of changes and easy callback for new state changes
  SimpleStack(
    this._state, {
    this.limit,
    this.onUpdate,
  }) : super(limit: limit) {
    modify(_state);
  }

  /// Limit of changes to keep in history
  int limit;

  T _state;

  /// Current state
  T get state => _state;

  set state(T val) => modify(val);

  void Function(T val) onUpdate;

  void modify(T val) => add(Change(
        _state,
        () => _newValue(val),
        (old) => _newValue(old),
      ));

  void _newValue(T val) {
    _state = val;
    if (onUpdate != null) {
      onUpdate(val);
    }
  }
}
