import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyProfileGoals extends StatefulWidget{
  MyProfileGoalsState createState() => MyProfileGoalsState();

}

class MyProfileGoalsState extends State<MyProfileGoals> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(title: Text("Goals"),),
      body: Stack(children: [createTitle()],),

    );
  }

  Widget createTitle() {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          "Goals",
          style: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w900,
              color: Colors.black54,
              fontSize: 53),
        ));
  }

  Widget createRow() {
    return Row(
      children: [
        Image()
      ],
    );
  }
  
}
