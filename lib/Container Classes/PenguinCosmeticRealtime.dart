import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'FoodData.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;

class PenguinCosmeticRealtime {
  static PenguinCosmetics equipped = PenguinCosmetics(penguinHat: PenguinHat.NONE, penguinShirt: PenguinShirt.NONE, penguinArm: PenguinArm.NONE, penguinShoes: PenguinShoes.NONE, penguinShadow: PenguinShadow.circular);
  DatabaseReference cosmeticRef;

  //firebase user variables
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  PenguinCosmeticRealtime() {
    getUser();
  }

  void getUser() async {
    user = await auth.currentUser();
    cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped");
    createFirebaseListener();
  }

  void createFirebaseListener() {
    cosmeticRef.onChildAdded.listen(_onEntry);
    cosmeticRef.onChildChanged.listen(_onEntry);
  }

  _onEntry(Event event) {
    print("get penguin cosmetics");
    cosmeticRef.once().then((DataSnapshot snapshot) {
        PenguinCosmetics snapshotData = PenguinCosmetics.fromSnapshot(snapshot);
        if(snapshotData != null) {
          print("not null");
          equipped = snapshotData;
        }
    });

  }

  static pushCosmetics(PenguinCosmetics toEquip, {PenguinHat hat, PenguinShirt shirt, PenguinArm arm, PenguinShoes shoes, PenguinShadow shadow}) async {

    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    if(hat == null) {
      hat = toEquip.penguinHat;
    }

    if(shirt == null) {
      shirt = toEquip.penguinShirt;
    }

    if(arm == null) {
      arm = toEquip.penguinArm;
    }

    if(shoes == null) {
      shoes = toEquip.penguinShoes;
    }

    if(shadow == null) {
      shadow = toEquip.penguinShadow;
    }

    print("hat: " + hat.describeEnum() + " shirt: " + shirt.describeEnum() + " arm: " + arm.describeEnum() + " shoes: " + shoes.describeEnum() + " shadow: " + shadow.describeEnum());
    DatabaseReference cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped");
    cosmeticRef.set({
      "hat": hat.describeEnum(),
      "shirt": shoes.describeEnum(),
      "arm": arm.describeEnum(),
      "shoes": shoes.describeEnum(),
      "shadow": shadow.describeEnum(),
    });
  }

}
