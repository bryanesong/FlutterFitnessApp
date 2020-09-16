import 'package:FlutterFitnessApp/Container%20Classes/AppStateEnum.dart';
import 'package:flutter/material.dart';

class EnumStack{
  Node head;

  EnumStack(){
    head = null;
  }

  void push(data){
    if(head == null){
      head = new Node(data);
    }else{
      Node current = head;
      while(current != null){
        current = current.next;
      }
      current = new Node(data);
    }
  }

  AppState pop(){
    if(head == null){
      return null;
    }else{
      Node current = head;
      Node next = current.next;
      while(next.next != null){
        current = next;
        next = current.next;
      }
      AppState saved = current.data;
      current = null;
      return saved; //return last node
    }
  }

  AppState peek(){
    if(head == null){
      return null;
    }else{
      Node current = head;
      Node next = current.next;
      while(next.next != null){
        current = next;
        next = current.next;
      }
      return current.data; //return last node
    }
  }

  String toString(){
    if(head == null){
      return "EMPTY STACK!";
    }else{
      String str = "";
      Node current = head;
      while(current != null){
        str+= current.data.toString() +" ";
      }
      return str;
    }
  }

  bool isEmpty(){
    if(head == null){
      return true;
    }
    return false;
  }
  
  void clear(){
    head = null;
  }


}

class Node{
  AppState data;
  Node next;
  Node(AppState data){
    this.data = data;
  }
}