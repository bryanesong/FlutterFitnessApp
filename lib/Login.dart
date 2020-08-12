import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nice_button/nice_button.dart';

final FirebaseAuth mAuth = FirebaseAuth.instance;

class LoginRoute extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        NiceButton(
                          radius: 40,
                          padding: const EdgeInsets.all(15),
                          text: "Register",
                          icon: Icons.account_box,
                          gradientColors: [Color(0xff36d1dc), Color(0xff5b86e5)],
                          onPressed: () {
                            signInWithEmailAndPassword(context);
                          },
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
    emailController.clear();
    passwordController.clear();
  }

  void signInWithEmailAndPassword(BuildContext context) async {
    print("email:" + emailController.text);
    print("password:" + passwordController.text);
    final FirebaseUser user = (await mAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )).user;

    dispose();
    if (user != null) {
      showAlertDialog(context,"Login Successful");
    } else {
      showAlertDialog(context,"Login Failed");
    }

  }

  //show alert dialog will eventually be replaced by something more aesthic, but it will work for now
  showAlertDialog(BuildContext context, String message){
    AlertDialog alert = AlertDialog(
      content: Text(message),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //this delay is just for now
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
        return alert;
      },
    );
  }
}