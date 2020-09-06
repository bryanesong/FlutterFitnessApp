import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/src/scheduler/ticker.dart';

class DynamicPenguinTest extends StatefulWidget {
  DynamicPenguinTestState createState() => DynamicPenguinTestState();
}

final double REAL_PENGU_IMAGE_SIZE = 1000;
String currentImage = "assets/images/firecracker.png";
double penguinSize = 300;
double cosmeticSize = 250;
double right = 10;
double left = 10;
GlobalKey _penguinKey = new GlobalKey(), _stackKey = new GlobalKey();
List<PositionCosmetics> leftArmInfo = new List<PositionCosmetics>();

class DynamicPenguinTestState extends State<DynamicPenguinTest>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  bool buildPengu = false;
  AnimationController _moveController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 7));
    _animation = IntTween(begin: 0, end: 3).animate(_animationController);

    _animationController.repeat().whenComplete(() {
      // put here the stuff you wanna do when animation completed!
    });

    double armLowAngle = -math.pi * 2 / 10;
    double armHighAngle = -math.pi * 2 / 16;
    //0
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //1
    leftArmInfo.add(PositionCosmetics(239, 507, armHighAngle, cosmeticSize));
    //2
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //3
    leftArmInfo.add(PositionCosmetics(239, 507, armHighAngle, cosmeticSize));
    //4
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //5
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //6
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //7
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //8
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //9
    leftArmInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("hehexd this is so troll"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                FlatButton(
                  onPressed: () {
                    buildPengu = false;
                    setState(() {});

                    buildPengu = true;
                    setState(() {});
                  },
                  child: Text("Draw"),
                ),
                FlatButton(
                  onPressed: () {
/*                      if(currentImage == "assets/images/firecracker.png") {
                        currentImage = "assets/images/koala.png";
                        setState(() {

                        });
                      } else {
                        currentImage = "assets/images/firecracker.png";
                        setState(() {

                        });
                      }*/
                    if (leftArmInfo[0].size == 250) {
                      for (PositionCosmetics c in leftArmInfo) {
                        c.size = c.size / 2;
                      }
                    } else {
                      for (PositionCosmetics c in leftArmInfo) {
                        c.size = c.size * 2;
                      }
                    }

/*                    if (penguinSize == 100) {
                      penguinSize = 200;
                    } else {
                      penguinSize = 100;
                    }*/

                    if (left == 10) {
                      left = 200;
                    } else {
                      left = 10;
                    }
                    setState(() {});
                  },
                  child: Text("dab"),
                ),
                FlatButton(
                  onPressed: () {
                    if (right == 30) {
                      right = 10;
                    } else {
                      right = 30;
                    }
                    setState(() {});
                  },
                  child: Text("Toggle"),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            key: _stackKey,
            duration: Duration(seconds: 3),
            curve: Curves.easeInOut,
            left: left,
            width: penguinSize,
            height: penguinSize,
            child: Stack(
              overflow: Overflow.visible,
              key: _penguinKey,
              children: [
                PenguinAnimate(animation: _animation),
                buildPengu
                    ? /*CosmeticAnimate(
                        animation: _animation,
                      )*/
                    CosmeticAnimate(
                        animation: _animation,
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
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
          return Image.asset(
            'assets/images/penguin${frame}.png',
            width: penguinSize,
            height: penguinSize,
            gaplessPlayback: true,
          );
        });
  }
}

class CosmeticAnimate extends AnimatedWidget {
  CosmeticAnimate({@required Animation<int> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return leftArmInfo[int.parse(animation.value.toString())]
            .position(Image.asset(currentImage));
      },
    );
  }
}

class PositionCosmetics {
  double realX;
  double realY;
  double rotationAngle;
  double size;

  PositionCosmetics(this.realX, this.realY, this.rotationAngle, this.size);

  Positioned position(Widget image) {
    //locate penguin
    RenderBox pengBox = _penguinKey.currentContext.findRenderObject();

    //locate how much scaffold has been shifted
    RenderBox scaffoldBox = _stackKey.currentContext.findRenderObject();

    //x y coords of where to start drawing cosmetic = peng global x - offsetx, peng global y - offsety
    Offset penguLocation = pengBox.localToGlobal(Offset(
        -scaffoldBox.localToGlobal(Offset.zero).dx,
        -scaffoldBox.localToGlobal(Offset.zero).dy));
    print(penguLocation.dx.toString() + " " + penguLocation.dy.toString());

    return Positioned(
      //math to determine where to place cosmetic:
      //1. locate ratio of where the cosmetic is normally placed in 1000 x 1000 grid ex: 388/1000, 500/1000
      //2. multiply by size of penguin
      //3. subtract by half the size of cosmetic to center
      left: (realX / REAL_PENGU_IMAGE_SIZE) *
              penguinSize /*+
          penguLocation.dx*/
          -
          size / 2,
      top: (realY / REAL_PENGU_IMAGE_SIZE) *
              penguinSize /*+
          penguLocation.dy*/
          -
          size / 2,
      child: Container(
          width: size,
          height: size,
          child: Transform.rotate(
            angle: rotationAngle,
            child: image,
          )),
    );
  }
}
