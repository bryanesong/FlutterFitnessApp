import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nice_button/nice_button.dart';
import 'package:flame/animation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

final double buttonWidth = 65;
final double buttonHeight = 65;


class HomeScreen extends StatelessWidget{
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black)
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
                      width: 56,
                      height: 56,
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
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
    ),
    );
  }
  */


  List<String> imgURLs = ['/assets/images/penguin1.png','/assets/images/penguin3.png','/assets/images/penguin4.png','/assets/images/penguin5.png'];

  @override
  Widget build(BuildContext context) {
    run();
  }

  void run() async{
    Util flameUtil = Util();
    await flameUtil.fullScreen();
    await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  }


}

class Penguin extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    PenguinState createState() => new PenguinState();
  }
}

class PenguinState extends State<Penguin>{

  @override
  Widget build(BuildContext context) {

  }

}

/*
ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.menu)),
                onTap: () {},
              ),
            ),
          ),

 */