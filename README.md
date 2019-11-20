# Undo.dart
An undo redo library for Dart.

## Usage

Create an ChangeStack to store changes

	import 'package:undo/undo.dart';
	
	var changes = new ChangeStack();
	
Add new undo, redo commands using `ChangeStack.add()`. When a change is added, it calls the change's `execute()` method. Use `Change.inline()` for simple inline changes.
	
	var count = 0;
	
	changes.add(
	  new Change.inline(() => count++, () => count--);
	  name: "Increase"
	);

Use `Change.property()` when changing a field on an object. This will store the field's old value so it can be reverted.

	var person = new Person()
	    ..firstName = "John"
	    ..lastName = "Doe";
	
	changes.add(
	  new Change.property(
	    person.firstName, 
	    () => person.firstName = "Jane",
	    (oldValue) = person.firstName = oldValue
	  )
	)

Undo a change with `undo()`.

	print(person.firstName); // Jane
	changes.undo();
	print(person.firstName); // John
	
Redo the change with `redo()`.

	changes.redo();
	print(person.firstName); // Jane
	
Use `group()` to wrap many changes in a transaction. Any new changes will be added to the group until `commit()` is invoked.

	count = 0;
	
	changes.group();
	
	var increase = new Change.inline(() => count++, () => count--);
	changes.add(increase);
	changes.add(increase);
	
	changes.commit();
	print(count); // 2
	
	changes.undo();
	print(count); // 0
	
Calling `discard()` instead of `commit()` will unapply the group. This is useful for previewing changes.

	count = 0;
	
	changes.group();
	changes.add(increase);		
	changes.add(increase);
	changes.discard();
	
	print(count); // 0
	
Extend `Change` to create your own changes.

	class IncreaseChange extends Change {
	
	  int value;
	  
	  IncreaseChange(this.value);
	  
	  void execute() => value++;
	  void undo() => value--;
	
	}