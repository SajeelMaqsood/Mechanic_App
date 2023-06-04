import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mechanic_app/DataHandler/appData.dart';
import 'package:mechanic_app/Pages/MainScreen.dart';
import 'package:mechanic_app/Pages/Mechanic_Pro.dart';
import 'package:mechanic_app/Pages/RegistertionScreen.dart';
import 'package:mechanic_app/Pages/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mechanic_app/configMap.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  currentfirebaseUser= FirebaseAuth.instance.currentUser;
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{

  await Firebase.initializeApp();
  print(message.notification!.title.toString());
  
}
Size mq=Size(0, 0);

FirebaseFirestore firestore= FirebaseFirestore.instance;

DatabaseReference  userRef= FirebaseDatabase.instance.ref().child("users");
DatabaseReference  mechanicRef= FirebaseDatabase.instance.ref().child("mechanic");
DatabaseReference  mRequestRef= FirebaseDatabase.instance.ref().child("mechanic").child(currentfirebaseUser!.uid).child("newReq");


DatabaseReference newRequestsRef= FirebaseDatabase.instance.ref().child("User Requests");


class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context)=> AppData(),
      child: MaterialApp(
        title: 'Mechanic App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:FirebaseAuth.instance.currentUser== null?LoginScreen.idScreen: MainScreen.idScreen,
        // initialRoute:MechanicInfo.idScreen,

        routes: {
           RegisterationScreen.idScreen: (context)=> RegisterationScreen(),
          LoginScreen.idScreen: (context)=> LoginScreen(),
          MainScreen.idScreen: (context)=> MainScreen(),
          MechanicInfo.idScreen: (context)=>MechanicInfo(),

        },
        debugShowCheckedModeBanner: false,
      ),
    );

  }
}
