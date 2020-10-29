import 'package:FlutterFitnessApp/PenguinCreator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;
class OwnedCosmeticsRealtime {
  //update function
  final Function() onNewOwnedCosmetic;

  //firebase listeners
  var onChangeListener;
  var onAddListener;

  //firebase variables
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static FirebaseUser _user;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static DatabaseReference _cosmeticRef;

  //list of retrieved inventory items
  static List<OwnedCosmeticInfo> _ownedCosmetics =
      new List<OwnedCosmeticInfo>();

  //accessible lists of owned cosmetics
  static List<String> ownedHats = new List<String>();
  static List<String> ownedShirts = new List<String>();
  static List<String> ownedArms = new List<String>();
  static List<String> ownedShoes = new List<String>();
  static List<String> ownedShadows = new List<String>();
  static List<List<String>> ownedCosmetics = [ownedHats, ownedShirts, ownedArms, ownedShoes, ownedShadows];

  OwnedCosmeticsRealtime({@required this.onNewOwnedCosmetic}) {
    _ownedCosmetics.clear();
    _getUser();
  }

  void dispose() {
    onAddListener.cancel();
    onChangeListener.cancel();
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
    onAddListener = _cosmeticRef.onChildAdded.listen(_onEntryAdded);
    onChangeListener = _cosmeticRef.onChildChanged.listen(_onEntryChanged);
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

    //create no cosmetic option
    for(int i = 0; i < ownedCosmetics.length; i++) {
      if(i == 0) {
        ownedCosmetics[i].add("NO_HAT");
      } else if(i == 1) {
        ownedCosmetics[i].add("NO_SHIRT");
      } else if(i == 2) {
        ownedCosmetics[i].add("NO_ARM");
      } else if(i == 3) {
        ownedCosmetics[i].add("NO_SHOES");
      } else if(i == 4) {
        ownedCosmetics[i].add("NO_SHADOW");
      }
    }

    for (int i = 0; i < _ownedCosmetics.length; i++) {
      OwnedCosmeticInfo curCosmetic = _ownedCosmetics[i];
      print("got " + curCosmetic.cosmeticName.toString() + " " + curCosmetic.cosmeticType.toString());
      if (curCosmetic.cosmeticType == "hat") {
        ownedHats.add(curCosmetic.cosmeticName);
      } else if (curCosmetic.cosmeticType == "shirt") {
        ownedShirts.add(curCosmetic.cosmeticName);
      } else if (curCosmetic.cosmeticType == "arm") {
        ownedArms.add(curCosmetic.cosmeticName);
      } else if (curCosmetic.cosmeticType == "shoes") {
        ownedShoes.add(curCosmetic.cosmeticName);
      } else if (curCosmetic.cosmeticType == "shadow") {
        ownedShadows.add(curCosmetic.cosmeticName);
      } else {
        print("invalid owned item type");
      }
    }
    onNewOwnedCosmetic();
  }

  static pushBoughtCosmetic(String cosmeticName) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();

    print("pushed cosmetic name: " + cosmeticName);

    String _cosmeticType;

    if(PenguinHat.NO_HAT.get().contains(cosmeticName)) {
      _cosmeticType = "hat";
    } else if(PenguinShirt.NO_SHIRT.get().contains(cosmeticName)) {
      _cosmeticType = "shirt";
    } else if(PenguinArm.NO_ARM.get().contains(cosmeticName)) {
      _cosmeticType = "arm";
    } else if(PenguinShoes.NO_SHOES.get().contains(cosmeticName)) {
      _cosmeticType = "shoes";
    } else if(PenguinShadow.NO_SHADOW.get().contains(cosmeticName)) {
      _cosmeticType = "shadow";
    }

    DatabaseReference cosmeticRef = database
        .reference()
        .child("Users")
        .child(user.uid)
        .child("Cosmetic Info")
        .child("Owned Cosmetics");
    cosmeticRef.push().set({
      "cosmeticName" : cosmeticName,
      "cosmeticType" : _cosmeticType
    });
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
