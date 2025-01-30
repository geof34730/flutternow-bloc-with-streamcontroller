import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'todo_model.dart';

class TodoBloc {
  final LocalStorage storage = LocalStorage('todo_app');
  List<TodoModel> _todos = [];

  // StreamController for managing the todo list state
  final StreamController<List<TodoModel>> _streamController = StreamController<List<TodoModel>>.broadcast();

  // Sink for adding new states
  Sink<List<TodoModel>> get sink => _streamController.sink;

  // Stream for listening to updates
  Stream<List<TodoModel>> get stream => _streamController.stream;

  // Load saved todos from local storage
  Future<void> loadTodos() async {
    await storage.ready;
    List<dynamic>? storedTodos = storage.getItem('todos');
    _todos = storedTodos?.map((e) => TodoModel.fromJson(e)).toList() ?? [];
    sink.add(_todos);
  }

  // Add a new todo
  void addTodo(String task) {
    _todos.add(TodoModel(task: task));
    storage.setItem('todos', _todos.map((e) => e.toJson()).toList());
    sink.add(_todos);
  }

  // Remove a todo by index
  void removeTodo(int index) {
    _todos.removeAt(index);
    storage.setItem('todos', _todos.map((e) => e.toJson()).toList());
    sink.add(_todos);
  }

  // Dispose method to close the StreamController
  void dispose() {
    _streamController.close();
  }
}

// Create a singleton instance of the bloc
final todoBloc = TodoBloc();
