import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyProfileGoals extends StatefulWidget {
  MyProfileGoalsState createState() => MyProfileGoalsState();
}

class MyProfileGoalsState extends State<MyProfileGoals> {
  double _width, _height;
  AutoSizeGroup _textFitGroup;
  AutoSizeGroup _checkListFitGroup;
  bool _trackCalories = false,
      _gainWeight = false,
      _loseWeight = false,
      _maintainWeight = false,
      _trackWorkouts = false;
  List<bool> goals;

  @override
  void initState() {

    goals = [_trackCalories, _gainWeight, _loseWeight, _maintainWeight, _trackWorkouts];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _textFitGroup = AutoSizeGroup();
    _checkListFitGroup = AutoSizeGroup();
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Goals"),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
              children: [
            createTitle(),
            createRow(),
            createDivider(),
            selectAllText(),
            makeChoices(),
            makeArrowButton(),
          ]),
        ],
      ),
    );
  }

  Widget createTitle() {
    return Container(
        child: Text(
          "Goals",
          textAlign: TextAlign.center,
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

  Widget selectAllText() {
    return Row(children: [
      Expanded(
        child: AutoSizeText(
          "Select all that apply:",
          textAlign: TextAlign.center,
          maxLines: 1,
          group: _textFitGroup,
          style: TextStyle(
            decoration: TextDecoration.none,
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w900,
            color: Colors.black54,
          ),
        ),
      )
    ]);
  }

  Widget makeChoices() {
    return Container(
        height: hpad(40),
        child: Scrollbar(child: ListView(
          children: [
            makeIndivChoice("Track My Calories", _trackCalories),
            makeIndivChoice("Gain Weight", _gainWeight),
            makeIndivChoice("Lose Weight", _loseWeight),
            makeIndivChoice("Maintain Weight", _maintainWeight),
            makeIndivChoice("Track My Workouts", _trackWorkouts),
          ],)
    ));
  }

  Widget makeIndivChoice(String boldedText, bool refBool) {
    return Row(children: [
      Expanded(
          child: StatefulBuilder(
              builder: (context, _setState) => CheckboxListTile(
                    value: refBool,
                    onChanged: (bool value) {
                      _setState(() => refBool = value);
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

  Widget makeArrowButton() {
    return Expanded(
      child: Container(
        alignment: Alignment.bottomRight,
          padding: EdgeInsets.fromLTRB(0, 0, wpad(5), hpad(5)),
          child: FlatButton(
            onPressed: () {
              navigateToAlphaCodePage(context);
            },
            child: Image.asset(
                "assets/images/arrow.png",
            height: hpad(7),)
          )),
    );
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }

  Future navigateToAlphaCodePage(context) async{
    /*Navigator.push(context,CupertinoPageRoute(builder: (context) => MyProfileInfo(goals: goals)));*/
  }

}


