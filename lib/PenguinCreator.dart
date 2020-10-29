import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import 'ContainerClasses/PenguinCosmeticRealtime.dart';

const double PENGUIN_IMAGE_SIZE = 1000;

enum PenguinAnimationType { wave }

enum PenguinHat {
  NO_HAT,
  pilgrimHat,
  sailorHat,
  samuraiHat,
}

extension PenguinHatTypeExtension on PenguinHat {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for (PenguinHat hat in PenguinHat.values) {
      enumValues.add(hat.toString().substring(hat.toString().indexOf('.') + 1));
    }
    return enumValues;
  }

  PenguinHat toEnum(String enumName) {
    for (PenguinHat hat in PenguinHat.values) {
      if (enumName ==
          hat.toString().substring(hat.toString().indexOf('.') + 1)) {
        return hat;
      }
    }
    print("invalid enum hat string name");
    return null;
  }
}

enum PenguinShirt { NO_SHIRT, usaTShirt, samuraiArmor }

extension PenguinShirtTypeExtension on PenguinShirt {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for (PenguinShirt shirt in PenguinShirt.values) {
      enumValues
          .add(shirt.toString().substring(shirt.toString().indexOf('.') + 1));
    }
    return enumValues;
  }

  PenguinShirt toEnum(String enumName) {
    for (PenguinShirt shirt in PenguinShirt.values) {
      if (enumName ==
          shirt.toString().substring(shirt.toString().indexOf('.') + 1)) {
        return shirt;
      }
    }
    print("invalid enum shirt string name");
    return null;
  }
}

enum PenguinArm {
  NO_ARM,
  koala,
  firecracker,
  baguette,
  katana,
  boomerang,
  ivoryFan,
  jollyMeal,
  kbbqSkewer,
  pelletDrum,
  wineBottle,
  yoyooyoyo
}

extension PenguinArmTypeExtension on PenguinArm {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for (PenguinArm arm in PenguinArm.values) {
      enumValues.add(arm.toString().substring(arm.toString().indexOf('.') + 1));
    }
    return enumValues;
  }

  PenguinArm toEnum(String enumName) {
    for (PenguinArm arm in PenguinArm.values) {
      if (enumName ==
          arm.toString().substring(arm.toString().indexOf('.') + 1)) {
        return arm;
      }
    }
    print("invalid enum arm string name");
    return null;
  }
}

enum PenguinShoes { NO_SHOES, mcdonaldShoes, clogs }

extension PenguinShoeTypeExtension on PenguinShoes {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for (PenguinShoes shoes in PenguinShoes.values) {
      enumValues
          .add(shoes.toString().substring(shoes.toString().indexOf('.') + 1));
    }
    return enumValues;
  }

  PenguinShoes toEnum(String enumName) {
    for (PenguinShoes shoes in PenguinShoes.values) {
      if (enumName ==
          shoes.toString().substring(shoes.toString().indexOf('.') + 1)) {
        return shoes;
      }
    }
    print("invalid enum shoe string name");
    return null;
  }
}

enum PenguinShadow { NO_SHADOW, circular }

extension PenguinShadowTypeExtension on PenguinShadow {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  List<String> get() {
    List<String> enumValues = new List<String>();
    for (PenguinShadow shadows in PenguinShadow.values) {
      enumValues.add(
          shadows.toString().substring(shadows.toString().indexOf('.') + 1));
    }
    return enumValues;
  }

  PenguinShadow toEnum(String enumName) {
    for (PenguinShadow shadows in PenguinShadow.values) {
      if (enumName ==
          shadows.toString().substring(shadows.toString().indexOf('.') + 1)) {
        return shadows;
      }
    }
    print("invalid enum shadow string name");
    return null;
  }
}

PenguinAnimationData wave_animation;

PenguinAnimationData currentPenguinAnimation;

//to instantiate a penguin, create a PenguinCreator object inside of a stack
//for example:

//PenguinCosmetics bigPenguCosmetics = new PenguinCosmetics("sailorHat", null, "koala", null);
//PenguinCreator(centerXCoord: left, centerYCoord: 200, penguinSize: penguinSize, scale: scale, cosmetics: bigPenguCosmetics, penguinAnimationType: PenguinAnimationType.wave,)
//change values while calling setstate and the penguin will update

class PenguinCreator extends StatefulWidget {
  final double centerXCoord;
  final double centerYCoord;
  final double size;
  final PenguinAnimationType penguinAnimationType;
  final PenguinCosmetics cosmetics;
  final PenguinType penguinType;
  final Function() onPenguinClick;

