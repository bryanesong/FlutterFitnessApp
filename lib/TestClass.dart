import 'dart:convert';

import 'package:FlutterFitnessApp/Container%20Classes/CalorieTrackerEntry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Container Classes/CalorieEntryContainer.dart';
import 'Container Classes/MyFoodsContainer.dart';

import 'package:http/http.dart' as http;

enum CalorieTrackerState {
  log,
  addFood,
  myFood,
  searchFood,
  addMyFood,
  addEntry
}

class TestClass extends StatefulWidget {
  TestClassState createState() => TestClassState();
}

class TestClassState extends State<TestClass> {
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //list of dated food entries
  CalorieEntryContainer entries;

  //list of personal foods
  MyFoodsContainer myFoods;

  //error messages
  String _errorMessage;
  String _errorTextBox;

  CalendarController _calorieCalendarController = CalendarController();

  TextEditingController _foodNameController = new TextEditingController(),
      _brandNameController = new TextEditingController(),
      _servingSizeController = new TextEditingController(),
      _measurementController = new TextEditingController(),
      _calorieController = new TextEditingController(),
      _searchFoodController = new TextEditingController();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  CalorieTrackerEntry testEntry;

  var _calorieState = CalorieTrackerState.log;

  double _width, _height;

  @override
  void initState() {
    getCurUser();

    super.initState();
  }

  void _onEntry(Event e) {
    setState(() {});
  }

