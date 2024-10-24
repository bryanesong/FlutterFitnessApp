import 'dart:convert';

import 'package:FlutterFitnessApp/ContainerClasses/AppStateEnum.dart';
import 'package:FlutterFitnessApp/ContainerClasses/CalorieEntryContainer.dart';
import 'package:FlutterFitnessApp/ContainerClasses/FoodData.dart';
import 'package:FlutterFitnessApp/ContainerClasses/MyFoodsContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:FlutterFitnessApp/ContainerClasses/PSize.dart';

class CalorieTracker extends StatefulWidget {
  final Function(AppState appState) onAppStateChange;
  final AppState appState;

  CalorieTracker({@required this.appState, @required this.onAppStateChange});

  @override
  CalorieTrackerState createState() => CalorieTrackerState();
}


class CalorieTrackerState extends State<CalorieTracker> with TickerProviderStateMixin {
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  //var to be disposed when object life is over
  var _entryAddedListener;

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


  void initState() {
    getCurUser();
    super.initState();
  }

  @override
  dispose() {
    _searchFoodController.dispose();
    _timeController.dispose();
    _calorieController.dispose();
    _measurementController.dispose();
    //_searchFoodController.dispose();
    _calorieCalendarController.dispose();
    _servingSizeController.dispose();
    _brandNameController.dispose();
    _foodNameController.dispose();
    _addFoodEntryController.dispose();
    _entryAddedListener.cancel();
    super.dispose();
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
    _entryAddedListener = entryRef.child("My Entries").onChildAdded.listen(_onEntry);
  }

  void _onEntry(Event e) {
    setState(() {});
  }

  Widget build(BuildContext context) {

    switch (widget.appState) {
      case AppState.Calorie_Log:
        return foodEntryPage();
      case AppState.Calorie_MyFood:
        return myFoodPage();
      case AppState.Calorie_SearchFood:
        return searchFoodPage();
      case AppState.Calorie_AddMyFood:
        return addMyFoodPage();
      case AppState.Calorie_EditEntry:
        return editEntryPage();
      default:
        return null;
    }
  }

  //<-------------------------------------------------FoodEntryPage------------------------------------------------->
  DateTime selectedDateTime = DateTime.now();

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
            Container(
              padding: EdgeInsets.fromLTRB(0, PSize.hPix(5), 0, 0),
              child: TableCalendar(
                calendarController: _calorieCalendarController,
                initialSelectedDay:
                selectedDateTime != null ? selectedDateTime : DateTime.now(),
                initialCalendarFormat: CalendarFormat.week,
                formatAnimation: FormatAnimation.slide,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                availableGestures: AvailableGestures.all,
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Weekly',
                },
                onDaySelected: _onDaySelectedCalorie,
              ),
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
                                _servingSizeController.text =
                                    editEntry.quantity.toInt().toString();
                                _measurementController.text =
                                    editEntry.measurement;
                                _calorieController.text =
                                    editEntry.calories.toString();
                                _timeController.text = editEntry.time;

