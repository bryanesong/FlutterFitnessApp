import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Test Files/DynamicPenguinTest.dart';

import 'dart:math' as math;

const double PENGUIN_IMAGE_SIZE = 1000;

enum PenguinAnimationType {
  wave
}
penguinAnimationData wave_animation;

penguinAnimationData currentPenguinAnimation;

//to instantiate a penguin, create a PenguinCreator object inside of a stack
//for example:

//PenguinCosmetics bigPenguCosmetics = new PenguinCosmetics("sailorHat", null, "koala", null);
//PenguinCreator(centerXCoord: left, centerYCoord: 200, penguinSize: penguinSize, scale: scale, cosmetics: bigPenguCosmetics, penguinAnimationType: PenguinAnimationType.wave,)
//change values while calling setstate and the penguin will update

double penguinSize = 0;
class PenguinCreator extends StatefulWidget {
  final double centerXCoord;
  final double centerYCoord;
  final double penguinSize;
  final double scale;
  final PenguinAnimationType penguinAnimationType;
  final PenguinCosmetics cosmetics;

  PenguinCreator(
      {@required this.centerXCoord, @required this.centerYCoord, @required this.penguinSize, @required this.scale, @required this.penguinAnimationType, @required this.cosmetics});

  @override
  _PenguinCreatorState createState() => _PenguinCreatorState();
}

BuildContext scaffoldContext;
GlobalKey penguinKey = new GlobalKey();
bool drawCosmetic = false;

class _PenguinCreatorState extends State<PenguinCreator>
    with TickerProviderStateMixin {
  //penguin animation controller
  AnimationController _animationController;
  Animation _animation;
  AnimationController _waddleController;
  Animation<double> _waddleAngle;
  AnimationController _sizeController;
  Animation<double> _sizeLength;

  //variable to store most recent scale size
  double curScale;

  //variable to store most recent x and y coords
  double curX;
  double curY;

  //variable to store most recent animation type
  PenguinAnimationType curAnimationType;

  @override
  void dispose() {
    _animationController.dispose();
    _waddleController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    scaffoldContext = context;

    //global penguin size is set so that even the cosmeticPosition class can access the info
    penguinSize = widget.penguinSize;

    //detect scale change
    if (curScale != widget.scale) {
      _sizeLength = Tween<double>(begin: curScale, end: widget.scale)
          .animate(_sizeController);
      _sizeController.forward(from: 0);
      curScale = widget.scale;
    }

    //detect if x or y coords have changed
    if (curX != widget.centerXCoord || curY != widget.centerYCoord) {
      waddle();
      curX = widget.centerXCoord;
      curY = widget.centerYCoord;
    }

    if (curAnimationType != widget.penguinAnimationType) {
      print("different animations");
      changeAnimationType();
      
      _animationController.duration = Duration(seconds: currentPenguinAnimation.seconds);
      _animationController.stop();
      _animationController.repeat();
      _animation = IntTween(begin: 0, end: currentPenguinAnimation.frames).animate(_animationController);
    }

    return AnimatedPositioned(
        key: penguinKey,
        //center penguin on this coord
        left: widget.centerXCoord - widget.penguinSize / 2,
        top: widget.centerYCoord - widget.penguinSize / 2,
        width: widget.penguinSize,
        height: widget.penguinSize,
        duration: Duration(seconds: 3),
        child: Transform.scale(
          scale: _sizeLength.value != 0 ? _sizeLength.value : widget.scale,
          child: RotationTransition(
              turns: _waddleAngle,
              child: Stack(
                overflow: Overflow.visible,
                fit: StackFit.expand,
                children: [
                  PenguinAnimate(
                    animation: _animation,
                    animationName: "penguin",
                  ),

                  //hat
                  widget.cosmetics.hat != null && penguinKey.currentContext != null
                      ? CosmeticAnimate(
                          animation: _animation, image: widget.cosmetics.hat, positionData: currentPenguinAnimation.hatData,)
                      : Container(),
                  //shirt
                  widget.cosmetics.shirt != null && penguinKey.currentContext != null
                      ? CosmeticAnimate(
                      animation: _animation, image: widget.cosmetics.shirt, positionData: currentPenguinAnimation.shirtData,)
                      : Container(),
                  //arm
                  widget.cosmetics.arm != null && penguinKey.currentContext != null
                      ? CosmeticAnimate(
                      animation: _animation, image: widget.cosmetics.arm, positionData: currentPenguinAnimation.armData,)
                      : Container(),
                  //feet
                  widget.cosmetics.shoes != null && penguinKey.currentContext != null
                      ? CosmeticAnimate(
                      animation: _animation, image: widget.cosmetics.shoes, positionData: currentPenguinAnimation.shoeData,)
                      : Container(),
                ],
              )),
        ));
  }

  void changeAnimationType() {
    switch(curAnimationType) {
      case(PenguinAnimationType.wave):
        currentPenguinAnimation = wave_animation;
        break;
      default:
        print("no animation set! (no bueno)");
    }
  }

  void waddle() {
    _waddleController.addListener(() => setState(() {}));
    TickerFuture tickerFuture = _waddleController.repeat();
    tickerFuture.timeout(Duration(seconds: 3), onTimeout: () {
      _waddleController.forward(from: 0);
      _waddleController.stop(canceled: true);
    });
  }

  @override
  void initState() {
    setWaveAnimationPositionalData();

    //initialize variables that detect changes
    curScale = widget.scale;
    curX = widget.centerXCoord;
    curY = widget.centerYCoord;
    curAnimationType = widget.penguinAnimationType;
    changeAnimationType();

    //penguin frame animation
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 7));
    _animation = IntTween(begin: 0, end: 9).animate(_animationController);

    _animationController.repeat().whenComplete(() {
      // put here the stuff you wanna do when animation completed!
    });

    //penguin waddle animation
    _waddleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    final curvedAnimation = CurvedAnimation(
        parent: _waddleController,
        curve: Curves.easeInOutBack,
        reverseCurve: Curves.easeInOutBack);
    _waddleAngle = Tween<double>(begin: 0, end: 0.005).animate(curvedAnimation);

    //penguin size animation
    _sizeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _sizeLength = Tween<double>(begin: 0, end: 0.005).animate(_sizeController);
    _sizeController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void setWaveAnimationPositionalData() {
    //<-------------------------------------------------------------Wave Animation------------------------------------------------------------->
    double cosmeticSize = 250;

    List<PositionCosmetics> hatInfo = new List<PositionCosmetics>();
    double hatX = 482;
    double lowHatY = 184;
    double highHatY = 174;
    double vertical = 0;
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //1
    hatInfo.add(PositionCosmetics(hatX, highHatY, vertical, cosmeticSize));
    //2
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //3
    hatInfo.add(PositionCosmetics(hatX, highHatY, vertical, cosmeticSize));
    //4
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //5
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //6
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //7
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //8
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));
    //9
    hatInfo.add(PositionCosmetics(hatX, lowHatY, vertical, cosmeticSize));


    List<PositionCosmetics> armInfo = new List<PositionCosmetics>();
    double armLowAngle = -math.pi * 2 / 10;
    double armHighAngle = -math.pi * 2 / 16;

    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //1
    armInfo.add(PositionCosmetics(239, 507, armHighAngle, cosmeticSize));
    //2
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //3
    armInfo.add(PositionCosmetics(239, 507, armHighAngle, cosmeticSize));
    //4
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //5
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //6
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //7
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //8
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));
    //9
    armInfo.add(PositionCosmetics(262, 528, armLowAngle, cosmeticSize));

    wave_animation = new penguinAnimationData(hatData: hatInfo, shirtData: null, armData: armInfo, shoeData: null, animationName: "penguin", frames: 9, seconds: 7);
  }


}

