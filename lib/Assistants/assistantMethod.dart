import 'dart:async';
import 'dart:io';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:mechanic_app/Assistants/requestAssistant.dart';
import 'package:mechanic_app/DataHandler/appData.dart';
import 'package:mechanic_app/Models/address.dart';
import 'package:mechanic_app/Models/allUsers.dart';
import 'package:mechanic_app/configMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Models/directDetails.dart';
import '../main.dart';

class AssistantMethods
{
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {

    print(initialPosition);
    print(finalPosition);
    print(API_KEY);
    String apiUri="https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$API_KEY";

    final Uri directionUrl = Uri.parse(apiUri);
    // String directionUrl = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$API_KEY");
    var res = await RequestAssistant.getRequest(directionUrl);

    print("REES");
    print(res.toString());

    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static void disableHomeTabLiveLocationUpdates()
  {
    // homeTabPageStreamSubscription.pause();
    homeTabStreamSubscription?.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static void enableHomeTabLiveLocationUpdates()
  {
    homeTabStreamSubscription?.resume();
    Geofire.setLocation(currentfirebaseUser!.uid,currentPositon!.latitude, currentPositon!.longitude);
  }

  static int calculateFares(DirectionDetails directionDetails)
  {

    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    double totalLocalAmount = totalFareAmount * 160;

      return totalLocalAmount.truncate();
  }







}