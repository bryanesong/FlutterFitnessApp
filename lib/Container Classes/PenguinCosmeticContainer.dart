import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'FoodData.dart';

class CalorieEntryContainer {
  /*List<DatedEntryList> entryHolder = new List<DatedEntryList>();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  FirebaseUser user;

  CalorieEntryContainer(this.user) {
    entryRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped");
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

      int dateIndex = 0;
      //getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key));
      //clear list
      entryHolder[dateIndex].entries.clear();
      for (var key in KEYS) {
        print(key.toString());
        entryHolder[dateIndex].add(new FoodData(
            key: key,
            calories: DATA[key]['calories'].toDouble(),
            foodType: DATA[key]['foodType'],
            brandName: DATA[key]['brandName'],
            measurement: DATA[key]['measurement'],
            quantity: DATA[key]['quantity'].toDouble(),
            time: DATA[key]['time']));
      }
    });

    // entryHolder[getAndCreateIndexOfDate(DateTime.parse(event.snapshot.key))].add(FoodData.fromSnapshot(event.snapshot));
  }*/

/*_onEntryChanged(Event event) {
    var old = codeList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    codeList[codeList.indexOf(old)] = AlphaCode.fromSnapshot(event.snapshot);
  }*/
}
