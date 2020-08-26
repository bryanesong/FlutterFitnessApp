import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyProfileReview extends StatefulWidget {
  List<bool> goals = new List<bool>();
  int age;
  String height;
  int weight;
  int targetWeight;
  int activityLevel;

  MyProfileReview(
      {this.goals, this.age, this.height, this.weight, this.targetWeight, this.activityLevel});

  MyProfileReviewState createState() =>
      MyProfileReviewState(
          goals: goals,
          age: age,
          weight: weight,
          targetWeight: targetWeight,
          activityLevel: activityLevel);
}


class MyProfileReviewState extends State<MyProfileReview> {

  List<bool> goals;
  int age;
  String height;
  int weight;
  int targetWeight;
  int activityLevel;

  double _width, _height;
  AutoSizeGroup _textFitGroup = new AutoSizeGroup();

  MyProfileReviewState(
      {this.goals, this.age, this.height, this.weight, this.targetWeight, this.activityLevel});

  @override
  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
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
            makeArrowButtons(),
          ])
        ]));
  }

  Widget createTitle() {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: AutoSizeText(
          "Review",
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

  Future navigateToPrevPage(context) async {
    Navigator.pop(context);
  }

  Future navigateToReview() {

  }


  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }
}
