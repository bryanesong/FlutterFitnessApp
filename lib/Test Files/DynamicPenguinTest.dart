import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';

class DynamicPenguinTest extends StatefulWidget {
  DynamicPenguinTestState createState() => DynamicPenguinTestState();
}

//List<PositionCosmetics> leftArmInfo = new List<PositionCosmetics>();

//test
double scale = 1;

class DynamicPenguinTestState extends State<DynamicPenguinTest> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("xd"),
        ),
        body: Stack(fit: StackFit.expand, children: [
          /*CarouselSlider(
            options: CarouselOptions(height: 400.0),
            items: [1,2,3,4,5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                          color: Colors.amber
                      ),
                      child: Text('text $i', style: TextStyle(fontSize: 16.0),)
                  );
                },
              );
            }).toList(),
          )*/

          FlatButton(
            onPressed: () async {
              final path = "assets/images/arm/firecracker.png1";
              print(await rootBundle.load(path));
            }, child: Text("dab"),
          )
        ]));
  }
}
