import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechanic_app/Pages/newRequestScreen.dart';

import '../Assistants/assistantMethod.dart';
import '../Models/UserDetail.dart';
import '../Pages/RegistertionScreen.dart';
import '../configMap.dart';
import '../main.dart';

class NotificationDialog extends StatelessWidget
{
  final UserDetails userDetails;

  NotificationDialog({required this.userDetails});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.0),
            Image.asset("images/car.png", width: 150.0,),
            SizedBox(height: 0.0,),
            Text("New Request", style: TextStyle(fontFamily: "Brand Bold", fontSize: 20.0,),),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/location.png", height: 16.0, width: 16.0,),
                      SizedBox(width: 20.0,),
                      Expanded(
                        child: Container(child: Text(userDetails.User_address.toString(), style: TextStyle(fontSize: 18.0),)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),

                ],
              ),
            ),

            SizedBox(height: 15.0),
            Divider(height: 2.0, thickness: 4.0,),
            SizedBox(height: 0.0),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.red)
                            ),
                        ),
                    ),

                    child:  Text(
                      "Cancel".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black
                      ),
                    ),
                  ),

                  SizedBox(width: 25.0),


                  ElevatedButton(
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRequest(context);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.green)
                        ),

                      ),

                    ),

                    child:  Text(
                      "Accept".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRequest(context)
  {

    mRequestRef.once().then((value)
    {
      final DataSnapshot dataSnapShot = value.snapshot;
      String theUserId = "";
      if(dataSnapShot.value != null)
      {
        theUserId = dataSnapShot.value.toString();

      }
      else
      {
        displayToastMessage("Request not exists.", context);
      }
      if(theUserId == userDetails.user_request_id)
      {
        mRequestRef.set("accepted");
        AssistantMethods.disableHomeTabLiveLocationUpdates();
         Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRequestScreen(userDetails: userDetails,)));
      }
      else if(theUserId == "cancelled")
      {
        displayToastMessage("Request has been Cancelled.", context);
      }
      else if(theUserId == "timeout")
      {
        displayToastMessage("Request has time out.", context);
      }
      else
      {
        displayToastMessage("Request not exists.", context);
      }
    });
  }
}