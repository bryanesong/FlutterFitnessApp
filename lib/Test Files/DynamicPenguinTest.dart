import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/src/scheduler/ticker.dart';

import 'PenguinCreator.dart';

class DynamicPenguinTest extends StatefulWidget {
  DynamicPenguinTestState createState() => DynamicPenguinTestState();
}

final double REAL_PENGU_IMAGE_SIZE = 1000;
String currentImage = "assets/images/firecracker.png";
double penguinSize = 200;
double cosmeticSize = 150;
double right = 10;
double left = 10;
double image = 0;
bool buildPengu = false;

//List<PositionCosmetics> leftArmInfo = new List<PositionCosmetics>();

//test
double scale = 1;

class DynamicPenguinTestState extends State<DynamicPenguinTest> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Lets gooo"),),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                FlatButton(
                  onPressed: () {
                    if (scale == 1) {
                      scale = .5;
                    } else {
                      scale = 1;
                    }
                    setState(() {

                    });
                  },
                  child: Text("Toggle"),
                ),
                FlatButton(
                  onPressed: () {
                    if (left == 10) {
                      image = 0;
                      left = 100;
                    } else {
                      image = 1;
                      left = 10;
                    }
                    setState(() {

                    });

                  },
                  child: Text("dab"),
                ),
              ],
            ),
          ),
          PenguinCreator(centerXCoord: left, centerYCoord: 60, penguinSize: penguinSize, scale: scale)
        ],
      ),
    );
  }
}
