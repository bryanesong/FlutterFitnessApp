import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'FoodData.dart';

enum PengType{Penguin, BabyPenguin}

extension PengTypeExtension on PengType {
  //return string value of selected enum value
  String describeEnum() {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }

  PengType toEnum(String enumName) {
    for (PengType type in PengType.values) {
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
  PenguinCosmetics equipped = PenguinCosmetics(penguinHat: PenguinHat.NONE, penguinShirt: PenguinShirt.NONE, penguinArm: PenguinArm.NONE, penguinShoes: PenguinShoes.NONE, penguinShadow: PenguinShadow.circular);
  DatabaseReference cosmeticRef;
  PengType pengType;

  //firebase user variables
  FirebaseUser user;
  final FirebaseAuth auth = FirebaseAuth.instance;

  PenguinCosmeticRealtime({this.pengType}) {
    getUser();
  }

  void getUser() async {
    user = await auth.currentUser();
    cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped")
        .child(pengType.describeEnum());
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

  pushCosmetics({PenguinHat hat, PenguinShirt shirt, PenguinArm arm, PenguinShoes shoes, PenguinShadow shadow}) async {

    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    if(hat == null) {
      hat = equipped.penguinHat;
    }

    if(shirt == null) {
      shirt = equipped.penguinShirt;
    }

    if(arm == null) {
      arm = equipped.penguinArm;
    }

    if(shoes == null) {
      shoes = equipped.penguinShoes;
    }

    if(shadow == null) {
      shadow = equipped.penguinShadow;
    }

    print("hat: " + hat.describeEnum() + " shirt: " + shirt.describeEnum() + " arm: " + arm.describeEnum() + " shoes: " + shoes.describeEnum() + " shadow: " + shadow.describeEnum());
    DatabaseReference cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Currently Equipped")
        .child(pengType.describeEnum());
    cosmeticRef.set({
      "hat": hat.describeEnum(),
      "shirt": shoes.describeEnum(),
      "arm": arm.describeEnum(),
      "shoes": shoes.describeEnum(),
      "shadow": shadow.describeEnum(),
    });
  }

}
