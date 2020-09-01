import 'package:firebase_database/firebase_database.dart';

class CalorieTrackerEntry {
  String key;
  double calories;
  String foodType;
  String brandName;
  String measurement;
  double quantity;
  String time;
  String foodDescription;

//  DocumentReference reference;

  CalorieTrackerEntry(
      this.key, this.calories, this.foodType, this.brandName, this.measurement, this.quantity, this.time);

  CalorieTrackerEntry.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        calories = snapshot.value["calories"].toDouble(),
        foodType = snapshot.value["foodType"],
        brandName = snapshot.value["brandName"],
        measurement = snapshot.value["measurement"],
        quantity = snapshot.value["quantity"].toDouble(),
        time = snapshot.value["time"];
}
