class WorkoutStrengthEntryContainer{
  int sets,reps,weight;
  String name;

  //date time information
  int year,month,day;
  int hour,minute,second;

  WorkoutStrengthEntryContainer(){
    sets = 0;
    reps = 0;
    weight = 0;
    name = "";
  }

  WorkoutStrengthEntryContainer.define(String name, int sets, int reps, int weight, int year,int month,int day,int hour,int minute,int second){

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

  WorkoutStrengthEntryContainer.parse(Map<dynamic,dynamic> data){
    this.name = data['Name'];
    this.sets = data['Sets'];
    this.reps = data['Reps'];
    this.weight = data['Weight'];
    this.year = data['Year'];
    this.month = data['Month'];
    this.day = data['Day'];
    this.hour = data['Hour'];
    this.minute = data['Minute'];
    this.second = data['Second'];
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

}