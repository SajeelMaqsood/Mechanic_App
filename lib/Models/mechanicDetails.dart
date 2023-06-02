import 'package:firebase_database/firebase_database.dart';

class Mechanic
{
  String ?name;
  String ?phone;
  String ?email;
  String ?id;
  String ?Cnic;
  String? JazzAcc;

  Mechanic({this.name, this.phone, this.email, this.id,this.Cnic,this.JazzAcc});

  Mechanic.fromSnapshot(DataSnapshot dataSnapshot)
  {
    name =dataSnapshot.child("mechanic_details").child("mechanic_name").value.toString();
    id = dataSnapshot.key;
    phone =dataSnapshot.child("phone").value.toString();
    email = dataSnapshot.child("email").value.toString();
    Cnic=dataSnapshot.child("mechanic_details").child("mechanic_cnic").value.toString();
    JazzAcc=dataSnapshot.child("mechanic_details").child("mechanic_Account").value.toString();



  }
}