import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:dayagenda/models/my_list.dart';

class CalendarService {
  // GoogleSignIn googleSignIn = GoogleSignIn(
  //   scopes: <String>[CalendarApi.calendarScope, TasksApi.tasksScope],
  // );

  // Future<List<TaskList>> getLists() async {
  //   TasksApi taskApi = await getTaskApi();
  //   var lists = await taskApi.tasklists.list();
  //   // print('lists.length: ${lists.items?.length}');
  //   return lists.items ?? [];
  // }

  Future<MyList> getEvents() async {
    MyList myList = MyList(
      title: 'Todayyy',
    );
    // MyTask myTask = MyTask(id: 'id0', title: 'Title', dateIndex: 0);
    // myList.items.add(myTask);

    // myTask = MyTask(id: 'id1', title: 'Title 2', dateIndex: 1);
    // myList.items.add(myTask);

    // myTask = MyTask(id: 'id2', title: 'Title 3', dateIndex: 2);
    // myList.items.add(myTask);

    return myList;

    // if (tasks != null) {
    //   for (var task in tasks.items!) {
    //     print('${task.kind}: ${task.due}: ${task.completed} ${task.title}');
    //     // if ((task.due. .start?.dateTime?.day == DateTime.now().day) &&
    //     //     (event.start?.dateTime?.month == DateTime.now().month) &&
    //     //     (event.start?.dateTime?.year == DateTime.now().year)) {
    //     //   print('TODAY:[${event.start?.dateTime?.toLocal().hour}:${event.start?.dateTime?.toLocal().minute}]${event.summary}');
    //     // }
    //   }
    // }

    // var calendarApi = CalendarApi(httpClient);
    // var _calendar = await calendarApi.calendarList.get('primary');
    // print(_calendar.summary);

    // var algo2 = await calendarApi.events.list('tomas@ambee.app');

    // if (algo2 != null) {
    //   print('length: ${algo2.summary}: ${algo2.items?.length}');
    //   for (event in algo2.items!) {
    //     // print('${event.start?.dateTime}: ${event.summary}');
    //     if ((event.start?.dateTime?.day == DateTime.now().day) &&
    //         (event.start?.dateTime?.month == DateTime.now().month) &&
    //         (event.start?.dateTime?.year == DateTime.now().year)) {
    //       print('TODAY:[${event.start?.dateTime?.toLocal().hour}:${event.start?.dateTime?.toLocal().minute}]${event.summary}');
    //     }
    //   }
    // }
  }

  addEvent() async {
    // await googleSignIn.signInSilently();

    // var httpClient = (await googleSignIn.authenticatedClient())!;
    // var calendarApi = CalendarApi(httpClient);

    Event event = Event(); // Create object of event
    event.summary = 'summaryText'; //Setting summary of object

    EventDateTime start = EventDateTime(); //Setting start time
    start.dateTime = DateTime.now();
    start.timeZone = "GMT+05:00";
    event.start = start;

    EventDateTime end = EventDateTime(); //setting end time
    end.timeZone = "GMT+05:00";
    end.dateTime = DateTime(2023, 4, 7, 2, 00);
    event.end = end;

    // var algo = await calendarApi.events.insert(Event(summary: 'serus', start: start, end: end), "primary");
    // print(algo.created);
  }
}
