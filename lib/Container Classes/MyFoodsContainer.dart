import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'CalorieTrackerEntry.dart';

class MyFoodsContainer {
  List<CalorieTrackerEntry> entryHolder = new List<CalorieTrackerEntry>();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  FirebaseUser user;

  MyFoodsContainer(this.user) {
    entryRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Calorie Tracker Data")
        .child("My Foods");
    createFirebaseListener();
  }

  void createFirebaseListener() {
    entryRef.onChildAdded.listen(_onEntry);
    entryRef.onChildChanged.listen(_onChange);
  }

  _onEntry(Event event) {
    entryHolder.add(CalorieTrackerEntry.fromSnapshot(event.snapshot));
  }

  _onChange(Event event) {
    var old = entryHolder.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    entryHolder[entryHolder.indexOf(old)] = CalorieTrackerEntry.fromSnapshot(event.snapshot);
  }
}

// entryHolder[getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key))].add(CalorieTrackerEntry.fromSnapshot(event.snapshot));
