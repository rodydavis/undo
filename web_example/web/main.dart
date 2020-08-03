import 'dart:html';

import 'package:undo/undo.dart';

void main() {
  SimpleStack<int> stack;
  final output = querySelector('#output');
  final ButtonElement undoButton = querySelector('#undo');
  final ButtonElement redoButton = querySelector('#redo');
  stack = SimpleStack<int>(0, onUpdate: (val) {
    output.text = '$val';
  });
  undoButton.disabled = !stack.canUndo;
  redoButton.disabled = !stack.canRedo;
  final ButtonElement incrementButton = querySelector('#increment');
  final ButtonElement decrementButton = querySelector('#decrement');
  incrementButton.onClick.listen((event) {
    stack.modify(stack.state + 1);
    undoButton.disabled = !stack.canUndo;
    redoButton.disabled = !stack.canRedo;
  });
  decrementButton.onClick.listen((event) {
    stack.modify(stack.state - 1);
    undoButton.disabled = !stack.canUndo;
    redoButton.disabled = !stack.canRedo;
  });
  undoButton.onClick.listen((event) {
    stack.undo();
    undoButton.disabled = !stack.canUndo;
    redoButton.disabled = !stack.canRedo;
  });
  redoButton.onClick.listen((event) {
    stack.redo();
    undoButton.disabled = !stack.canUndo;
    redoButton.disabled = !stack.canRedo;
  });
}
