import 'package:firebase_database/firebase_database.dart';

class CalorieTrackerEntry {
  String key;
  int calories;
  String foodType;
  String measurement;
  int quantity;
  String time;

//  DocumentReference reference;

  CalorieTrackerEntry(this.calories, this.foodType, this.measurement, this.quantity, this.time);

  CalorieTrackerEntry.fromSnapshot(DataSnapshot snapshot) : key = snapshot.key,
        calories = snapshot.value["calories"], foodType = snapshot.value["foodType"],
        measurement = snapshot.value["measurement"], quantity = snapshot.value["quantity"], time = snapshot.value["time"];


  toJson() {
    return {
      "calories" : calories,
      "foodType" : foodType,
      "measurement" : measurement,
      "quantity" : quantity,
      "time" : time,
    };
  }

}