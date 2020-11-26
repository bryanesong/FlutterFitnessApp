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

  GlobalKey _signInKey = GlobalKey();
  GlobalKey _signUpKey = GlobalKey();
  double _penguinPositionX = -1;
  double _penguinPositionY = -1;
  double _penguinSize = 150;
  double _iconSize = 125;
  String _curLocation;
  bool _setUpSizesInBuild = true;

  //do not draw other components of stack until false
  bool _comicShown = true;

  //replace gesture detector with container to be able to click
  bool _showGestureDetector = true;

  //to fade comic in/out
  double _comicOpacity = 0.0;

  @override
  void initState() {
    //test of user is already logged in
    userLoggedIn().then((value) => value ? navigateToHomePage(context) : null);

    //executed after initial build state
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          setState(() {
            _comicOpacity = 1.0;
          })
        });
    super.initState();
  }

  Future<bool> userLoggedIn() async {
    return await FirebaseAuth.instance.currentUser() != null;
  }

  @override
  Widget build(BuildContext context) {
    //set phone
    PSize.width = MediaQuery.of(context).size.width;
    PSize.height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    if (_setUpSizesInBuild) {
      _iconSize = PSize.wPix(30);
      _penguinSize = 125;
      _setUpSizesInBuild = false;
    }

    return Scaffold(
      /*appBar: AppBar(title: Text("hello"),),*/
      body: Center(
          child: Container(
              constraints: BoxConstraints.expand(),
              //padding: EdgeInsets.fromLTRB(0, 100, 0, 50),
              color: Colors.white,
              child: Stack(
                children: [
                  _comicShown ? Container() : createPenguinImage(),
                  _comicShown
                      ? Container()
                      : Column(
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
                  _showGestureDetector
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              //draw other components in stack
                              _comicShown = false;
                              _comicOpacity = 0.0;
                            });

                            //replace gesture detector with container to detect clicks on "Sign In" and "Sign Up"
                            Future.delayed(Duration(seconds: 2), () {
                              setState(() {
                                _showGestureDetector = false;
                              });
                            });
                          },
                          child: AnimatedOpacity(
                            duration: Duration(seconds: 2),
                            opacity: _comicOpacity,
                            child: Container(
                              constraints: BoxConstraints.expand(),
                              child: Image.asset(
                                "assets/images/comicStrip.jpg",
                              ),
                            ),
                          ))
                      : Container()
                ],
              ))),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget createPenguinImage() {
    if (_penguinPositionX == -1 && _penguinPositionY == -1) {
      _penguinPositionX = MediaQuery.of(context).size.width / 2;
      _penguinPositionY = MediaQuery.of(context).size.height / 2;
    }
    return PenguinCreator(
        centerXCoord: _penguinPositionX,
        centerYCoord: _penguinPositionY,
        size: _penguinSize,
        penguinAnimationType: PenguinAnimationType.wave,
        cosmetics: PenguinCosmetics(
            penguinHat: PenguinHat.NO_HAT,
            penguinShadow: PenguinShadow.circular,
            penguinShirt: PenguinShirt.NO_SHIRT,
            penguinArm: PenguinArm.NO_ARM,
            penguinShoes: PenguinShoes.NO_SHOES));
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
                key: _signInKey,
                constraints: BoxConstraints(
                    minWidth: _iconSize,
                    minHeight: _iconSize,
                    maxHeight: _iconSize,
                    maxWidth: _iconSize),
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
                key: _signUpKey,
                constraints: BoxConstraints(
                    minWidth: _iconSize,
                    minHeight: _iconSize,
                    maxHeight: _iconSize,
                    maxWidth: _iconSize),
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
    if (_curLocation == from) {
      from == "Sign In"
          ? navigateToLoginPage(context)
          : navigateToAlphaCodePage(context);
    } else {
      if (from == "Sign Up") {
        box = _signUpKey.currentContext.findRenderObject();
        _curLocation = "Sign Up";
      } else {
        box = _signInKey.currentContext.findRenderObject();
        _curLocation = "Sign In";
      }
      Offset position = box.localToGlobal(Offset.zero);
      _penguinPositionX = position.dx + _iconSize / 2;
      _penguinPositionY = position.dy + _iconSize / 2 - 50;
      _penguinSize = 300;
      setState(() {});
      Future.delayed(const Duration(seconds: 3), () {
        from == "Sign In"
            ? navigateToLoginPage(context)
            : navigateToAlphaCodePage(context);
      });
    }
  }

  Future navigateToHomePage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future navigateToLoginPage(context) async {
    print("NOT logged in,");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginRoute()));
  }

  Future navigateToAlphaCodePage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PromptAlphaCode()));
  }
}
