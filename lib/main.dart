import 'dart:async';
import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:FlutterFitnessApp/WorkoutStrengthEntryContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'FancyButton.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';

import 'PinInformation.dart';

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

/*
  Dear future bryan,
  dont forget to add permission into Info.plist for iOS location

  yuh,
  9/1/20 bryan

  reference article:
  https://pub.dev/packages/location
 */

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

enum WidgetMarker{home,calorie, workout, stats, inventory, logCardio}
enum WorkoutState{log, addStrength, addCardio}

class HomeScreen extends StatefulWidget{
  @override
  HomeScreenState createState() => HomeScreenState();
}

BuildContext logoutContext;

class HomeScreenState extends State<HomeScreen> {

  //when this is true, the onLocationChanged will add to the polylines to track the user running
  bool startLocationTracking = false;
  double totalDistanceTraveled = 0;
  LatLng previousCoordinates;

  List<LatLng> latlng = List();

  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  DateTime currentDayShown = DateTime.now();

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
    getWorkoutLog(); //load things in workout list
    checkLocation();
    getCameraPosition(0,0);
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      //print("CURRENT LOCATION: "+cLoc.toString());//this will continuously print lmfao so only uncomment when u need to debugg
      //change camera position to follow the user on the map
      getCameraPosition(cLoc.latitude,cLoc.longitude);
      if(startLocationTracking){
        getDistanceTraveled(cLoc.latitude, cLoc.longitude);
        latlng.add(new LatLng(cLoc.latitude,cLoc.longitude));
        print("Current polylines count: "+_polylines.length.toString());
        print("Adding new polyline- $cLoc");
        _polylines.add(new Polyline(
          polylineId: PolylineId("TEMP ID"),
          visible: true,
          //latlng is List<LatLng>
          points: latlng,
          color: Colors.blue,
        ));
      }
    });
  }


  //will take in new lat and lng coordinates and calculate the distance between the last known coordinates and add to them
  void getDistanceTraveled(double lat, double lng){
    if(previousCoordinates == null){
      previousCoordinates = new LatLng(lat, lng);
    }else{
      //uses the Haversine formula to calculate distance between two lat/lng points and adds them to totalDistanceTraveled variable
      double R = 6371; // Radius of the earth in km
      double dLat = convertDegreeToRadians(lat-previousCoordinates.latitude);  // convertDegreeToRadians below
      double dLon = convertDegreeToRadians(lng-previousCoordinates.longitude);
      double a = sin(dLat/2) * sin(dLat/2) + cos(convertDegreeToRadians(previousCoordinates.latitude)) * cos(convertDegreeToRadians(lat)) * sin(dLon/2) * sin(dLon/2);
      double c = 2 * atan2(sqrt(a), sqrt(1-a));
      double distanceKm = R * c; // Distance in km
      double distanceMiles = distanceKm * 0.62137119;
      totalDistanceTraveled +=distanceMiles;
      //set previous coordinates to current coordinates
      previousCoordinates = new LatLng(lat,lng);
    }
  }

  double convertDegreeToRadians(double num){
    return num * (pi/180);
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
                border: Border.all(width: 4.0, color: Colors.blueAccent)
            ),
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
                  onPressed: () {
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
                          width: 1, //this is the side of the border
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
                          style: BorderStyle.solid
                      )
                  ),
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
    );
  }

  //_scaffoldKey.currentState.openEndDrawer();

  //returns the custom container that is shown above the 5 main app buttons at the bottom and below the appbar
  Widget getCustomContainer() {
    switch (selectedWidgetMarker) {
      case WidgetMarker.home:
        return getIdleScreenWidget();
      case WidgetMarker.calorie:
        return getIdleScreenWidget();
      case WidgetMarker.workout:
        return getWorkoutLogWidget();
      case WidgetMarker.inventory:
        return getInventoryWidget();
      case WidgetMarker.stats:
        return getStatsWidget();
      case WidgetMarker.logCardio:
        return logNewCardioWidget();
    }
    return getGraphWidget();
  }

  //this is just a placeholder widget, not really used for anything
  Widget getGraphWidget() {
    return Container(
      height: 200,
      color: Colors.red,
    );
  }

  //this will return the stats container widget although not yet implemented, still waiting on both calorie tracker / workout log integration
  Widget getStatsWidget() {
    return new Container();
  }

  //this will return the inventory widget, not yet implemented(assigned to Evan)
  Widget getInventoryWidget() {
    return new Container();
  }

  //main layout for the workout log when user presses the workout log button
  //consists of a 1 row calendar at the top while the bottom changes depending on what the user is doing
  Widget getWorkoutLogWidget() {
    print("Current workout state: $currentWorkoutState");
    if(currentWorkoutState == WorkoutState.addStrength || currentWorkoutState == WorkoutState.addCardio){
      return getWorkoutState();
    }else{
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
            Expanded(//this is the container that holds all the stuff underneath the 1 row table calendar
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

  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected: ' + day.day.toString());
    setState(() {
      currentDayShown = day;
    });
  }

  Widget getAddWorkoutButton() {
    if (addWorkoutButtonVisibility) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: FloatingActionButton(
            onPressed: () async {
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
                    onPressed: () {
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
    } else {
      return new Container();
    }
  }

  Widget getWorkoutState() {
    switch (currentWorkoutState) {
      case WorkoutState.log:
        return getWorkoutLog();
      case WorkoutState.addStrength:
        return getWorkoutAddStrength();
      case WorkoutState.addCardio:
        return getWorkoutAddCardioButtons();
    }
    return getWorkoutLog();
  }

  Widget noWorkoutsLoggedWidget() {
    return new Container(
      alignment: Alignment.center,
      child: Text("You have no workouts logged for today. :("),
    );
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

  Widget getWorkoutAddCardioButtons(){
    return new Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FancyButton(
                child: Text(
                  "Log Previous Cardio Workout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                size: 50,
                color: Color(0xFFCA3034),
                onPressed: () {
                  print("Button pressed to log previous cardio workout.");
                },
              ),
            ],
          ),
          new Padding(
            padding: EdgeInsets.all(16.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FancyButton(
                child: Text(
                  "Log New Cardio Workout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                size: 50,
                color: Colors.blue,
                onPressed: () {
                  print("Button pressed to log previous cardio workout.");
                  setState(() {
                    selectedWidgetMarker = WidgetMarker.logCardio;
                  });
                },
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget logNewCardioWidget(){
    return new Container(
      child: new Column(
        children: [
          getCurrentCardioTime(),
          getCurrentCardioDistance(),
          getCurrentCardioPace(),
          Padding(padding: EdgeInsets.all(5.0)),
          getCardioLogButtons(),
        ],
      ),
    );
  }

  //this is the controller used for the stopwatch when logging a cardio workout
  //contains prints for examples to retrieve time data ex:current time and seconds
  final _stopWatchTimer = StopWatchTimer(
    onChange: (value) {
      final displayTime = StopWatchTimer.getDisplayTime(value);
      //print('displayTime: '+displayTime.toString()); //used for debugging
    },
    //when the stop watch is going I also want to be checking every 5 seconds the lat/lng creating a polyline and adding to the polylines
    onChangeRawSecond: (value){
      if(value % 5 == 0 && value != 0){
        print("THIS IS EVERY 5 SECONDS");
      }
    },
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  Widget getCurrentCardioTime(){
    return new Container(
      child: StreamBuilder<int>(
        stream: _stopWatchTimer.rawTime,
        initialData: 0,
        builder: (context, snap) {
          final value = snap.data;
          final displayTime = StopWatchTimer.getDisplayTime(value);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  displayTime,
                  style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  void checkLocation() async{
    print("getting location data");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("locations services have not been enabled.");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("permissions have not been granted for location.");
        return;
      }
    }

    _locationData = await location.getLocation();
    print("location data retrieved... lat: "+_locationData.latitude.toString()+" lng: "+_locationData.longitude.toString());
  }

  //variables used for the google maps implementation
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation = CameraPosition(target: LatLng(0, 0),);

  void getCameraPosition(double lat, double lng) async{
    _myLocation = CameraPosition(
    target: LatLng(lat, lng),
    zoom: 14.4746,
    );
    //print("finished setting _myLocation variable."); //used to debugging
  }

  //will eventually need to set a current location marker when the user presses start
  //and then another current location marker when the user presses end
  Set<Marker> _locationMarker(){
    return <Marker>[
      Marker(
        markerId: MarkerId("Current Location"),
        position: LatLng(_locationData.latitude,_locationData.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title:"Current Location"),
      ),
    ].toSet();
  }

  //will hold markers for start and endpoints
  Set<Marker> _markers = {};
  //this is hold the polylines used to track each run
  //will probably create a polyline every 5 seconds or something
  Set<Polyline> _polylines = {};


  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();

  //will be used to set start and end markers or honestly any other markers that are needed
  //marker is based off current _locationData lat and lng
  Set<Marker> _setCurrentLocationMarker(String markerName){
    return <Marker>[
      Marker(
        markerId: MarkerId("$markerName"),
        position: LatLng(_locationData.latitude,_locationData.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title:"$markerName"),
      ),
    ].toSet();
  }

  //when the google map is intialized when the user loads it up in the widget
  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Widget getCurrentCardioDistance(){
    checkLocation();
    getCameraPosition(_locationData.latitude,_locationData.longitude);
    print("Location: latitude: "+_locationData.latitude.toString()+" longitude: "+_locationData.longitude.toString());
    return new Column(
      children:<Widget>[
        Text("Location: latitude: "+_locationData.latitude.toString()+" longitude: "+_locationData.longitude.toString()),
        Text("Total Distance Traveled: $totalDistanceTraveled miles"),
        SizedBox(
            width: MediaQuery.of(context).size.width,  // or use fixed size like 200
            height: MediaQuery.of(context).size.height/2,
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: _myLocation,
              onMapCreated: onMapCreated,
            ),
        ),
      ],
    );
  }

  Widget getCurrentCardioPace(){
    return new Container(
      child: Text("Current Pace: "),
    );
  }

  String startStop = "Start";
  Color startStopColor = Colors.green;

  String pauseResume = "Pause";
  Color pauseResumeColor = Colors.orange;



  //returns buttons to stop and start timer
  //returns the layout depending on if the user has started tracking or not
  Widget getCardioLogButtons(){
    if(startLocationTracking){
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getStartStopButton(),
          Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width /15)),//made it relative so they buttons dont look stupid on devices of varying sizes lmfao
          getPauseResumeButton(),
        ],
      );
    }else{
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getStartStopButton(),
        ],
      );
    }
  }

  //returns the pause resume button for live cardio tracker
  Widget getPauseResumeButton(){
    return FancyButton(
      child: Text(
        pauseResume,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      size: 50,
      color: pauseResumeColor,
      onPressed: () {
        setState(() {
          if(pauseResume == "Pause"){
            pauseResume = "Resume";
            pauseResumeColor = Colors.grey;
          }else{
            pauseResume = "Pause";
            pauseResumeColor = Colors.orange;
          }
        });
      },
    );
  }

  //returns the start top button for live cardio tracker
  Widget getStartStopButton(){
    return FancyButton(
      child: Text(
        startStop,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      size: 50,
      color: startStopColor,
      onPressed: () {
        print("start stop button pressed.");
        setState(() {
          if(startStop == "Start"){
            startLocationTracking = true;
            startStop="Stop";
            startStopColor = Colors.red;

            //reset the timer incase it wasn't reset before, in addition to resetting before starting LOL
            _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
            // Start
            _stopWatchTimer.onExecute.add(StopWatchExecute.start);

            //empty out all previous user run tracking information
            _polylines.clear();
            polylineCoordinates.clear();
            latlng.clear();
            totalDistanceTraveled = 0;
            previousCoordinates = null;

            _markers.add(new Marker(
              markerId: MarkerId("Starting Point"),
              position: LatLng(_locationData.latitude,_locationData.longitude),
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title:"Starting Point"),
            ));
          }else{
            startLocationTracking = false;
            startStop="Start";
            startStopColor = Colors.green;
            _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            print("polylines: "+_polylines.toString());
            Alert(
              context: context,
              type: AlertType.info,
              title: "Save Cardio Workout",
              desc: "Would you like to save this workout?",
              buttons: [
                DialogButton(
                  color: Colors.red,
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      currentWorkoutState = WorkoutState.log;
                      addWorkoutButtonVisibility = true;
                      //will pop the current alert and get rid of the alert
                      Navigator.pop(context);
                    });
                  },
                  width: 120,
                ),
                DialogButton(
                  color: Colors.green,
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      currentWorkoutState = WorkoutState.log;
                      addWorkoutButtonVisibility = true;

                      //add the cardio workout to the firebase

                      //will pop the current alert and get rid of the alert
                      Navigator.pop(context);
                    });
                  },
                  width: 120,
                )
              ],
            ).show();
          }
        });
      },
    );
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
        if(snapshot.hasData){
          workouts.clear();
          Map<dynamic, dynamic> values = snapshot.data.value;
          if(values != null){
            values.forEach((key, value) {
              WorkoutStrengthEntryContainer temp = WorkoutStrengthEntryContainer.parse(value);
              //print("Year compare: "+temp.getYear().toString() +" and "+currentDayShown.year.toString());//debugging purposes
              if(temp.getYear() == currentDayShown.year && temp.getMonth() == currentDayShown.month && temp.getDay() == currentDayShown.day){
                //print("current day workout: "+temp.toString());//debugging purposes
                workouts.add(new WorkoutStrengthEntryContainer.parse(value));
              }
            });
          }
        }
        if(workouts.length == 0){
          return noWorkoutsLoggedWidget();
        }else{
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
        }
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



