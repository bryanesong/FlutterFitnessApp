import 'package:flutter/cupertino.dart';

class WorkoutContainer{
  int sets;
  int reps;
  String name;
  DateTime dateTime;

  WorkoutContainer(){
    sets = 0;
    reps = 0;
    name = "N/A";
    dateTime = new DateTime.now();
  }

  WorkoutContainer.setValues(int sets, int reps, name, DateTime dateTime){
    this.sets = sets;
    this.reps = reps;
    this.name = name;
    this.dateTime = dateTime;
  }

  String toString(){
    return name+" Sets: "+sets.toString()+" Reps: "+reps.toString()+" Date: "+dateTime.month.toString()+"/"+dateTime.day.toString()+"/"+dateTime.year.toString();
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

  DateTime getDateTime(){
    return dateTime;
  }

  void setDateTime(DateTime dateTime){
    this.dateTime = dateTime;
  }

}