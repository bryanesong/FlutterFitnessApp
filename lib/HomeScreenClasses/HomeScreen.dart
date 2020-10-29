import 'package:FlutterFitnessApp/ContainerClasses/AppStateEnum.dart';
import 'package:FlutterFitnessApp/ContainerClasses/OwnedCosmeticsRealtime.dart';
import 'package:FlutterFitnessApp/ContainerClasses/PSize.dart';
import 'package:FlutterFitnessApp/ContainerClasses/PenguinCosmeticRealtime.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'CalorieTracker.dart';
import 'CosmeticSelector.dart';
import 'WorkoutTracker.dart';
import 'package:FlutterFitnessApp/ContainerClasses/EnumStack.dart';

enum WidgetMarker { home, calorie, workout, stats, inventory, logCardio }

WidgetMarker selectedWidgetMarker = WidgetMarker.home;

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
    //set size of screen size
    PSize.width = MediaQuery.of(context).size.width;
    PSize.height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

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
                          //content
                          getCustomContainer(),
                          //top navigation bar
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: PSize.hPix(9),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: PSize.wPix(12),
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
                                        width: PSize.wPix(8),
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
                              padding: EdgeInsets.fromLTRB(PSize.wPix(2),
                                  PSize.wPix(1), PSize.wPix(2), 0),
                            ),
                          ),
                          !hidePenguin ? PenguinCreator(
                            penguinType: PenguinType.penguin,
                            size: 300,
                            centerXCoord: PSize.wPix(50),
                            penguinAnimationType: PenguinAnimationType.wave,
                            centerYCoord: PSize.hPix(50),
                          ) : Container(),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  OwnedCosmeticsRealtime.pushBoughtCosmetic("jollyMeal");
                                });
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
                              width: PSize.hPix(10),
                              height: PSize.hPix(10),
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
                              width: PSize.hPix(10),
                              height: PSize.hPix(10),
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
                              width: PSize.hPix(10),
                              height: PSize.hPix(10),
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
                              width: PSize.hPix(10),
                              height: PSize.hPix(10),
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
                              width: PSize.hPix(10),
                              height: PSize.hPix(10),
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
    if (currentInt < heldItem.length - 1) {
      currentInt++;
    } else {
      currentInt = 0;
    }
    PenguinCosmeticRealtime.pushCosmetics(penguinType: PenguinType.penguin, cosmeticName: heldItem[currentInt].describeEnum());
  }

  //returns the custom container that is shown above the 5 main app buttons at the bottom and below the appbar
  Widget getCustomContainer() {
    //make penguin disappear if not on dashboard page
    switch (selectedWidgetMarker) {
      case WidgetMarker.home:
        return Image.asset(
          "assets/images/seattleBackground.jpg",
          width: PSize.wPix(100),
          height: PSize.hPix(100),
          fit: BoxFit.fill,
        );
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
        return CosmeticSelector(
          appState: enumStack.peek(),
          onAppStateChange: (AppState appState) {
            setAppState(appState);
          },
        );
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
    } else if (appState == AppState.Workout_Log) {
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
