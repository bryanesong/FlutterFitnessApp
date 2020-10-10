import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'FoodData.dart';

enum PenguinType{Penguin, BabyPenguin}

extension PenguinTypeExtension on PenguinType {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  PenguinType toEnum(String enumName) {
    for (PenguinType type in PenguinType.values) {
      if(enumName == type.toString().substring(type.toString().indexOf('.') + 1)) {
        return type;
      }
    }
    print("invalid enum string name");
    return null;
  }
}

final FirebaseDatabase database = FirebaseDatabase.instance;
class PenguinCosmeticRealtime {
  final Function() onNewCosmetics;

  static List<PenguinCosmetics> listOfPenguinCosmetics = new List<PenguinCosmetics>(PenguinType.values.length);

  DatabaseReference cosmeticRef;
  PenguinType penguinType;

  //firebase user variables
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  PenguinCosmeticRealtime({@required this.penguinType, @required this.onNewCosmetics}) {
    getUser();

    for(int i = 0; i < listOfPenguinCosmetics.length; i++) {
      if(listOfPenguinCosmetics[i] == null) {
        listOfPenguinCosmetics[i] = new PenguinCosmetics(penguinHat: PenguinHat.NONE, penguinShirt: PenguinShirt.NONE, penguinArm: PenguinArm.NONE, penguinShoes: PenguinShoes.NONE, penguinShadow: PenguinShadow.NONE);
        print("was null, fixed");
      }
    }
  }

  void getUser() async {
    user = await auth.currentUser();
    cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped")
        .child(penguinType.describeEnum());
    createFirebaseListener();
  }

  void createFirebaseListener() {
    cosmeticRef.onChildChanged.listen(_onChange);
    _onChange(null);
  }

  _onChange(Event event) {
    print("get penguin cosmetics");
    cosmeticRef.once().then((DataSnapshot snapshot) {
        PenguinCosmetics snapshotData = PenguinCosmetics.fromSnapshot(snapshot);
        if(snapshotData != null) {
          print("not null");
          listOfPenguinCosmetics[penguinType.index] = snapshotData;
          print(listOfPenguinCosmetics[penguinType.index].penguinArm.toString());
          onNewCosmetics();
        }
    });

  }

  static pushCosmetics({@required PenguinType penguinType, PenguinHat hat, PenguinShirt shirt, PenguinArm arm, PenguinShoes shoes, PenguinShadow shadow}) async {

    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    if(hat == null) {
      hat = listOfPenguinCosmetics[penguinType.index].penguinHat;
    }

    if(shirt == null) {
      shirt = listOfPenguinCosmetics[penguinType.index].penguinShirt;
    }

    if(arm == null) {
      arm = listOfPenguinCosmetics[penguinType.index].penguinArm;
    }

    if(shoes == null) {
      shoes = listOfPenguinCosmetics[penguinType.index].penguinShoes;
    }

    if(shadow == null) {
      shadow = listOfPenguinCosmetics[penguinType.index].penguinShadow;
    }

    print("hat: " + hat.describeEnum() + " shirt: " + shirt.describeEnum() + " arm: " + arm.describeEnum() + " shoes: " + shoes.describeEnum() + " shadow: " + shadow.describeEnum());
    DatabaseReference cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped")
        .child(penguinType.describeEnum());
    cosmeticRef.set({
      "hat": hat.describeEnum(),
      "shirt": shirt.describeEnum(),
      "arm": arm.describeEnum(),
      "shoes": shoes.describeEnum(),
      "shadow": shadow.describeEnum(),
    });
  }

}
