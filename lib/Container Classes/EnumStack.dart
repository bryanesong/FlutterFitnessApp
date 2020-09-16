import 'package:FlutterFitnessApp/Container%20Classes/AppStateEnum.dart';
import 'package:flutter/material.dart';

class EnumStack{
  Node head;

  EnumStack(){
    head = null;
  }

  void push(AppState data){
    if(head == null){
      print("head is null");
      head = new Node(data);
    }else{
      Node current = head;
      while(current.next != null){
        current = current.next;
      }
      current.next = new Node(data);
    }
  }

  AppState pop(){
    Node current = head;
    if (current == null)
      return null;

    if (current.next == null) {
      return null;
    }

    Node secondLast = current;
    while (secondLast.next.next != null)
      secondLast = secondLast.next;

    secondLast.next = null;
    return current.data;
  }

  AppState peek(){
    Node current = head;
    if (current == null){
      print("empty stack");
      return null;
    }else{
      while(current.next!=null){
        current = current.next;
      }
      return current.data;
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
        current = current.next;
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