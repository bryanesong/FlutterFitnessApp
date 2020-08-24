import 'dart:async';
import 'file:///C:/Users/talk2/Documents/FlutterFitnessApp/lib/SignUpClasses/MyProfileGoals.dart';
import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flame/widgets/sprite_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Login.dart';

Sprite _sprite;
animation.Animation _animation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _sprite = await Sprite.loadSprite('penguinSpriteSheet1.png', width: 1144, height: 1108);

  await Flame.images.load('penguinSpriteSheet1.png');
  final _animationSpriteSheet = SpriteSheet(
    imageName: 'penguinSpriteSheet1.png',
    columns: 2,
    rows: 1,
    textureWidth: 1144,
    textureHeight: 1108,
  );
  _animation = _animationSpriteSheet.createAnimation(
    0,
    stepTime: 0.5,
    to: 2,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final animationGb = _animation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInOrSignUp(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position _position = Position(256.0, 256.0);

  @override
  void initState() {
    super.initState();
    changePosition();
  }

  void changePosition() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _position = Position(10 + _position.x, 10 + _position.y);
    });
  }


  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text('Base Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Pengu Fit'),
            Container(
              width: 200,
              height: 200,
              child: AnimationWidget(animation: _animation),
            ),
            RaisedButton(
              child: Text("Log in"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRoute(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
/*
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The main route"),
      ),
      body: Center(
          child: RaisedButton(
            child: Text("Open next route"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginRoute(),
                ),
              );
            },
          )
      ),
    );
  }

 */

final double buttonWidth = 65;
final double buttonHeight = 65;

String currentState = "idle_screen";
var _calendarController = CalendarController();

enum WidgetMarker{home,calorie, workout, stats, inventory}

class HomeScreen extends StatefulWidget{
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>{
  AnimationController _animationController;
  Animation _animation;

  AnimationController _waddleController;
  Animation<double> _waddleAngle;
  GlobalKey signInKey = GlobalKey();
  GlobalKey signUpKey = GlobalKey();
  double penguinPositionX = -1;
  double penguinPositionY = -1;
  double penguinSize = 150;

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  WidgetMarker selectedWidgetMarker = WidgetMarker.home;
  List workouts = new List();
  String mainScreenTitle = "Home Screen";

  @override
  void initState() {
    // TODO: implement initState
    initializeStuff();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void initializeStuff() async{
    _calendarController = CalendarController();
    //get workoutlog from firebase

    //placeholdr for workout log for now
    workouts.add("workout 1");
    workouts.add("workout 2");
    workouts.add("workout 3");
    workouts.add("workout 4");
    workouts.add("workout 5");
    workouts.add("workout 6");
    workouts.add("workout 7");
    workouts.add("workout 8");
    workouts.add("workout 9");
    workouts.add("workout 10");
    workouts.add("workout 11");
    workouts.add("workout 12");
  }

  @override
  Widget build(BuildContext context) {
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

  }

  Widget getInventoryWidget(){

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
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
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
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.add_a_photo),
                          title: Text(workouts[index]),
                          onTap: (){
                            print("You've clicked on workout number: "+index.toString());
                          },
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: FloatingActionButton(
                      onPressed:() async{

                      },
                      child: Icon(Icons.add),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        //child: createPenguinImage(),
      ),
    );
  }

  Widget createPenguinImage() {
    if (penguinPositionX == -1 && penguinPositionY == -1) {
      penguinPositionX = MediaQuery.of(context).size.width / 2;
      penguinPositionY = MediaQuery.of(context).size.height -( MediaQuery.of(context).size.height / 5);
    }
    return AnimatedPositioned(
        width: penguinSize,
        height: penguinSize,
        duration: Duration(seconds: 3),
        //divided by 2 to center the penguin
        top: penguinPositionY - penguinSize / 2 /*- AppBar().preferredSize.height-MediaQuery.of(context).padding.top*/,
        left: penguinPositionX - penguinSize / 2,
        curve: Curves.decelerate,
        child: RotationTransition(
            turns: _waddleAngle,
            child: AnimatedContainer(
                duration: Duration(seconds: 3),
                curve: Curves.decelerate,
                child: PenguinAnimate(animation: _animation))));
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
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }

  void logout(context) {
    print("signed user out.");
    mAuth.signOut();
    Navigator.pop(context);
  }


}

