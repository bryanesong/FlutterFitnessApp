import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'CalorieTrackerEntry.dart';

class CalorieEntryContainer {
  List<DatedEntryList> entryHolder = new List<DatedEntryList>();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  FirebaseUser user;

  CalorieEntryContainer(this.user) {
    entryRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Calorie Tracker Data")
        .child("My Entries");
    createFirebaseListener();
  }

  void createFirebaseListener() {
    entryRef.onChildAdded.listen(_onEntry);
    entryRef.onChildChanged.listen(_onEntry);
  }

  _onEntry(Event event) {
    print("grab");

    entryRef.child(event.snapshot.key).once().then((DataSnapshot snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;

      int dateIndex =
          getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key));
      //clear list
      entryHolder[dateIndex].entries.clear();
      for (var key in KEYS) {
        print(key.toString());
        entryHolder[dateIndex].add(new CalorieTrackerEntry(
            key,
            DATA[key]['calories'],
            DATA[key]['foodType'],
            DATA[key]['brandName'],
            DATA[key]['measurement'],
            DATA[key]['quantity'],
            DATA[key]['time']));
      }
    });

    // entryHolder[getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key))].add(CalorieTrackerEntry.fromSnapshot(event.snapshot));
  }

  /*_onEntryChanged(Event event) {
    var old = codeList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    codeList[codeList.indexOf(old)] = AlphaCode.fromSnapshot(event.snapshot);
  }*/

  int getAndCreateIndexOfDate(DateTime date) {
    //locate list of entries by date
    int index = getIndexOfDate(date);
    if (index != -1) {
      return index;
    } else {
      //if doesn't exist, create the entry list
      entryHolder.add(new DatedEntryList(date));
      //sort entryHolder
      entryHolder.sort((a, b) {
        return a.compareTo(b);
      });
      //return index of the new list
      //entryRef.child(date);
      return getIndexOfDate(date);
    }
  }

  int getIndexOfDate(DateTime date) {
    for (int i = 0; i < entryHolder.length; i++) {
      if (dateToString(entryHolder[i].date) == dateToString(date)) {
        print("found date in list");
        return i;
      }
    }
    //not found
    print("no date found");
    return -1;
  }

  DatedEntryList getDateEntries(DateTime date) {
    int index = getIndexOfDate(date);
    if (index != -1) {
      return entryHolder[index];
    } else {
      return null;
    }
  }

  String dateToString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int length() {
    return entryHolder.length;
  }
}

class DatedEntryList {
  DateTime date;
  List<CalorieTrackerEntry> entries = new List<CalorieTrackerEntry>();

  DatedEntryList(this.date);

  compareTo(DatedEntryList b) {
    return date.compareTo(b.date);
  }

  void add(CalorieTrackerEntry entry) {
    entries.add(entry);
  }

  int length() {
    return entries.length;
  }
}
