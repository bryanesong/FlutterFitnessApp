import 'package:FlutterFitnessApp/MyProfileReview.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class MyProfileInfo extends StatefulWidget {
  List<bool> goals = new List<bool>();

  MyProfileInfo({this.goals});

  MyProfileInfoState createState() => MyProfileInfoState(goals: goals);
}

class MyProfileInfoState extends State<MyProfileInfo> {
  double _width, _height;
  AutoSizeGroup _textFitGroup;
  String _weightMeasurement, _heightMeasurement;
  double decreaseListviewHeightBy = 0;
  GlobalKey listViewKey = new GlobalKey();
  AutoSizeGroup rowLabels = new AutoSizeGroup();
  //0: Sedentary, 1: Lightly Active, 2: Moderately Active, 3: Very Active
  int _activityLevel = -1;
  TextEditingController _ageController = new TextEditingController(), _heightController = new TextEditingController(), _weightController = new TextEditingController(), _targetWeightController = new TextEditingController();
  List<bool> goals = new List<bool>();

  String errorMessage = "";
  String errorType = "";


  MyProfileInfoState({this.goals});


  @override
  void initState() {
    _weightMeasurement = "Lb";
    _heightMeasurement = "Ft";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _textFitGroup = AutoSizeGroup();
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      print("keyboard up");
      RenderBox box = listViewKey.currentContext.findRenderObject();
      decreaseListviewHeightBy = box.localToGlobal(Offset.zero).dy +
          box.size.height -
          (MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom);
    } else {
      decreaseListviewHeightBy = 0;
    }

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Personal Info"),
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Column(children: [
            createTitle(),
            createRow(),
            createDivider(),
            createListView(),
            makeArrowButtons(),
          ])
        ]));
  }

  Widget createTitle() {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: AutoSizeText(
          "Personal Info",
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
        createColInRow("Goals", "", EdgeInsets.fromLTRB(wpad(16), 0, 0, 0)),
        createColInRow(
            "Personal", "Info", EdgeInsets.fromLTRB(wpad(8), 0, wpad(8), 0)),
        createColInRow("Review", "", EdgeInsets.fromLTRB(0, 0, wpad(16), 0)),
      ],
    );
  }

  Widget createColInRow(String label1, String label2, EdgeInsets insets) {
    return Flexible(
      child: Container(
          height: wpad(18),
          alignment: Alignment.center,
          padding: insets,
          child: Column(
            children: [
              Container(
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

  Widget createListView() {
    return Container(
        key: listViewKey,
        width: wpad(80),
        height: hpad(40) - decreaseListviewHeightBy,
        child: Scrollbar(
            child: ListView(
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
                  errorText: errorType == "Age" ? errorMessage : null
              ),
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
              decoration: InputDecoration(border: OutlineInputBorder(),
                hintText: _heightMeasurement == "Ft" ? "5-11" : null,
                  errorText: errorType == "Height" ? errorMessage : null
              ),
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
                errorText: textLabel == errorType ? errorMessage : null
              ),
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
      child: Column(children: [
        Container(
          width: wpad(80),
            height: hpad(3),
            child: AutoSizeText("Activity Level:",
              group: rowLabels,
              textAlign: TextAlign.left,)),
        createFlatButton("Sedentary", 0),
        createFlatButton("Lightly Active", 1),
        createFlatButton("Moderately Active", 2),
        createFlatButton("Very Active", 3),

      ],),
    );
  }

  Widget createFlatButton(String textLabel, int level) {
    return Container(
        width: wpad(80),
        child: FlatButton(
          color: _activityLevel == level ? Colors.lightBlueAccent : Colors.white,
          onPressed: () {
            setState(() {
              _activityLevel = level;
            });

          },

          shape: RoundedRectangleBorder(side: BorderSide(
              color: Colors.black54,
              width: 1,
              style: BorderStyle.solid
          ), borderRadius: BorderRadius.circular(50)),
          child: Text(textLabel),
      )
    );
  }

  Widget makeArrowButtons() {
    return Expanded(
        child: Stack(children: [
      Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, wpad(5), hpad(5)),
          child: FlatButton(
              onPressed: () {
                if(_ageController.text == "") {
                  print("age error");
                  errorMessage = "Age cannot be blank";
                  errorType = "Age";
                } else if(_heightController.text == "") {
                  errorMessage = "Height cannot be blank";
                  errorType = "Height";
                } else if(_weightController.text == "") {
                  errorMessage = "Weight cannot be blank";
                  errorType = "Weight";
                } else if(_targetWeightController.text == "") {
                  errorMessage = "Target Weight cannot be blank";
                  errorType = "Target Weight";
                } else if(_activityLevel == -1) {

                } else {
                  navigateToReview(context);
                }

                setState(() {});

              },
              child: Image.asset(
                "assets/images/arrow.png",
                height: hpad(7),
              ))),
      Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.fromLTRB(wpad(5), 0, 0, hpad(5)),
          child: FlatButton(
              onPressed: () {
                navigateToPrevPage(context);
              },
              child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Image.asset(
                    "assets/images/arrow.png",
                    height: hpad(7),
                  )))),
    ]));
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }

  Future navigateToPrevPage(context) async {
    Navigator.pop(context);
  }

  Future navigateToReview(context) async {
    Navigator.push(context,CupertinoPageRoute(builder: (context) => MyProfileReview(
        goals: goals,
        age: int.parse(_ageController.text),
        weight: int.parse(_weightController.text),
        targetWeight: int.parse(_targetWeightController.text),
        activityLevel: _activityLevel)));
  }
}