  PenguinCreator(
      {@required this.centerXCoord,
      @required this.centerYCoord,
      @required this.size,
      @required this.penguinAnimationType,
      this.cosmetics,
      this.penguinType,
      this.onPenguinClick}) {
    if (cosmetics == null && penguinType == null) {
      print("ERROR COSMETICS FOR PENGUIN NOT DEFINED");
    }
  }

  @override
  _PenguinCreatorState createState() => _PenguinCreatorState();
}

BuildContext scaffoldContext;
bool drawCosmetic = false;

class _PenguinCreatorState extends State<PenguinCreator>
    with TickerProviderStateMixin {
  PenguinCosmetics penguinCosmetics = new PenguinCosmetics(
      penguinHat: PenguinHat.NO_HAT,
      penguinShirt: PenguinShirt.NO_SHIRT,
      penguinArm: PenguinArm.NO_ARM,
      penguinShoes: PenguinShoes.NO_SHOES,
      penguinShadow: PenguinShadow.NO_SHADOW);

  GlobalKey penguinKey = new GlobalKey();

  //create firebase cosmetic listener
  PenguinCosmeticRealtime _updateCosmetics;

  //penguin animation controller
  AnimationController _animationController;
  Animation _animation;
  AnimationController _waddleController;
  Animation<double> _waddleAngle;
  AnimationController _sizeController;
  Animation<double> _sizeLength;

  //variable to store most recent scale size
  double _curScale;

  //variable to store most recent x and y coords
  double _curX;
  double _curY;

  //variable to store most recent animation type
  PenguinAnimationType _curAnimationType;

  @override
  void initState() {
    setWaveAnimationPositionalData();

    //initialize variables that detect changes
    _curScale = widget.size / PENGUIN_IMAGE_SIZE + 0.001;
    _curX = widget.centerXCoord;
    _curY = widget.centerYCoord;
    _curAnimationType = widget.penguinAnimationType;
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

    //rebuild penguin creator internally if new cosmetics are found in firebase
    if (widget.penguinType != null) {
      _updateCosmetics = new PenguinCosmeticRealtime(
          penguinType: widget.penguinType,
          onNewCosmetics: () {
            setState(() {
              penguinCosmetics = PenguinCosmeticRealtime
                  .listOfPenguinCosmetics[widget.penguinType.index];
            });
          });
    } else {
      penguinCosmetics = widget.cosmetics;
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waddleController.dispose();
    _sizeController.dispose();
    _updateCosmetics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    scaffoldContext = context;

    //if widget cosmetics are not null, set them to be the penguin's cosmetics
    if (widget.cosmetics != null) {
      penguinCosmetics = widget.cosmetics;
    }

    //detect scale change
    if (_curScale != widget.size) {
      _sizeLength =
          Tween<double>(begin: _curScale, end: widget.size / PENGUIN_IMAGE_SIZE)
              .animate(_sizeController);
      _sizeController.forward(from: 0);

      _curScale = widget.size / PENGUIN_IMAGE_SIZE;
    }

    //detect if x or y coords have changed
    if (_curX != widget.centerXCoord || _curY != widget.centerYCoord) {
      waddle();
      _curX = widget.centerXCoord;
      _curY = widget.centerYCoord;
    }

    //update animation if a new one takes place
    if (_curAnimationType != widget.penguinAnimationType) {
      print("different animations");
      changeAnimationType();

      _animationController.duration =
          Duration(seconds: currentPenguinAnimation.seconds);
      _animationController.stop();
      _animationController.repeat();
      _animation = IntTween(begin: 1, end: currentPenguinAnimation.frameNum)
          .animate(_animationController);
    }

    return AnimatedPositioned(
        //to create sliding animation
        key: penguinKey,
        //center penguin on this coord
        left: widget.centerXCoord - PENGUIN_IMAGE_SIZE / 2,
        top: widget.centerYCoord - PENGUIN_IMAGE_SIZE / 2,
        width: PENGUIN_IMAGE_SIZE,
        height: PENGUIN_IMAGE_SIZE,
        duration: Duration(seconds: 3),
        child: Transform.scale(
          //to resize
          scale: _sizeLength.value,
          child: RotationTransition(
              //for waddle animation
              turns: _waddleAngle,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  //shadow
                  penguinCosmetics.penguinShadow != PenguinShadow.NO_SHADOW
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName:
                              penguinCosmetics.penguinShadow.describeEnum(),
                          imageList: currentPenguinAnimation.shadowData,
                          penguinKey: penguinKey,
                        )
                      : Container(),

                  PenguinAnimate(
                    animation: _animation,
                    animationName: currentPenguinAnimation.animationName,
                    frames: currentPenguinAnimation.frames,
                  ),

                  //shirt
                  penguinCosmetics.penguinShirt != PenguinShirt.NO_SHIRT
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName:
                              penguinCosmetics.penguinShirt.describeEnum(),
                          imageList: currentPenguinAnimation.shirtData,
                          penguinKey: penguinKey,
                        )
                      : Container(),

                  //hat
                  penguinCosmetics.penguinHat != PenguinHat.NO_HAT
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName:
                              penguinCosmetics.penguinHat.describeEnum(),
                          imageList: currentPenguinAnimation.hatData,
                          penguinKey: penguinKey,
                        )
                      : Container(),

                  //feet
                  penguinCosmetics.penguinShoes != PenguinShoes.NO_SHOES
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName:
                              penguinCosmetics.penguinShoes.describeEnum(),
                          imageList: currentPenguinAnimation.shoeData,
                          penguinKey: penguinKey,
                        )
                      : Container(),

                  //arm
                  penguinCosmetics.penguinArm != PenguinArm.NO_ARM
                      ? CosmeticAnimate(
                          animation: _animation,
                          cosmeticName:
                              penguinCosmetics.penguinArm.describeEnum(),
                          imageList: currentPenguinAnimation.armData,
                          penguinKey: penguinKey,
                        )
                      : Container(),
                  //create on click listener
                  FlatButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(width: PENGUIN_IMAGE_SIZE/widget.size/2, height: PENGUIN_IMAGE_SIZE/widget.size/2,),
                    onPressed: () {
                      widget.onPenguinClick();
                    },
                  )
                ],
              )),
        ));
  }

  void changeAnimationType() {
    switch (_curAnimationType) {
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

  void setWaveAnimationPositionalData() {
    //<-------------------------------------------------------------Wave Animation------------------------------------------------------------->
    double cosmeticSize = 1;

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
    shirtInfo.add(PositionCosmetics(500, 500, 0, cosmeticSize));

    List<PositionCosmetics> shoeInfo = new List<PositionCosmetics>();
    shoeInfo.add(PositionCosmetics(500, 500, 0, cosmeticSize));

    List<PositionCosmetics> shadowInfo = new List<PositionCosmetics>();
    shadowInfo.add(PositionCosmetics(388, 574, 0, cosmeticSize));

    wave_animation = new PenguinAnimationData(
        hatData: hatInfo,
        shirtData: shirtInfo,
        armData: armInfo,
        shoeData: shoeInfo,
        shadowData: shadowInfo,
        animationName: "waveAnimation",
        frames: [1, 2, 1, 2, 1, 3, 4, 3, 4, 3, 3],
        seconds: 7);
  }
}

class PenguinAnimate extends AnimatedWidget {
  final String animationName;
  final List<int> frames;

  PenguinAnimate(
      {@required Animation<int> animation,
      @required this.animationName,
      @required this.frames})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return Image.asset(
            "assets/images/$animationName/" +
                frames[animation.value - 1].toString() +
                ".png",
            gaplessPlayback: true,
          );
        });
  }
}

