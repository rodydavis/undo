part of undo;

class ChangeStack extends ChangeGroupBase {
  
  Queue<Change> _undos = new ListQueue();
  Queue<Change> _redos = new ListQueue();
  
  int max;
  
  bool get canRedo => _redos.isNotEmpty;
  bool get canUndo => _undos.isNotEmpty;
  
  String get redoLabel => canRedo ? _redos.first.label : '';
  String get undoLabel => canUndo ? _undos.last.label : '';
  
  ChangeStack({this.max});
  
  void _add(Change change, {String label}) {
    change.execute();
    change.label = label;
    
    _undos.addLast(change);
    _redos.clear();

    if (max != null && _undos.length > max) {
      _undos.removeFirst();
    }
  }
  
  void clear() {
    _undos.clear();
    _redos.clear();
  }
  
  void redo() {
    if (canRedo) {
      var change = _redos.removeFirst();
      change.execute();
      _undos.addLast(change);
    }
  }
  
  void undo() {
    if (canUndo) {
      var change = _undos.removeLast();
      change.undo();
      _redos.addFirst(change);
    }
  }
  
}
