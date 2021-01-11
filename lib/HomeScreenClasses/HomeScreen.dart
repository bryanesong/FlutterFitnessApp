import 'package:FlutterFitnessApp/Container%20Classes/AppStateEnum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'CalorieTracker.dart';
import 'FriendsList.dart';
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

//seperate enum states per major button

//stack for back arrow enum implementation
EnumStack enumStack = new EnumStack();

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
                          //PenguinCreator(cosmetics: PenguinCosmetics(PenguinHat.pilgrimHat, PenguinShirt.usaTShirt, PenguinArm.firecracker, PenguinShoes.mcdonaldShoes ), scale: 1, penguinSize: 300, centerXCoord: wpad(50), penguinAnimationType: PenguinAnimationType.wave, centerYCoord: hpad(50),),
                        ],
                      ),
                    ),
                    //bottom nav bar------------------------------------------------------------
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

  //_scaffoldKey.currentState.openEndDrawer();

  //returns the custom container that is shown above the 5 main app buttons at the bottom and below the appbar
  Widget getCustomContainer() {
    //make penguin disappear if not on dashboard page
    switch (selectedWidgetMarker) {
      case WidgetMarker.home:{
        return homeScreenNavigation();
      }
      case WidgetMarker.calorie:
        return CalorieTracker(
          appState: enumStack.peek(),
          onAppStateChange: (AppState appState) {
            setAppState(appState);
          },
        );
      case WidgetMarker.workout:
        return WorkoutTracker();
      case WidgetMarker.inventory:
        return Container();
      case WidgetMarker.stats:
        return Container();
      case WidgetMarker.logCardio:
        return Container();
    }
    return Container();
  }

  //responsible for home screen navigation
  Widget homeScreenNavigation(){
    //get current appstate from top of stack
    AppState current = enumStack.peek();
    if(current == AppState.HomeScreen_Idle){
      return homeScreenIdleWidget();
    }else if(current == AppState.HomeScreen_Chat){
      return homeScreenChat();
    }else{
      //return error if current state returns something that isnt native to the home screen, which it wouldn't....right?
      return Container(
        child: Text("Error...pepehands..."),
      );
    }
  }

  Widget homeScreenIdleWidget(){
    return new Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/japanBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      child: new Column(
        children: [
          Padding(
            padding: EdgeInsets.all(hpad(4)),
          ),
          Row(
            children:[
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: wpad(14),
                    child: FlatButton(
                      padding:
                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Image.asset("assets/images/chatButton.png"),
                      onPressed: () {
                        setAppState(AppState.HomeScreen_Chat);
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget homeScreenChat(){
    return FriendsList();
  }

  void setAppState(AppState appState) {
    enumStack.push(appState);
    setState(() {});
  }

  void changeContainer(AppState appState, WidgetMarker widgetMarker) {
    //clear stack here
    enumStack.clear();

    enumStack.push(AppState.HomeScreen_Idle);
    print("1: "+ enumStack.toString());
    enumStack.push(appState);
    print("2: "+enumStack.toString());

    selectedWidgetMarker = widgetMarker;
    setState(() {});
  }

  void onBack() {
    enumStack.pop();
    if (enumStack.peek() == AppState.HomeScreen_Idle) {
      selectedWidgetMarker = WidgetMarker.home;
    }

    setState(() {});
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
