
//gays are legednary but i also find them relaxing
//dab on the haters

/*
  Dear future bryan,
  dont forget to add permission into Info.plist for iOS location

  yuh,
  9/1/20 bryan

  reference article:
  https://pub.dev/packages/location
 */

import 'package:FlutterFitnessApp/SignInOrSignUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ContainerClasses/PSize.dart';

void main() async {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInOrSignUp(),
    );
  }
}

/*

  ========================================================================================================================================


  HOME SCREEN

   ========================================================================================================================================

   */
