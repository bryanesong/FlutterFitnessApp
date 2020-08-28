import 'dart:async';

import 'SignUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'AlphaCode.dart';


class PromptAlphaCode extends StatefulWidget {
  @override
  PromptAlphaCodeState createState() => PromptAlphaCodeState();
}

class PromptAlphaCodeState extends State<PromptAlphaCode> {
  double _width, _height;
  final _alphaCode1Controller = TextEditingController();
  final _alphaCode2Controller = TextEditingController();
  FocusNode _focusBox1 = new FocusNode(), _focusBox2 = new FocusNode();
  List<AlphaCode> codeList = [];
  DatabaseReference codeRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool errorFound = false;
  String errorText = "";

  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    codeRef = database.reference().child("Alpha Codes");
    codeRef.onChildAdded.listen(_onEntryAdded);
    codeRef.onChildChanged.listen(_onEntryChanged);

    super.initState();
  }

  _onEntryAdded(Event event) {
    codeList.add(AlphaCode.fromSnapshot(event.snapshot));
    /*print(codeList[codeList.length - 1].userEmail);
    print("added");*/
  }

  _onEntryChanged(Event event) {
    var old = codeList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    codeList[codeList.indexOf(old)] = AlphaCode.fromSnapshot(event.snapshot);
  }

  @override
  void dispose() {
    _alphaCode1Controller.dispose();
    _alphaCode2Controller.dispose();
    _focusBox1.dispose();
    _focusBox2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
        key: formKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Alpha Code"),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, hpad(1), 0, 0),
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Alpha Code",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.w900,
                        fontSize: 53,
                        color: Colors.black54),
                  ),
                ),
                alphaCodeInput(),
                Container(
                    padding: EdgeInsets.fromLTRB(0, hpad(5), 0, 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.black54)),
                      onPressed: () {
                        checkAlphaCode();
                      },
                      child: Text("Continue", style: TextStyle(fontSize: 20)),
                    )),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, hpad(3)),
              alignment: Alignment.bottomCenter,
              child: Text("Request your alphacode at www.teampainpoints.com"),
            )
          ],
        ));
  }

  Widget alphaCodeInput() {
    return Container(
        padding: EdgeInsets.fromLTRB(0, hpad(25), 0, 0),
        child:Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: wpad(25),
          child: TextField(
              controller: _alphaCode1Controller,
              onChanged: (String value) {
                value.length == 3 ? _focusBox2.requestFocus() : "";
              },
              decoration: InputDecoration(
                  counterText: "", errorText: errorFound ? errorText : null),
              keyboardType: TextInputType.number,
              autofocus: true,
              focusNode: _focusBox1,
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              maxLength: 3),
        ),
        Text('-', style: TextStyle(fontSize: 20)),
        Container(
          width: wpad(25),
          child: TextField(
              controller: _alphaCode2Controller,
              onChanged: (String value) {
                value.length == 0 ? _focusBox1.requestFocus() : "";
              },
              decoration: InputDecoration(
                  counterText: "", errorText: errorFound ? "" : null),
              keyboardType: TextInputType.number,
              focusNode: _focusBox2,
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              maxLength: 3),
        )
      ],
    ));
  }

  void checkAlphaCode() {
    String _inputtedCode =
        _alphaCode1Controller.text + "-" + _alphaCode2Controller.text;

    bool codeFound = false;
    //locate code
    codeList.forEach((AlphaCode code) {
      if (_inputtedCode == code.alphaCode) {
        codeFound = true;
        if (code.inUse) {
          errorFound = true;
          errorText = "Code in use";
        } else if (!code.enabled) {
          errorFound = true;
          errorText = "Code disabled";
        } else {
          navigateToSignUpPage(context, code);
        }
        setState(() {});
      }
    });

    if (!codeFound) {
      errorFound = true;
      errorText = "No match found";
      setState(() {});
    }
  }

  double wpad(double percent) {
    return _width * percent / 100;
  }

  double hpad(double percent) {
    return _height * percent / 100;
  }

}

Future navigateToSignUpPage(context, AlphaCode curCode) async {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => SignUpRoute(curCode: curCode)));
}
