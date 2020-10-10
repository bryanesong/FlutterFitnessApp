import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class OwnedCosmeticsRealtime {
  //
  final Function() onNewOwnedCosmetic;

  //firebase variables
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static FirebaseUser _user;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static DatabaseReference _cosmeticRef;

  //list of retrieved inventory items
  static List<OwnedCosmeticInfo> _ownedCosmetics =
      new List<OwnedCosmeticInfo>();

  //accessible lists of owned cosmetics
  static List<PenguinHat> ownedHats = new List<PenguinHat>();
  static List<PenguinShirt> ownedShirts = new List<PenguinShirt>();
  static List<PenguinArm> ownedArms = new List<PenguinArm>();
  static List<PenguinShoes> ownedShoes = new List<PenguinShoes>();
  static List<PenguinShadow> ownedShadows = new List<PenguinShadow>();

  OwnedCosmeticsRealtime({this.onNewOwnedCosmetic}) {
    _getUser();
  }

  void _getUser() async {
    //navigate to correct spot in firebase
    _user = await _auth.currentUser();
    _cosmeticRef = _database
        .reference()
        .child("Users")
        .child(_user.uid)
        .child("Cosmetic Info")
        .child("Owned Cosmetics");
    _createFirebaseListener();
  }

  void _createFirebaseListener() {
    //create listeners for added and removed owned cosmetics
    _cosmeticRef.onChildAdded.listen(_onEntryAdded);
    _cosmeticRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    _ownedCosmetics.add(OwnedCosmeticInfo.fromSnapshot(event.snapshot));
    _reorganizeToLists();
  }

  _onEntryChanged(Event event) {
    var old = _ownedCosmetics.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    _ownedCosmetics[_ownedCosmetics.indexOf(old)] =
        OwnedCosmeticInfo.fromSnapshot(event.snapshot);
    _reorganizeToLists();
  }

  _reorganizeToLists() {
    ownedHats.clear();
    ownedShirts.clear();
    ownedArms.clear();
    ownedShoes.clear();
    ownedShadows.clear();

    for (int i = 0; i < _ownedCosmetics.length; i++) {
      OwnedCosmeticInfo curCosmetic = _ownedCosmetics[i];
      if (curCosmetic.cosmeticType == "Hat") {
        ownedHats.add(PenguinHat.NONE.toEnum(curCosmetic.cosmeticName));
      } else if (curCosmetic.cosmeticType == "Shirt") {
        ownedShirts.add(PenguinShirt.NONE.toEnum(curCosmetic.cosmeticName));
      } else if (curCosmetic.cosmeticType == "Arm") {
        ownedArms.add(PenguinArm.NONE.toEnum(curCosmetic.cosmeticName));
      } else if (curCosmetic.cosmeticType == "Shoes") {
        ownedShoes.add(PenguinShoes.NONE.toEnum(curCosmetic.cosmeticName));
      } else if (curCosmetic.cosmeticType == "Shadow") {
        ownedShadows.add(PenguinShadow.NONE.toEnum(curCosmetic.cosmeticName));
      } else {
        print("invalid owned item type");
      }
    }
  }
}

class OwnedCosmeticInfo {
  String cosmeticName;
  String cosmeticType;
  String key;

  OwnedCosmeticInfo.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        cosmeticName = snapshot.value["cosmeticName"],
        cosmeticType = snapshot.value["cosmeticType"];
}
