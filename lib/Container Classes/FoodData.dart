import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;

class FoodData {
  //quantity: number of servings user has consumed
  //measurement: cups, slices, patties

  String key;
  double calories;
  String foodType;
  String brandName;
  String measurement;
  double quantity;
  String time;

  /*String portionMeasurement;*/
  //either in grams, ml etc.

  double protein;
  double carbs;
  double fats;
  List<String> portionNames = new List<String>();
  List<double> portionSizes = new List<double>();
  List<String> portionUnits = new List<String>();
  String id;

  bool isUSDAEntry = false;

//  DocumentReference reference;

  FoodData(
  {this.key, this.calories, this.foodType, this.brandName, this.measurement, this.quantity, this.time, this.protein, this.carbs, this.fats, this.id, this.isUSDAEntry});

  FoodData.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        calories = snapshot.value["calories"].toDouble(),
        foodType = snapshot.value["foodType"],
        brandName = snapshot.value["brandName"],
        measurement = snapshot.value["measurement"],
        quantity = snapshot.value["quantity"].toDouble(),
        time = snapshot.value["time"];

  //to parse USDA food entries

  factory FoodData.fromJson(Map<String, dynamic> json) {
    double parsedProtein = 0;
    double parsedCarbs = 0;
    double parsedFats = 0;
    double parsedCalories = 0;

    for (Map i in json['foodNutrients']) {
      if (i["name"] == "Protein") {
        parsedProtein = i["amount"];
      }
      if (i["name"] == "Carbohydrate, by difference") {
        parsedCarbs = i["amount"];
      }
      if (i["name"] == "Total lipid (fat)") {
        parsedFats = i["amount"];
      }
      if (i["name"] == "Energy") {
        parsedCalories = i["amount"];
      }
    }

    return FoodData(
      foodType: json['description'],
      brandName: json['brandOwner'],
      protein: double.parse(parsedProtein.toStringAsFixed(2)),
      carbs: double.parse(parsedCarbs.toStringAsFixed(2)),
      fats: double.parse(parsedFats.toStringAsFixed(2)),
      calories: double.parse(parsedCalories.toStringAsFixed(2)),
      id: json['fdcId'].toString(),
      isUSDAEntry: true,
    );
  }

  Future<int> findPortions() async {
    //ensure data in arrays don't stack
    clearArrays();

    //retrieve extra info on specific item
    final responseSecondary = await http.get(
        "https://api.nal.usda.gov/fdc/v1/food/" +
            id +
            "?api_key=OtpdWCaIaKlnq3DXBs5VcVorVDopFLNaVrGLWT6i");

    Map<String, dynamic> portionJson = jsonDecode(responseSecondary.body);

    //3 pieces of data added per entry.
    //1. portionName i.e. 1 Cup, 2 Patties (user will mainly see this)
    //2. portionSize i.e. 200, 100, 40 (for computing reason)
    //3. portionUnit i.e. g, ml, gal (will need to deal with measurements other than grams)

    if (portionJson['foodPortions'].length == 0) {
      //if no portion array is found, resort to householdServingText
      if (portionJson['householdServingFullText'] != null &&
          portionJson['servingSize'] != null &&
          portionJson['servingSizeUnit'] != null) {
        portionNames.add(portionJson['householdServingFullText']);
        portionSizes.add(double.parse(portionJson['servingSize'].toStringAsFixed(2)));
        portionUnits.add(portionJson['servingSizeUnit']);
      }
    } else {
      //locate the different portions in "foodPortions"
      for (Map i in portionJson['foodPortions']) {
        if (i['portionDescription'] != null && i['gramWeight'] != null) {
          portionNames.add(i['portionDescription']);
          portionSizes.add(double.parse(i['gramWeight'].toStringAsFixed(2)));
          portionUnits.add("g");
        } else if (i['modifier'] != null && i['gramWeight'] != null) {
          print(i['modifier']);
          portionNames.add(i['modifier']);
          portionSizes.add(double.parse(i['gramWeight'].toStringAsFixed(2)));
          portionUnits.add("g");
        } else {
          print("no portions found");
        }
      }
    }

    return 1;
  }

  void clearArrays() {
    portionSizes.clear();
    portionUnits.clear();
    portionNames.clear();
  }

  String toString() {
    return foodType +
        " " + /* brandName + " " +*/ protein.toString() +
        " " +
        carbs.toString() +
        " " +
        fats.toString() +
        " " +
        calories.toString();
  }
}
