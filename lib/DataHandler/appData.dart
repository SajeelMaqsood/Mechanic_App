import 'dart:ffi';

import 'package:mechanic_app/Models/address.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier
{

   Address ?userLocation;

   void updateUserLocation(Address userAddress)
  {
    userLocation= userAddress;

    notifyListeners();

  }
}