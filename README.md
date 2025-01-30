# Gestion d'état avec StreamController et persistance locale dans Flutter

## Introduction
Ce projet est une application Flutter utilisant `StreamController` pour gérer l'état et `localstorage` pour la persistance des données. L'application est une simple To-Do List permettant d'ajouter et de supprimer des tâches tout en les sauvegardant localement.

## Prérequis
Avant de commencer, assurez-vous d'avoir :

- Flutter installé sur votre machine
- Un éditeur comme Visual Studio Code ou Android Studio
- Une connaissance de base en Flutter et Dart

## Installation
Clonez ce dépôt et installez les dépendances :

```sh
git clone https://github.com/votre-utilisateur/votre-repo.git
cd votre-repo
flutter pub get
```

## Dépendances
Les dépendances utilisées dans ce projet sont :

```yaml
dependencies:
  flutter:
    sdk: flutter
  localstorage: ^4.0.0
```

## Structure du projet
```
/lib
  ├── main.dart          # Point d'entrée de l'application
  ├── todo_bloc.dart     # Bloc gérant la logique et le StreamController
  ├── todo_model.dart    # Modèle de données pour les tâches
```

## Fonctionnalités
- Ajouter une tâche
- Supprimer une tâche
- Sauvegarder et charger les tâches avec `localstorage`

## Exemple de code
### Modèle de données
```dart
class TodoModel {
  final String task;
  final bool isCompleted;

  TodoModel({required this.task, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'task': task,
        'isCompleted': isCompleted,
      };

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        task: json['task'],
        isCompleted: json['isCompleted'],
      );
}
```

### Bloc de gestion des tâches
```dart
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'todo_model.dart';

class TodoBloc {
  final LocalStorage storage = LocalStorage('todo_app');
  List<TodoModel> _todos = [];

  final StreamController<List<TodoModel>> _streamController = StreamController<List<TodoModel>>.broadcast();

  Sink<List<TodoModel>> get sink => _streamController.sink;
  Stream<List<TodoModel>> get stream => _streamController.stream;

  Future<void> loadTodos() async {
    await storage.ready;
    List<dynamic>? storedTodos = storage.getItem('todos');
    _todos = storedTodos?.map((e) => TodoModel.fromJson(e)).toList() ?? [];
    sink.add(_todos);
  }

  void addTodo(String task) {
    _todos.add(TodoModel(task: task));
    storage.setItem('todos', _todos.map((e) => e.toJson()).toList());
    sink.add(_todos);
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    storage.setItem('todos', _todos.map((e) => e.toJson()).toList());
    sink.add(_todos);
  }

  void dispose() {
    _streamController.close();
  }
}

final todoBloc = TodoBloc();
```

### Interface utilisateur
```dart
import 'package:flutter/material.dart';
import 'todo_bloc.dart';
import 'todo_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    todoBloc.loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter task'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                todoBloc.addTodo(_controller.text);
                _controller.clear();
              }
            },
            child: Text('Add Todo'),
          ),
          Expanded(
            child: StreamBuilder<List<TodoModel>>(
              stream: todoBloc.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks available'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].task),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => todoBloc.removeTodo(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Exécution de l'application
Lancez l'application avec la commande suivante :

```sh
flutter run
```

## Contribution
Les contributions sont les bienvenues ! Ouvrez une issue ou un pull request pour proposer des améliorations.

## Licence
Ce projet est sous licence MIT. Vous pouvez l'utiliser et le modifier librement.
