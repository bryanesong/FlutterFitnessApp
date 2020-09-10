import 'package:google_maps_flutter/google_maps_flutter.dart';

class WorkoutCardioEntryContainer{
  String name;
  double distance;
  int time;
  DateTime dateTime;
  Set<Polyline> polylines = {};
  String type = "Cardio";

  WorkoutCardioEntryContainer(){
    name = "";
    distance = 0;
    time = 0;
    dateTime = new DateTime.now();
  }

  WorkoutCardioEntryContainer.define(String name, double distance, int time, DateTime dateTime,Set<Polyline> polylines){
    this.name = name;
    this.distance = distance;
    this.time = time;
    this.dateTime = dateTime;
    this.polylines = polylines;
  }

  //this will parse all the information except for polylines
  WorkoutCardioEntryContainer.parse(Map<dynamic,dynamic> data){
    this.name = data['Name'];
    String temp = data['DateTime'];
    this.dateTime = new DateTime(int.parse(temp.substring(0,4)),int.parse(temp.substring(5,7)),int.parse(temp.substring(8,10)));//year,month,day,hour,minute,millisecond,microsecond
    if(data['Distance'] == 0){
      this.distance = 0.0;
    }else{
      this.distance = data['Distance'];
    }
    this.time = data['Time'];
  }

  String getName(){
    return name;
  }

  void setName(String name){
    this.name =name;
  }

  double getDistance(){
    return distance;
  }

  void setDistance(){
    this.distance = distance;
  }

  int getTime(){
    return time;
  }

  void setTime(int time){
    this.time = time;
  }

  DateTime getDateTime(){
    return dateTime;
  }

  void setDateTime(DateTime dateTime){
    this.dateTime = dateTime;
  }

  Set<Polyline> getPolylines(){
    return polylines;
  }

  void setPolylines(Set<Polyline> polylines){
    this.polylines = polylines;
  }

  String getType(){
    return type;
  }


}