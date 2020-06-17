import 'dart:async';

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
  final _controller = TrackedStreamController<int>();

  @override
  void initState() {
    _controller.add(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          final count = snapshot.data;
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: FloatingActionButton(
              heroTag: ValueKey('add_button'),
              child: Icon(Icons.add),
              onPressed: () {
                _controller.add(count + 1);
              },
            ),
          );
        });
  }
}