                                //set state
                                widget.onAppStateChange(AppState.Calorie_EditEntry);
                                setState(() {});
                              },
                              title: Text(
                                curEntry.foodType,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(curEntry.brandName != null &&
                                      curEntry.brandName != ""
                                  ? "[" +
                                      curEntry.brandName +
                                      "] " +
                                      curEntry.quantity.toInt().toString() +
                                      ", " +
                                      curEntry.measurement
                                  : curEntry.quantity.toInt().toString() +
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
          padding: EdgeInsets.all(5),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              widget.onAppStateChange(AppState.Calorie_SearchFood);
              setState(() {});
            },
            child: Icon(Icons.restaurant),
          ),
        ),

        //list view border
      ],
    );
  }

  void _onDaySelectedCalorie(DateTime day, List events) {
    //update widgets when new day is selected
    setState(() {
      selectedDateTime = day;
    });
  }

  //<-------------------------------------------------EditEntryPage------------------------------------------------->
  FoodData editEntry = new FoodData();

  Widget editEntryPage() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, PSize.hPix(3), 0, 0),
          child: Column(
            children: [
              createEditRow(
                  "Food Name", editEntry.foodType, _foodNameController, "text"),
              createEditRow("Brand Name (not required)", editEntry.brandName,
                  _brandNameController, "text"),
              createEditRow(
                  "Serving Size",
                  editEntry.quantity.toInt().toString(),
                  _servingSizeController,
                  "number"),
              createEditRow("Measurement", editEntry.measurement,
                  _measurementController, "text"),
              createEditRow("Calories", editEntry.calories.toInt().toString(),
                  _calorieController, "number"),
              createEditRow("Time", editEntry.time, _timeController, "text"),
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          width: PSize.wPix(100),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(PSize.wPix(2), 0, PSize.wPix(2), PSize.wPix(2)),
                child: FlatButton(
                  onPressed: () {
                    widget.onAppStateChange(AppState.Calorie_Log);
                    _errorTextBox = "";
                    clearEditTextControllers();
                    setState(() {});
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
              )),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(PSize.wPix(2), 0, PSize.wPix(2), PSize.wPix(2)),
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

  Widget createEditRow(String title, String currentText,
      TextEditingController controller, String inputType) {
    return Container(
      padding: EdgeInsets.fromLTRB(PSize.wPix(5), 0, PSize.wPix(5), PSize.hPix(1)),
      child: Column(
        children: [
          Container(
            width: PSize.wPix(90),
            height: PSize.hPix(4),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: PSize.wPix(90),
            height: title == _errorTextBox ? PSize.hPix(6) : PSize.hPix(4),
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
      entryRef
          .child("My Entries")
          .child(DateFormat('yyyy-MM-dd').format(selectedDateTime))
          .child(editEntry.key)
          .set({
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
        widget.onAppStateChange(AppState.Calorie_Log);
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
  String dropdownValue = "";

  Widget searchFoodPage() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              //to space below the nav bar
              padding: EdgeInsets.fromLTRB(0, PSize.hPix(7), 0, 0),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(PSize.wPix(2), PSize.wPix(2), PSize.wPix(2), 0),
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          color: widget.appState == AppState.Calorie_SearchFood
                              ? Colors.lightBlueAccent
                              : Colors.blue,
                          onPressed: () {},
                          child: Text("Search Food"),
                        ),
                      )),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(PSize.wPix(2), PSize.wPix(2),PSize.wPix(2), 0),
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          color: widget.appState == AppState.Calorie_MyFood
                              ? Colors.lightBlueAccent
                              : Colors.blue,
                          onPressed: () {
                            widget.onAppStateChange(AppState.Calorie_MyFood);
                            setState(() {});
                          },
                          child: Text("My Food"),
                        ),
                      )),
                ],
              ),
            ),

            Row(
              children: [
                Container(
                    //padding: EdgeInsets.fromLTRB(PSize.wPix(4), 0, PSize.wPix(4), 0),
                    child: FlatButton(
                  onPressed: () {
                    searchDatabase(_searchFoodController.text);
                  },
                  child: Icon(Icons.search),
                )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(PSize.wPix(2), 0, PSize.wPix(6), 0),
                    child: TextField(
                      controller: _searchFoodController,
                      decoration:
                          InputDecoration(hintText: "Search for a food"),
                    ),
                  ),
                ),
                Container(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        //resort list
                        sortSearchFoodList(searchEntries);
                      });
                    },
                    items: <String>['' ,'A-Z', 'Z-A', 'Cal ^', 'Cal v']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                )
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
                        widget.onAppStateChange(AppState.Calorie_AddEntry);
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
                          width: PSize.wPix(20),
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
                padding: EdgeInsets.fromLTRB(0, PSize.hPix(2), 0, 0),
                child: Text("No food entries found")));
  }

  void searchDatabase(String foodSearch) async {
    searchEntries = await fetchData(foodSearch);
    sortSearchFoodList(searchEntries);
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

  void sortSearchFoodList(List<FoodData> searchEntries) {
    bool swapOccured = true;
    while(swapOccured) {
      swapOccured = false;
      for (int i = 0; i < searchEntries.length-1; i++) {
        FoodData tempData = searchEntries[0];

        print("run");
        if(dropdownValue == "A-Z" && searchEntries[i].foodType.compareTo(searchEntries[i+1].foodType) > 0) {
          //if entry 1 comes later than entry 2 in the alphabet, swap
          tempData = searchEntries[i];
          searchEntries[i] = searchEntries[i+1];
          searchEntries[i+1] = tempData;
          //stay in loop of swap occured
          swapOccured = true;

        } else if(dropdownValue == "Z-A" && searchEntries[i].foodType.compareTo(searchEntries[i+1].foodType) < 0) {
          //if entry 1 comes earlier than entry 2 in the alphabet, swap
          tempData = searchEntries[i];
          searchEntries[i] = searchEntries[i+1];
          searchEntries[i+1] = tempData;
          //stay in loop of swap occured
          swapOccured = true;

        } else if(dropdownValue == "Cal v" && searchEntries[i].calories < searchEntries[i+1].calories) {
          //if entry 1 has less calories than entry 2, swap
          tempData = searchEntries[i];
          searchEntries[i] = searchEntries[i+1];
          searchEntries[i+1] = tempData;
          //stay in loop of swap occured
          swapOccured = true;

        } else if(dropdownValue == "Cal ^" && searchEntries[i].calories > searchEntries[i+1].calories) {
          //if entry 1 has more calories than entry 2, swap
          tempData = searchEntries[i];
          searchEntries[i] = searchEntries[i+1];
          searchEntries[i+1] = tempData;
          //stay in loop of swap occured
          swapOccured = true;

        }
      }
    }
  }

  //<-------------------------------------------------myFoodPage------------------------------------------------->
  Widget myFoodPage() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              //to space below the nav bar
              padding: EdgeInsets.fromLTRB(0, PSize.hPix(7), 0, 0),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(PSize.wPix(2), PSize.wPix(2), PSize.wPix(2), 0),
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          color: widget.appState == AppState.Calorie_SearchFood
                              ? Colors.lightBlueAccent
                              : Colors.blue,
                          onPressed: () {
                            widget.onAppStateChange(AppState.Calorie_SearchFood);
                            setState(() {});
                          },
                          child: Text("Search Food"),
                        ),
                      )),
                  Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(PSize.wPix(2), PSize.wPix(2), PSize.wPix(2), 0),
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          color: widget.appState == AppState.Calorie_MyFood
                              ? Colors.lightBlueAccent
                              : Colors.blue,
                          onPressed: () {},
                          child: Text("My Food"),
                        ),
                      )),
                ],
              ),
            ),
            createMyFoodListView(),
          ],
        ),
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {
              widget.onAppStateChange(AppState.Calorie_AddMyFood);
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
                      width: PSize.wPix(20),
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
          //to space below the nav bar
          padding: EdgeInsets.fromLTRB(0, PSize.hPix(6.5), 0, 0),
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
          width: PSize.wPix(100),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(PSize.wPix(2), 0, PSize.wPix(2), PSize.wPix(2)),
                child: FlatButton(
                  onPressed: () {
                    widget.onAppStateChange(AppState.Calorie_MyFood);
                    clearTextControllers();
                    setState(() {});
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                ),
              )),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(PSize.wPix(2), 0, PSize.wPix(2), PSize.wPix(2)),
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
      padding: EdgeInsets.fromLTRB(PSize.wPix(5), 0, PSize.wPix(5), PSize.hPix(1)),
      child: Column(
        children: [
          Container(
            width: PSize.wPix(90),
            height: PSize.hPix(4),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: PSize.wPix(90),
            height: title == _errorTextBox ? PSize.hPix(6) : PSize.hPix(4),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                errorText: title == _errorTextBox ? _errorMessage : null,
                /*focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                )*/
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
        "time": DateFormat('hh:MM a').format(DateTime.now()),
      });
      clearTextControllers();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAppStateChange(AppState.Calorie_MyFood);
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
      curEntry.portionNames.add(
          curEntry.quantity.toInt().toString() + " " + curEntry.measurement);
      curEntry.portionUnits.add("g");
      curEntry.portionSizes.add(100);
    } else {
      await curEntry.findPortions();
    }

    List<String> combinedPortionNameSize = new List<String>();
    for (int i = 0; i < curEntry.portionNames.length; i++) {
      //combine portion name and portion sizes for dropdown list
      if (curEntry.isUSDAEntry) {
        combinedPortionNameSize.add(curEntry.portionNames[i] +
            " (" +
            curEntry.portionSizes[i].toString() +
            curEntry.portionUnits[i] +
            ")");
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
                                  width: PSize.wPix(60),
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
                          width: PSize.wPix(10),
                          padding: EdgeInsets.fromLTRB(0, 0, PSize.wPix(3), 0),
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
        "brandName": curEntry.brandName,
      });
      return true;
    } else {
      return false;
    }
  }

  //this will return the stats container widget although not yet implemented, still waiting on both calorie tracker / workout log integration
  Widget getStatsWidget() {
    return new Container();
  }

  //this will return the inventory widget, not yet implemented(assigned to Evan)
  Widget getInventoryWidget() {
    return new Container();
  }
}
