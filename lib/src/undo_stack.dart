part of undo;

class ChangeStack extends ChangeGroupBase {
  final _streamController = StreamController<ChangeStack>.broadcast();
  Stream<ChangeStack> get stream => _streamController.stream.asBroadcastStream();

  Queue<Change> _undos = new ListQueue();
  Queue<Change> _redos = new ListQueue();

  int max;

  bool get canRedo => _redos.isNotEmpty;
  bool get canUndo => _undos.isNotEmpty;

  String get redoLabel => canRedo ? _redos.first.label : '';
  String get undoLabel => canUndo ? _undos.last.label : '';

  ChangeStack({this.max}) {
    _streamController.add(this);
  }

  void _add(Change change, {String label}) {
    change.execute();
    change.label = label;

    _undos.addLast(change);
    _redos.clear();

    if (max != null && _undos.length > max) {
      _undos.removeFirst();
    }

    _streamController.add(this);
  }

  void clear() {
    _undos.clear();
    _redos.clear();
    _streamController.add(null);
  }

  void redo() {
    if (canRedo) {
      var change = _redos.removeFirst();
      change.execute();
      _undos.addLast(change);
      _streamController.add(this);
    }
  }

  void undo() {
    if (canUndo) {
      var change = _undos.removeLast();
      change.undo();
      _redos.addFirst(change);
      _streamController.add(this);
    }
  }

  void dispose() {
    _streamController.close();
  }
}
