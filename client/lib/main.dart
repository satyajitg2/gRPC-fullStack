import 'dart:math';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protos/protos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ClientChannel _channel;
  late TodoServiceClient _stub;

  Todo? todo;
  Stream<Todo>? _todoStream;

  @override
  void initState() {
    super.initState();

    _channel = ClientChannel('localhost',
        port: 8081,
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()));
    _stub = TodoServiceClient(_channel);
    _todoStream = _stub.getTodoStream(GetTodoByIdRequest(id: 1));
  }

  Future<void> _getTodo() async {
    final id = Random().nextInt(100);

    final todo = await _stub.getTodo(GetTodoByIdRequest(id: id));

    setState(() {
      this.todo = todo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
                stream: _todoStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    final todo = snapshot.data as Todo;
                    return Column(
                      children: [
                        Text(todo.id.toString()),
                        Text(todo.title),
                        Text(todo.completed.toString()),
                      ],
                    );
                  }
                  return const Text('Loading');
                }),
            /*
            This is when we don't use StreamBuilder.
            if (todo != null)
              Column(
                children: [
                  Text(todo!.id.toString()),
                  Text(todo!.title),
                  Text(todo!.completed.toString()),
                ],
              )
            else
              Text('GET your things done'),
              */
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getTodo,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
