# undo

[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
![github pages](https://github.com/rodydavis/undo/workflows/github%20pages/badge.svg)
![tests](https://github.com/rodydavis/undo/workflows/test/badge.svg)
[![GitHub stars](https://img.shields.io/github/stars/rodydavis/undo?color=blue)](https://github.com/rodydavis/undo)
[![undo](https://img.shields.io/pub/v/undo.svg)](https://pub.dev/packages/undo)

An undo redo library for Dart/Flutter. Forked from [here](https://github.com/Mixbook/undo.dart) and updated for Flutter. Demo can be viewed [here](https://rodydavis.github.io/undo/).

## Usage

Create an ChangeStack to store changes

```dart
import 'package:undo/undo.dart';
	
var changes = ChangeStack();
```
	
Add new undo, redo commands using `ChangeStack.add()`. When a change is added, it calls the change's `execute()` method. Use `Change()` for simple inline changes.
	
```dart
var count = 0;
	
changes.add(
  Change(count, () => count++, (val) => count = val);
  name: "Increase"
);
```

Use `Change()` when changing a field on an object. This will store the field's old value so it can be reverted.

```dart
var person = new Person()
    ..firstName = "John"
    ..lastName = "Doe";

changes.add(
  Change(
    person.firstName, 
    () => person.firstName = "Jane",
    (oldValue) = person.firstName = oldValue
  )
)
```

Undo a change with `undo()`.

```dart
print(person.firstName); // Jane
changes.undo();
print(person.firstName); // John
```
	
Redo the change with `redo()`.

```dart
changes.redo();
print(person.firstName); // Jane
```

### Simple Stack Example

```dart

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SimpleStack _controller;

  @override
  void initState() {
    _controller = SimpleStack<int>(
      0,
      onUpdate: (val) {
        if (mounted)
          setState(() {
            print('New Value -> $val');
          });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final count = _controller.state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Undo/Redo Example'),
      ),
      body: Center(
        child: Text('Count: $count'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: !_controller.canUndo
                  ? null
                  : () {
                      if (mounted)
                        setState(() {
                          _controller.undo();
                        });
                    },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: !_controller.canRedo
                  ? null
                  : () {
                      if (mounted)
                        setState(() {
                          _controller.redo();
                        });
                    },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: ValueKey('add_button'),
        child: Icon(Icons.add),
        onPressed: () {
          _controller.modify(count + 1);
        },
      ),
    );
  }
}

```
