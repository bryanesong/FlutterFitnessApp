import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SignUpRoute extends StatefulWidget {
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUpRoute> {
  TextField username, password1, password2, email = new TextField();
  var keyboardListener;
  String title = 'Sign Up';

  @override
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        visible ? title = "" : title = "Sign Up";
        setState(() {

        });
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(children: [createTitle(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createTextField("Usn", username, false),
          createTextField("Pwd", password1, true),
          createTextField("Pwd", password2, true),
          createTextField("Email", email, false),
          createCheckboxTile()
        ],
      ),
    ]));
  }

  Widget createTitle() {
    return Container(
      alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Text(
          title,
          style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w900,
              fontSize: 53,
              color: Colors.black54),
        ));
  }

  Widget createTextField(String textLabel, TextField field, bool isPassword) {
    field = new TextField(
      style: TextStyle(fontSize: 20, color: Colors.black45),
      obscureText: isPassword,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$textLabel',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(20, 5, 0, 0), width: 250, child: field)
      ],
    );
  }

  Widget createCheckboxTile() {
    return CheckboxListTile(title: Text('Remind Me'), value: false, controlAffinity: ListTileControlAffinity.trailing,);
  }
}
