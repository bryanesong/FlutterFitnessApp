import 'dart:async';
import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flame/widgets/sprite_widget.dart';
import 'package:flutter/material.dart';
import 'Login.dart';

Sprite _sprite;
animation.Animation _animation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _sprite = await Sprite.loadSprite('penguinSpriteSheet1.png', width: 1144, height: 1108);

  await Flame.images.load('penguinSpriteSheet1.png');
  final _animationSpriteSheet = SpriteSheet(
    imageName: 'penguinSpriteSheet1.png',
    columns: 2,
    rows: 1,
    textureWidth: 1144,
    textureHeight: 1108,
  );
  _animation = _animationSpriteSheet.createAnimation(
    0,
    stepTime: 0.5,
    to: 2,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final animationGb = _animation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInOrSignUp(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position _position = Position(256.0, 256.0);

  @override
  void initState() {
    super.initState();
    changePosition();
  }

  void changePosition() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _position = Position(10 + _position.x, 10 + _position.y);
    });
  }


  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text('Base Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Pengu Fit'),
            Container(
              width: 200,
              height: 200,
              child: AnimationWidget(animation: _animation),
            ),
            RaisedButton(
              child: Text("Log in"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRoute(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
/*
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The main route"),
      ),
      body: Center(
          child: RaisedButton(
            child: Text("Open next route"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginRoute(),
                ),
              );
            },
          )
      ),
    );
  }

 */

final double buttonWidth = 65;
final double buttonHeight = 65;

class HomeScreen extends StatelessWidget{
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: new AppDrawer(),
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: Text('Home Screen'),
        actions: <Widget>[
          new Container(),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                image: DecorationImage(
                  image: AssetImage("assets/images/seattleBackgroundTEMP.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                width: 200,
                height: 200,
                child: AnimationWidget(animation: _animation),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 4.0,color: Colors.blueAccent)
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
                          width: buttonWidth,
                          height: buttonHeight,
                          child: new Image.asset(
                            'assets/images/calorieButton.png',
                            fit: BoxFit.fill,
                          ),
                      ),
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
                          child: new Image.asset(
                            'assets/images/workoutButton.png',
                            fit: BoxFit.fill,
                          ),
                      ),
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
                          child: new Image.asset(
                            'assets/images/inventoryButton.png',
                            fit: BoxFit.fill,
                          ),
                      ),
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
                          child: new Image.asset(
                            'assets/images/statsButton.png',
                            fit: BoxFit.fill,
                          ),
                      ),
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
                          child: new Image.asset(
                            'assets/images/settingsButton.png',
                            fit: BoxFit.fill,
                          ),
                      ),
                      onTap: () {
                        _scaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future navigateAnimationTest(context) async{
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => HomeScreen())
    );
  }

}

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => new _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text("Item 1"),
          ),
          new ListTile(
            title: new Text("Item 2"),
          ),
          new ListTile(
            title: new Text("Item 2"),
          ),
        ],
      ),
    );
  }
}