  void getCurUser() async {
    user = await auth.currentUser();

    entries = new CalorieEntryContainer(user);
    myFoods = new MyFoodsContainer(user);

    entryRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Calorie Tracker Data");

    //update list on items being added
    entryRef.child("My Entries").onChildAdded.listen(_onEntry);

    testEntry = new CalorieTrackerEntry("", 100, "potato", "", "Cup", 1,
        DateFormat('yyyy-MM-dd').format(new DateTime(2020, 8, 26)));

    //doStuff1();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Test class",
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: getContainer()),
          Container(
            height: 90,
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Text("This is the bottom bar"),
          )
        ],
      ),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {});
  }

  Widget getContainer() {
    switch (_calorieState) {
      case CalorieTrackerState.log:
        return foodEntryPage();
/*      case CalorieTrackerState.addEntry:
        return addEntryPage();*/
      case CalorieTrackerState.myFood:
        return myFoodPage();
      case CalorieTrackerState.searchFood:
        return searchFoodPage();
      case CalorieTrackerState.addMyFood:
        return addMyFoodPage();
      default:
        return null;
    }
  }

  //<-------------------------------------------------FoodEntryPage------------------------------------------------->
  Widget foodEntryPage() {
    DatedEntryList listOfCurDay;
    if (_calorieCalendarController.selectedDay != null) {
      listOfCurDay =
          entries.getDateEntries(_calorieCalendarController.selectedDay);
    }

    return Stack(
      children: [
        Column(
          children: [
            TableCalendar(
              calendarController: _calorieCalendarController,
              initialCalendarFormat: CalendarFormat.week,
              formatAnimation: FormatAnimation.slide,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              availableGestures: AvailableGestures.all,
              availableCalendarFormats: const {
                CalendarFormat.week: 'Weekly',
              },
              onDaySelected: _onDaySelected,
            ),
            Container(
                padding:
                    EdgeInsets.fromLTRB(0, wpad(2), 0, wpad(2)),
                child: listOfCurDay != null
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        //get list of entries of current day
                        itemCount: listOfCurDay.length(),
                        itemBuilder: (BuildContext context, int index) {
                          CalorieTrackerEntry curEntry =
                              listOfCurDay.entries[index];
                          return ListTile(
                              title: Text(
                                curEntry.foodType,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                  curEntry.quantity.toInt().toString() +
                                      ", " +
                                      curEntry.measurement),
                              trailing: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(curEntry.calories.toString()),
                                    FlatButton(
                                      onPressed: () {
                                        entryRef
                                            .child("My Entries")
                                            .child(DateFormat('yyyy-MM-dd')
                                                .format(
                                                    _calorieCalendarController
                                                        .selectedDay)
                                                .toString())
                                            .child(entries
                                                .getDateEntries(
                                                    _calorieCalendarController
                                                        .focusedDay)
                                                .entries[index]
                                                .key)
                                            .remove();
                                        entries
                                            .getDateEntries(
                                                _calorieCalendarController
                                                    .focusedDay)
                                            .entries
                                            .removeAt(index);
                                        setState(() {});
                                      },
                                      child: Icon(Icons.delete),
                                    )
                                  ],
                                ),
                              ));

                          /*Container(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        curEntry.foodType,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      child: Text(curEntry.calories.toString()),
                                      alignment: Alignment.centerRight,
                                    ),
                                    Container(
                                        alignment: Alignment.centerRight,
                                        child: FlatButton(
                                          onPressed: () {
                                            entryRef
                                                .child("My Entries")
                                                .child(DateFormat('yyyy-MM-dd')
                                                    .format(
                                                        _calorieCalendarController
                                                            .selectedDay)
                                                    .toString())
                                                .child(entries
                                                    .getDateEntries(
                                                        _calorieCalendarController
                                                            .focusedDay)
                                                    .entries[index]
                                                    .key)
                                                .remove();
                                            entries
                                                .getDateEntries(
                                                    _calorieCalendarController
                                                        .focusedDay)
                                                .entries
                                                .removeAt(index);
                                            setState(() {});
                                          },
                                          child: Icon(Icons.delete),
                                        ))
                                  ],
                                ),
                                Container(
                                  child: Text(curEntry.quantity.toString() +
                                      " " +
                                      curEntry.measurement),
                                  alignment: Alignment.centerLeft,
                                ),
                              ],
                            ),
                          )*/
                        },
                      )
                    : Text("No food entries found")),
          ],
        ),
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              _calorieState = CalorieTrackerState.searchFood;
              setState(() {});
            },
            child: Icon(Icons.restaurant),
          ),
        ),

        //list view border
      ],
    );
  }

  //<-------------------------------------------------SearchFoodPage------------------------------------------------->
  List<USDAEntry> searchEntries = new List<USDAEntry>();

  Widget searchFoodPage() {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                  child: FlatButton(
                    color: _calorieState == CalorieTrackerState.searchFood
                        ? Colors.lightBlueAccent
                        : Colors.blue,
                    onPressed: () {},
                    child: Text("Search Food"),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                  child: FlatButton(
                    color: _calorieState == CalorieTrackerState.myFood
                        ? Colors.lightBlueAccent
                        : Colors.blue,
                    onPressed: () {
                      _calorieState = CalorieTrackerState.myFood;
                      setState(() {});
                    },
                    child: Text("My Food"),
                  ),
                )),
              ],
            ),
            Row(
              children: [
                Container(
                    //padding: EdgeInsets.fromLTRB(wpad(4), 0, wpad(4), 0),
                    child: FlatButton(
                  onPressed: () {
                    searchDatabase(_searchFoodController.text);
                  },
                  child: Icon(Icons.search),
                )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(6), 0),
                    child: TextField(
                      controller: _searchFoodController,
                      decoration:
                          InputDecoration(hintText: "Search for a food"),
                    ),
                  ),
                ),
              ],
            ),
            createSearchListView()
          ],
        )
      ],
    );
  }

  Widget createSearchListView() {
    return Expanded(
        child: searchEntries != null && searchEntries.length != 0
            ? ListView.builder(
                itemCount: searchEntries.length,
                itemBuilder: (BuildContext context, int index) {
                  //get list of entries of current day
                  USDAEntry curEntry = searchEntries[index];
                  return GestureDetector(
                      onTap: () {
                        _calorieState = CalorieTrackerState.addEntry;
                      },
                      child: ListTile(
                        onTap: () {
                          print("clicked");
                          addEntryDialog(curEntry);
                        },
                        title: Text(curEntry.foodName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: curEntry.brandName != null
                            ? Text("Brand Name: " +
                                curEntry.brandName +
                                " Protein: " +
                                curEntry.protein.toString() +
                                " Fats: " +
                                curEntry.fats.toString() +
                                " Carbs: " +
                                curEntry.carbs.toString())
                            : Text("Protein: " +
                                curEntry.protein.toString() +
                                " Fats: " +
                                curEntry.fats.toString() +
                                " Carbs: " +
                                curEntry.carbs.toString()),
                        trailing: Container(
                          width: wpad(20),
                          child: Row(
                            children: [
                              Container(
                                child: Text(
                                  curEntry.calories.toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              )
            : Container(
                padding: EdgeInsets.fromLTRB(0, hpad(2), 0, 0),
                child: Text("No food entries found")));
  }

  void searchDatabase(String foodSearch) async {
    searchEntries = await fetchData(foodSearch);
    setState(() {});
  }

  Future<List<USDAEntry>> fetchData(String foodSearch) async {
    final responseMain = await http.get(
        "https://api.nal.usda.gov/fdc/v1/foods/list?api_key=OtpdWCaIaKlnq3DXBs5VcVorVDopFLNaVrGLWT6i&query=${foodSearch.replaceAll(" ", "%20")}");
    List<USDAEntry> searchEntryList = new List<USDAEntry>();
    print(responseMain.statusCode);

    if (responseMain.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      for (Map i in jsonDecode(responseMain.body)) {
        searchEntryList.add(USDAEntry.fromJson(i));
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }

    return searchEntryList;
  }

  //<-------------------------------------------------myFoodPage------------------------------------------------->
  Widget myFoodPage() {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                  child: FlatButton(
                    color: _calorieState == CalorieTrackerState.searchFood
                        ? Colors.lightBlueAccent
                        : Colors.blue,
                    onPressed: () {
                      _calorieState = CalorieTrackerState.searchFood;
                      setState(() {});
                    },
                    child: Text("Search Food"),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                  child: FlatButton(
                    color: _calorieState == CalorieTrackerState.myFood
                        ? Colors.lightBlueAccent
                        : Colors.blue,
                    onPressed: () {},
                    child: Text("My Food"),
                  ),
                )),
              ],
            ),
            createMyFoodListView(),
          ],
        ),
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              _calorieState = CalorieTrackerState.addMyFood;
              setState(() {});
            },
            child: Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Widget createMyFoodListView() {
    return Expanded(
        child: myFoods.entryHolder != null && myFoods.entryHolder.length != 0
            ? ListView.builder(
                itemCount: myFoods.entryHolder.length,
                itemBuilder: (BuildContext context, int index) {
                  //get list of entries of current day
                  CalorieTrackerEntry curEntry = myFoods.entryHolder[index];
                  return GestureDetector(
                      onTap: () {
                        _calorieState = CalorieTrackerState.addEntry;
                      },
                      child: ListTile(
                        onTap: () {
                          print("tapped: " + index.toString());
                        },
                        title: Text(curEntry.foodType,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(curEntry.quantity.toString() +
                            " " +
                            curEntry.measurement),
                        trailing: Container(
                          width: wpad(20),
                          child: Row(
                            children: [
                              Container(
                                child: Text(
                                  curEntry.calories.toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Expanded(
                                  child: FlatButton(
                                onPressed: () {
                                  entryRef
                                      .child("My Foods")
                                      .child(myFoods.entryHolder[index].key)
                                      .remove();
                                  myFoods.entryHolder.removeAt(index);
                                  setState(() {});
                                },
                                child: Icon(Icons.delete),
                              ))
                            ],
                          ),
                        ),
                      ));
                },
              )
            : Text("No food entries found"));
  }

//<-------------------------------------------------addMyFoodPage------------------------------------------------->
  Widget addMyFoodPage() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, hpad(3), 0, 0),
          child: Column(
            children: [
              createRow("Food Name", "Pizza", _foodNameController, "text"),
              createRow("Brand Name (not required)", "McDonalds",
                  _brandNameController, "text"),
              createRow("Serving Size", "1", _servingSizeController, "number"),
              createRow("Measurement", "Slice", _measurementController, "text"),
              createRow("Calories", "100", _calorieController, "number"),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          width: wpad(100),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), wpad(2)),
                child: FlatButton(
                  onPressed: () {
                    _calorieState = CalorieTrackerState.myFood;
                    clearTextControllers();
                    setState(() {});
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
              )),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), wpad(2)),
                child: FlatButton(
                  onPressed: () {
                    submitAddMyFood();
                    setState(() {});
                  },
                  child: Text("Submit", style: TextStyle(color: Colors.blue)),
                ),
              )),
            ],
          ),
        )
      ],
    );
  }

  Widget createRow(String title, String hint, TextEditingController controller,
      String inputType) {
    return Container(
      padding: EdgeInsets.fromLTRB(wpad(5), 0, wpad(5), hpad(1)),
      child: Column(
        children: [
          Container(
            width: wpad(90),
            height: hpad(4),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: wpad(90),
            height: title == _errorTextBox ? hpad(6) : hpad(4),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                errorText: title == _errorTextBox ? _errorMessage : null,
                //counterText: " ",
              ),
              keyboardType: inputType == "number"
                  ? TextInputType.number
                  : TextInputType.text,
              controller: controller,
            ),
          )
        ],
      ),
    );
  }

  void submitAddMyFood() {
    if (_foodNameController.text == "") {
      _errorTextBox = "Food Name";
      _errorMessage = "Blank must be filled";
    }
    /*else if (_measurementController.text == "") {
      _errorTextBox = "Brand Name";
      _errorMessage = "Blank must be filled";
    } */
    else if (_servingSizeController.text == "") {
      _errorTextBox = "Serving Size";
      _errorMessage = "Blank must be filled";
    } else if (_measurementController.text == "") {
      _errorTextBox = "Measurement";
      _errorMessage = "Blank must be filled";
    } else if (_calorieController.text == "") {
      _errorTextBox = "Calories";
      _errorMessage = "Blank must be filled";
    } else {
      entryRef.child("My Foods").push().set({
        "calories": double.parse(_calorieController.text),
        "foodType": _foodNameController.text,
        "brandName": _brandNameController.text,
        "measurement": _measurementController.text,
        "quantity": double.parse(_servingSizeController.text),
        "time": testEntry.time,
      });
      clearTextControllers();
      Future.delayed(const Duration(milliseconds: 500), () {
        _calorieState = CalorieTrackerState.myFood;
        setState(() {});
      });
    }
    setState(() {});
  }

  void clearTextControllers() {
    _calorieController.clear();
    _servingSizeController.clear();
    _measurementController.clear();
    _foodNameController.clear();
    _brandNameController.clear();
  }

  //<-------------------------------------------------addEntryDialog------------------------------------------------->
  TextEditingController _addFoodEntryController = new TextEditingController();

  void addEntryDialog(USDAEntry curEntry) async {
    await curEntry.findPortions();

    String selectedPortion = curEntry.portionNames[0];
    double portionSize = curEntry.portionSizes[0];

    _addFoodEntryController.text = "1";

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(curEntry.foodName),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
                FlatButton(
                  onPressed: () {
                    if (addEntry(curEntry, _addFoodEntryController, portionSize,
                        selectedPortion)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text("Add", style: TextStyle(color: Colors.blue)),
                )
              ],
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedPortion,
                          onChanged: (String newVal) {
                            setState(() {
                              selectedPortion = newVal;

                              //locate portion size from selectedPortion variable
                              for (int i = 0;
                                  i < curEntry.portionNames.length;
                                  i++) {
                                if (selectedPortion ==
                                    curEntry.portionNames[i]) {
                                  portionSize = curEntry.portionSizes[i];
                                }
                              }
                            });
                          },
                          items: curEntry.portionNames
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: new SizedBox(
                                  width: wpad(60),
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ));
                          }).toList(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: wpad(10),
                          padding: EdgeInsets.fromLTRB(0, 0, wpad(3), 0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _addFoodEntryController,
                            textAlign: TextAlign.center,
                            onChanged: (String text) {
                              setState(() {});
                            },
                          ),
                        ),
                        Text(_addFoodEntryController.text != ""
                            ? "Servings = " +
                                (double.parse(_addFoodEntryController.text) *
                                        portionSize *
                                        (curEntry.calories / 100))
                                    .toStringAsFixed(2) +
                                " cal"
                            : "Servings = 0 cal")
                      ],
                    ),
                  ],
                );
              }));
        });
  }

  bool addEntry(USDAEntry curEntry, TextEditingController controller,
      double portionSize, String selectedPortion) {
    if (controller.text != "") {
      entryRef
          .child("My Entries")
          .child(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .push()
          .set({
        "calories": double.parse((double.parse(_addFoodEntryController.text) *
                portionSize *
                (curEntry.calories / 100))
            .toStringAsFixed(2)),
        "foodType": curEntry.foodName,
        "measurement": selectedPortion,
        "quantity": double.parse(controller.text),
        "time": DateFormat('hh:mm a').format(DateTime.now()).toString()
      });
      return true;
    } else {
      return false;
    }
  }

  void doStuff1() {
    entryRef.child("My Foods").push().set({
      "calories": testEntry.calories,
      "foodType": testEntry.foodType,
      "brandName": testEntry.brandName,
      "measurement": testEntry.measurement,
      "quantity": testEntry.quantity,
      "time": testEntry.time,
    });
  }

  void doStuff2() {
    entryRef.child("My Entries").child("2020-08-27").push().set({
      "calories": testEntry.calories,
      "foodType": testEntry.foodType,
      "measurement": testEntry.measurement,
      "quantity": testEntry.quantity,
      "time": testEntry.time,
    });
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }
}

