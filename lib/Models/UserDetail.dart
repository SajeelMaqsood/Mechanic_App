import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserDetails
{
  String ?User_address;
  LatLng ?userLoc;
  String ?user_request_id;
  // String payment_method;
  String ?User_name;
  String ?User_phone;
  String payment_method="Cash";

  UserDetails({this.User_address,this.userLoc,this.User_name,this.User_phone,this.user_request_id});
 }