import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechanic_app/Models/UserDetail.dart';

import '../AllWidgets/collectPaymentDialog.dart';
import '../AllWidgets/progressDialog.dart';
import '../Assistants/assistantMethod.dart';
import '../Assistants/mapKitAssistant.dart';
import '../configMap.dart';
import '../main.dart';
import 'chatScreen.dart';


class NewRequestScreen extends StatefulWidget {

  final UserDetails ?userDetails;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  NewRequestScreen({this.userDetails});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newReqGoogleMapController;
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCorOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions = LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;

  Position? myPostion;
  String status = "accepted";
  String durationRide="";
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.black87;
  Timer ?timer;
  var posLatLng;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();

    acceptUserRequest();
  }

  void createIconMarker()
  {
    if(animatingMarkerIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value)
      {
        animatingMarkerIcon = value;
      });
    }
  }

  void getLiveLocUpdates()
  {
    LatLng oldPos = LatLng(0, 0);

    userStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPositon = position;
      myPostion = position;
      LatLng mPostion = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, myPostion!.latitude, myPostion!.latitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPostion,
        icon: animatingMarkerIcon!,
        rotation: rot,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition = new CameraPosition(target: mPostion, zoom: 17);
        newReqGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere((marker)=> marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
      oldPos = mPostion;
      updateReqDetails();

      String userRequestId = widget.userDetails!.user_request_id.toString();
      Map locMap =
      {
        "latitude": currentPositon!.latitude.toString(),
        "longitude": currentPositon!.longitude.toString(),
      };
      newRequestsRef.child(userRequestId).child("mechanic_location").set(locMap);
    });}

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRequestScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markersSet,
            circles: circleSet,
            polylines: polyLineSet,
            onMapCreated: (GoogleMapController controller) async
            {
              _controllerGoogleMap.complete(controller);
              newReqGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265.0;
              });


              var currentLatLng = LatLng(currentPositon!.latitude, currentPositon!.longitude);
              var userLatLng = widget.userDetails!.userLoc;
              print("current");
              print(currentLatLng);
              print("user");
              print(userLatLng);

              await getPlaceDirection(currentLatLng!, userLatLng!);

              getLiveLocUpdates();
            },
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 270.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  children: [

                    Text(
                      durationRide,
                      style: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold", color: Colors.deepPurple),
                    ),

                    SizedBox(height: 16.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.userDetails!.User_name.toString(), style: TextStyle(fontFamily: "Brand Bold", fontSize: 24.0),),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ChatScreen(userDetails: widget.userDetails!,)));

                            },
                              child: Icon(Icons.chat)
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 26.0,),

                    Row(
                      children: [
                        Image.asset("images/location.png", height: 16.0, width: 16.0,),
                        SizedBox(width: 18.0,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userDetails!.User_address.toString(),
                              style: TextStyle(fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 26.0,),


                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child:ElevatedButton(
                        onPressed: ()   {
                          if(status == "accepted")
                          {
                            status = "arrived";
                            String userRequestId = widget.userDetails!.user_request_id.toString();
                            newRequestsRef.child(userRequestId).child("status").set(status);

                            setState(() {
                              btnTitle = "Start Work";
                              btnColor = Colors.purple;
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context)=> ProgressDialog(message: "Please wait...",),
                            );

                            // await getPlaceDirection(widget.rideDetails.pickup, widget.rideDetails.dropoff);

                            Navigator.pop(context);
                          }
                          else if(status == "arrived")
                          {
                            status = "onwork";
                            String userRequestId = widget.userDetails!.user_request_id.toString();
                            newRequestsRef.child(userRequestId).child("status").set(status);

                            setState(() {
                              btnTitle = "End Work";
                              btnColor = Colors.redAccent;
                            });

                            initTimer();
                          }
                          else if(status == "onwork")
                          {
                            endTheTrip();
                          }
                        },
                        style: ButtonStyle(

                          backgroundColor:
                          MaterialStateProperty.all(btnColor),
                          shape: MaterialStateProperty.all(
                            new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(24.0),
                            ),
                          ),
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(btnTitle, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                              Icon(Icons.directions_car, color: Colors.white, size: 26.0,),
                            ],
                          ),
                        ),
                      ),




                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> getPlaceDirection(LatLng pickUpLatLng, LatLng dropOffLatLng) async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",)
    );


    print("This is Points ::");
    print(pickUpLatLng);
    print(dropOffLatLng);
    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    print(details);
    print(details.toString());
    print("This is Encoded Points ::");
    print(details?.encodedPoints.toString());


    Navigator.pop(context);



    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details!.encodedPoints.toString());


    polylineCorOrdinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty)
    {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCorOrdinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylineCorOrdinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude  &&  pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }
    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newReqGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptUserRequest()
  {
    String userRequestId = widget.userDetails!.user_request_id.toString();
    newRequestsRef.child(userRequestId).child("status").set("accepted");
    newRequestsRef.child(userRequestId).child("mechanic_name").set(mechanicInformation!.name);
    newRequestsRef.child(userRequestId).child("mechanic_phone").set(mechanicInformation!.phone);
    newRequestsRef.child(userRequestId).child("mechanic_id").set(mechanicInformation!.id);
    newRequestsRef.child(userRequestId).child("mechanic_image").set(mechanicInformation!.imageurl);

    // mRequestRef.child(userRequestId).child("car_details").set('${driversInformation.car_color} - ${driversInformation.car_model}');

    Map locMap =
    {
      "latitude": currentPositon!.latitude.toString(),
      "longitude": currentPositon!.longitude.toString(),
    };
    newRequestsRef.child(userRequestId).child("mechanic_location").set(locMap);
    mechanicRef.child(currentfirebaseUser!.uid).child("history").child(userRequestId).set(true);
  }

  void updateReqDetails() async
  {
    if(isRequestingDirection == false)
    {
      isRequestingDirection = true;

      if(myPostion == null)
      {
        return;
      }

      posLatLng = LatLng(myPostion!.latitude, myPostion!.longitude);
      LatLng? destinationLatLng;

        destinationLatLng =LatLng(widget.userDetails!.userLoc!.latitude, widget.userDetails!.userLoc!.longitude);


      print(destinationLatLng);

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(posLatLng, destinationLatLng!);
      if(directionDetails != null)
      {
        setState(() {
          durationRide = directionDetails.durationText!;
        });
      }

      isRequestingDirection = false;
    }
  }

  void initTimer()
  {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async
  {
    timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> ProgressDialog(message: "Please wait...",),
    );

    var userLatLng = LatLng(widget.userDetails!.userLoc!.latitude, widget.userDetails!.userLoc!.longitude);

    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(posLatLng, userLatLng);

    Navigator.pop(context);

    int fareAmount = AssistantMethods.calculateFares(directionalDetails!);

    String rideRequestId = widget.userDetails!.user_request_id.toString();
    newRequestsRef.child(rideRequestId).child("fares").set(fareAmount.toString());
    newRequestsRef.child(rideRequestId).child("status").set("ended");
    userStreamSubscription!.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> CollectPaymentDialog(paymentMethod: widget.userDetails!.payment_method, fareAmount: fareAmount,),
    );

    saveEarnings(fareAmount);
  }
  void saveEarnings(int fareAmount)
  {
    mechanicRef.child(currentfirebaseUser!.uid).child("earnings").once().then((value) {

    final DataSnapshot dataSnapShot = value.snapshot;
    if(dataSnapShot.value != null)
    {
      double oldEarnings = double.parse(dataSnapShot.value.toString());
      double totalEarnings = fareAmount + oldEarnings;

      mechanicRef.child(currentfirebaseUser!.uid).child("earnings").set(totalEarnings.toStringAsFixed(2));
    }
    else
    {
      double totalEarnings = fareAmount.toDouble();
      mechanicRef.child(currentfirebaseUser!.uid).child("earnings").set(totalEarnings.toStringAsFixed(2));
    }
  });

  }
}
