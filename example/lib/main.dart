import 'package:flutter/material.dart';

import 'package:undo/undo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;
  var changes = ChangeStack();
  @override
  Widget build(BuildContext context) {
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
              onPressed: !changes.canUndo
                  ? null
                  : () {
                      if (mounted)
                        setState(() {
                          changes.undo();
                        });
                    },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: !changes.canRedo
                  ? null
                  : () {
                      if (mounted)
                        setState(() {
                          changes.redo();
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
          if (mounted)
            setState(() {
              changes.add(Change.inline(
                () => count++,
                () => count--,
              ));
              changes.commit();
            });
        },
      ),
    );
  }
}
