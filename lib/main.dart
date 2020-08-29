import 'dart:async';
import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:FlutterFitnessApp/WorkoutStrengthEntryContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';


animation.Animation penguinAnimation;
Position _position = Position(256.0, 256.0);
AnimationController _animationController;
Animation _animation;

AnimationController _waddleController;
Animation<double> _waddleAngle;
double penguinPositionX = -1;
double penguinPositionY = -1;
double penguinSize = 150;
double iconSize = 125;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.images.load('penguinSpriteSheet1.png');

  final penguinSpriteSheet = SpriteSheet(
    imageName: 'penguinSpriteSheet1.png',
    textureWidth: 200,
    textureHeight: 200,
    columns: 2,
    rows: 1,
  );

  penguinAnimation = penguinSpriteSheet.createAnimation(
    0,
    stepTime: 0.4,
    to: 2,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInOrSignUp(),
    );
  }
}

  /*

  ========================================================================================================================================


  HOME SCREEN

   ========================================================================================================================================

   */

final double buttonWidth = 65;
final double buttonHeight = 65;

String currentState = "idle_screen";
var _calendarController = CalendarController();

enum WidgetMarker{home,calorie, workout, stats, inventory}
enum WorkoutState{log, addStrength, addCardio}

class HomeScreen extends StatefulWidget{
  @override
  HomeScreenState createState() => HomeScreenState();
}

BuildContext logoutContext;

class HomeScreenState extends State<HomeScreen>{

  DateTime currentDayShown;

  bool addWorkoutButtonVisibility = true;

  bool strengthNameValidate = false;
  bool strengthSetsValidate = false;
  bool strengthRepsValidate = false;
  bool strengthWeightValidate = false;

  TextEditingController strengthTextControllerReps;
  TextEditingController strengthTextControllerSets;
  TextEditingController strengthTextControllerWeight;
  TextEditingController strengthTextControllerName;


  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  WidgetMarker selectedWidgetMarker = WidgetMarker.home;
  WorkoutState currentWorkoutState = WorkoutState.log;
  List workouts = new List();
  String mainScreenTitle = "Home Screen";

  @override
  void initState() {
    super.initState();
    strengthTextControllerReps = TextEditingController();
    strengthTextControllerSets = TextEditingController();
    strengthTextControllerWeight = TextEditingController();
    strengthTextControllerName = TextEditingController();
    //initializeStuff();
    _calendarController = CalendarController();
    changePosition();
  }

