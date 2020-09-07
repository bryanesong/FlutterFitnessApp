import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DynamicPenguinTest.dart';

import 'dart:math' as math;

List<PositionCosmetics> leftArmInfo = new List<PositionCosmetics>();

const double PENGUIN_IMAGE_SIZE = 1000;

class PenguinCreator extends StatefulWidget {
  final double centerXCoord;
  final double centerYCoord;
  final double penguinSize;
  final double scale;

  PenguinCreator(
      {this.centerXCoord, this.centerYCoord, this.penguinSize, this.scale});

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
/*    if (image == 0) {
      _animationController.duration = Duration(seconds: 1);
      _animationController.stop();
      _animationController.repeat();
      _animation = IntTween(begin: 0, end: 9).animate(_animationController);
    } else {
      _animationController.duration = Duration(seconds: 6);
      _animationController.stop();
      _animationController.repeat();
      _animation = IntTween(begin: 0, end: 3).animate(_animationController);
    }*/
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
                  drawCosmetic
                      ? CosmeticAnimate(
                          animation: _animation, image: "koala", scale: 1.0)
                      : Container(),
                  FlatButton(
                    onPressed: () {
                      drawCosmetic = true;
                      _sizeController.stop();
                      waddle();
                    },
                    child: Text("dab"),
                  )
                ],
              )),
        ));
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
    //initialize variables that detect changes
    curScale = widget.scale;
    curX = widget.centerXCoord;
    curY = widget.centerYCoord;

    //penguin frame animation
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 7));
    _animation = IntTween(begin: 0, end: 3).animate(_animationController);

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

    double armLowAngle = -math.pi * 2 / 10;
    double armHighAngle = -math.pi * 2 / 16;

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
    super.initState();
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

//store cosmetic data
class PenguinCosmetics {
  String hat = "";
  String shirt = "";
  String rightArm = "";
  String leftArm = "";
  String shoes = "";

  PenguinCosmetics(
      this.hat, this.shirt, this.rightArm, this.leftArm, this.shoes);
}

//
class CosmeticAnimate extends AnimatedWidget {
  final String image;
  final double scale;

  CosmeticAnimate(
      {@required Animation<int> animation,
      @required this.image,
      @required this.scale})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return leftArmInfo[int.parse(animation.value.toString())]
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
      left: (realX / REAL_PENGU_IMAGE_SIZE) * penguinSize +
          penguLocation.dx -
          size / 2,
      top: (realY / REAL_PENGU_IMAGE_SIZE) * penguinSize +
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

class penguinAnimationData {
  //hold all the info for a specific animation
  List<PositionCosmetics> hatData = new List<PositionCosmetics>();
  List<PositionCosmetics> shirtData = new List<PositionCosmetics>();
  List<PositionCosmetics> leftArmData = new List<PositionCosmetics>();
  List<PositionCosmetics> rightArmData = new List<PositionCosmetics>();
  List<PositionCosmetics> shoeData = new List<PositionCosmetics>();
  String animationName;
  double frames;

  penguinAnimationData(
      {@required this.hatData,
      @required this.shirtData,
      @required this.leftArmData,
      @required this.rightArmData,
      @required this.shoeData,
      @required this.animationName,
      @required this.frames});
}
