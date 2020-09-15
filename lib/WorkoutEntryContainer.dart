import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:string_scanner/string_scanner.dart';

class WorkoutEntryContainer{
  //general variables for both types
  String name,type;
  int year,month,day;
  int hour,minute,second;
  String key;

  //variables specific for strength
  int sets,reps,weight;

  //variables specific for cardio
  double distance;
  int time;
  Set<Polyline> polylines = {};
  var timeArray = new List<int>(3);// hours, minutes, seconds

  //date time information

  WorkoutEntryContainer.defineStrength(String name, int sets, int reps, int weight, int year,int month,int day,int hour,int minute,int second){
    this.sets = sets;
    this.reps = reps;
    this.weight = weight;
    this.name = name;
    this.year = year;
    this.month = month;
    this.day = day;
    this.hour = hour; //this is expected to be recieved in 24hr format since you can always convert it later
    this.minute = minute;
    this.second = second;
  }

  WorkoutEntryContainer.defineCardio(String name, int time, double distance, Set<Polyline> polylines,int year,int month,int day,int hour,int minute,int second){
    this.name = name;
    this.time = time;
    this.distance = distance;
    this.polylines = polylines;
    this.type = "Cardio";
    this.year = year;
    this.month = month;
    this.day = day;
    this.hour = hour; //this is expected to be recieved in 24hr format since you can always convert it later
    this.minute = minute;
    this.second = second;
  }

  WorkoutEntryContainer.parse(Map<dynamic,dynamic> data, String key){
    this.key = key;
    if(data['Type']=="Strength"){
      this.type = "Strength";

      this.name = data['Name'];
      this.sets = data['Sets'];
      this.reps = data['Reps'];
      this.weight = data['Weight'];

      //date
      this.year = data['Year'];
      this.month = data['Month'];
      this.day = data['Day'];
      this.hour = data['Hour'];
      this.minute = data['Minute'];
      this.second = data['Second'];
    }else{
      this.type = "Cardio";

      this.name = data['Name'];
      if(data['Distance'] == 0){
        this.distance = 0.0;
      }else{
        this.distance = data['Distance'];
      }
      //this.polylines = data['Polylines']; //will need to tweak this somehow/ read in data from a string formatted like a list
      //print("getting poylines for run name:"+name); //used for testing
      if(data['Polylines'] != null){
        List<dynamic> temp = data['Polylines'];
        List<LatLng> latlng = List();
        //print("poylines length: "+temp.length.toString()); //used for testing
        for(int i = 0;i<temp.length;i++){
          String str = temp[i].toString().replaceAll("(", " ");
          str.replaceAll(")", " ");

          RegExp exp = new RegExp(r"(-?.\d+)");
          Iterable<RegExpMatch> hold = exp.allMatches(str);
          String total = "";
          int strCount = 0;
          double lat = 0;
          double lng = 0;
          bool latValued = false;

          for(var element in hold){
            total+=element.group(0);
            strCount++;
            if(strCount == 2){
              //print("element combined: $total"); //used for debugging
              double parsed = double.parse(total);
              if(!latValued){
                lat = parsed;
                //print("lat: $lat"); //used for debugging
                latValued = true;
              }else{
                latlng.add(new LatLng(lat,lng));
                polylines.add(new Polyline(
                  polylineId: PolylineId("TEMP ID"),
                  visible: true,
                  //latlng is List<LatLng>
                  points: latlng,
                  color: Colors.blue,
                ));
                lng = parsed;
                //print("lng: $lng"); //used for debugging
                latValued = false;
              }
              //print("after parsed to double: $parsed"); //used for debugging
              total = "";
              strCount = 0;
            }
          }
          //print("element combined: $total"); //used for debugging
        }
      }
      this.time = data['Time'];
      convertToTimeArray(this.time);
      //date
      this.year = data['Year'];
      this.month = data['Month'];
      this.day = data['Day'];
      this.hour = data['Hour'];
      this.minute = data['Minute'];
      this.second = data['Second'];
    }
    print("FINISHED PARSING-------------------------- type: $type");
  }

  //converts the raw time from the firebase to a readable list of integers which represet the time
  void convertToTimeArray(int time){
    int placeholder = time;
    print("inital time: $time"); //used for debugging
    //convert time to hours
    //hours = 60seconds * 60 minutes = 3600 seconds
    int hours = (placeholder / 3600).truncate();
    timeArray[0] = (hours);
    placeholder -= (hours * 3600);

    //convert leftover time to minutes and subtract
    int minutes = (placeholder / 60).truncate();
    timeArray[1] = (minutes);
    placeholder -=(minutes * 60);

    //leftover time will be in seconds
    timeArray[2] = (placeholder);

    print(timeArray);
  }

  //this method will reverse the first two characters in a string and return that string
  String flip(String s){
    String result = "";
    result +=s[1];
    result+=s[0];
    return result;
  }

  String toString(){
    return "Name: "+name+" Sets: "+sets.toString()+" Reps: "+reps.toString()+" Date: "+month.toString()+"/"+day.toString()+"/"+year.toString();//+"/"+dateTime.day.toString()+"/"+dateTime.year.toString();
  }

  String toStringNoDate(){
    return "Name: "+name+" Sets: "+sets.toString()+" Reps: "+reps.toString();
  }

  int getWeight(){
    if(weight == null){
      return 0;
    }
    return weight;
  }

  void setWeight(int weight){
    this.weight = weight;
  }

  int getSets(){
    return sets;
  }

  void setSets(int sets){
    this.sets = sets;
  }

  int getReps(){
    return reps;
  }

  void setReps(int reps){
    this.reps = reps;
  }

  String getName(){
    return name;
  }

  void setName(String name){
    this.name = name;
  }

  int getYear(){
    return year;
  }

  void setYear(int year){
    this.year = year;
  }

  int getMonth(){
    return month;
  }

  void setMonth(int month){
    this.month = month;
  }

  int getDay(){
    return day;
  }

  void setDay(int day){
    this.day = day;
  }

  int getHour(){
    return hour;
  }

  void setHour(int hour){
    this.hour = hour;
  }

  int getMinute(){
    return minute;
  }

  void setMinute(int minute){
    this.minute = minute;
  }

  int getSecond(){
    return second;
  }

  void setSecond(int second){
    this.second = second;
  }

  String getType(){
    return type;
  }

  double getDistance(){
    return this.distance;
  }

  void setDistance(double distance){
    this.distance = distance;
  }

  int getTime(){
    return this.time;
  }

  List getTimeArray(){
    return this.timeArray;
  }

  String getKey(){
    return this.key;
  }

}