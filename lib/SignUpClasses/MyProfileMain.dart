import 'package:FlutterFitnessApp/AnimationTest.dart';
import 'package:FlutterFitnessApp/HomeScreen.dart';
import 'package:FlutterFitnessApp/main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

enum ProfilePageMarker { Goals, Info, Review }

class MyProfileMain extends StatefulWidget {
  final username;
  final email;

  MyProfileMain({this.username, this.email});

  MyProfileMainState createState() =>
      MyProfileMainState(username: username, email: email);
}

class MyProfileMainState extends State<MyProfileMain> {
  double _width, _height;
  AutoSizeGroup _textFitGroup = new AutoSizeGroup(),
      _reviewTextGroup = new AutoSizeGroup();

  //overall variables
  Widget _myProfileGoalsPage, _myProfileInfoPage, _myProfileReviewPage;
  ProfilePageMarker _selectedProfilePage;
  String username;
  String email;
  FirebaseUser user;
  ScrollController _scrollController = new ScrollController();
  DatabaseReference ref;
  String _titleText;
  GlobalKey _goalsKey = new GlobalKey(),
      _personalInfoKey = new GlobalKey(),
      _reviewKey = new GlobalKey(),
      _curPageKey = new GlobalKey();
  double miniPenguinSize = 0, miniPenguinX = 0, miniPenguinY = 0;

  //MyProfileGoals variables
  AutoSizeGroup _checkListFitGroup;
  bool _trackCalories = false,
      _gainWeight = false,
      _loseWeight = false,
      _maintainWeight = false,
      _trackWorkouts = false;
  List<bool> goals = new List<bool>();

  //MyProfileInfo variables
  String _weightMeasurement = "Lb", _heightMeasurement = "Ft";
  double decreaseListviewHeightBy = 0;
  GlobalKey listViewKey = new GlobalKey();
  AutoSizeGroup rowLabels = new AutoSizeGroup();
  int _activityLevel =
      -1; //0: Sedentary, 1: Lightly Active, 2: Moderately Active, 3: Very Active
  TextEditingController _ageController = new TextEditingController(),
      _heightController = new TextEditingController(),
      _weightController = new TextEditingController(),
      _targetWeightController = new TextEditingController();
  String errorMessage = "";
  String errorType = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  MyProfileMainState({this.user, this.username, this.email});

  @override
  void initState() {
    getCurUser();

    _selectedProfilePage = ProfilePageMarker.Goals;

    ref = FirebaseDatabase.instance.reference();

    goals = [
      _trackCalories,
      _gainWeight,
      _loseWeight,
      _maintainWeight,
      _trackWorkouts
    ];

    Future.delayed(Duration(milliseconds: 300), () {
      moveMiniPenguin();
    });

    super.initState();
  }

  void getCurUser() async {
    user = await auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    //decrease window size for MyProfileInfo list view
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      print("keyboard up");
      if(listViewKey.currentContext != null) {
        RenderBox box = listViewKey.currentContext.findRenderObject();
        decreaseListviewHeightBy = box
            .localToGlobal(Offset.zero)
            .dy +
            box.size.height -
            (MediaQuery
                .of(context)
                .size
                .height -
                MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom);
      }
    } else {
      decreaseListviewHeightBy = 0;
    }


    updateListView();

