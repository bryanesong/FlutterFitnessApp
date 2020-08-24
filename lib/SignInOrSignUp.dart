import 'dart:io';
import 'package:FlutterFitnessApp/Login.dart';
import 'package:FlutterFitnessApp/PromptAlphaCode.dart';
import 'package:FlutterFitnessApp/SignUp.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class SignInOrSignUp extends StatefulWidget {
  SignInOrSignUpState createState() => SignInOrSignUpState();
}

class SignInOrSignUpState extends State<SignInOrSignUp> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  AnimationController _waddleController;
  Animation<double> _waddleAngle;
  GlobalKey signInKey = GlobalKey();
  GlobalKey signUpKey = GlobalKey();
  double penguinPositionX = -1;
  double penguinPositionY = -1;
  double penguinSize = 150;
  double iconSize = 125;
  double _width, _height;

  @override
  void initState() {
    super.initState();




    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 6));
    _animation = IntTween(begin: 0, end: 9).animate(_animationController);

    _animationController.repeat().whenComplete(() {
      // put here the stuff you wanna do when animation completed!
    });

    _waddleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    final curvedAnimation = CurvedAnimation(
        parent: _waddleController,
        curve: Curves.easeInOutBack,
        reverseCurve: Curves.easeInOutBack);
    _waddleAngle = Tween<double>(begin: 0, end: 0.005).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    iconSize = wpad(35);

    return Scaffold(/*appBar: AppBar(title: Text("hello"),),*/ body: Center(
        child: Container(
            constraints: BoxConstraints.expand(),
            //padding: EdgeInsets.fromLTRB(0, 100, 0, 50),
            color: Colors.white,
            child: Stack(
              children: [
                createPenguinImage(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Container(padding: EdgeInsets.fromLTRB(15, 0, 15, 0),child: FittedBox(child: Text(
                    'FITNESS NAME',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w900,
                        color: Colors.grey),
                  ),)),

                    createSignInSignOutRow()
                  ],
                ),
              ],
            ))),);


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
    return AnimatedPositioned(
        width: penguinSize,
        height: penguinSize,
        duration: Duration(seconds: 3),
        //divided by 2 to center the penguin
        top: penguinPositionY - penguinSize / 2 /*- AppBar().preferredSize.height-MediaQuery.of(context).padding.top*/,
        left: penguinPositionX - penguinSize / 2,
        curve: Curves.decelerate,
        child: RotationTransition(
            turns: _waddleAngle,
            child: AnimatedContainer(
                duration: Duration(seconds: 3),
                curve: Curves.decelerate,
                child: PenguinAnimate(animation: _animation))));
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
                child: Text(
                  "Sign In",
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
                child: Text(
                  "Sign Up",
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

  void buttonPushed(String from) async{
    RenderBox box;
    from == "Sign Up"
        ? box = signUpKey.currentContext.findRenderObject()
        : box = signInKey.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    penguinPositionX = position.dx + iconSize / 2;
    penguinPositionY = position.dy + iconSize / 2 - 50;
    penguinSize = 250;

    waddle();

    Future.delayed(const Duration(seconds: 3), ()
    {
      from == "Sign In" ? navigateToLoginPage(context) : navigateToAlphaCodePage(context);
    });


  }

  void waddle() {
    _waddleController.addListener(() => setState(() {}));
    TickerFuture tickerFuture = _waddleController.repeat();
    tickerFuture.timeout(Duration(seconds: 3), onTimeout: () {
      _waddleController.forward(from: 0);
      _waddleController.stop(canceled: true);
    });
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }

  Future navigateToLoginPage(context) async{
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => HomeScreen())
    );
  }

  Future navigateToAlphaCodePage(context) async{
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => PromptAlphaCode())
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
          return new Image.asset(
            'assets/images/penguin${frame}.png',
            gaplessPlayback: true,
          );
        });
  }

}