  void changePosition() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _position = Position(10 + _position.x, 10 + _position.y);
    });
  }

  @override
  dispose() {
    _calendarController.dispose();
    strengthTextControllerReps.dispose();
    strengthTextControllerSets.dispose();
    strengthTextControllerWeight.dispose();
    strengthTextControllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logoutContext = context;
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: new AppDrawer(),
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: Text(mainScreenTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: getCustomContainer(),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 4.0,color: Colors.blueAccent)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  padding: EdgeInsets.all(0),
                  minWidth: 5,
                  shape: CircleBorder(
                      side: BorderSide(
                          width: 1,//this is the side of the border
                          color: Colors.blue,
                          style: BorderStyle.solid
                      )
                  ),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: new Image.asset(
                      'assets/images/calorieButton.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: (){
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
                          width: 1,//this is the side of the border
                          color: Colors.blue,
                          style: BorderStyle.solid
                      )
                  ),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: new Image.asset(
                      'assets/images/workoutButton.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: (){
                    setState(() {
                      print("set state invoked for workout.");
                      mainScreenTitle = "Workout Log";
                      selectedWidgetMarker = WidgetMarker.workout;
                    });
                  },
                ),
                MaterialButton(
                  padding: EdgeInsets.all(0),
                  minWidth: 5,
                  shape: CircleBorder(
                      side: BorderSide(
                          width: 1,//this is the side of the border
                          color: Colors.blue,
                          style: BorderStyle.solid
                      )
                  ),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: new Image.asset(
                      'assets/images/inventoryButton.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: (){
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
                          width: 1,//this is the side of the border
                          color: Colors.blue,
                          style: BorderStyle.solid
                      )
                  ),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: new Image.asset(
                      'assets/images/statsButton.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: (){
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
                          width: 1,//this is the side of the border
                          color: Colors.blue,
                          style: BorderStyle.solid
                      )
                  ),
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: new Image.asset(
                      'assets/images/settingsButton.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  onPressed: (){
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //_scaffoldKey.currentState.openEndDrawer();

  Widget getCustomContainer(){
    switch(selectedWidgetMarker){
      case WidgetMarker.home:
        return getIdleScreenWidget();
      case WidgetMarker.calorie:
        return getIdleScreenWidget();
      case  WidgetMarker.workout:
        return getworkoutLogWidget();
      case WidgetMarker.inventory:
        return getInventoryWidget();
      case WidgetMarker.stats:
        return getStatsWidget();
    }
    return getGraphWidget();
  }

  Widget getGraphWidget() {
    return Container(
      height: 200,
      color: Colors.red,
    );
  }

  Widget getStatsWidget(){
    return new Container();
  }

  Widget getInventoryWidget(){
    return new Container();
  }

  Widget getworkoutLogWidget(){
    return Container(
      child: Column(
        children: [
          TableCalendar(
            calendarController: _calendarController,
            initialCalendarFormat: CalendarFormat.week,
            formatAnimation: FormatAnimation.slide,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableGestures: AvailableGestures.all,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Weekly',
            },
            onDaySelected: _onDaySelected,
          ),
          Expanded(
            child: Stack(
              children: [
                getWorkoutState(),
                getAddWorkoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected: '+day.day.toString());
    setState(() {
      currentDayShown = day;
    });
  }

  Widget getAddWorkoutButton(){
    if(addWorkoutButtonVisibility){
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: FloatingActionButton(
            onPressed:() async{
              Alert(
                context: context,
                type: AlertType.info,
                title: "Add Workout",
                desc: "Would you like to log a cardio or strength workout?",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Cardio",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: (){
                      setState(() {
                        currentWorkoutState = WorkoutState.addCardio;
                        addWorkoutButtonVisibility = false;
                        Navigator.pop(context);
                      });
                    },
                    width: 120,
                  ),
                  DialogButton(
                    child: Text(
                      "Strength",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        currentWorkoutState = WorkoutState.addStrength;
                        addWorkoutButtonVisibility = false;
                        Navigator.pop(context);
                      });
                    },
                    width: 120,
                  )
                ],
              ).show();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
          ),
        ),
      );
    }else{
      return new Container();
    }
  }

  Widget getWorkoutState(){
    switch (currentWorkoutState){
      case WorkoutState.log:
        return getWorkoutLog();
      case WorkoutState.addStrength:
        return getWorkoutAddStrength();
      case WorkoutState.addCardio:
        return getWorkoutAddCardio();
    }
    return getWorkoutLog();
  }

  Widget getWorkoutAddStrength(){
    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getStrengthNameTextField(),
          getStrengthSetsTextField(),
          getStrengthRepsTextField(),
          getStrengthWeightTextField(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                textColor: Colors.red,
                onPressed: () {
                  setState(() {
                    currentWorkoutState = WorkoutState.log;
                    //reset validation booleans so they dont maintain the same state
                    strengthNameValidate = false;
                    strengthSetsValidate = false;
                    strengthRepsValidate = false;
                    strengthWeightValidate = false;
                    addWorkoutButtonVisibility = true;
                  });
                },
                child: const Text('Cancel', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              RaisedButton(
                textColor: Colors.green,
                onPressed: () {
                  print("submit button for strength workout pressed.");
                  setState(() {
                    strengthTextControllerName.text.isEmpty ? strengthNameValidate = true : strengthNameValidate = false;
                    strengthTextControllerSets.text.isEmpty ? strengthSetsValidate = true : strengthSetsValidate = false;
                    strengthTextControllerReps.text.isEmpty ? strengthRepsValidate = true : strengthRepsValidate = false;
                    strengthTextControllerWeight.text.isEmpty ? strengthWeightValidate = true : strengthWeightValidate = false;
                    addWorkoutButtonVisibility = true;
                    print(strengthNameValidate);
                    print(strengthSetsValidate);
                    print(strengthRepsValidate);
                    print(strengthWeightValidate);
                    if(!strengthNameValidate && !strengthSetsValidate && !strengthRepsValidate && !strengthWeightValidate){
                      print("adding strength workout to database...");
                      addWorkoutToDatabase();
                      currentWorkoutState = WorkoutState.log;
                      //reset validation booleans so they dont maintain the same state
                      strengthNameValidate = false;
                      strengthSetsValidate = false;
                      strengthRepsValidate = false;
                      strengthWeightValidate = false;
                      addWorkoutButtonVisibility = true;
                    }
                    populateWorkoutLog();
                  });
                },
                child: const Text('Submit', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ]),
    );
  }

  void populateWorkoutLog() async{

  }

  void addWorkoutToDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    //this retrieves the current UID that is logged in from the firebase
    //should not be null since user needs to be logged in in order to access this route
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    print("TESTING UNDERNEATH:");
    print("name: "+strengthTextControllerName.text.toString());
    print("sets: "+strengthTextControllerSets.text.trim());
    print("reps: "+strengthTextControllerReps.text.trim());
    print("weight: "+strengthTextControllerWeight.text.trim());
    print("END OF TEST---------------------");

    DateTime currentTime = new DateTime.now();
    WorkoutStrengthEntryContainer entry = new WorkoutStrengthEntryContainer.define(
      strengthTextControllerName.text.toString(),
      int.parse(strengthTextControllerSets.text.trim()),
      int.parse(strengthTextControllerReps.text.trim()),
      int.parse(strengthTextControllerWeight.text.trim()),
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      currentTime.minute,
      currentTime.second
    );

    print("Added to Workout Log for user: "+uid);
    //ref.child("Users").child(uid).child("Workout Log Data").

    //get current number of children in workoutlog
    //int workoutLogCount;

    //print("workoutLogCount: "+workoutLogCount.toString());

    print("WEIGHT CHECK: "+entry.getWeight().toString());
    //add entry to firebase
    ref.child("Users").child(uid).child("Workout Log Data").push().set({
      'Name': entry.getName().trim(),
      'Sets': entry.getSets(),
      'Reps': entry.getReps(),
      'Weight': entry.getWeight(),
      'Year': entry.getYear(),
      'Month': entry.getMonth(),
      'Day': entry.getDay(),
      'Hour': entry.getHour(),
      'Minute': entry.getMinute(),
      'Second': entry.getSecond(),
    });
    strengthTextControllerName.clear();
    strengthTextControllerSets.clear();
    strengthTextControllerReps.clear();
    strengthTextControllerWeight.clear();

  }

  Widget getStrengthWeightTextField(){
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Weight(lbs):",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent)
          ),
          width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 3),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: strengthTextControllerWeight,
            decoration: InputDecoration(
              labelText: 'Enter the Value',
              errorText: strengthNameValidate ? 'Value Can\'t Be Empty' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget getStrengthRepsTextField(){
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Reps:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent)
          ),
          width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 3),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: strengthTextControllerReps,
            decoration: InputDecoration(
              labelText: 'Enter the Value',
              errorText: strengthRepsValidate ? 'Value Can\'t Be Empty' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget getStrengthSetsTextField(){
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Sets:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent)
          ),
          width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 3),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: strengthTextControllerSets,
            decoration: InputDecoration(
              labelText: 'Enter the Value',
              errorText: strengthSetsValidate ? 'Value Can\'t Be Empty' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget getStrengthNameTextField(){
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Name:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent)
          ),
          width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 3),
          height: 50,
          child: TextField(
            controller: strengthTextControllerName,
            decoration: InputDecoration(
              labelText: 'Enter the Value',
              errorText: strengthNameValidate ? 'Value Can\'t Be Empty' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget getWorkoutAddCardio(){

  }

  DatabaseReference reference = FirebaseDatabase.instance.reference();
  String hold = "";

  Future<String> getUID() async{
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    uid.toLowerCase();
    print("uid as Future<String>: "+uid);
    hold = uid;
    return uid;
  }



  Widget getWorkoutLog(){
    getUID();
    //used to for testing to make sure getUID is invoked
    if(hold == ""){
      print("current userID is empty.");
    }
    return FutureBuilder(
      future: reference.child("Users").child(hold).child("Workout Log Data").once(),
      builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
        print("getUID: "+getUID().toString());
        if(snapshot.hasData){
          workouts.clear();
          Map<dynamic, dynamic> values = snapshot.data.value;
          if(values != null){
            values.forEach((key, value) {
              WorkoutStrengthEntryContainer temp = WorkoutStrengthEntryContainer.parse(value);
              print("Year compare: "+temp.getYear().toString() +" and "+currentDayShown.year.toString());
              if(temp.getYear() == currentDayShown.year && temp.getMonth() == currentDayShown.month && temp.getDay() == currentDayShown.day){
                print("current day workout: "+temp.toString());
                workouts.add(new WorkoutStrengthEntryContainer.parse(value));
              }
            });
          }
        }
        return new ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (BuildContext context,int index) {
            return Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: getWorkoutItem(index),
            );
          },
        );
      },
    );
  }

  Widget getWorkoutItem(int index){
    return Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workouts[index].getMonth().toString()+"/"+workouts[index].getDay().toString()+"/"+workouts[index].getYear().toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Name: "+workouts[index].getName(),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            "Sets: "+workouts[index].getSets().toString(),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            "Reps: "+workouts[index].getReps().toString(),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            "Weight: "+workouts[index].getWeight().toString(),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  /*
  Box effect for list view
  decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
   */

  Widget getIdleScreenWidget(){
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        image: DecorationImage(
            image: AssetImage("assets/images/seattleBackground.jpg"),
            fit: BoxFit.cover
        ),
      ),
      child: Container(
        width: 200,
        height: 200,
        //put penguin animation here
        //child: createPenguinImage(),
      ),
    );
  }

  Widget createPenguinImage() {
    if (penguinPositionX == -1 && penguinPositionY == -1) {
      penguinPositionX = MediaQuery.of(context).size.width / 2;
      penguinPositionY = MediaQuery.of(context).size.height / 2;
    }
    return AnimatedPositioned(
        width: penguinSize,
        height: penguinSize,
        duration: Duration(seconds: 3),
        //divided by 2 to center the penguin
        top: penguinPositionY - penguinSize / 2 /*- AppBar().preferredSize.height-MediaQuery.of(context).padding.top*/,
        left: penguinPositionX - penguinSize / 2,
        child: PenguinAnimate(animation: _animation),
    );
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

  void logout(context) async{
    print("signed user out.");
    mAuth.signOut();
    Navigator.pop(context);
    Navigator.pop(logoutContext);
  }

}

class PenguinAnimate extends AnimatedWidget {
  PenguinAnimate({@required Animation<int> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          String frame = animation.value.toString();
          return new Image.asset(
            'assets/images/penguin$frame.png',
            gaplessPlayback: true,
          );
        });
  }
}