    //create variables to store the 3 list views

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Register Info"),
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Column(children: [
            createTitle(),
            createRow(),
            createDivider(),
            displayListView(),
            makeArrowButtons(),
          ]),
          makeMiniPenguin(),
        ]));
  }

  Widget createTitle() {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: AutoSizeText(
          _titleText,
          maxLines: 1,
          style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w900,
              color: Colors.black54,
              fontSize: 53),
        ));
  }

  Widget createRow() {
    return Row(
      children: [
        createColInRow(
            "Goals", "", EdgeInsets.fromLTRB(wpad(16), 0, 0, 0), _goalsKey),
        createColInRow("Personal", "Info",
            EdgeInsets.fromLTRB(wpad(8), 0, wpad(8), 0), _personalInfoKey),
        createColInRow(
            "Review", "", EdgeInsets.fromLTRB(0, 0, wpad(16), 0), _reviewKey),
      ],
    );
  }

  Widget createColInRow(
      String label1, String label2, EdgeInsets insets, GlobalKey key) {
    return Flexible(
      child: Container(
          height: wpad(18),
          alignment: Alignment.center,
          padding: insets,
          child: Column(
            children: [
              Container(
                key: key,
                width: wpad(10),
                height: wpad(10),
                child: Image.asset("assets/images/transparentCircle.png"),
              ),
              Expanded(
                child: AutoSizeText(label1,
                    maxLines: 1,
                    group: _textFitGroup,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                    )),
              ),
              Expanded(
                child: AutoSizeText(label2,
                    maxLines: 1,
                    group: _textFitGroup,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w900,
                      color: Colors.black54,
                    )),
              )
            ],
          )),
    );
  }

  Widget createDivider() {
    return Divider(
      color: Colors.black,
      height: 20,
      thickness: 2,
      indent: wpad(25),
      endIndent: wpad(25),
    );
  }

  Widget displayListView() {
    switch (_selectedProfilePage) {
      case ProfilePageMarker.Goals:
        return _myProfileGoalsPage;
      case ProfilePageMarker.Info:
        return _myProfileInfoPage;
        break;
      case ProfilePageMarker.Review:
        return _myProfileReviewPage;
        break;
      default:
        print("no profile page selected");
        return null;
    }
  }

  Widget updateListView() {
    switch (_selectedProfilePage) {
      case ProfilePageMarker.Goals:
        _curPageKey = _goalsKey;
        _titleText = "Goals";
        _myProfileGoalsPage = createGoalsListView();
        break;
      case ProfilePageMarker.Info:
        _curPageKey = _personalInfoKey;
        _titleText = "Personal Info";
        _myProfileInfoPage = createInfoListView();
        break;
      case ProfilePageMarker.Review:
        _curPageKey = _reviewKey;
        _titleText = "Review";
        _myProfileReviewPage = createReviewListView();
        break;
    }
  }

  Widget makeMiniPenguin() {
    return AnimatedPositioned(
      duration: Duration(seconds: 2),
      curve: Curves.easeInOut,
      left: miniPenguinX,
      top: miniPenguinY,
      child: Container(
        child: Image.asset(
          "assets/images/penguin1.png",
          width: miniPenguinSize,
          height: miniPenguinSize,
        ),
      ),
    );
  }

  void moveMiniPenguin() {
    RenderBox box;
    Offset position;
    box = _curPageKey.currentContext.findRenderObject();
    position = box.localToGlobal(Offset.zero);
    miniPenguinSize = box.size.height;
    miniPenguinX = position.dx;
    miniPenguinY = position.dy -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top;
    setState(() {

    });
  }

  //<-------------------------------MyProfileGoals List View------------------------------->

  Widget createGoalsListView() {
    return Container(
        height: hpad(40),
        child: Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              children: [
                makeIndivChoice("Track My Calories", 0),
                makeIndivChoice("Gain Weight", 1),
                makeIndivChoice("Lose Weight", 2),
                makeIndivChoice("Maintain Weight", 3),
                makeIndivChoice("Track My Workouts", 4),
              ],
            )));
  }

  Widget makeIndivChoice(String boldedText, int index) {
    bool refBool = goals[index];
    return Row(children: [
      Expanded(
          child: StatefulBuilder(
              builder: (context, _setState) => CheckboxListTile(
                    value: refBool,
                    onChanged: (bool value) {
                      _setState(() {
                        refBool = value;
                        workaroundUpdateBool(index, value);
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: AutoSizeText.rich(
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w300,
                            fontSize: 20),
                        children: <TextSpan>[
                          TextSpan(text: "I want to "),
                          TextSpan(
                              text: boldedText,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black54))
                        ],
                      ),
                      maxLines: 1,
                      group: _checkListFitGroup,
                    ),
                  )))
    ]);
  }

  void workaroundUpdateBool(int index, bool val) {
    goals[index] = val;
  }

  //<-------------------------------MyProfileInfo List View------------------------------->

  Widget createInfoListView() {
    return Container(
        key: listViewKey,
        width: wpad(80),
        height: hpad(40) - decreaseListviewHeightBy,
        child: Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              children: [
                createAgeRow(),
                createHeightRow(),
                createWeightRow("Weight", _weightController),
                createWeightRow("Target Weight", _targetWeightController),
                createSedentaryLevels(),
              ],
            )));
  }

  Widget createAgeRow() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, hpad(2), 0, 0),
        child: Row(
          children: [
            Expanded(
                child: AutoSizeText(
              "Age   ",
              group: rowLabels,
              maxLines: 1,
            )),
            Container(
                padding: EdgeInsets.fromLTRB(wpad(1), 0, 0, 0),
                width: wpad(67),
                //height: hpad(8),
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorText: errorType == "Age" ? errorMessage : null),
                )),
          ],
        ));
  }

  Widget createHeightRow() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, hpad(2), 0, 0),
        child: Row(
          children: [
            Expanded(
                child: AutoSizeText(
              "Height",
              group: rowLabels,
              maxLines: 1,
            )),
            Container(
                padding: EdgeInsets.fromLTRB(wpad(1), 0, wpad(3), 0),
                width: wpad(52),
                //height: hpad(8),
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: _heightMeasurement == "Ft" ? "5-11" : null,
                      errorText: errorType == "Height" ? errorMessage : null),
                )),
            Container(
                width: wpad(15),
                //height: hpad(8),
                child: DropdownButton<String>(
                  value: _heightMeasurement,
                  onChanged: (String value) {
                    setState(() {
                      _heightMeasurement = value;
                    });
                  },
                  items: <String>['Ft', 'Cm']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ))
          ],
        ));
  }

  Widget createWeightRow(String textLabel, TextEditingController controller) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, hpad(2), 0, 0),
        child: Row(
          children: [
            Expanded(
                child: AutoSizeText(
              textLabel,
              group: rowLabels,
              maxLines: 2,
            )),
            Container(
                padding: EdgeInsets.fromLTRB(wpad(1), 0, wpad(3), 0),
                width: wpad(52),
                //height: hpad(8),
                child: TextField(
                  controller: controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorText: textLabel == errorType ? errorMessage : null),
                  keyboardType: TextInputType.number,
                )),
            Container(
                width: wpad(15),
                //height: hpad(8),
                child: DropdownButton<String>(
                  value: _weightMeasurement,
                  onChanged: (String value) {
                    setState(() {
                      _weightMeasurement = value;
                    });
                  },
                  items: <String>['Lb', 'Kg']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ))
          ],
        ));
  }

  Widget createSedentaryLevels() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, hpad(3), 0, hpad(3)),
      child: Column(
        children: [
          Container(
              width: wpad(80),
              height: hpad(3),
              child: AutoSizeText(
                "Activity Level:",
                group: rowLabels,
                textAlign: TextAlign.left,
              )),
          createFlatButton("Sedentary", 0),
          createFlatButton("Lightly Active", 1),
          createFlatButton("Moderately Active", 2),
          createFlatButton("Very Active", 3),
        ],
      ),
    );
  }

  Widget createFlatButton(String textLabel, int level) {
    return Container(
        width: wpad(80),
        child: FlatButton(
          color:
              _activityLevel == level ? Colors.lightBlueAccent : Colors.white,
          onPressed: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _activityLevel = level;
            });
          },
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.black54, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50)),
          child: Text(textLabel),
        ));
  }

  //<-------------------------------MyProfileReview List View------------------------------->

  Widget createReviewListView() {
    return Container(
      width: wpad(80),
      height: hpad(40) - decreaseListviewHeightBy,
      child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: [
              createInfoRow("Username: ", username, 1),
              createLongDivider(),
              createInfoRow("Email: ", email, 1),
              createLongDivider(),
              createInfoRow("Goals: ", getGoals(), 2),
              createLongDivider(),
              createInfoRow("Age: ", _ageController.text, 1),
              createLongDivider(),
              createInfoRow("Height: ",
                  _heightController.text + " " + _heightMeasurement, 1),
              createLongDivider(),
              createInfoRow("Weight: ",
                  _weightController.text + " " + _weightMeasurement, 1),
              createLongDivider(),
              createInfoRow("Target Weight: ",
                  _targetWeightController.text + " " + _weightMeasurement, 1),
              createLongDivider(),
              createInfoRow("Activity Level: ", getActivityLevel(), 1),
            ],
          )),
    );
  }

  Widget createInfoRow(String textLabel, String info, int maxLines) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, hpad(1), 0, hpad(1)),
      width: wpad(80),
      child: Row(
        children: [
          Expanded(
            child: AutoSizeText.rich(
              TextSpan(
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w300,
                    fontSize: 20),
                children: <TextSpan>[
                  TextSpan(text: textLabel),
                  TextSpan(
                      text: info,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w900,
                          color: Colors.black54))
                ],
              ),
              maxLines: 1,
              group: _reviewTextGroup,
            ),
          )
        ],
      ),
    );
  }

  Widget createLongDivider() {
    return Divider(
      color: Colors.grey,
      height: 20,
      thickness: 1,
    );
  }

  Widget makeArrowButtons() {
    if (_selectedProfilePage == ProfilePageMarker.Goals) {
      return Expanded(child: Stack(children: [createRightArrow()]));
    } else {
      return Expanded(
          child: Stack(children: [createRightArrow(), createLeftArrow()]));
    }
  }

  Widget createLeftArrow() {
    return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.fromLTRB(wpad(5), 0, 0, hpad(5)),
        child: FlatButton(
            onPressed: () {
              backArrowPressed();
            },
            child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.asset(
                  "assets/images/arrow.png",
                  height: hpad(7),
                ))));
  }

  Widget createRightArrow() {
    if (_selectedProfilePage == ProfilePageMarker.Review) {
      return Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, hpad(5), hpad(5)),
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.black54)),
            onPressed: () {
              nextArrowPressed();
            },
            child: Text("GO!", style: TextStyle(fontSize: 20)),
          ));
    } else {
      return Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, wpad(5), hpad(5)),
          child: OutlineButton(
              onPressed: () {
                nextArrowPressed();
              },
              child: Image.asset(
                "assets/images/arrow.png",
                height: hpad(7),
              )));
    }
  }

  void backArrowPressed() {

    switch (_selectedProfilePage) {
      case ProfilePageMarker.Goals:
        break;
      case ProfilePageMarker.Info:
        _selectedProfilePage = ProfilePageMarker.Goals;
        break;
      case ProfilePageMarker.Review:
        _selectedProfilePage = ProfilePageMarker.Info;
        break;
    }

    //update build
    setState(() {});
    updateListView();
    moveMiniPenguin();
  }

  void nextArrowPressed() {

    switch (_selectedProfilePage) {
      case ProfilePageMarker.Goals:
        _selectedProfilePage = ProfilePageMarker.Info;
        break;

      case ProfilePageMarker.Info:
        if (_ageController.text == "") {
          print("age error");
          errorMessage = "Age cannot be blank";
          errorType = "Age";
        } else if (_heightController.text == "") {
          errorMessage = "Height cannot be blank";
          errorType = "Height";
        } else if (_weightController.text == "") {
          errorMessage = "Weight cannot be blank";
          errorType = "Weight";
        } else if (_targetWeightController.text == "") {
          errorMessage = "Target Weight cannot be blank";
          errorType = "Target Weight";
        } else if (_activityLevel == -1) {
        } else {
          _selectedProfilePage = ProfilePageMarker.Review;
        }
        break;

      case ProfilePageMarker.Review:
        ref.child("Users").child(user.uid).child("User Info").set({
          'Username': username,
          'Email': email,
          'Goals': getGoals(),
          'Age': _ageController.text,
          'Height': _heightController.text,
          'HMeasureType': _heightMeasurement,
          'Weight': _weightController.text,
          'Target Weight': _targetWeightController.text,
          'WMeasureType': _weightMeasurement,
          'Activity Level': getActivityLevel(),
        });
        navigateToHomePage(context);
        break;
    }
    //update build
    setState(() {});
    updateListView();
    moveMiniPenguin();
  }

  String getActivityLevel() {
    switch (_activityLevel) {
      case (0):
        return "Sedentary";
      case (1):
        return "Lightly Active";
      case (2):
        return "Moderately Active";
      case (3):
        return "Very Active";
      default:
        return null;
    }
  }

  String getGoals() {
    String returnString = "";
    if (goals[0]) {
      returnString += "Track Calories, ";
    }
    if (goals[1]) {
      returnString += "Gain Weight, ";
    }
    if (goals[2]) {
      returnString += "Lose Weight, ";
    }
    if (goals[3]) {
      returnString += "Maintain Weight, ";
    }
    if (goals[4]) {
      returnString += "Track Workouts, ";
    }

    if (returnString.length > 0) {
      returnString = returnString.substring(0, returnString.length - 2);
    }
    return returnString;
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }

  Future navigateToHomePage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
