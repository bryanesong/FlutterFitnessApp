import 'dart:io';
import 'package:FlutterFitnessApp/AnimationTest.dart';
import 'package:FlutterFitnessApp/Login.dart';
import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'ContainerClasses/PSize.dart';
import 'HomeScreenClasses/HomeScreen.dart';
import 'SignUpClasses/PromptAlphaCode.dart';
import 'SignUpClasses/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SignInOrSignUp extends StatefulWidget {
  SignInOrSignUpState createState() => SignInOrSignUpState();
}

class SignInOrSignUpState extends State<SignInOrSignUp>
    with TickerProviderStateMixin {
  final FirebaseAuth mAuth = FirebaseAuth.instance;

  AnimationController _animationController;

  AnimationController _waddleController;
  GlobalKey signInKey = GlobalKey();
  GlobalKey signUpKey = GlobalKey();
  double penguinPositionX = -1;
  double penguinPositionY = -1;
  double penguinSize = .5;
  double iconSize = 125;
  String curLocation;
  bool setUpSizesInBuild = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PSize.width = MediaQuery.of(context).size.width;
    PSize.height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    if (setUpSizesInBuild) {
      iconSize = PSize.wPix(30);
      penguinSize = .5;
      setUpSizesInBuild = false;
    }

    return Scaffold(
      /*appBar: AppBar(title: Text("hello"),),*/ body: Center(
          child: Container(
              constraints: BoxConstraints.expand(),
              //padding: EdgeInsets.fromLTRB(0, 100, 0, 50),
              color: Colors.white,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/comicTEMP.png",
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
                  createPenguinImage(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: FittedBox(
                            child: Text(
                              'FITNESS NAME',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey),
                            ),
                          )),
                      createSignInSignOutRow()
                    ],
                  ),
                ],
              ))),
    );
  }

  @override
  dispose() {
    _animationController.dispose();
    _waddleController.dispose();
    super.dispose();
  }

  Widget createPenguinImage() {
    if (penguinPositionX == -1 && penguinPositionY == -1) {
      penguinPositionX = MediaQuery.of(context).size.width / 2;
      penguinPositionY = MediaQuery.of(context).size.height / 2;
    }
    return PenguinCreator(
        centerXCoord: penguinPositionX,
        centerYCoord: penguinPositionY,
        penguinSize: 300,
        scale: penguinSize,
        penguinAnimationType: PenguinAnimationType.wave,
        cosmetics: PenguinCosmetics(
            penguinHat: PenguinHat.NONE,
            penguinShadow: PenguinShadow.circular,
            penguinShirt: PenguinShirt.NONE,
            penguinArm: PenguinArm.NONE,
            penguinShoes: PenguinShoes.NONE));
  }

  Widget createSignInSignOutRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45, width: 3),
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.all(20),
              child: RawMaterialButton(
                key: signInKey,
                constraints: BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxHeight: iconSize,
                    maxWidth: iconSize),
                onPressed: () => (buttonPushed("Sign In")),
                fillColor: Colors.white,
                child: AutoSizeText(
                  "Sign In",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w900,
                      fontSize: 40,
                      color: Colors.grey),
                ),
                padding: EdgeInsets.all(10),
                shape: CircleBorder(),
              )),
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45, width: 3),
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.all(20),
              child: RawMaterialButton(
                key: signUpKey,
                constraints: BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxHeight: iconSize,
                    maxWidth: iconSize),
                onPressed: () => (buttonPushed("Sign Up")),
                fillColor: Colors.white,
                child: AutoSizeText(
                  "Sign Up",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w900,
                      fontSize: 40,
                      color: Colors.grey),
                ),
                padding: EdgeInsets.all(10),
                shape: CircleBorder(),
              ))
        ],
      ),
    );
  }

  void buttonPushed(String from) async {
    RenderBox box;
    if (curLocation == from) {
      from == "Sign In"
          ? navigateToLoginPage(context)
          : navigateToAlphaCodePage(context);
    } else {
      if (from == "Sign Up") {
        box = signUpKey.currentContext.findRenderObject();
        curLocation = "Sign Up";
      } else {
        box = signInKey.currentContext.findRenderObject();
        curLocation = "Sign In";
      }
      Offset position = box.localToGlobal(Offset.zero);
      penguinPositionX = position.dx + iconSize / 2;
      penguinPositionY = position.dy + iconSize / 2 - 50;
      penguinSize = 1;
      setState(() {});
      Future.delayed(const Duration(seconds: 3), () {
        from == "Sign In"
            ? navigateToLoginPage(context)
            : navigateToAlphaCodePage(context);
      });
    }
  }

  Future navigateToLoginPage(context) async {
    if (await FirebaseAuth.instance.currentUser() != null) {
      print("currently logged in.");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      print("NOT logged in,");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginRoute()));
    }
  }

  Future navigateToAlphaCodePage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PromptAlphaCode()));
  }
}