class PenguinAnimate extends AnimatedWidget {
  final String animationName;

  PenguinAnimate(
      {@required Animation<int> animation, @required this.animationName})
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
            'assets/images/$animationName$frame.png',
            gaplessPlayback: true,
          );
        });
  }
}

//
class CosmeticAnimate extends AnimatedWidget {
  final String image;
  final List<PositionCosmetics> positionData;

  CosmeticAnimate(
      {@required Animation<int> animation,
      @required this.image,
      @required this.positionData})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return positionData[int.parse(animation.value.toString())]
            .placeCosmetic(context, image);
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

  Widget placeCosmetic(BuildContext context, String image) {
    //locate penguin
    RenderBox pengBox = penguinKey.currentContext.findRenderObject();

    //locate how much scaffold has been shifted
    RenderBox scaffoldBox = scaffoldContext.findRenderObject();

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
      left: (realX / PENGUIN_IMAGE_SIZE) * penguinSize +
          penguLocation.dx -
          size / 2,
      top: (realY / PENGUIN_IMAGE_SIZE) * penguinSize +
          penguLocation.dy -
          size / 2,
      child: Container(
          width: size,
          height: size,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Image.asset("assets/images/$image.png"),
          )),
    );
  }
}

//store cosmetic data
class PenguinCosmetics {
  String hat = "";
  String shirt = "";
  String arm = "";
  String shoes = "";

  PenguinCosmetics(
      this.hat, this.shirt, this.arm, this.shoes);
}

class penguinAnimationData {
  //hold all the info for a specific animation
  List<PositionCosmetics> hatData = new List<PositionCosmetics>();
  List<PositionCosmetics> shirtData = new List<PositionCosmetics>();
  List<PositionCosmetics> armData = new List<PositionCosmetics>();
  List<PositionCosmetics> shoeData = new List<PositionCosmetics>();
  String animationName;
  int frames;
  int seconds;

  penguinAnimationData(
      {@required this.hatData,
      @required this.shirtData,
      @required this.armData,
      @required this.shoeData,
      @required this.animationName,
      @required this.frames,
      @required this.seconds});
}
