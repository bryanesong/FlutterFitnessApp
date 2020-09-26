import 'package:FlutterFitnessApp/Container%20Classes/AppStateEnum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'CalorieTracker.dart';
import 'WorkoutTracker.dart';
import 'package:FlutterFitnessApp/Container Classes/EnumStack.dart';

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

final GlobalKey _scaffoldKey = new GlobalKey();
BuildContext logoutContext;
bool hidePenguin = false;
//seperate enum states per major button

//stack for back arrow enum implementation
EnumStack enumStack = new EnumStack();

//temp handheld variable
int currentInt = 0;
List<PenguinArm> heldItem = PenguinArm.values;

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    enumStack.push(AppState.HomeScreen_Idle);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    logoutContext = context;
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: AppDrawer(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Builder(
          builder: (context) => SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          !hidePenguin ? Image.asset("assets/images/seattleBackground.jpg",
                            width: wpad(100),
                            height: hpad(100),
                            fit: BoxFit.fill,
                          ) : Container(),
                          //content
                          getCustomContainer(),
                          //top navigation bar
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: hpad(9),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: wpad(12),
                                        child: FlatButton(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          onPressed: () {
                                            onBack();
                                          },
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
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          onPressed: () {
                                            Scaffold.of(context)
                                                .openEndDrawer();
                                          },
                                          child: Image.asset(
                                            "assets/images/hamburger.png",
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.fromLTRB(
                                  wpad(2), wpad(1), wpad(2), 0),
                            ),
                          ),
                          PenguinCreator(cosmetics: PenguinCosmetics(PenguinHat.samuraiHat, PenguinShirt.samuraiArmor, heldItem[currentInt], PenguinShoes.clogs, PenguinShadow.circular ), scale: hidePenguin ? 0 : 1, penguinSize: 300, centerXCoord: wpad(50), penguinAnimationType: PenguinAnimationType.wave, centerYCoord: hpad(50),),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: FlatButton(
                              onPressed: () {
                                swapItem();
                              },
                              child: Icon(Icons.navigate_next),
                            ),
                          )
                        ],
                      ),
                    ),
                    //bottom nav bar
                    Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 4.0, color: Colors.blueAccent)),
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
                                changeContainer(
                                    AppState.Calorie_Log, WidgetMarker.calorie);
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
                                changeContainer(
                                    AppState.Workout_Log, WidgetMarker.workout);
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
                                changeContainer(AppState.Cosmetics_Home,
                                    WidgetMarker.inventory);
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
                                changeContainer(AppState.Statistics_Home,
                                    WidgetMarker.stats);
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
                                changeContainer(AppState.HomeScreen_Idle,
                                    WidgetMarker.home);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  void swapItem() {
    if(currentInt < heldItem.length-1) {
      currentInt++;
    } else {
      currentInt = 0;
    }
    setState(() {

    });
  }

  //returns the custom container that is shown above the 5 main app buttons at the bottom and below the appbar
  Widget getCustomContainer() {
    //make penguin disappear if not on dashboard page
    switch (selectedWidgetMarker) {
      case WidgetMarker.home:
        return Container();
      case WidgetMarker.calorie:
        return CalorieTracker(
          appState: enumStack.peek(),
          onAppStateChange: (AppState appState) {
            setAppState(appState);
          },
        );
      case WidgetMarker.workout:
        return WorkoutTracker(
          appState: enumStack.peek(),
          onAppStateChange: (AppState appState) {
            setAppState(appState);
          },
        );
      case WidgetMarker.inventory:
        return Container();
      case WidgetMarker.stats:
        return Container();
      case WidgetMarker.logCardio:
        return Container();
    }
    return Container();
  }

  void setAppState(AppState appState) {
    //when switching between searchfood and my food in calorie tracker
    if ((appState == AppState.Calorie_SearchFood &&
            enumStack.peek() == AppState.Calorie_MyFood) ||
        (appState == AppState.Calorie_MyFood &&
            enumStack.peek() == AppState.Calorie_SearchFood)) {
      enumStack.pop();
      enumStack.push(appState);
    } else if(appState == AppState.Workout_Log){
      enumStack.clear();
      enumStack.push(AppState.HomeScreen_Idle);
      enumStack.push(appState);
    } else {
      enumStack.push(appState);
    }
    setState(() {});
  }

  void changeContainer(AppState appState, WidgetMarker widgetMarker) {
    //clear stack here
    enumStack.clear();
    if (appState != AppState.HomeScreen_Idle) {
      enumStack.push(AppState.HomeScreen_Idle);
      hidePenguin = true;
    } else {
      hidePenguin = false;
    }
    print("1: " + enumStack.toString());
    enumStack.push(appState);
    print("2: " + enumStack.toString());

    selectedWidgetMarker = widgetMarker;
    setState(() {});
  }

  void onBack() {
    if (!enumStack.isEmpty()) {
      enumStack.pop();
      if (enumStack.peek() == AppState.HomeScreen_Idle) {
        selectedWidgetMarker = WidgetMarker.home;
        hidePenguin = false;
      }

      setState(() {});
    }
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

final FirebaseAuth mAuth = FirebaseAuth.instance;

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => new _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 150,
      child: new Drawer(
        child: new ListView(
          children: <Widget>[
            new ListTile(
              title: new Text("Profile Settings"),
              onTap: () {
                print("Clicked on profile settings!");
              },
            ),
            new ListTile(
              title: new Text("About Us"),
              onTap: () {
                print("Clicked on about us.");
              },
            ),
            new ListTile(
              title: new Text("Log out"),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void logout(context) async {
    print("signed user out.");
    mAuth.signOut();
    Navigator.pop(context);
    Navigator.pop(logoutContext);
  }
}
