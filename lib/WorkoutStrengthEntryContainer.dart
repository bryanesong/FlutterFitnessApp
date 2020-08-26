class WorkoutStrengthEntryContainer{
  int sets,reps,weight;
  String name;
  DateTime dateTime;

  WorkoutStrengthEntryContainer(){
    sets = 0;
    reps = 0;
    weight = 0;
    name = "";
    dateTime = new DateTime.now();
  }

  WorkoutStrengthEntryContainer.define(String name, int sets, int reps, int weight, DateTime dateTime){
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