import 'package:google_maps_flutter/google_maps_flutter.dart';

class WorkoutCardioEntryContainer{
  String name;
  double distance,time;
  DateTime dateTime;
  Set<Polyline> polylines = {};
  String type = "Strength";

  WorkoutCardioEntryContainer(){
    name = "";
    distance = 0;
    time = 0;
    dateTime = new DateTime.now();
  }

  WorkoutCardioEntryContainer.define(String name, double distance, double time, DateTime dateTime,Set<Polyline> polylines){
    this.name = name;
    this.distance = distance;
    this.time = time;
    this.dateTime = dateTime;
    this.polylines = polylines;
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

  double getTime(){
    return time;
  }

  void setTime(double time){
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