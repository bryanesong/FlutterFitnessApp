import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/util.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nice_button/nice_button.dart';
import 'package:flame/animation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:FlutterFitnessApp/main.dart';
import 'package:flame/animation.dart' as animation;
import 'AnimationTest.dart';
import 'main.dart';

/*
final double buttonWidth = 65;
final double buttonHeight = 65;

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backgroundTemp.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                width: 200,
                height: 200,
                child: AnimationWidget(animation: _animation),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 4.0,color: Colors.blueAccent)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Icon(Icons.menu)),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Icon(Icons.menu)),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Icon(Icons.menu)),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Icon(Icons.menu)),
                      onTap: () {},
                    ),
                  ),
                ),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Icon(Icons.menu)),
                      onTap: () {
                        navigateAnimationTest(context);
                      },
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

  Future navigateAnimationTest(context) async{
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => AnimationTest())
    );
  }

}
*/