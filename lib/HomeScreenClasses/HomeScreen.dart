import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CalorieTracker.dart';

enum WidgetMarker { home, calorie, workout, stats, inventory, logCardio }

WidgetMarker selectedWidgetMarker = WidgetMarker.home;

final double buttonWidth = 65;
final double buttonHeight = 65;

double _width;
double _height;

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

BuildContext logoutContext;

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    logoutContext = context;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    //content
                    getCustomContainer(),
                    //top navigation bar
                    Align(
                      alignment: Alignment.topCenter,
                      child:Container(
                        height: hpad(9),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: wpad(12),
                                  child: FlatButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    onPressed: () {},
                                    child: Image.asset(
                                      "assets/images/HomeScreenBackArrow.png",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: wpad(8),
                                  child: FlatButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    onPressed: () {},
                                    child: Image.asset(
                                      "assets/images/hamburger.png",
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        padding:
                        EdgeInsets.fromLTRB(wpad(2), wpad(1), wpad(2), 0),
                      ),
                    ),
                  ],
                ),
              ),
              //bottom nav bar
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 4.0, color: Colors.blueAccent)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      minWidth: 5,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1, //this is the side of the border
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: new Image.asset(
                          'assets/images/calorieButton.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          print("set state invoked for calorie.");
                          selectedWidgetMarker = WidgetMarker.calorie;
                        });
                      },
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      minWidth: 5,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1, //this is the side of the border
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: new Image.asset(
                          'assets/images/workoutButton.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          print("set state invoked for workout.");
                          selectedWidgetMarker = WidgetMarker.workout;
                        });
                      },
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      minWidth: 5,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1, //this is the side of the border
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: new Image.asset(
                          'assets/images/inventoryButton.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          print("set state invoked for inventory.");
                          selectedWidgetMarker = WidgetMarker.inventory;
                        });
                      },
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      minWidth: 5,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1, //this is the side of the border
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: new Image.asset(
                          'assets/images/statsButton.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          print("set state invoked for stats.");
                          selectedWidgetMarker = WidgetMarker.stats;
                        });
                      },
                    ),
                    MaterialButton(
                      padding: EdgeInsets.all(0),
                      minWidth: 5,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1, //this is the side of the border
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      child: SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: new Image.asset(
                          'assets/images/homeButtonTEMP.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedWidgetMarker = WidgetMarker.home;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  //_scaffoldKey.currentState.openEndDrawer();

  //returns the custom container that is shown above the 5 main app buttons at the bottom and below the appbar
  Widget getCustomContainer() {
    return CalorieTracker();
    //make penguin disappear if not on dashboard page
/*    switch (selectedWidgetMarker) {
      case WidgetMarker.home:
        return getIdleScreenWidget();
      case WidgetMarker.calorie:
        return getCalorieWidget();
      case WidgetMarker.workout:
        return getWorkoutLogWidget();
      case WidgetMarker.inventory:
        return getInventoryWidget();
      case WidgetMarker.stats:
        return getStatsWidget();
      case WidgetMarker.logCardio:
        return logNewCardioWidget();
    }
    return getGraphWidget();*/
  }
}

double wpad(double percent) {
  //print("wpad called: " + (_width * percent / 100).toString());
  return _width * percent / 100;
}

double hpad(double percent) {
 // print("hpad called: " + (_height * percent / 100).toString());
  return _height * percent / 100;
}
