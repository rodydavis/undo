import 'dart:async';

import 'package:test/test.dart';
import 'package:undo/undo.dart';

void main() {
  group('Test Undo/Redo Object Modifications', () {
    group('initial state', () {
      test('is correct', () {
        final states = <int>[];
        expect(SimpleStack(0, onUpdate: states.add).state, 0);
      });
    });

    group('canUndo', () {
      test('is false when no state changes have occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        expect(testObject.canUndo, isFalse);
      });

      test('is true when a single state change has occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        expect(testObject.canUndo, isTrue);
      });

      test('is false when undos have been exhausted', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        expect(testObject.canUndo, isFalse);
      });
    });

    group('canRedo', () {
      test('is false when no state changes have occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        expect(testObject.canRedo, isFalse);
      });

      test('is true when a single undo has occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        expect(testObject.canRedo, isTrue);
      });

      test('is false when redos have been exhausted', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        await Future<void>.delayed(Duration.zero, testObject.redo);
        expect(testObject.canRedo, isFalse);
      });
    });

    group('clearHistory', () {
      test('clears history and redos on new testObject', () async {
        final testObject = SimpleStack(0)..clearHistory();
        expect(testObject.canRedo, isFalse);
        expect(testObject.canUndo, isFalse);
      });
    });

    group('undo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(Duration.zero, testObject.undo);

        expect(states, [0]);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, limit: 0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);

        expect(states, [0, 1]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, limit: 1, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        await Future<void>.delayed(Duration.zero, testObject.undo);

        expect(states, [0, 1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);

        expect(states, [0, 1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);

        expect(states, [0, 1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(Duration.zero, testObject.redo);

        expect(states, [0]);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.redo);

        expect(states, [0, 1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        await Future<void>.delayed(Duration.zero, testObject.redo);

        expect(states, [0, 1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        await Future<void>.delayed(Duration.zero, testObject.redo);
        await Future<void>.delayed(Duration.zero, testObject.redo);

        expect(states, [0, 1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final testObject = SimpleStack(0, onUpdate: states.add);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state + 1));
        await Future<void>.delayed(Duration.zero, testObject.undo);
        await Future<void>.delayed(
            Duration.zero, () => testObject.modify(testObject.state - 1));
        await Future<void>.delayed(Duration.zero, testObject.redo);

        expect(states, [0, 1, 2, 1, 0]);
      });
    });
  });
}
