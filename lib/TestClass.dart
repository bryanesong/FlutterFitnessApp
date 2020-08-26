import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Container Classes/CalorieEntryContainer.dart';

class TestClass extends StatefulWidget {
  FirebaseUser user;


  TestClassState createState() => TestClassState();
}

class TestClassState extends State<TestClass> {
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CalorieEntryContainer entries;
  CalendarController _calorieCalendarController = CalendarController();

  @override
  void initState() {
    getCurUser();
    super.initState();
  }

  void getCurUser() async {
    user = await auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: Text("Test class"),
    ),
      body: Column(children: [
        TableCalendar(
          calendarController: _calorieCalendarController,
          initialCalendarFormat: CalendarFormat.week,
          formatAnimation: FormatAnimation.slide,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          availableGestures: AvailableGestures.all,
          availableCalendarFormats: const {
            CalendarFormat.week: 'Weekly',
          },
        ),
        FlatButton(
          color: Colors.blue,
          child: Text("hi"),
          onPressed: () {
            doStuff();
          },
        )],),);

  }

  void doStuff() {
    print(user.uid);
    print(DateFormat('yyyy-MM-dd').format(_calorieCalendarController.selectedDay));
  }


}