import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Base Screen',
    home: BaseScreen(),
  ));

}

class BaseScreen extends StatelessWidget{
  final DatabaseReference database = FirebaseDatabase.instance.reference();

  void sendData(){
    database.child("Test").set("cool");
    print("data sent!");
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Firebase Connect'),
        ),
        body: Center(
            child: RaisedButton(
              child: Text('Login'),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRoute())
                );
              },
              //sendData(); //used as debug to send test data to firebase
            ),
        ), //center
    );
  }
}




