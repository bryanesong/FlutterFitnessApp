import 'dart:convert';

import 'package:FlutterFitnessApp/Container%20Classes/FoodData.dart';
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
  addEntry,
  editEntry
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
      _timeController = new TextEditingController(),
      _searchFoodController = new TextEditingController();

  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference entryRef;

  FoodData testEntry;

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

    testEntry = new FoodData(
        calories: 100,
        foodType: "potato",
        measurement: "Cup",
        quantity: 1,
        time: DateFormat('yyyy-MM-dd').format(new DateTime(2020, 8, 26)));

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
      case CalorieTrackerState.editEntry:
        return editEntryPage();
      default:
        return null;
    }
  }

  //<-------------------------------------------------FoodEntryPage------------------------------------------------->
  DateTime selectedDateTime;
  Widget foodEntryPage() {
    DatedEntryList listOfCurDay;
    //if selected day is not null, get entries of the day
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
              initialSelectedDay: selectedDateTime != null ? selectedDateTime : DateTime.now(),
              initialCalendarFormat: CalendarFormat.week,
              formatAnimation: FormatAnimation.slide,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              availableGestures: AvailableGestures.all,
              availableCalendarFormats: const {
                CalendarFormat.week: 'Weekly',
              },
              onDaySelected: _onDaySelected,
            ),
            Expanded(
                child: listOfCurDay != null
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        //get list of entries of current day
                        itemCount: listOfCurDay.length(),
                        itemBuilder: (BuildContext context, int index) {
                          FoodData curEntry = listOfCurDay.entries[index];
                          return ListTile(
                          onTap: () {
                            //set global variable to current entry so editEntry widget knows which entry to edit
                            editEntry = curEntry;

                            //set the controllers to show  the entry data
                            _foodNameController.text = editEntry.foodType;
                            _brandNameController.text = editEntry.brandName;
                            _servingSizeController.text = editEntry.quantity.toInt().toString();
                            _measurementController.text = editEntry.measurement;
                            _calorieController.text = editEntry.calories.toString();
                            _timeController.text = editEntry.time;
                            _calorieState = CalorieTrackerState.editEntry;
                            setState(() {

                            });
                          },
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

  void _onDaySelected(DateTime day, List events) {
    selectedDateTime = day;
    //update widgets when new day is selected
    setState(() {});
  }

  //<-------------------------------------------------EditEntryPage------------------------------------------------->
  FoodData editEntry = new FoodData();
  Widget editEntryPage() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, hpad(3), 0, 0),
          child: Column(
            children: [
              createEditRow("Food Name", editEntry.foodType, _foodNameController, "text"),
              createEditRow("Brand Name (not required)", editEntry.brandName,
                  _brandNameController, "text"),
              createEditRow("Serving Size", editEntry.quantity.toInt().toString(), _servingSizeController, "number"),
              createEditRow("Measurement", editEntry.measurement, _measurementController, "text"),
              createEditRow("Calories", editEntry.calories.toInt().toString(), _calorieController, "number"),
              createEditRow("Time", editEntry.time, _timeController, "text"),
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
                        _calorieState = CalorieTrackerState.log;
                        _errorTextBox = "";
                        clearEditTextControllers();
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
                        submitChangeEntry();
                        setState(() {});
                      },
                      child: Text("Change", style: TextStyle(color: Colors.blue)),
                    ),
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget createEditRow(String title, String currentText, TextEditingController controller,
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
              maxLines: 1,
              decoration: InputDecoration(
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

  void submitChangeEntry() {
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
    } else if (_timeController.text == "") {
      _errorTextBox = "Time";
      _errorMessage = "Blank must be filled";
    } else {
      print(editEntry.key);
      entryRef.child("My Entries").child(DateFormat('yyyy-MM-dd').format(selectedDateTime)).child(editEntry.key).set({
        "calories": double.parse(_calorieController.text),
        "foodType": _foodNameController.text,
        "brandName": _brandNameController.text,
        "measurement": _measurementController.text,
        "quantity": double.parse(_servingSizeController.text),
        "time": _timeController.text,
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        clearEditTextControllers();
        _errorTextBox = "";
        _calorieState = CalorieTrackerState.log;
        setState(() {});
      });
    }
    setState(() {});
  }

  void clearEditTextControllers() {
    _calorieController.clear();
    _servingSizeController.clear();
    _measurementController.clear();
    _foodNameController.clear();
    _brandNameController.clear();
    _timeController.clear();
  }

  //<-------------------------------------------------SearchFoodPage------------------------------------------------->
  List<FoodData> searchEntries = new List<FoodData>();

  Widget searchFoodPage() {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                //back button to go back to the log
                Container(
                  child: FlatButton(
                    onPressed: () {
                      _calorieState = CalorieTrackerState.log;
                      _searchFoodController.clear();
                      searchEntries.clear();
                      setState(() {

                      });
                    },
                    child: Icon(Icons.chevron_left),
                  ),
                ),
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
                  FoodData curEntry = searchEntries[index];
                  return GestureDetector(
                      onTap: () {
                        _calorieState = CalorieTrackerState.addEntry;
                      },
                      child: ListTile(
                        onTap: () {
                          print("clicked");
                          addEntryDialog(curEntry);
                        },
                        title: Text(curEntry.foodType,
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

  Future<List<FoodData>> fetchData(String foodSearch) async {
    final responseMain = await http.get(
        "https://api.nal.usda.gov/fdc/v1/foods/list?api_key=OtpdWCaIaKlnq3DXBs5VcVorVDopFLNaVrGLWT6i&query=${foodSearch.replaceAll(" ", "%20")}");
    List<FoodData> searchEntryList = new List<FoodData>();
    print(responseMain.statusCode);

    if (responseMain.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      for (Map i in jsonDecode(responseMain.body)) {
        searchEntryList.add(FoodData.fromJson(i));
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
                //back button to go back to the log
                Container(
                  child: FlatButton(
                    onPressed: () {
                      _calorieState = CalorieTrackerState.log;
                      _searchFoodController.clear();
                      searchEntries.clear();
                      setState(() {

                      });
                    },
                    child: Icon(Icons.chevron_left),
                  ),
                ),
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
                  FoodData curEntry = myFoods.entryHolder[index];
                  return ListTile(
                    onTap: () {
                      addEntryDialog(curEntry);
                    },
                    title: Text(curEntry.foodType,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(curEntry.quantity.toInt().toString() +
                        " " +
                        curEntry.measurement),
                    trailing: Container(
                      width: wpad(20),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              curEntry.calories.toString(),
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
                  );
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

  void addEntryDialog(FoodData curEntry) async {
    //fill out foodEntryInfo in the same way as a USDA entry
    if (!curEntry.isUSDAEntry) {
      curEntry.clearArrays();
      curEntry.portionNames.add(curEntry.quantity.toInt().toString() + " " + curEntry.measurement);
      curEntry.portionUnits.add("g");
      curEntry.portionSizes.add(100);
    } else {
      await curEntry.findPortions();
    }



    List<String> combinedPortionNameSize = new List<String>();
    for (int i = 0; i < curEntry.portionNames.length; i++) {
      //combine portion name and portion sizes for dropdown list
      if(curEntry.isUSDAEntry) {
        combinedPortionNameSize.add(
            curEntry.portionNames[i] + " (" + curEntry.portionSizes[i].toString() + curEntry.portionUnits[i] + ")");
      } else {
        combinedPortionNameSize.add(curEntry.portionNames[i]);
      }
    }

    String selectedPortion = combinedPortionNameSize[0];
    int pickedIndex = 0;

    _addFoodEntryController.text = "1";

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(curEntry.foodType),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
                FlatButton(
                  onPressed: () {
                    if (addEntry(
                        curEntry,
                        _addFoodEntryController,
                        curEntry.portionSizes[pickedIndex],
                        curEntry.portionNames[pickedIndex],
                        curEntry.portionUnits[pickedIndex])) {
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

                              //locate index from selectedPortion variable
                              for (int i = 0;
                                  i < combinedPortionNameSize.length;
                                  i++) {
                                if (selectedPortion ==
                                    combinedPortionNameSize[i]) {
                                  pickedIndex = i;
                                }
                              }
                            });
                          },
                          items: combinedPortionNameSize
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
                                        curEntry.portionSizes[pickedIndex] *
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

  bool addEntry(FoodData curEntry, TextEditingController controller,
      double portionSize, String portionName, String portionUnit) {
    if (controller.text != "") {
      entryRef
          .child("My Entries")
          .child(DateFormat('yyyy-MM-dd').format(selectedDateTime))
          .push()
          .set({
        "calories": double.parse((double.parse(_addFoodEntryController.text) *
                portionSize *
                (curEntry.calories / 100))
            .toStringAsFixed(2)),
        "foodType": curEntry.foodType,
        "measurement": portionName,
        "quantity": double.parse(controller.text),
        "time": DateFormat('hh:mm a').format(DateTime.now()).toString(),
        "portionSize": portionSize,
        "portionUnit": portionUnit,
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
