part of undo_tests;

void testPropertyChanges() {
  
  group("Property change", () {
    ChangeStack stack;
    
    setUp(() {
      stack = new ChangeStack();
    });
    
    test("should invoke execute closure", () {
      var value = false;
      stack.add(new Change.property(value, () => value = true, (old) => value = old));
      expect(value, isTrue);
    });
    
    test("should invoke undo closure", () {
      var value = false;
      stack.add(new Change.property(value, () => value = true, (old) => value = old));
      stack.undo();
      expect(value, isFalse);
    });
  });
  
}