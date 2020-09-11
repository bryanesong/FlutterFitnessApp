import 'dart:async';
import 'dart:convert';
import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:FlutterFitnessApp/WorkoutCardioEntryContainer.dart';
import 'package:FlutterFitnessApp/WorkoutStrengthEntryContainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'Container Classes/CalorieEntryContainer.dart';
import 'Container Classes/FoodData.dart';
import 'Container Classes/MyFoodsContainer.dart';
import 'FancyButton.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';

import 'PinInformation.dart';
import 'WorkoutEntryContainer.dart';
//gays are legednary but i also find them relaxing
//dab on the haters

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

enum WidgetMarker { home, calorie, workout, stats, inventory, logCardio }
enum WorkoutState { log, addStrength, addCardio }
enum CalorieTrackerState {
  log,
  addFood,
  myFood,
  searchFood,
  addMyFood,
  addEntry,
  editEntry
}

/*
  Widget createPenguinImage() {
    if (penguinPositionX == -1 && penguinPositionY == -1) {
      penguinPositionX = MediaQuery.of(context).size.width / 2;
      penguinPositionY = MediaQuery.of(context).size.height / 2 + 50;
    }
    return AnimatedPositioned(
        width: penguinSize,
        height: penguinSize,
        duration: Duration(seconds: 3),
        //divided by 2 to center the penguin
        top: penguinPositionY - penguinSize / 2 /*- AppBar().preferredSize.height-MediaQuery.of(context).padding.top*/,
        left: penguinPositionX - penguinSize / 2,
        curve: Curves.decelerate,
        child: PenguinAnimate(animation: _animation));
  }

  void createPenguinAnimation() async{
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 6));
    _animation = IntTween(begin: 0, end: 9).animate(_animationController);

    _animationController.repeat().whenComplete(() {
      // put here the stuff you wanna do when animation completed!
    });
  }
*/



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
