part of undo;

abstract class Change {
  
  Change();
  
  factory Change.property(Object oldValue, execute(), undo(Object oldValue)) {
    return new _PropertyChange(oldValue, execute, undo);
  }
  
  factory Change.inline(execute(), undo()) {
    return new _InlineChange(execute, undo);
  }
  
  String label;
  
  void execute();
  
  void undo();
  
}

abstract class ChangeGroupBase {
  
  _ChangeGroup _openGroup;
  bool get isGrouping => _openGroup != null;
  
  void add(Change change) {
    if (isGrouping) {
      _openGroup.add(change);
    } else {
      _add(change);
    }
  }
  
  void _add(Change change);

  void clear();
  
  void group({String label}) {
    _openGroup = new _ChangeGroup()
        ..label = label;
  }
  
  void commit() {
    if (isGrouping) {
      _add(_openGroup);
      _openGroup = null;
    }
  }
  
  void discard() {
    if (isGrouping) {
      _openGroup.undo();
      _openGroup = null;
    }
  }
  
  void undo();
  
}

class _PropertyChange extends Change {
  
  Object _oldValue;
  Function _execute;
  Function _undo;
  
  _PropertyChange(this._oldValue, this._execute(), this._undo(Object oldValue));
  
  void execute() {
    _execute();
  }
  
  void undo() {
    _undo(_oldValue);
  }
  
}

class _InlineChange extends Change {
  
  Function _execute;
  Function _undo;
  
  _InlineChange(this._execute(), this._undo());
  
  void execute() {
    _execute();
  }
  
  void undo() {
    _undo();
  }
  
}

class _ChangeGroup extends ChangeGroupBase implements Change {

  String label;
  
  List<Change> _changes = [];
  
  void _add(Change change) {
    _changes.add(change);
    change.execute();
  }

  void clear() {
    _changes.clear();
  }
  
  void execute() {
    _changes.forEach((c) => c.execute());
  }
  
  void undo() {
    _changes.reversed.forEach((c) => c.undo());
  }
  
}