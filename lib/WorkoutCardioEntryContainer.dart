class WorkoutCardioEntryContainer{
  String name;
  double distance,time;
  DateTime dateTime;

  WorkoutCardioEntryContainer(){
    name = "";
    distance = 0;
    time = 0;
    dateTime = new DateTime.now();
  }

  WorkoutCardioEntryContainer.define(String name, double distance, double time, DateTime dateTime){
    this.name = name;
    this.distance = distance;
    this.time = time;
    this.dateTime = dateTime;
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


}