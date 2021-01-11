
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'HomeScreen.dart';

class FriendsList extends StatefulWidget {
  @override
  FriendsListState createState() => FriendsListState();
}

class FriendsListState extends State<FriendsList>{

  void initState(){
    super.initState();
    friendCodeController = TextEditingController();
  }

  void dispose(){
    super.dispose();
    friendCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: wpad(15),vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "search username...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0x36FFFFFF),
                            const Color(0x0FFFFFFF)
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(2),
                      child: Image.asset("assets/images/search_icon.png"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: hpad(80),
                  child: getFriendsList(),
                ),
              ),
            ],
          ),
          getAddFriendButton(),
        ],
      ),
    );
  }

  bool addFriendButtonVisibility = true;
  TextEditingController friendCodeController;

  Widget getAddFriendButton(){
    if (addFriendButtonVisibility) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: FloatingActionButton(
            onPressed: () async {
              Alert(
                context: context,
                type: AlertType.info,
                title: "Add Friend",
                desc: "Enter friend code: ",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Add Friend",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        //do add friend stuff here
                        addFriendByCode();
                      });
                    },
                    width: 120,
                  )
                ],
                content:TextField(
                controller: friendCodeController,
                decoration: InputDecoration(
                  hintText: "friend-code",
                ),
              ),
              ).show();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  void addFriendByCode(){
    String friendCode = friendCodeController.text.toString().trim();
    
  }

  List friendsUsernameList = new List();
  List friendIDList = new List();

  DatabaseReference reference = FirebaseDatabase.instance.reference();
  String hold = "";

  Widget getFriendsList(){
    getUID();
    //used to for testing to make sure getUID is invoked
    if (hold == "") {
      print("current userID is empty.");
    }
    return FutureBuilder(
      future: reference.child("Users").child(hold).child("Friends List Info").child("List").once(),
      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.hasData) {
          friendsUsernameList.clear();
          friendIDList.clear();
          Map<dynamic, dynamic> values = snapshot.data.value;
          print("values: $values");
          if (values != null) {
            values.forEach((key, value) {
              print("key: "+key+" value: "+value.toString());
              if(key == "friendList"){
                List<dynamic> temp = value;
                temp.forEach((element) {
                  print("friendID element: "+element.toString());
                  friendIDList.add(element);
                });
              }
              if(key == "usernameList"){
                List<dynamic> temp = value;
                temp.forEach((element) {
                  print("friendUsername element: "+element.toString());
                  friendsUsernameList.add(element);
                });
              }
            });
          }else{
            print("values was null");
          }
        }
        print("friend list length after adding both: "+friendsUsernameList.length.toString());
        if (friendsUsernameList.length == 0) {
          return noFriendsNotificationWidget();
        } else {
          return new ListView.builder(
            itemCount: friendsUsernameList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: hpad(10),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: friendListTuple(friendsUsernameList[index], index),
              );
            },
          );
        }
      },
    );
  }

  Future<String> getUID() async {
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;
    uid.toLowerCase();
    print("uid as Future<String>: " + uid);
    hold = uid;
    return uid;
  }

  Widget friendListTuple(String friendName,int index){
    return new Card(
      child: new Row(
        children: [
          Image.asset("assets/images/TEMP_profile_picture.png"),
          Expanded(
            child: Text(
                "$friendName",
              style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.4),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: () {
              removeFriend(index);
            },
          ),
        ],
      ),
    );
  }


  //will remove friend from friends list in firebase for both people alike
  // INCOMPLETE
  void removeFriend(int index) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    final FirebaseUser user = await mAuth.currentUser();
    final uid = user.uid;

    //ref.child("Users").child(uid).child("Workout Log Data").child(workout.getKey()).remove();

  }

  Widget noFriendsNotificationWidget(){
    return Container(
      child: Text("You have no friends :( sad peepo scooter"),
    );
  }

}
