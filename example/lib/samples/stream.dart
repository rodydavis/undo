import 'dart:async';

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
  final _controller = TrackedStreamController(0);

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
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: FloatingActionButton(
            heroTag: ValueKey('add_button'),
            child: Icon(Icons.add),
            onPressed: () {
              _controller.add(count! + 1);
            },
          ),
        );
      },
    );
  }
}

class TrackedStreamController<T> implements StreamController<T> {
  late SimpleStack<T> _simpleStack;
  late StreamController<T> _streamController;

  TrackedStreamController(
    T value, {
    int? limit,
    this.onCancel,
    this.onListen,
    this.onPause,
    this.onResume,
    bool sync = false,
  }) {
    _streamController = StreamController(
      onCancel: onCancel,
      onListen: onListen,
      onPause: onPause,
      onResume: onResume,
      sync: sync,
    );
    _simpleStack = SimpleStack(value, limit: limit, onUpdate: (newVal) {
      _streamController.add(newVal);
    });
  }

  Stream<T> get stream => _streamController.stream;
  void add(T value) => _simpleStack.modify(value);

  bool get canUndo => _simpleStack.canUndo;
  bool get canRedo => _simpleStack.canRedo;
  void redo() => _simpleStack.redo();
  void undo() => _simpleStack.undo();

  @override
  FutureOr<void> Function()? onCancel;

  @override
  void Function()? onListen;

  @override
  void Function()? onPause;

  @override
  void Function()? onResume;

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _streamController.addError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<T> source, {bool? cancelOnError}) async {
    _streamController.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future get done => _streamController.done;

  @override
  bool get hasListener => _streamController.hasListener;

  @override
  bool get isClosed => _streamController.isClosed;

  @override
  bool get isPaused => _streamController.isPaused;

  @override
  StreamSink<T> get sink => _streamController.sink;

  @override
  Future close() => _streamController.close();
}
