import 'package:firebase_database/firebase_database.dart';

class Mechanic
{
  String ?name;
  String ?phone;
  String ?email;
  String ?id;
  String ?Cnic;
  String? JazzAcc;
  String? imageurl;

  Mechanic({this.name, this.phone, this.email, this.id,this.Cnic,this.JazzAcc,this.imageurl});

  Mechanic.fromSnapshot(DataSnapshot dataSnapshot)
  {
    name =dataSnapshot.child("mechanic_details").child("mechanic_name").value.toString();
    id = dataSnapshot.key;
    phone =dataSnapshot.child("phone").value.toString();
    email = dataSnapshot.child("email").value.toString();
    Cnic=dataSnapshot.child("mechanic_details").child("mechanic_cnic").value.toString();
    JazzAcc=dataSnapshot.child("mechanic_details").child("mechanic_Account").value.toString();
    imageurl=dataSnapshot.child("mechanic_details").child("mechanic_image").value.toString();



  }
}