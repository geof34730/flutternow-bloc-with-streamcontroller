class TodoModel {
  final String task;
  final bool isCompleted;

  TodoModel({required this.task, this.isCompleted = false});

  // Convert object to JSON
  Map<String, dynamic> toJson() => {
    'task': task,
    'isCompleted': isCompleted,
  };

  // Convert JSON to object
  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    task: json['task'],
    isCompleted: json['isCompleted'],
  );
}
