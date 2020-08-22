import 'package:FlutterFitnessApp/MyProfileGoals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AlphaCode.dart';
import 'dart:math';

class SignUpRoute extends StatefulWidget {
  AlphaCode curCode;

  SignUpRoute({Key key, this.curCode}) : super(key: key);

  SignUpState createState() => SignUpState(curCode: curCode);
}

class SignUpState extends State<SignUpRoute> {
  TextField _username = new TextField(),
      _password1 = new TextField(),
      _password2 = new TextField(),
      _email = new TextField();

  //checkbox bool
  bool _checked = false;

  //coord locator keys
  GlobalKey _usernameKey = new GlobalKey(),
      _password1Key = new GlobalKey(),
      _password2Key = new GlobalKey(),
      _emailKey = new GlobalKey(),
      mostRecentTextKey = new GlobalKey();

  FocusNode _usernameFocus = new FocusNode(),
      _password1Focus = new FocusNode(),
      _password2Focus = new FocusNode(),
      _emailFocus = new FocusNode();

  TextEditingController _usernameController = new TextEditingController(),
      _password1Controller = new TextEditingController(),
      _password2Controller = new TextEditingController(),
      _emailController = new TextEditingController();

  double fishY = AppBar().preferredSize.height;
  double fishSize = 0;

  FirebaseUser user;
  AlphaCode curCode;

  double curYOfUsn = -1;
  bool waitForAnimation = false;
  String _passwordErrorInfo = "";
  String _invalidErrorType = "";

  DatabaseReference ref;

  SignUpState({this.curCode});

  @override
  void initState() {
    super.initState();

    _emailController.text = curCode.userEmail;

    Future.delayed(const Duration(milliseconds: 1000), () {
      fishSize = 40;
      moveFish(_usernameKey);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _password1Controller.dispose();
    _password2Controller.dispose();
    _emailFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!waitForAnimation) {
      Future.delayed(const Duration(milliseconds: 50), () {
        moveFish(mostRecentTextKey);
      });
    }
    // TODO: implement build
    AppBar appbar = new AppBar(
      title: Text("Sign Up"),
    );
    return Scaffold(
        appBar: appbar,
        body: Stack(children: [
          AnimatedContainer(
            height: MediaQuery
                .of(context)
                .viewInsets
                .bottom > 0 ? 0 : 100,
            duration: Duration(milliseconds: 100),
            child: createTitle(),
          ),
          Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                  child: createTextField(
                    "Usn  ",
                    _username,
                    false,
                    _usernameKey,
                    _usernameFocus,
                    _usernameController,
                    false,),
                ),
              ),
              Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: createTextField(
                        "Pwd  ",
                        _password1,
                        true,
                        _password1Key,
                        _password1Focus,
                        _password1Controller,
                        false),
                  )),
              Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: createTextField(
                        "Pwd  ",
                        _password2,
                        true,
                        _password2Key,
                        _password2Focus,
                        _password2Controller,
                        false),
                  )),
              Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: createTextField(
                        "Email",
                        _email,
                        false,
                        _emailKey,
                        _emailFocus,
                        _emailController,
                        true),
                  )),
              Flexible(
                child: createCheckboxTile(),
              ),
              Flexible(child: createGoButton()),
            ],
          ),
          createFish(),
        ]));
  }

  Widget createTitle() {
    return Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          "Sign Up",
          style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w900,
              color: Colors.black54,
              fontSize: 53),
        ));
  }

  Widget createTextField(String textLabel,
      TextField field,
      bool isPassword,
      GlobalKey key,
      FocusNode focus,
      TextEditingController controller,
      bool isLocked,) {
    field = new TextField(
      readOnly: isLocked,
      style: TextStyle(fontSize: 20, color: Colors.black45),
      obscureText: isPassword,
      focusNode: focus,
      controller: controller,
      decoration: InputDecoration(
          errorText: _invalidErrorType == textLabel.trim()
              ? _passwordErrorInfo
              : null
      ),
    );

    focus.addListener(() {
      if (focus.hasFocus && waitForAnimation == false) {
        mostRecentTextKey = key;
        Future.delayed(const Duration(milliseconds: 150), () {
          moveFish(key);
        });
      }
    });

    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(

            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: Text(
              '$textLabel',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            )),
        Expanded(
            child: field)
      ],
    );
  }

  Widget createCheckboxTile() {
/*    double spaceFromRight = 0;
    print('checkbox');
    RenderBox box = rememberMeSpacer.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    spaceFromRight = position.dx;*/

    return Container(
        alignment: Alignment.centerRight,
        child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            alignment: Alignment.centerRight,
            width: 200 + 30.0,
            child: CheckboxListTile(
              title: Text('Remember Me'),
              controlAffinity: ListTileControlAffinity.trailing,
              value: _checked,
              onChanged: (bool value) {
                _checked = value;
                setState(() {});
              },
            )));
  }

  Widget createGoButton() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.black54)),
          onPressed: () {
            validateUserInput();
          },
          child: Text("GO!", style: TextStyle(fontSize: 20)),
        ));
  }

  Widget createFish() {
    //fish icon:     Icons made by <a href="https://www.flaticon.com/authors/those-icons" title="Those Icons">Those Icons</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
    return AnimatedPositioned(
      width: fishSize,
      height: fishSize,
      top: fishY,
      left: 10,
      duration: Duration(milliseconds: 100),
      child: Image.asset("assets/images/fish.png"),
    );
  }

  void moveFish(GlobalKey key) {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext.findRenderObject();
      Offset position = box.localToGlobal(Offset.zero);
      fishY = position.dy -
          AppBar().preferredSize.height -
          MediaQuery
              .of(context)
              .padding
              .top - fishSize / 2 + box.size.height / 2;
      print(position.dy);
      waitForAnimation = true;

      Future.delayed(const Duration(milliseconds: 25), () {
        waitForAnimation = false;
      });
      setState(() {});
    }
  }

  void validateUserInput() {
    if (_usernameController.text == "") {
      setState(() {
        _passwordErrorInfo = "Username cannot be left blank";
        _invalidErrorType = "Usn";
      });
    } else if (_password1Controller.text.length < 6) {
      setState(() {
        _passwordErrorInfo = "Password length must be 6 or greater";
        _invalidErrorType = "Pwd";
      });
    } else if (_password1Controller.text != _password2Controller.text) {
      setState(() {
        _passwordErrorInfo = "Passwords must match!";
        _invalidErrorType = "Pwd";
      });
    } else {
      registerAccount();
    }
  }

  void registerAccount() async {
    //COMMENTED OUT FOR TESTING PURPOSES
    /*user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${_emailController.text}",
        password: "${_password1Controller.text}"))
        .user;
    Random random = Random.secure();
    const _chars = 'abcdefghijklmnopqrstuvwxyz';
    String uniqueKey = String.fromCharCodes(Iterable.generate(
        10, (_) => _chars.codeUnitAt(random.nextInt(_chars.length))));

    ref = FirebaseDatabase.instance.reference();

    ref.child("Users").push().child("Friends List Info").child("List").set({
      'UUID': uniqueKey,
      'Username': _usernameController.text
    });

    await ref.child("Alpha Codes").orderByChild("userEmail").equalTo(curCode.userEmail).onChildAdded.listen((Event event) {
      ref.child("Alpha Codes").child(event.snapshot.key).child("inUse").set(true);
    });*/
    navigateToAlphaCodePage(context);
  }
}

Future navigateToAlphaCodePage(context) async{
  Navigator.push(context,MaterialPageRoute(
      builder: (context) => MyProfileGoals()
  ));
}

