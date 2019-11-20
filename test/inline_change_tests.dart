part of undo_tests;

void testInlineChanges() {
  
  group("Inline change", () {
    ChangeStack stack;
    
    setUp(() {
      stack = new ChangeStack();
    });
    
    test("should invoke execute closure", () {
      var value = false;
      stack.add(new Change.inline(() => value = true, () => value = false));
      expect(value, isTrue);
    });
    
    test("should invoke undo closure", () {
      var value = false;
      stack.add(new Change.inline(() => value = true, () => value = false));
      stack.undo();
      expect(value, isFalse);
    });
  });
  
}