library undo_tests;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:undo/undo.dart';

part 'undo_stack_tests.dart';
part 'inline_change_tests.dart';
part 'property_change_tests.dart';

void main() {
  testUndoStack();
  testInlineChanges();
  testPropertyChanges();
}

class ChangeMock extends Mock implements Change {
  @override
  String label;

  @override
  void execute() {
    // TODO: implement execute
  }

  @override
  void undo() {
    // TODO: implement undo
  }
  
}