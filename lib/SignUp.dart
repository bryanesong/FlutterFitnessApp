import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SignUpRoute extends StatefulWidget {
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUpRoute> {
  TextField username, password1, password2, email = new TextField();
  var keyboardListener;
  bool _checked = false;
  String title = 'Sign Up';
  GlobalKey rememberMeSpacer = new GlobalKey();

  @override
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        visible ? title = "" : title = "Sign Up";
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(children: [
      createTitle(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createTextField("Usn", username, false, null),
          createTextField("Pwd", password1, true, null),
          createTextField("Pwd", password2, true, null),
          createTextField("Email", email, false, rememberMeSpacer),
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

  Widget createTextField(String textLabel, TextField field, bool isPassword, Key spacerKey) {
    field = new TextField(
      style: TextStyle(fontSize: 20, color: Colors.black45),
      obscureText: isPassword,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Container(
        key: spacerKey,
        child: Text(
          '$textLabel',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        )
      ),
        Container(
            padding: EdgeInsets.fromLTRB(20, 5, 0, 0), width: 250, child: field)
      ],
    );
  }

  Widget createCheckboxTile() {
    return Container(width: 170,
        child: CheckboxListTile(
      title: Text('Remind Me'),
      controlAffinity: ListTileControlAffinity.trailing,
      value: _checked,
      onChanged: (bool value) {
        _checked = value;
        setState(() {});
      },
    ));
  }
}
