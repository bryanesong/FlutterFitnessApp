import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'FoodData.dart';

class MyFoodsContainer {
  List<FoodData> entryHolder = new List<FoodData>();

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
    entryHolder.add(FoodData.fromSnapshot(event.snapshot));
  }

  _onChange(Event event) {
    var old = entryHolder.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    entryHolder[entryHolder.indexOf(old)] = FoodData.fromSnapshot(event.snapshot);
  }
}

// entryHolder[getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key))].add(FoodData.fromSnapshot(event.snapshot));
