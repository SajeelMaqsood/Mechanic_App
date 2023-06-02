import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Users
{
  String? id;
  String? email;
  String? name;
  String? phone;



  Users({this.id,this.name,this.phone,this.email});

  Users.fromSnapshot(DataSnapshot? dataSnapshot)
  {

      id= dataSnapshot!.key;
      email=dataSnapshot.child('email').value.toString();
      name=dataSnapshot.child('name').value.toString();
      phone=dataSnapshot.child('phone').value.toString();


  }
}