# undo_example

Demonstrates how to use the undo plugin.

## Example

```dart
import 'package:flutter/material.dart';

import 'package:undo/undo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

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