//
class CosmeticAnimate extends AnimatedWidget {
  final String cosmeticName;
  final ImageList imageList;
  final GlobalKey penguinKey;

  CosmeticAnimate(
      {@required Animation<int> animation,
      @required this.cosmeticName,
      @required this.imageList,
      @required this.penguinKey})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<int>;
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return imageList.get(cosmeticName, animation.value, context);
      },
    );
  }
}

class PositionCosmetics {
  double realX;
  double realY;
  double rotationAngle;
  double percentOfPenguin;

  PositionCosmetics(
      this.realX, this.realY, this.rotationAngle, this.percentOfPenguin);

  Widget placeCosmetic(BuildContext context, String image) {
    return Positioned(
      //math to determine where to place cosmetic:
      //1. place the cosmetic in the 1000 x 1000 grid ex: 388, 500
      //2. subtract by half the size of cosmetic to center
      left: realX - PENGUIN_IMAGE_SIZE * percentOfPenguin / 2,
      top: realY - PENGUIN_IMAGE_SIZE * percentOfPenguin / 2,
      child: Container(
          width: PENGUIN_IMAGE_SIZE * percentOfPenguin,
          height: PENGUIN_IMAGE_SIZE * percentOfPenguin,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Image.asset(
              "assets/images/$image",
              gaplessPlayback: true,
            ),
          )),
    );
  }
}

//store cosmetic data
class PenguinCosmetics {
  PenguinHat penguinHat = PenguinHat.NO_HAT;
  PenguinShirt penguinShirt = PenguinShirt.NO_SHIRT;
  PenguinArm penguinArm = PenguinArm.NO_ARM;
  PenguinShoes penguinShoes = PenguinShoes.NO_SHOES;
  PenguinShadow penguinShadow = PenguinShadow.circular;

  PenguinCosmetics(
      {@required this.penguinHat,
      @required this.penguinShirt,
      @required this.penguinArm,
      @required this.penguinShoes,
      @required this.penguinShadow});

