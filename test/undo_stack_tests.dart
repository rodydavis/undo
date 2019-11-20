part of undo_tests;

void testUndoStack() {
  
  group("Undo stack", () {
    
    ChangeStack stack;
    
    setUp(() {
      stack = new ChangeStack();
    });
    
    test("should be undoable after adding change", () {
      stack.add(new ChangeMock());
      expect(stack.canUndo, isTrue);
    });
    
    test("should not be redoable after adding change", () {
      stack.add(new ChangeMock());
      expect(stack.canRedo, isFalse);
    });
    
    test("should execute added change", () {
      var change = new ChangeMock();
      stack.add(change);
      change.getLogs(callsTo('execute')).verify(happenedOnce);
    });
    
    test("should not exceed max undos", () {
      stack = new ChangeStack(max: 2)
          ..add(new ChangeMock())
          ..add(new ChangeMock())
          ..add(new ChangeMock())
          ..undo()
          ..undo();
      
      expect(stack.canUndo, isFalse);
    });
    
    test("should invoke Change.undo() on undo", () {
      var change = new ChangeMock();
      stack.add(change);
      stack.undo();
      change.getLogs(callsTo('undo')).verify(happenedOnce);
    });
    
    test("should invoke Change.execute() on redo", () {
      var change = new ChangeMock();
      stack.add(change);
      change.clearLogs();
      stack.undo();
      
      stack.redo();
      change.getLogs(callsTo('execute')).verify(happenedOnce);
    });
    
    test("should not be undoable or redoable after clearing", () {
      stack.add(new ChangeMock());
      stack.add(new ChangeMock());
      stack.undo();
      stack.clear();
      
      expect(stack.canRedo, isFalse);
      expect(stack.canUndo, isFalse);
    });
    
    test("should group changes", () {
      stack.group();
      
      var change1 = new ChangeMock();
      stack.add(change1);
      
      var change2 = new ChangeMock();
      stack.add(change2);
      
      stack.commit();
      
      change1.clearLogs();
      change2.clearLogs();
      
      stack.undo();
      change2.getLogs(callsTo('undo')).verify(happenedOnce);
      change1.getLogs(callsTo('undo')).verify(happenedOnce);
      
      stack.redo();
      
      change1.getLogs(callsTo('execute')).verify(happenedOnce);
      change2.getLogs(callsTo('execute')).verify(happenedOnce);
    });
    
    test("should rollback discard change", () {
      stack.group();
      
      var change1 = new ChangeMock();
      stack.add(change1);
      
      var change2 = new ChangeMock();
      stack.add(change2);
      
      stack.discard();
      
      change2.getLogs(callsTo('undo')).verify(happenedOnce);
      change1.getLogs(callsTo('undo')).verify(happenedOnce);
      expect(stack.canUndo, isFalse);
    });
    
  });
  
}