import 'package:FlutterFitnessApp/Container%20Classes/CalorieTrackerEntry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Container Classes/CalorieEntryContainer.dart';

class TestClass extends StatefulWidget {


  TestClassState createState() => TestClassState();
}

class TestClassState extends State<TestClass> {
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CalorieEntryContainer entries;
  CalendarController _calorieCalendarController = CalendarController();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  CalorieTrackerEntry testEntry;

  @override
  void initState() {


    getCurUser();
    super.initState();
  }

  void getCurUser() async {
    user = await auth.currentUser();

    entryRef = database.reference().child("Users").child(user.uid).child("Calorie Tracker Data");

    testEntry = new CalorieTrackerEntry(100, "potato", "Cup", 1, DateFormat('yyyy-MM-dd').format(new DateTime(2020, 8, 26)));
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
          }
        ),
      FlatButton(
        color: Colors.blue,
        child: Text("hi"),
        onPressed: () {
          doStuff2();
        },
      )],),);

  }

  void doStuff() {
    /*print(user.uid);
    print(DateFormat('yyyy-MM-dd').format(_calorieCalendarController.selectedDay));*/

  }

  void doStuff2() {
    entryRef.child("2020-08-26").set({
      "calories" : testEntry.calories,
      "foodType" : testEntry.foodType,
      "measurement" : testEntry.measurement,
      "quantity" : testEntry.quantity,
      "time" : testEntry.time,
    });
  }


}