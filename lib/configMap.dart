import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechanic_app/Models/mechanicDetails.dart';

import 'Models/allUsers.dart';

String API_KEY='AIzaSyA06urkWllGfrZwsKHSomPfZvYKhs8z7v0';

User? firebaseUser;
User? currentfirebaseUser;
Users ?userCurrentInfo=Users();


StreamSubscription<Position> ?homeTabStreamSubscription;
StreamSubscription<Position> ?userStreamSubscription;

final assetsAudioPlayer= AssetsAudioPlayer();
Position? currentPositon;

Mechanic ?mechanicInformation=Mechanic();