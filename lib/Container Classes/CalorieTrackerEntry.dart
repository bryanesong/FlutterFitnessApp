import 'package:firebase_database/firebase_database.dart';

class CalorieTrackerEntry {
  String key;
  int calories;
  String foodType;
  String brandName;
  String measurement;
  int quantity;
  String time;

//  DocumentReference reference;

  CalorieTrackerEntry(
      this.key, this.calories, this.foodType, this.brandName, this.measurement, this.quantity, this.time);

  CalorieTrackerEntry.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        calories = snapshot.value["calories"],
        foodType = snapshot.value["foodType"],
        brandName = snapshot.value["brandName"],
        measurement = snapshot.value["measurement"],
        quantity = snapshot.value["quantity"],
        time = snapshot.value["time"];
}
