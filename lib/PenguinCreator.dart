import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Test Files/DynamicPenguinTest.dart';

import 'dart:math' as math;

const double PENGUIN_IMAGE_SIZE = 1000;

enum PenguinAnimationType { wave }

enum PenguinHat {
  pilgrimHat,
  sailorHat,
}

extension PenguinHatTypeExtension on PenguinHat {
  String describeEnum() {
    switch (this) {
      case PenguinHat.pilgrimHat:
        return ("pilgrimHat");
      case PenguinHat.sailorHat:
        return ("sailorHat");
      default:
        return null;
    }
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for(PenguinHat hat in PenguinHat.values) {
      enumValues.add(hat.toString().substring(hat.toString().indexOf('.') + 1));
    }
    return enumValues;
  }
}

enum PenguinShirt { usaTShirt }

extension PenguinShirtTypeExtension on PenguinShirt {
  String describeEnum() {
    switch (this) {
      case PenguinShirt.usaTShirt:
        return "usaTShirt";
      default:
        return null;
    }
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for(PenguinShirt shirt in PenguinShirt.values) {
      enumValues.add(shirt.toString().substring(shirt.toString().indexOf('.') + 1));
    }
    return enumValues;
  }
}

enum PenguinArm { koala, firecracker }

extension PenguinArmTypeExtension on PenguinArm {
  String describeEnum() {
    switch (this) {
      case PenguinArm.koala:
        return "koala";
      case PenguinArm.firecracker:
        return "firecracker";
      default:
        return null;
    }
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for(PenguinArm arm in PenguinArm.values) {
      enumValues.add(arm.toString().substring(arm.toString().indexOf('.') + 1));
    }
    return enumValues;
  }
}

enum PenguinShoes { mcdonaldShoes }

extension PenguinShoeTypeExtension on PenguinShoes {
  String describeEnum() {
    switch (this) {
      case PenguinShoes.mcdonaldShoes:
        return "mcdonaldShoes";
      default:
        return null;
    }
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for(PenguinShoes shoes in PenguinShoes.values) {
      enumValues.add(shoes.toString().substring(shoes.toString().indexOf('.') + 1));
    }
    return enumValues;
  }
}

PenguinAnimationData wave_animation;

PenguinAnimationData currentPenguinAnimation;

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
      {@required this.centerXCoord,
      @required this.centerYCoord,
      @required this.penguinSize,
      @required this.scale,
      @required this.penguinAnimationType,
      @required this.cosmetics});

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

    //update animation if a new one takes place
    if (curAnimationType != widget.penguinAnimationType) {
      print("different animations");
      changeAnimationType();

      _animationController.duration =
          Duration(seconds: currentPenguinAnimation.seconds);
      _animationController.stop();
      _animationController.repeat();
      _animation = IntTween(begin: 1, end: currentPenguinAnimation.frames)
          .animate(_animationController);
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
          scale: _sizeLength.value,
          child: RotationTransition(
              turns: _waddleAngle,
              child: Stack(
                overflow: Overflow.visible,
                fit: StackFit.expand,
                children: [
                  PenguinAnimate(
                    animation: _animation,
                    animationName: currentPenguinAnimation.animationName,
                  ),

                  //hat
                  widget.cosmetics.penguinHat != null &&
                          penguinKey.currentContext != null
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName: widget.cosmetics.penguinHat.describeEnum(),
                          imageList: currentPenguinAnimation.hatData,
                        )
                      : Container(),
                  //shirt
                  widget.cosmetics.penguinShirt != null &&
                          penguinKey.currentContext != null
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName: widget.cosmetics.penguinShirt.describeEnum(),
                          imageList: currentPenguinAnimation.shirtData,
                        )
                      : Container(),
                  //arm
                  widget.cosmetics.penguinArm != null &&
                          penguinKey.currentContext != null
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName: widget.cosmetics.penguinArm.describeEnum(),
                          imageList: currentPenguinAnimation.armData,
                        )
                      : Container(),
                  //feet
                  widget.cosmetics.penguinShoes != null &&
                          penguinKey.currentContext != null
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName: widget.cosmetics.penguinShoes.describeEnum(),
                          imageList: currentPenguinAnimation.shoeData,
                        )
                      : Container(),
                ],
              )),
        ));
  }

  void changeAnimationType() {
    switch (curAnimationType) {
      case (PenguinAnimationType.wave):
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
    curScale = scale+0.001;
    curX = widget.centerXCoord;
    curY = widget.centerYCoord;
    curAnimationType = widget.penguinAnimationType;
    changeAnimationType();

    //penguin frame animation
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 7));
    _animation = IntTween(begin: 1, end: 10).animate(_animationController);

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

    //redraw penguin with cosmetics after initially drawing penguin
    Future.delayed(const Duration(milliseconds: 50), () {
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

    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //1
    armInfo.add(PositionCosmetics(212, 521, armHighAngle, cosmeticSize));
    //2
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //3
    armInfo.add(PositionCosmetics(212, 521, armHighAngle, cosmeticSize));
    //4
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //5
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //6
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //7
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //8
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));
    //9
    armInfo.add(PositionCosmetics(234, 566, armLowAngle, cosmeticSize));

    List<PositionCosmetics> shirtInfo = new List<PositionCosmetics>();
    shirtInfo.add(PositionCosmetics(500, 500, 0, widget.penguinSize));

    List<PositionCosmetics> shoeInfo = new List<PositionCosmetics>();
    shoeInfo.add(PositionCosmetics(500, 500, 0, widget.penguinSize));

    wave_animation = new PenguinAnimationData(
        hatData: hatInfo,
        shirtData: shirtInfo,
        armData: armInfo,
        shoeData: shoeInfo,
        animationName: "waveAnimation",
        frames: 10,
        seconds: 7);
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
            'assets/images/$animationName/$frame.png',
            gaplessPlayback: true,
          );
        });
  }
}