  PenguinCosmetics.fromSnapshot(DataSnapshot snapshot)
      : penguinHat = PenguinHat.NO_HAT.toEnum(snapshot.value["hat"]),
        penguinShirt = PenguinShirt.NO_SHIRT.toEnum(snapshot.value["shirt"]),
        penguinArm = PenguinArm.NO_ARM.toEnum(snapshot.value["arm"]),
        penguinShoes = PenguinShoes.NO_SHOES.toEnum(snapshot.value["shoes"]),
        penguinShadow =
            PenguinShadow.NO_SHADOW.toEnum(snapshot.value["shadow"]);

  String getCosmetic(int index) {
    if (index == 0) {
      return penguinHat.describeEnum();
    } else if (index == 1) {
      return penguinShirt.describeEnum();
    } else if (index == 2) {
      return penguinArm.describeEnum();
    } else if (index == 3) {
      return penguinShoes.describeEnum();
    } else if (index == 4) {
      return penguinShadow.describeEnum();
    }
  }
}

class PenguinAnimationData {
  //hold all the info for a specific animation
  ImageList hatData = new ImageList();
  ImageList shirtData = new ImageList();
  ImageList armData = new ImageList();
  ImageList shoeData = new ImageList();
  ImageList shadowData = new ImageList();
  List<int> frames = new List<int>();
  String animationName;
  int frameNum;
  int seconds;

  PenguinAnimationData(
      {@required List<PositionCosmetics> hatData,
      @required List<PositionCosmetics> shirtData,
      @required List<PositionCosmetics> armData,
      @required List<PositionCosmetics> shoeData,
      @required List<PositionCosmetics> shadowData,
      @required this.animationName,
      @required this.frames,
      @required this.seconds}) {
    this.hatData.data = hatData;
    this.shirtData.data = shirtData;
    this.armData.data = armData;
    this.shoeData.data = shoeData;
    this.shadowData.data = shadowData;
    this.frameNum = frames.length;

    //picked random hat to get all values of enum
    this
        .hatData
        .initiate(animationName, "hats", PenguinHat.pilgrimHat.get(), frames);
    this.shirtData.initiate(
        animationName, "shirts", PenguinShirt.usaTShirt.get(), frames);
    this
        .armData
        .initiate(animationName, "arm", PenguinArm.firecracker.get(), frames);
    this.shoeData.initiate(
        animationName, "shoes", PenguinShoes.mcdonaldShoes.get(), frames);
    this.shadowData.initiate(
        animationName, "shadows", PenguinShadow.circular.get(), frames);
  }
}

class ImageList {
  List<PositionCosmetics> data = new List<PositionCosmetics>();
  CosmeticFrameDictionary frameDictionary = new CosmeticFrameDictionary();
  String type = "";

  Widget get(String cosmeticName, int frame, BuildContext context) {
    String image = "";
    //if special animation for cosmetic exists, access dictionary
    if (frameDictionary.get(cosmeticName) != null) {
      image = frameDictionary.get(cosmeticName)[frame - 1];
    } else {
      //resort to generic image
      image = type + "/" + cosmeticName + ".png";
    }

    //if frame doesn't have animation data
    if (frame - 1 < data.length) {
      return data[frame - 1].placeCosmetic(context, image);
    } else {
      //resort to frame 1 data
      return data[0].placeCosmetic(context, image);
    }
  }

  void initiate(String animationName, String type, List<String> cosmeticList,
      List<int> frames) async {
    this.type = type;

    //iterate through all cosmetics and look for cosmetics that change images during the animation
    for (int i = 0; i < cosmeticList.length; i++) {
      bool customImageFound = false;
      List<String> customImageList = new List<String>();
      for (int j = 0; j < frames.length; j++) {
        String specialImagePath = type +
            "/" +
            animationName +
            "/" +
            cosmeticList[i] +
            "(" +
            frames[j].toString() +
            ").png";

        //if image can be found add to image list
        if (await loadImage(specialImagePath) != null) {
          customImageList.add(specialImagePath);
          customImageFound = true;
        } else {
          //add regular image
          customImageList
              .add(type + "/" + animationName + "/" + cosmeticList[i] + ".png");
        }
      }
      //if custom image was found, add list to dictionary
      if (customImageFound) {
        frameDictionary.add(customImageList, cosmeticList[i]);
      }
      //else don't add. imageList will return the default image if no customImageList is found for the current image
    }
  }

  Future loadImage(String path) async {
    try {
      return await rootBundle.load("assets/images/" + path);
    } catch (e) {
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
    for (int i = 0; i < labels.length; i++) {
      if (labels[i] == label) {
        return dictionary[i];
      }
    }
    return null;
  }
}
