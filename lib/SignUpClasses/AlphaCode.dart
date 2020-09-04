import 'package:firebase_database/firebase_database.dart';

class AlphaCode {
  String key;
  String alphaCode;
  String userEmail;
  bool inUse;
  bool enabled;

//  DocumentReference reference;

  AlphaCode(this.alphaCode, this.userEmail, this.inUse, this.enabled);

  AlphaCode.fromSnapshot(DataSnapshot snapshot) : key = snapshot.key,
  alphaCode = snapshot.value["alphaCode"], userEmail = snapshot.value["userEmail"],
  inUse = snapshot.value["inUse"], enabled = snapshot.value["enabled"];
}

/*  toJson() {
    return {
      "alphaCode" : alphaCode,
      "userEmail" : userEmail,
      "inUse" : inUse,
      "enabled" : enabled,
    };
  }


  @override
  String toString() => "User<$userEmail>";*/
