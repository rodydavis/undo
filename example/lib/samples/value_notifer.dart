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
  TrackedValueNotifier _controller = TrackedValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, count, child) => Scaffold(
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
            _controller.value = count + 1;
          },
        ),
      ),
    );
  }
}

class TrackedValueNotifier<T> extends ValueNotifier<T> {
  late SimpleStack<T> _simpleStack;

  TrackedValueNotifier(T val, {int? limit}) : super(val) {
    _simpleStack = SimpleStack<T>(val, limit: limit, onUpdate: (newVal) {
      value = newVal;
      notifyListeners();
    });
  }

  @override
  // ignore: avoid_return_types_on_setters
  void set value(T newValue) {
    _simpleStack.modify(newValue);
    super.value = newValue;
  }

  bool get canUndo => _simpleStack.canUndo;
  bool get canRedo => _simpleStack.canRedo;
  void redo() => _simpleStack.redo();
  void undo() => _simpleStack.undo();
}
