import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyProfileInfo extends StatefulWidget {
  List<bool> goals = new List<bool>();

  MyProfileInfo({this.goals});

  MyProfileInfoState createState() => MyProfileInfoState();
}

class MyProfileInfoState extends State<MyProfileInfo> {
  double _width, _height;
  AutoSizeGroup _textFitGroup;
  String _weightMeasurement, _heightMeasurement;
  double decreaseListviewHeightBy = 0;
  GlobalKey listViewKey = new GlobalKey();
  //1: Sedentary, 2: Lightly Active, 3: Moderately Active, 4: Very Active
  List<bool> sedentaryLevel = [false, false, false, false];
  AutoSizeGroup rowLabels = new AutoSizeGroup();

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
            createWeightRow("Weight"),
            createWeightRow("Target Weight"),
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
            height: hpad(8),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder()),
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
            height: hpad(8),
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(border: OutlineInputBorder()),
            )),
        Container(
            width: wpad(15),
            height: hpad(8),
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

  Widget createWeightRow(String textLabel) {
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
            height: hpad(8),
            child: TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            )),
        Container(
            width: wpad(15),
            height: hpad(8),
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

  Widget createFlatButton(String textLabel, int numInBoolList) {
    return Container(
        width: wpad(80),
        child: FlatButton(
          color: sedentaryLevel[numInBoolList] ? Colors.lightBlueAccent : Colors.white,
          onPressed: () {
            clearSedentaryList();
            setState(() {
              sedentaryLevel[numInBoolList] = true;
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

  void clearSedentaryList() {
    for(int i = 0; i < sedentaryLevel.length; i++) {
      sedentaryLevel[i] = false;
    }
  }

  Widget makeArrowButtons() {
    return Expanded(
        child: Stack(children: [
      Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, wpad(5), hpad(5)),
          child: FlatButton(
              onPressed: () {
                /*navigateToAlphaCodePage(context);*/
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
}
