import 'package:FlutterFitnessApp/Container%20Classes/CalorieTrackerEntry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Container Classes/CalorieEntryContainer.dart';
import 'Container Classes/MyFoodsContainer.dart';

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
      _addFoodEntryController = new TextEditingController();

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

  void getCurUser() async {
    user = await auth.currentUser();

    entries = new CalorieEntryContainer(user);
    myFoods = new MyFoodsContainer(user);

    entryRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Calorie Tracker Data");

    testEntry = new CalorieTrackerEntry("", 100, "potato", "", "Cup", 1,
        DateFormat('yyyy-MM-dd').format(new DateTime(2020, 8, 26)));

    //doStuff1();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery
        .of(context)
        .size
        .width;
    _height = MediaQuery
        .of(context)
        .size
        .height;
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
            width: MediaQuery
                .of(context)
                .size
                .width,
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
      case CalorieTrackerState.addEntry:
        return addEntryPage();
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
                padding: EdgeInsets.fromLTRB(
                    wpad(10), wpad(2), wpad(10), wpad(2)),
                child: listOfCurDay != null
                    ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  //get list of entries of current day
                  itemCount: listOfCurDay.length(),
                  itemBuilder: (BuildContext context, int index) {
                    CalorieTrackerEntry curEntry =
                    listOfCurDay.entries[index];
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                child: Text(curEntry.foodType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                padding: EdgeInsets.fromLTRB(0, hpad(1), 0, 0),
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(curEntry.calories.toString()),
                                  alignment: Alignment.centerRight,
                                ),
                              )
                            ],
                          ),
                          Container(
                              child: Text(curEntry.quantity.toString() + " " + curEntry.measurement),
                              alignment: Alignment.centerLeft,
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : Text("No food entries found")
            ),
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
                  padding: EdgeInsets.fromLTRB(wpad(4), 0, wpad(4), 0),
                  child: Icon(Icons.search),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(6), 0),
                    child: TextField(
                      decoration:
                      InputDecoration(hintText: "Search for a food"),
                    ),
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
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
            Expanded(
                child: myFoods.entryHolder != null &&
                    myFoods.entryHolder.length != 0
                    ? ListView.builder(
                  itemCount: myFoods.entryHolder.length,
                  itemBuilder: (BuildContext context, int index) {
                    //get list of entries of current day
                    CalorieTrackerEntry curEntry =
                    myFoods.entryHolder[index];
                    return GestureDetector(
                      onTap: () {
                        _calorieState = CalorieTrackerState.addEntry;
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(curEntry.foodType),
                            Text(curEntry.quantity.toString()),
                            Text(curEntry.measurement),
                            Text(curEntry.calories.toString()),
                            Container(
                                alignment: Alignment.centerRight,
                                child: FlatButton(
                                  onPressed: () {
                                    entryRef
                                        .child("My Foods")
                                        .child(myFoods
                                        .entryHolder[index].key)
                                        .remove();
                                    myFoods.entryHolder.removeAt(index);
                                    setState(() {});
                                  },
                                  child: Icon(Icons.delete),
                                ))
                          ],
                        ),
                      ),
                    );
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
              _calorieState = CalorieTrackerState.addMyFood;
              setState(() {});
            },
            child: Icon(Icons.add),
          ),
        )
      ],
    );
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
              createRow("Brand Name", "McDonalds", _brandNameController, "text"),
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
                    padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                    child: FlatButton(
                      color: Colors.grey,
                      onPressed: () {
                        _calorieState = CalorieTrackerState.myFood;
                        clearTextControllers();
                        setState(() {});
                      },
                      child: Text("Cancel"),
                    ),
                  )),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(wpad(2), 0, wpad(2), 0),
                    child: FlatButton(
                      color: Colors.grey,
                      onPressed: () {
                        submitAddMyFood();
                        setState(() {});
                      },
                      child: Text("Submit"),
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
            height: hpad(5),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: wpad(90),
            height: hpad(5),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                errorText: title == _errorTextBox ? _errorMessage : null,
                counterText: " ",
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
    } else if (_measurementController.text == "") {
      _errorTextBox = "Brand Name";
      _errorMessage = "Blank must be filled";
    } else if (_servingSizeController.text == "") {
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
        "calories": int.parse(_calorieController.text),
        "foodType": _foodNameController.text,
        "brandName": _brandNameController.text,
        "measurement": _measurementController.text,
        "quantity": int.parse(_servingSizeController.text),
        "time": testEntry.time,
      });
      clearTextControllers();
      _calorieState = CalorieTrackerState.myFood;
    }
    setState(() {});
  }

  void clearTextControllers() {
    _calorieController.clear();
    _servingSizeController.clear();
    _measurementController.clear();
    _foodNameController.clear();
  }

  //<-------------------------------------------------addEntryPage------------------------------------------------->
  Widget addEntryPage() {

  }


  Widget createListViewBorder() {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        border: Border.all(
            width: 3.0
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(5.0)
        ),
      ),
    );
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