//
class CosmeticAnimate extends AnimatedWidget {
  final String cosmeticName;
  final ImageList imageList;

  CosmeticAnimate(
      {@required Animation<int> animation,
      @required this.cosmeticName,
      @required this.imageList})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return imageList.get(cosmeticName, int.parse(animation.value.toString()), context);
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
            child: Image.asset("assets/images/$image",
              gaplessPlayback: true,),
          )),
    );
  }
}

//store cosmetic data
class PenguinCosmetics {
  PenguinHat penguinHat;
  PenguinShirt penguinShirt;
  PenguinArm penguinArm;
  PenguinShoes penguinShoes;

  PenguinCosmetics(
      this.penguinHat, this.penguinShirt, this.penguinArm, this.penguinShoes);
}

class PenguinAnimationData {
  //hold all the info for a specific animation
  ImageList hatData = new ImageList();
  ImageList shirtData = new ImageList();
  ImageList armData = new ImageList();
  ImageList shoeData = new ImageList();
  String animationName;
  int frames;
  int seconds;

  PenguinAnimationData(
      {@required List<PositionCosmetics> hatData,
      @required List<PositionCosmetics> shirtData,
      @required List<PositionCosmetics> armData,
      @required List<PositionCosmetics> shoeData,
      @required this.animationName,
      @required this.frames,
      @required this.seconds}) {
    this.hatData.data = hatData;
    this.shirtData.data = shirtData;
    this.armData.data = armData;
    this.shoeData.data = shoeData;

    //picked random hat to get all values of enum
    this.hatData.initiate(animationName, "hats", PenguinHat.pilgrimHat.get(), frames);
    this.shirtData.initiate(animationName, "shirts", PenguinShirt.usaTShirt.get(), frames);
    this.armData.initiate(animationName, "arm", PenguinArm.firecracker.get(), frames);
    this.shoeData.initiate(animationName, "shoes", PenguinShoes.mcdonaldShoes.get(), frames);
  }
}

class ImageList {
  List<PositionCosmetics> data = new List<PositionCosmetics>();
  CosmeticFrameDictionary frameDictionary = new CosmeticFrameDictionary();
  String type = "";

  Widget get(String cosmeticName, int frame, BuildContext context) {
    String image = "";
    //if special animation for cosmetic exists, access dictionary
    if(frameDictionary.get(cosmeticName) != null) {
      image = frameDictionary.get(cosmeticName)[frame-1];
    } else {
      //resort to generic image
      image = type + "/" + cosmeticName + ".png";
    }

    //if frame doesn't have animation data
    if(frame-1 < data.length) {
      return data[frame-1].placeCosmetic(context, image);
    } else {
      //resort to frame 1 data
      return data[0].placeCosmetic(context, image);
    }
  }

  void initiate(String animationName, String type, List<String> cosmeticList, int frameCount) async {
    this.type = type;

    //iterate through all cosmetics and look for cosmetics that change images during the animation
    for(int i = 0; i < cosmeticList.length; i++) {
      bool customImageFound = false;
      List<String> customImageList = new List<String>();
      for (int j = 0; j < frameCount; j++) {
        String specialImagePath = type + "/" + animationName + "/" + cosmeticList[i] + "(" + (j+1).toString() + ").png";

        //if image can be found add to image list
        if(await loadImage(specialImagePath) != null) {
          customImageList.add(specialImagePath);
          customImageFound = true;
        } else {
          //add regular image
          customImageList.add(type + "/" + animationName + "/" + cosmeticList[i] + ".png");
        }

      }
      //if custom image was found, add list to dictionary
      if(customImageFound) {
        frameDictionary.add(customImageList, cosmeticList[i]);
      }
      //else don't add. imageList will return the default image if no customImageList is found for the current image
    }
  }

  Future loadImage(String path) async {
    try {
      return await rootBundle.load("assets/images/" + path);
    } catch(e) {
      return null;
    }
  }
}

class CosmeticFrameDictionary {
  //dictionary to hold the frames of custom cosmetics
  List<List<String>> dictionary = new List<List<String>>();
  List<String> labels = new List<String>();

  void add(List<String> pathList, String label) {
    dictionary.add(pathList);
    labels.add(label);
  }

  List<String> get(String label) {
    for(int i = 0; i < labels.length; i++) {
      if(labels[i] == label) {
        return dictionary[i];
      }
    }
    return null;
  }
}
