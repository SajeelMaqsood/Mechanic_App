import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Models/UserDetail.dart';
import '../configMap.dart';
import '../main.dart';
import 'notificationDialog.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");

    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {

        });
  }


  void firebaseInit(BuildContext context) {



    FirebaseMessaging.onMessage.listen((message) {
      print("reqid");
      print(getUserRequestId(message));
      //AndroidNotification ? android=message.notification!.android;
      if (kDebugMode) {

        print(message.notification!.title.toString());
        print(message.notification!.body.toString());

        retrieveUserRequestInfo(getUserRequestId(message),context);

        //getRideRequestId(message as Map<String, dynamic>);
      }
      if(Platform.isAndroid){
      initLocalNotifications(context, message);
      showNotification(message);}
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {

        print(message.notification!.title.toString());
        print(message.notification!.body.toString());

        retrieveUserRequestInfo(getUserRequestId(message),context);

        //getRideRequestId(message as Map<String, dynamic>);
      }
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);}
    });

  }
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High importance Notification',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'Your channel Description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted provisional permission");
    } else {
      print("user denied permission");
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    // messaging.subscribeToTopic("allmechanic");
    // messaging.subscribeToTopic("allusers");
    return token!;
  }


  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
  String getUserRequestId(RemoteMessage message)
  {
    String userRequestId = "";
    userRequestId =message.data["user_request_id"].toString();
    print(userRequestId);
    return userRequestId;
  }

  void retrieveUserRequestInfo(String userRequestId,BuildContext context)
  {
    newRequestsRef.child(userRequestId).once().then((value)
    {
      final DataSnapshot dataSnapShot = value.snapshot;

      if(dataSnapShot.value != null)
      {



        assetsAudioPlayer.play();

        double userLocationLat = double.parse(dataSnapShot.child('user_Loc').child('latitude').value.toString());
        double userLocationLng = double.parse(dataSnapShot.child('user_Loc').child('longitude').value.toString());
        String userAddress = dataSnapShot.child('user_address').value.toString();

        // String paymentMethod = dataSnapShot.value['payment_method'].toString();

        String User_name = dataSnapShot.child('user_name').value.toString();
        String User_phone = dataSnapShot.child('user_phone').value.toString();

        UserDetails userDetails = UserDetails();
        userDetails.user_request_id = userRequestId;
        userDetails.User_address = userAddress;
        userDetails.userLoc = LatLng(userLocationLat, userLocationLng);
        // userDetails.payment_method = paymentMethod;
        userDetails.User_name = User_name;
        userDetails.User_phone = User_phone;

        print("Information :: ");
        print(userDetails.User_address);


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(userDetails: userDetails,),
        );
      }
    });
  }

}