class USDAEntry {
  double protein;
  double carbs;
  double fats;
  double calories;
  String foodName;
  String brandName;
  List<String> portionNames = new List<String>();
  List<double> portionSizes = new List<double>();
  String id;

  USDAEntry(
      {this.protein,
      this.carbs,
      this.fats,
      this.calories,
      this.foodName,
      this.brandName,
      this.id});

  factory USDAEntry.fromJson(Map<String, dynamic> json) {
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

    return USDAEntry(
      foodName: json['description'],
      brandName: json['brandOwner'],
      protein: double.parse(parsedProtein.toStringAsFixed(2)),
      carbs: double.parse(parsedCarbs.toStringAsFixed(2)),
      fats: double.parse(parsedFats.toStringAsFixed(2)),
      calories: double.parse(parsedCalories.toStringAsFixed(2)),
      id: json['fdcId'].toString(),
    );
  }

  Future<int> findPortions() async {
    portionNames.clear();
    portionSizes.clear();
    final responseSecondary = await http.get(
        "https://api.nal.usda.gov/fdc/v1/food/" +
            id +
            "?api_key=OtpdWCaIaKlnq3DXBs5VcVorVDopFLNaVrGLWT6i");
    print("dab");
    print(id);
    Map<String, dynamic> portionJson = jsonDecode(responseSecondary.body);

    if (portionJson['foodPortions'].length == 0) {
      //if no portion array is found, resort to householdServingText
      if (portionJson['householdServingFullText'] != null &&
          portionJson['servingSize'] != null &&
          portionJson['servingSizeUnit'] != null) {
        portionNames.add(portionJson['householdServingFullText'] +
            " (" +
            double.parse(portionJson['servingSize'].toStringAsFixed(2))
                .toString() +
            portionJson['servingSizeUnit'] + ")");
        portionSizes
            .add(double.parse(portionJson['servingSize'].toStringAsFixed(2)));
      }
    } else {
      //locate the different portions in "foodPortions"
      for (Map i in portionJson['foodPortions']) {
        if (i['portionDescription'] != null && i['gramWeight'] != null) {
          portionNames.add(i['portionDescription'] +
              " (" +
              double.parse(i['gramWeight'].toStringAsFixed(2)).toString() +
              "g) ");
          portionSizes.add(double.parse(i['gramWeight'].toStringAsFixed(2)));
        } else if (i['modifier'] != null && i['gramWeight'] != null) {
          print(i['modifier']);
          portionNames.add(i['modifier'] +
              " (" +
              double.parse(i['gramWeight'].toStringAsFixed(2)).toString() +
              "g) ");
          portionSizes.add(double.parse(i['gramWeight'].toStringAsFixed(2)));
        } else {
          print("no portions found");
        }
      }
    }

    return 1;
  }

  String toString() {
    return foodName +
        " " + /* brandName + " " +*/ protein.toString() +
        " " +
        carbs.toString() +
        " " +
        fats.toString() +
        " " +
        calories.toString();
  }
}
