import 'dart:async';

import 'package:FlutterFitnessApp/SignUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:FlutterFitnessApp/AlphaCode.dart';

class PromptAlphaCode extends StatefulWidget {
  @override
  PromptAlphaCodeState createState() => PromptAlphaCodeState();
}

class PromptAlphaCodeState extends State<PromptAlphaCode> {
  final _alphaCode1Controller = TextEditingController();
  final _alphaCode2Controller = TextEditingController();
  FocusNode _focusBox1 = new FocusNode(), _focusBox2 = new FocusNode();
  List<AlphaCode> codeList = [];
  DatabaseReference codeRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    codeRef = database.reference().child("Alpha Codes");
    codeRef.onChildAdded.listen(_onEntryAdded);
    codeRef.onChildChanged.listen(_onEntryChanged);
    updateFirebase();

    super.initState();
  }

  _onEntryAdded(Event event) {
    codeList.add(AlphaCode.fromSnapshot(event.snapshot));
    print(codeList[codeList.length - 1].userEmail);
    print("added");
  }

  _onEntryChanged(Event event) {
    var old = codeList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    codeList[codeList.indexOf(old)] = AlphaCode.fromSnapshot(event.snapshot);
  }

  void updateFirebase() {
    //codeRef.child("1").child("userEmail").set("yeet");
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
    // TODO: implement build
    return Scaffold(
        key: formKey,
        appBar: AppBar(
          title: Text("Alpha Code"),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                alphaCodeInput(),
                Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.black54)),
                      onPressed: () {
                        checkAlphaCode();
                      },
                      child: Text("Continue", style: TextStyle(fontSize: 20)),
                    ))
              ],
            ),
          ],
        ));
  }

  Widget alphaCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: TextField(
              controller: _alphaCode1Controller,
              onChanged: (String value) {
                value.length == 3 ? _focusBox2.requestFocus() : "";
              },
              keyboardType: TextInputType.number,
              autofocus: true,
              focusNode: _focusBox1,
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              maxLength: 3),
        ),
        Text('-', style: TextStyle(fontSize: 20)),
        Container(
          width: 100,
          child: TextField(
              controller: _alphaCode2Controller,
              onChanged: (String value) {
                value.length == 0 ? _focusBox1.requestFocus() : "";
              },
              keyboardType: TextInputType.number,
              focusNode: _focusBox2,
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              maxLength: 3),
        )
      ],
    );
  }

  void checkAlphaCode() {
    String _inputtedCode =
        _alphaCode1Controller.text + "-" + _alphaCode2Controller.text;

    //locate code
    codeList.forEach((AlphaCode code) {
      //COMMENTED OUT FOR TESTING PURPOSES
      if (_inputtedCode == code.alphaCode /*&& !code.inUse && code.enabled*/) {
        navigateToSignUpPage(context, code);
      }
    });
  }
}

Future navigateToSignUpPage(context, AlphaCode curCode) async {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => SignUpRoute(curCode: curCode)));
}
/*

AccessCode _AccessCodeFromJson(Map<dynamic, dynamic> json) {
  return AccessCode(
    json['alphaCode'] as String,
    json['userEmail'] == null ? null : json['userEmail'] as String,
    json['inUse'] as bool,
  );
}

Map<String, dynamic> _AccessCodeToJson(AccessCode instance) =>
    <String, dynamic> {
      'alphaCode': instance.alphaCode,
      'userEmail': instance.userEmail,
      'inUse': instance.inUse,
    };*/
