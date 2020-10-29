import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'FoodData.dart';

enum PenguinType{penguin, babyPenguin}

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

  //firebase listeners
  var onChangeListener;

  PenguinCosmeticRealtime({@required this.penguinType, @required this.onNewCosmetics}) {
    getUser();

    for(int i = 0; i < listOfPenguinCosmetics.length; i++) {
      if(listOfPenguinCosmetics[i] == null) {
        listOfPenguinCosmetics[i] = new PenguinCosmetics(penguinHat: PenguinHat.NO_HAT, penguinShirt: PenguinShirt.NO_SHIRT, penguinArm: PenguinArm.NO_ARM, penguinShoes: PenguinShoes.NO_SHOES, penguinShadow: PenguinShadow.NO_SHADOW);
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
    onChangeListener = cosmeticRef.onChildChanged.listen(_onChange);
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

  static pushCosmetics({@required PenguinType penguinType, String cosmeticName}) async {

    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    print("pushed cosmetic name: " + cosmeticName);

    String hat = listOfPenguinCosmetics[penguinType.index] != null ? listOfPenguinCosmetics[penguinType.index].penguinHat.describeEnum() : "NO_HAT";
    String shirt = listOfPenguinCosmetics[penguinType.index] != null ? listOfPenguinCosmetics[penguinType.index].penguinShirt.describeEnum() : "NO_SHIRT";
    String arm = listOfPenguinCosmetics[penguinType.index] != null ? listOfPenguinCosmetics[penguinType.index].penguinArm.describeEnum() : "NO_ARM";
    String shoes = listOfPenguinCosmetics[penguinType.index] != null ? listOfPenguinCosmetics[penguinType.index].penguinShoes.describeEnum() : "NO_SHOES";
    String shadow = listOfPenguinCosmetics[penguinType.index] != null ? listOfPenguinCosmetics[penguinType.index].penguinShadow.describeEnum() : "NO_SHADOW";

    if(PenguinHat.NO_HAT.get().contains(cosmeticName)) {
      hat = cosmeticName;
    } else if(PenguinShirt.NO_SHIRT.get().contains(cosmeticName)) {
      shirt = cosmeticName;
    } else if(PenguinArm.NO_ARM.get().contains(cosmeticName)) {
      arm = cosmeticName;
    } else if(PenguinShoes.NO_SHOES.get().contains(cosmeticName)) {
      shoes = cosmeticName;
    } else if(PenguinShadow.NO_SHADOW.get().contains(cosmeticName)) {
      shadow = cosmeticName;
    }


    print("hat: " + hat + " shirt: " + shirt + " arm: " + arm + " shoes: " + shoes + " shadow: " + shadow);
    DatabaseReference cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped")
        .child(penguinType.describeEnum());
    cosmeticRef.set({
      "hat": hat,
      "shirt": shirt,
      "arm": arm,
      "shoes": shoes,
      "shadow": shadow,
    });
  }

  void dispose() {
    onChangeListener.cancel();
  }

}
