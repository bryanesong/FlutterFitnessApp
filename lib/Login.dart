import 'dart:io';

import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nice_button/nice_button.dart';

import 'HomeScreenClasses/HomeScreen.dart';
import 'main.dart';

final FirebaseAuth mAuth = FirebaseAuth.instance;

class LoginRoute extends StatefulWidget{
  @override
  LoginRouteState createState() => LoginRouteState();
}

class LoginRouteState extends State<LoginRoute> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    //checkLoggedIn();
  }

  void checkLoggedIn() async{
    if (mAuth != null) {
      print("currently logged in.");
      Navigator.of(context).pop();
      navigateToHomeScreenNoContext();
    } else {
      print("NOT logged in,");
    }
  }

  void navigateToHomeScreenNoContext() async{
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  SnackBar snackBarSuccess = SnackBar(
    content: Text('Logged In Successfully'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  final snackBarFail = SnackBar(
    content: Text('Unable to Login'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Material(
        child: new Container (
            padding: const EdgeInsets.all(30.0),
            color: Colors.white,
            child: new Container(
              child: new Center(
                  child: new Column(
                      children : [
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new TextFormField(//EMAIL FORM FIELD
                          controller: emailController,
                          decoration: new InputDecoration(
                            labelText: "Enter Email",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                              ),
                            ),
                            //fillColor: Colors.green
                          ),
                          validator: (val) {
                            if(val.length==0) {
                              return "Email cannot be empty";
                            }else{
                              return null;
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: new InputDecoration(
                            labelText: "Enter Password",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(
                              ),
                            ),
                            //fillColor: Colors.green
                          ),
                          validator: (val) {
                            if(val.length==0) {
                              return "Password cannot be empty";
                            }else{
                              return null;
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Padding(padding: EdgeInsets.only(top: 20.0)),
                        new Builder(
                          builder: (context)=>
                              NiceButton(
                                radius: 40,
                                padding: const EdgeInsets.all(15),
                                text: "Log in",
                                icon: Icons.account_box,
                                gradientColors: [Color(0xff36d1dc), Color(0xff5b86e5)],
                                onPressed: () {
                                  signInWithEmailAndPassword(context);
                                },
                              ),
                        ),
                      ]
                  )
              ),
            )
        )
      ),
    );
  }

  void dispose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signInWithEmailAndPassword(BuildContext context) async {
    print("email:" + emailController.text);
    print("password:" + passwordController.text);
    final FirebaseUser user = (await mAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )).user;


    print("user info: "+user.toString());
    if (user != null){
      print("Login Successful");
      navigateToHomeScreen(context);
    } else {
      print("Login Failed");
      Scaffold.of(context).showSnackBar(snackBarFail);
    }
  }

  //show alert dialog will eventually be replaced by something more aesthic, but it will work for now

  Future navigateToHomeScreen(context) async{
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  Widget createCheckboxTile() {
    return Container(width: 170,
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.trailing,
          value: rememberMe,
          onChanged: (bool value) {
            rememberMe = value;
            setState(() {});
          },
        ));
  }
}
