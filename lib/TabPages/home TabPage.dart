import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechanic_app/Models/mechanicDetails.dart';
import 'package:mechanic_app/Pages/RegistertionScreen.dart';
import 'package:mechanic_app/configMap.dart';
import 'package:mechanic_app/main.dart';

import '../Notifications/NotificationServices.dart';

class HomeTabPage extends StatefulWidget {
  HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;


  String mechanicStatusText= "Offline Now - Go Online ";
  Color mechanicStatusColor= Colors.black;
  bool isAvailable=false;

  LatLng desLocation = LatLng(37.3161, -121.9195);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
    getCurrentMechanicInfo();
    assetsAudioPlayer.open(Audio("sound/alert.mp3"));

  }


  void locatePosition() async {
    await _determinePosition();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPositon = position;
    desLocation = LatLng(currentPositon!.latitude, currentPositon!.longitude);
    setState(() {
      CameraPosition cameraPosition =
      CameraPosition(target: desLocation, zoom: 18.0);
      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }
  void getCurrentMechanicInfo()async
  {
    currentfirebaseUser= await FirebaseAuth.instance.currentUser;


    mechanicRef.child(currentfirebaseUser!.uid).once().then((value)
    {
      final DataSnapshot dataSnapShot = value.snapshot;
      if(dataSnapShot.value!=null){

        mechanicInformation=Mechanic.fromSnapshot(dataSnapShot);

      }
          });
    NotificationServices notificationServices=NotificationServices();
    notificationServices.firebaseInit(context);
    notificationServices.requestNotificationPermission();
    notificationServices.getDeviceToken().then((value) {
      print('deviceToken');
      print(value);
      mechanicRef.child(currentfirebaseUser!.uid).child("token").set(value);
    });


  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: desLocation,
            zoom: 18,
          ),
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,

        ),

        // online offline mechanic

        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),
       Positioned(
         top: 60.0,
           left: 0.0,
           right: 0.0,
           child:  Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16.0),
                 child:  ElevatedButton(
                   onPressed: () {


                     if(isAvailable!= true)
                       {
                         makeMechanicOnline();
                         getLocationLiveUpdate();

                         setState(() {
                           mechanicStatusColor=Colors.green;
                           mechanicStatusText="Online Now ";
                           isAvailable=true;
                         });

                         displayToastMessage("you are Online Now. ", context);

                       }
                     else
                       {

                         makeMechanicOffline();

                         setState(() {
                           mechanicStatusColor=Colors.black;
                           mechanicStatusText="Offline Now - Go Online ";
                           isAvailable=false;
                         });

                         displayToastMessage("you are Offline Now. ", context);

                       }


                   },
                   style: ButtonStyle(
                       backgroundColor:
                       MaterialStateProperty.all(mechanicStatusColor),
                       shape: MaterialStateProperty.all(
                           RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(18.0),
                           ))),
                   child: Row(
                     children: [
                       Text(
                         mechanicStatusText,
                         style: TextStyle(
                             fontSize: 18.0,
                             fontFamily: "Brand-Bold",
                             color: Colors.white),
                       ),
                       Icon(Icons.phone_android, color: Colors.white, size: 26.0,)
                     ],
                   ),
                 ),
               ),
             ],

           ),)

      ],
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
  
  void makeMechanicOnline() async{

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPositon = position;
    Geofire.initialize("availableMechanic");
    Geofire.setLocation(currentfirebaseUser!.uid, currentPositon!.latitude, currentPositon!.longitude);
    mRequestRef.set("searching");
    mRequestRef.onValue.listen((event) {

    });
  }

   void getLocationLiveUpdate(){

    homeTabStreamSubscription= Geolocator.getPositionStream().listen((Position position) {
      currentPositon=position;
      if(isAvailable==true){
        Geofire.setLocation(currentfirebaseUser!.uid, position!.latitude, position!.longitude);
      }

      LatLng latLng=LatLng(position.latitude,position.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));

    });

   }
   void makeMechanicOffline(){
     Geofire.removeLocation(currentfirebaseUser!.uid);
     mRequestRef.onDisconnect();
     mRequestRef.remove();
     mRequestRef.set(null);
   }
}
