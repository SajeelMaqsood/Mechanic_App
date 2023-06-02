// import 'dart:async';
// import 'dart:ffi';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:mechanic_app/AllWidgets/Divider.dart';
// import 'package:mechanic_app/Assistants/assistantMethod.dart';
// import 'package:mechanic_app/DataHandler/appData.dart';
// import 'package:mechanic_app/Pages/loginScreen.dart';
// import 'package:mechanic_app/Pages/searchScreen.dart';
// import 'package:mechanic_app/configMap.dart';
// import 'package:mechanic_app/main.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
//
// class MainScreen extends StatefulWidget {
//   static const String idScreen = 'MainScreen';
//
//   MainScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   final Completer<GoogleMapController> _controllerGoogleMap =
//   Completer<GoogleMapController>();
//
//   GoogleMapController? newGoogleMapController;
//
//   GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
//   LatLng desLocation = LatLng(37.3161, -121.9195);
//
//   Position? currentPositon;
//   String? Address;
//   bool visibility = true;
//
//   var geoLocator = Geolocator();
//
//   double bottomPaddingOfMap = 0;
//   double reqcontHeight=0;
//   double contHeight=300.0;
//
//
//   var _value = 0;
//
//   void displaycont(){
//     setState(() {
//       reqcontHeight=250.0;
//       contHeight=0;
//     });
//     saveUserRequest();
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     AssistantMethods.getCurrentOnlineUserInfo();
//     locatePosition();
//   }
//
//
//
//
//   void saveUserRequest(){
//     var userLoaction = Provider.of<AppData>(context,listen: false).userLocation;
//     Map userlocMap={
//       "latitude" : userLoaction!.latitude.toString(),
//       "longitude" : userLoaction!.longitude.toString(),
//     };
//     Map userinfo={
//       "mechanic_id":"wating",
//       "user_Loc": userlocMap,
//       "created_at": DateTime.now().toString(),
//       "user_name": userCurrentInfo!.name,
//       "user_phone":userCurrentInfo!.phone,
//       "user_address":userLoaction.placeName,
//     };
//     if(_value==0){
//       carUserRef.set(userinfo);}
//     else if(_value==1){
//       bikeUserRef.set(userinfo);
//     }
//   }
//
//
//   void cancelReq()
//   {
//     if(_value==0){
//       carUserRef.remove();}
//     else if(_value==1){
//       bikeUserRef.remove();
//     }
//   }
//
//   restApp(){
//     setState(() {
//
//       reqcontHeight=0;
//       contHeight=300;
//
//     });
//   }
//
//
//   void locatePosition() async {
//     await _determinePosition();
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     currentPositon = position;
//     desLocation = LatLng(currentPositon!.latitude, currentPositon!.longitude);
//     AssistantMethods.searchCoordinateAddress(desLocation, context);
//     setState(() {
//       CameraPosition cameraPosition =
//       CameraPosition(target: desLocation, zoom: 18.0);
//       newGoogleMapController!
//           .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     //Screen design
//     return Scaffold(
//         key: scaffoldkey,
//         drawer: Container(
//           color: Colors.white,
//           width: 255.0,
//           child: Drawer(
//             child: ListView(
//               children: [
//                 //DrawerHeader
//                 Container(
//                   height: 165.0,
//                   child: DrawerHeader(
//                     decoration: BoxDecoration(color: Colors.white),
//                     child: Row(
//                       children: [
//                         Image.asset(
//                           "images/user_icon.png",
//                           height: 65.0,
//                           width: 65.0,
//                         ),
//                         SizedBox(width: 16.0),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               userCurrentInfo!.name.toString(),
//                               style: TextStyle(
//                                   fontSize: 16.0, fontFamily: "Brand-Bold"),
//                             ),
//                             SizedBox(
//                               height: 6.0,
//                             ),
//                             Text("visit Profile"),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 DividerWidget(),
//
//                 SizedBox(height: 12.0),
//
//                 //Drawer body
//                 ListTile(
//                   leading: Icon(Icons.history),
//                   title: Text(
//                     "History",
//                     style: TextStyle(fontSize: 15.0),
//                   ),
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.person),
//                   title: Text(
//                     "Visit profile",
//                     style: TextStyle(fontSize: 15.0),
//                   ),
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.info),
//                   title: Text(
//                     "About",
//                     style: TextStyle(fontSize: 15.0),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: (){
//                     FirebaseAuth.instance.signOut();
//                     Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
//                   },
//                   child: ListTile(
//                     leading: Icon(Icons.logout),
//                     title: Text(
//                       "SignOut",
//                       style: TextStyle(fontSize: 15.0),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             GoogleMap(
//               padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
//               mapType: MapType.normal,
//               initialCameraPosition: CameraPosition(
//                 target: desLocation,
//                 zoom: 18,
//               ),
//               onCameraMove: (CameraPosition? position) {
//                 if (desLocation != position!.target) {
//                   setState(() {
//                     desLocation = position.target;
//                     visibility = false;
//                   });
//                 }
//               },
//               onCameraIdle: () {
//                 print(desLocation);
//                 AssistantMethods.searchCoordinateAddress(desLocation, context);
//                 print('camer idle');
//                 setState(() {
//                   visibility = true;
//                 });
//               },
//               zoomControlsEnabled: false,
//               zoomGesturesEnabled: true,
//               onMapCreated: (GoogleMapController controller) {
//                 _controllerGoogleMap.complete(controller);
//                 newGoogleMapController = controller;
//
//                 setState(() {
//                   bottomPaddingOfMap = 280.0;
//                 });
//               },
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//             ),
//
//             // Positioned(
//             //   top: 460.0,
//             //   right: 25.0,
//             //   child: GestureDetector(
//             //     onTap: () {
//             //       locatePosition();
//             //     },
//             //
//             //     child: Container(
//             //       height: 45.0,
//             //       width: 45.0,
//             //       decoration: BoxDecoration(
//             //         color: Colors.white,
//             //         borderRadius: BorderRadius.circular(30.0),
//             //         border: Border.all(
//             //             width: 2.0,
//             //             color: Colors.grey),
//             //       ),
//             //       child: Icon(
//             //         Icons.my_location,
//             //         size: 30.0,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             Positioned(
//               top: 45.0,
//               left: 22.0,
//               child: GestureDetector(
//                 onTap: () {
//                   scaffoldkey.currentState?.openDrawer();
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(22.0),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black,
//                           blurRadius: 6.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(
//                             0.7,
//                             0.7,
//                           ))
//                     ],
//                   ),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.menu,
//                       color: Colors.black,
//                     ),
//                     radius: 20.0,
//                   ),
//                 ),
//               ),
//             ),
//
//             // Positioned(
//             //   bottom: 0.0,
//             //   right: 0.0,
//             //   left: 0.0,
//             //   child: Container(
//             //     decoration: BoxDecoration(
//             //       color: Colors.white,
//             //       borderRadius: BorderRadius.only(
//             //         topRight: Radius.circular(16.0),
//             //         topLeft: Radius.circular(16.0),
//             //       ),
//             //       boxShadow: [
//             //         BoxShadow(
//             //             color: Colors.black54,
//             //             blurRadius: 16.0,
//             //             spreadRadius: 0.5,
//             //             offset: Offset(
//             //               0.7,
//             //               0.7,
//             //             ))
//             //       ],
//             //     ),
//             //     height: reqcontHeight,
//             //     child: Padding(
//             //       padding: const EdgeInsets.all(30.0),
//             //       child: Column(children: [
//             //         SizedBox(
//             //           height: 12.0,
//             //         ),
//             //         SizedBox(
//             //           width: double.infinity,
//             //           child: ColorizeAnimatedTextKit(
//             //               onTap: () {
//             //                 print("Tap Event");
//             //               },
//             //               text: [
//             //                 "Requesting ...",
//             //                 "Please wait ...",
//             //                 "Finding a Mechanic...",
//             //               ],
//             //               textStyle:
//             //                   TextStyle(
//             //                       fontSize: 55.0,
//             //                       fontFamily: "Signatra"),
//             //               colors: const [
//             //                 Colors.green,
//             //                 Colors.pink,
//             //                 Colors.purple,
//             //                 Colors.blue,
//             //                 Colors.yellow,
//             //                 Colors.red,
//             //                     ],
//             //               textAlign: TextAlign.center,
//             //           ),
//             //         ),
//             //         SizedBox(
//             //           height: 12.0,
//             //         ),
//             //         GestureDetector(
//             //           onTap: (){
//             //             cancelReq();
//             //             restApp();
//             //           },
//             //           child: Container(
//             //             height: 60.0,
//             //             width: 60.0,
//             //             decoration: BoxDecoration(
//             //               color: Colors.white,
//             //               borderRadius: BorderRadius.circular(26.0),
//             //               border: Border.all(
//             //                   width: 2.0,
//             //                   color: Colors.grey),
//             //             ),
//             //             child: Icon(Icons.close),
//             //           ),
//             //         ),
//             //         SizedBox(height: 10.0,),
//             //
//             //         Container(
//             //           width: double.infinity,
//             //           child: Text(
//             //             "Cancel",
//             //             textAlign: TextAlign.center,
//             //             style: TextStyle(fontSize: 12.0),
//             //           ),
//             //
//             //         )
//             //       ]),
//             //     ),
//             //   ),
//             // )
//           ],
//         ));
//   }
//
//   /// Determine the current position of the device.
//   ///
//   /// When the location services are not enabled or permissions
//   /// are denied the `Future` will return an error.
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled don't continue
//       // accessing the position and request users of the
//       // App to enable the location services.
//       return Future.error('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, next time you could try
//         // requesting permissions again (this is also where
//         // Android's shouldShowRequestPermissionRationale
//         // returned true. According to Android guidelines
//         // your App should show an explanatory UI now.
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, handle appropriately.
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     // When we reach here, permissions are granted and we can
//     // continue accessing the position of the device.
//     return await Geolocator.getCurrentPosition();
//   }
//
//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     properties.add(DiagnosticsProperty<GoogleMapController>(
//         'newGoogleMapController', newGoogleMapController));
//     properties.add(DiagnosticsProperty<Geolocator>('geoLocator', geoLocator));
//   }
// }
