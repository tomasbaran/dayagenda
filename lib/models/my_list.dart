import 'package:today/models/my_task.dart';

class MyList {
  DateTime? date;
  String? title;
  String? id;
  List<MyTask> tasks;
  List<MyTask> completedTasks;
  MyList({
    this.title,
    this.id,
  })  : tasks = [],
        completedTasks = [];

  @override
  String toString() {
    return '\ntasks: $tasks\ncompleted: $completedTasks';
  }

  // Define a method to clone the object.
  MyList clone() {
    // Create a new MyList and manually copy over fields
    MyList clone = MyList(title: title, id: id);
    clone.date = date; // Assuming DateTime is immutable
    clone.tasks = tasks.map((task) => task.clone()).toList(); // Deep copy of tasks
    clone.completedTasks = completedTasks.map((task) => task.clone()).toList(); // Deep copy of completedTasks
    return clone;
  }
}
