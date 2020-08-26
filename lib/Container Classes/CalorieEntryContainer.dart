import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'CalorieTrackerEntry.dart';

class CalorieEntryContainer {
  List<DatedEntryList> entryHolder = new List<DatedEntryList>();
  
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  FirebaseUser user;

  CalorieEntryContainer(this.user) {
    entryRef = database.reference().child("Users").child(user.uid).child("Calorie Tracker Data");
    createFirebaseListener();
  }

  void createFirebaseListener() {
    entryRef.onChildAdded.listen(_onEntryAdded);
    //entryRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    entryHolder[getAndCreateIndexOfDate(DateTime.parse(event.))].add(CalorieTrackerEntry.fromSnapshot(event.snapshot));
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
    if(index != -1) {
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
    for(int i = 0; i < entryHolder.length; i++) {
      if(entryHolder[i].date.toString() == date.toString()) {
        return i;
      }
    }
    //not found
    print("no date found");
    return -1;
  }

  DatedEntryList getDateEntries(DateTime date) {
    int index = getIndexOfDate(date);
    if(index != -1) {
      return entryHolder[index];
    } else {
      return null;
    }
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
  
}