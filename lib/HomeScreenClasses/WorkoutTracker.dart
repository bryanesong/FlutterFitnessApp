import 'dart:async';
import 'dart:math';

import 'package:FlutterFitnessApp/ContainerClasses/AppStateEnum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:FlutterFitnessApp/FancyButton.dart';
import 'package:FlutterFitnessApp/WorkoutEntryContainer.dart';



class WorkoutTracker extends StatefulWidget {
  final Function(AppState appState) onAppStateChange;
  final AppState appState;

  WorkoutTracker({@required this.appState, @required this.onAppStateChange});
  @override
  WorkoutTrackerState createState() => WorkoutTrackerState();
}


class WorkoutTrackerState extends State<WorkoutTracker> with TickerProviderStateMixin {



  var _calendarController = CalendarController();
  List workouts = new List();
  Location location = new Location();

  //when this is true, the onLocationChanged will add to the polylines to track the user running
  bool startLocationTracking = false;
  double totalDistanceTraveled = 0.0;
  LatLng previousCoordinates;

  Color polylineColor = Colors.blue;

  List<LatLng> latlng = List();

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

  TextEditingController cardioTextName;

  final FirebaseAuth mAuth = FirebaseAuth.instance;

  void initState(){
    super.initState();
    //init strength workout controllers
    strengthTextControllerReps = TextEditingController();
    strengthTextControllerSets = TextEditingController();
    strengthTextControllerWeight = TextEditingController();
    strengthTextControllerName = TextEditingController();
    //init cardio workout controllers
    cardioTextName = TextEditingController();
    //initializeStuff();
    _calendarController = CalendarController();

    getWorkoutLog(); //load things in workout list
    checkLocation();

    //set initial camrea position for google maps
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
        setState(() {
          _polylines.add(new Polyline(
            polylineId: PolylineId("TEMP ID"),
            visible: true,
            //latlng is List<LatLng>
            points: latlng,
            color: polylineColor,
          ));
        });

      }
    });
  }

  @override
  dispose() {
    _calendarController.dispose();
    //strength workout dipose
    strengthTextControllerReps.dispose();
    strengthTextControllerSets.dispose();
    strengthTextControllerWeight.dispose();
    strengthTextControllerName.dispose();
    //cardio workout dipose
    cardioTextName.dispose();
    super.dispose();
    print("called dispose");
  }

  @override
  Widget build(BuildContext context) {
    print("Current workout state: " + widget.appState.toString());
    if(widget.appState == AppState.Workout_AddStrength || widget.appState == AppState.Workout_AddCardio || widget.appState == AppState.Workout_LogCardio){
      return getWorkoutState();
    }else {
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
              //this is the container that holds all the stuff underneath the 1 row table calendar
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

  Widget getWorkoutState() {
    switch (widget.appState) {
      case AppState.Workout_Log:
        return getWorkoutLog();
      case AppState.Workout_AddStrength:
        return getWorkoutAddStrength();
      case AppState.Workout_AddCardio:
        return getWorkoutAddCardioButtons();
      case AppState.Workout_LogCardio:
        return logNewCardioWidget();
      default:
        print("invalid workout state");
        return null;
    }
    return getWorkoutLog();
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
                        widget.onAppStateChange(AppState.Workout_AddCardio);
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
                        widget.onAppStateChange(AppState.Workout_AddStrength);
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

  Widget noWorkoutsLoggedWidget() {
    return new Container(
      alignment: Alignment.center,
      child: Text("You have no workouts logged for today. :("),
    );
  }

  Widget getWorkoutAddStrength() {
    return Container(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                      strengthTextControllerName.text.isEmpty
                          ? strengthNameValidate = true
                          : strengthNameValidate = false;
                      strengthTextControllerSets.text.isEmpty
                          ? strengthSetsValidate = true
                          : strengthSetsValidate = false;
                      strengthTextControllerReps.text.isEmpty
                          ? strengthRepsValidate = true
                          : strengthRepsValidate = false;
                      strengthTextControllerWeight.text.isEmpty
                          ? strengthWeightValidate = true
                          : strengthWeightValidate = false;
                      addWorkoutButtonVisibility = true;
                      print(strengthNameValidate);
                      print(strengthSetsValidate);
                      print(strengthRepsValidate);
                      print(strengthWeightValidate);
                      if (!strengthNameValidate &&
                          !strengthSetsValidate &&
                          !strengthRepsValidate &&
                          !strengthWeightValidate) {
                        print("adding strength workout to database...");
                        addStrengthWorkoutToDatabase();
                        widget.onAppStateChange(AppState.Workout_Log);
                        //reset validation booleans so they dont maintain the same state
                        strengthNameValidate = false;
                        strengthSetsValidate = false;
                        strengthRepsValidate = false;
                        strengthWeightValidate = false;
                        addWorkoutButtonVisibility = true;
                      }
                    });
                  },
                  child: const Text('Submit', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ]),
    );
  }

  void addStrengthWorkoutToDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    //this retrieves the current UID that is logged in from the firebase
    //should not be null since user needs to be logged in in order to access this route
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    print("TESTING UNDERNEATH:");
    print("name: " + strengthTextControllerName.text.toString());
    print("sets: " + strengthTextControllerSets.text.trim());
    print("reps: " + strengthTextControllerReps.text.trim());
    print("weight: " + strengthTextControllerWeight.text.trim());
    print("END OF TEST---------------------");

    DateTime currentTime = new DateTime.now();
    WorkoutEntryContainer entry = new WorkoutEntryContainer.defineStrength(
        strengthTextControllerName.text.toString(),
        int.parse(strengthTextControllerSets.text.trim()),
        int.parse(strengthTextControllerReps.text.trim()),
        int.parse(strengthTextControllerWeight.text.trim()),
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentTime.hour,
        currentTime.minute,
        currentTime.second);

    print("Added to Workout Log for user: " + uid);
    //ref.child("Users").child(uid).child("Workout Log Data").

    //get current number of children in workoutlog
    //int workoutLogCount;

    //print("workoutLogCount: "+workoutLogCount.toString());

    print("WEIGHT CHECK: " + entry.getWeight().toString());
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
      'Type': "Strength",//to signify that this workout entry is a strength one
    });
    strengthTextControllerName.clear();
    strengthTextControllerSets.clear();
    strengthTextControllerReps.clear();
    strengthTextControllerWeight.clear();
  }

  Widget getStrengthWeightTextField() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Weight(lbs):",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration:
          BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 3),
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

  Widget getStrengthRepsTextField() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Reps:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration:
          BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 3),
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

  Widget getStrengthSetsTextField() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Sets:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration:
          BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 3),
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

  Widget getStrengthNameTextField() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          "Name:",
          style: TextStyle(fontSize: 25),
        ),
        new Container(
          decoration:
          BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width / 3),
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

  Widget getWorkoutAddCardioButtons() {
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
                    print("Button pressed to log new cardio workout.");
                    setState(() {
                      widget.onAppStateChange(AppState.Workout_LogCardio);
                    });
                  },
                ),
              ],
            ),
          ],
        ));
  }

  Widget logNewCardioWidget() {
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

  Widget getCurrentCardioTime() {
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  void checkLocation() async {
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
    //print("location data retrieved... lat: " + _locationData.latitude.toString() + " lng: " + _locationData.longitude.toString()); //used for debugging
  }

  //variables used for the google maps implementation
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation = CameraPosition(
    target: LatLng(0, 0),
  );

  void getCameraPosition(double lat, double lng) async {
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

  Widget getCurrentCardioDistance() {
    checkLocation();
    getCameraPosition(_locationData.latitude, _locationData.longitude);
    print("Location: latitude: " +
        _locationData.latitude.toString() +
        " longitude: " +
        _locationData.longitude.toString());
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

  Widget getCurrentCardioPace() {
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
            _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            polylineColor = Colors.red;
          }else{
            pauseResume = "Pause";
            pauseResumeColor = Colors.orange;
            _stopWatchTimer.onExecute.add(StopWatchExecute.start);
            polylineColor = Colors.blue;
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
            polylineColor = Colors.blue;

            //reset the timer incase it wasn't reset before, in addition to resetting before starting LOL
            _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
            // Start
            _stopWatchTimer.onExecute.add(StopWatchExecute.start);

            //empty out all previous user run tracking information
            _polylines.clear();
            polylineCoordinates.clear();
            latlng.clear();
            totalDistanceTraveled = 0.0;
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
                      widget.onAppStateChange(AppState.Workout_Log);
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
                      widget.onAppStateChange(AppState.Workout_Log);
                      addWorkoutButtonVisibility = true;
                      //add the cardio workout to the firebase
                      //will pop the current alert and get rid of the alert
                      Navigator.pop(context);
                      Alert(
                        context:context,
                        type: AlertType.info,
                        title: "Name Your Workout",
                        desc: "Name your workout:",
                        buttons: [
                          DialogButton(
                            color: Colors.green,
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                addCardioWorkoutToDatabase();
                                //will pop the current alert and get rid of the alert
                                Navigator.pop(context);
                              });
                            },
                            width: 120,
                          ),
                        ],
                        content: TextField(
                          controller: cardioTextName,
                          decoration: InputDecoration(
                            hintText: "workout name",

                            //counterText: " ",
                          ),
                        ),
                      ).show();
                    });
                  },
                  width: 120,
                ),
              ],
            ).show();
          }
        });
      },
    );
  }

  //this method will add a cardio workout to database depending on the current information gathered
  void addCardioWorkoutToDatabase() async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    String key = ref.child("Users").child(uid).child("Workout Log Data").push().key;
    DateTime current = new DateTime.now();
    ref.child("Users").child(uid).child("Workout Log Data").child(key).set({
      'Name': cardioTextName.text.trim().toString(),
      'Distance':totalDistanceTraveled,
      'Time': _stopWatchTimer.secondTime.value,//will write the total amount of seconds in the timer and push that to firebase
      'Year': current.year,
      'Month': current.month,
      'Day': current.day,
      'Hour':current.hour,
      'Minute':current.minute,
      'Second': current.second,
      'Type': "Cardio",
    });
    print("STOP WATCH RAW:");
    print(_stopWatchTimer.secondTime.value);

    print("KEY: "+key);
    print("POLY LINES:");
    int count = 0;

    _polylines.forEach((element) {
      //ref.child("Users").child(uid).child("Workout Log Data").child(key).child("Polylines").child(count.toString()).set(element.points.toString());
      List<LatLng> temp = element.points;
      print("points length: "+temp.length.toString());
      for(int i = 0;i<temp.length;i++){
        ref.child("Users").child(uid).child("Workout Log Data").child(key).child("Polylines").child(i.toString()).child("Latitude").set(temp[i].latitude);
        ref.child("Users").child(uid).child("Workout Log Data").child(key).child("Polylines").child(i.toString()).child("Longitude").set(temp[i].longitude);
      }

      print("Adding polyline: "+count.toString()+", runtime type: "+element.points.runtimeType.toString());
      count++;
    });


    cardioTextName.clear();
    print("Cardio workout added to database for user: $uid");

  }

  DatabaseReference reference = FirebaseDatabase.instance.reference();
  String hold = "";

  Future<String> getUID() async {
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    uid.toLowerCase();
    print("uid as Future<String>: " + uid);
    hold = uid;
    return uid;
  }

  //returns a listview of all of the workouts being logged for the current day selected in the workout log(assigned to bryan)
  Widget getWorkoutLog(){
    getUID();
    //used to for testing to make sure getUID is invoked
    if (hold == "") {
      print("current userID is empty.");
    }
    return FutureBuilder(
      future:
      reference.child("Users").child(hold).child("Workout Log Data").once(),
      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.hasData) {
          workouts.clear();
          Map<dynamic, dynamic> values = snapshot.data.value;
          if (values != null) {
            values.forEach((key, value) {
              WorkoutEntryContainer temp = WorkoutEntryContainer.parse(value,key);
              print("key: "+key);
              print("Year compare: "+temp.getYear().toString() +" and "+currentDayShown.year.toString());//debugging purposes
              if (temp.getYear() == currentDayShown.year && temp.getMonth() == currentDayShown.month && temp.getDay() == currentDayShown.day) {
                //print("current day workout: "+temp.toString());//debugging purposes
                workouts.add(new WorkoutEntryContainer.parse(value,key));
              }
            });
          }
        }
        print("workout log length after adding both: "+workouts.length.toString());
        if (workouts.length == 0) {
          return noWorkoutsLoggedWidget();
        } else {
          return new ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
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

  Widget getWorkoutItem(int index) {
    print("GET WORKOUT ITEM METHOD INVOKED...");
    print("index: $index, workout type: "+workouts[index].getType());
    if(workouts[index].getType() == "Strength"){
      return Card(
        child: new Row(
          children: [
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workouts[index].getMonth().toString() +
                      "/" +
                      workouts[index].getDay().toString() +
                      "/" +
                      workouts[index].getYear().toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Name: " + workouts[index].getName(),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Sets: " + workouts[index].getSets().toString(),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Reps: " + workouts[index].getReps().toString(),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Weight: " + workouts[index].getWeight().toString(),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        workouts.removeAt(index);
                      });
                    },
                    child: Icon(Icons.delete),
                  ),
                ),
            )
          ],
        ),
      );
    }else{
      //return a cardio container
      return Card(
        child: new Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //get date for workout, will probably remove this later since the date is depending on what you click on so its redundant
                Text(
                  workouts[index].getMonth().toString() +
                      "/" +
                      workouts[index].getDay().toString() +
                      "/" +
                      workouts[index].getYear().toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Name: "+workouts[index].getName()),
                Text("Distance: "+workouts[index].getDistance().toString()),
                getTotalRunTime(workouts[index]),
                getAverageRunningPace(workouts[index]),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      removeWorkout(workouts[index]);
                    });
                  },
                  child: Icon(Icons.delete),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void removeWorkout(WorkoutEntryContainer workout) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    ref.child("Users").child(uid).child("Workout Log Data").child(workout.getKey()).remove();
    print("REMOVED WORKOUT NAMED: "+workout.getName());
  }

  Widget getTotalRunTime(WorkoutEntryContainer currentWorkout){
    int hour,minute,second;
    List<int> timeArray = currentWorkout.getTimeArray();
    //seconds
    String result = "";
    if(timeArray[0] != null){
      hour = timeArray[0];
      result+= "Hours: "+hour.toString();
    }
    //minutes
    if(timeArray[1] != null){
      minute = timeArray[1];
      result+= " Minutes: "+minute.toString();
    }
    //hours
    if(timeArray[2] != null){
      second = timeArray[2];
      result+= " Seconds: "+second.toString();
    }

    return Text("Time: $result");
  }

  //returns a widget displaying the running pace the user was running at
  Widget getAverageRunningPace(WorkoutEntryContainer currentWorkout){
    List<int> timeArray = currentWorkout.getTimeArray();
    print(timeArray); //used for debugging
    double minuteTotal = 0;
    //seconds
    if(timeArray[2] != null){
      minuteTotal+= timeArray[2] / 60;
    }
    //minutes
    if(timeArray[1] != null){
      minuteTotal += timeArray[1];
    }
    //hours
    if(timeArray[0] != null){
      minuteTotal += timeArray[0] * 60;
    }

    //USED FOR DEBUGGIN VVVV
    print("TIME - hour: "+timeArray[0].toString()+" minute: "+timeArray[1].toString()+" second: "+timeArray[2].toString());
    print("minute total: $minuteTotal");
    print("Distance ran: "+currentWorkout.getDistance().toString()+" divided by minutes: $minuteTotal"+" equals: "+(currentWorkout.getDistance() / minuteTotal).toString());
    //now need to convert back to minutes and seconds
    //this is where i wrote the calculation for pace, not sure if I did it write since now looking back at it it might not make sense
    //but im too lazy to relook at this since there's more important things to look back on
    //yuh
    double paceNotConverted = (currentWorkout.getDistance() / minuteTotal);
    int minutes = (currentWorkout.getDistance() / minuteTotal).truncate();
    double seconds = double.parse(paceNotConverted.toString().split('.')[1].substring(0,paceNotConverted.toString().length-2));
    seconds *= 60;//multiply by 60 seconds to return it to its 60 second per minute format
    int convertedSeconds = seconds.truncate();

    return Text("PACE - minutes: $minutes seconds: $convertedSeconds");
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
}

