class ToDoItem {
  String title;
  bool isCompleted;
  DateTime dueDate;

  ToDoItem({
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
  });
}