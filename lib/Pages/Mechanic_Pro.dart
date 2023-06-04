import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechanic_app/Pages/MainScreen.dart';
import 'package:mechanic_app/Pages/RegistertionScreen.dart';
import 'package:mechanic_app/configMap.dart';
import 'package:mechanic_app/main.dart';

import '../AllWidgets/Divider.dart';

class MechanicInfo extends StatefulWidget {
  MechanicInfo({Key? key}) : super(key: key);
  static const String idScreen='Mechanic_info';

  @override
  State<MechanicInfo> createState() => _MechanicInfoState();
}

class _MechanicInfoState extends State<MechanicInfo> {
  final _formKey = GlobalKey<FormState>();

  String ?_image;
  String? imageUrl;
  int _value=0;
  TextEditingController NameTextEditingController= TextEditingController();


  final CnicTextEditingController= MaskedTextController(mask: '00000-0000000-0');
  // TextEditingController CnicTextEditingController= TextEditingController();

  final JazzTextEditingController= MaskedTextController(mask: '00000000000');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.0,),
                Stack(
                  children: [
                    _image!= null?
                    ClipRRect(
                        borderRadius:
                        BorderRadius.circular(80),
                        child: Image.file(File(_image!),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover
                        )
                    )
                    :
                    CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 60,
                    ),


                    Positioned(
                      bottom: 0,
                      right: 0,
                      top:92 ,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          _showBottomSheet(context);
                        },
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ],
                ),



                Padding(padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.2, 32.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    Text("Profile Detail", style: TextStyle(fontFamily: "Signatra",fontSize: 24.0),),
                    SizedBox(height: 15.0,),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key:_formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: NameTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Name",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                  labelStyle: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Name";
                                } else if (NameTextEditingController.text.length <
                                    3) {
                                  return "Name length should be more than 3 characters";
                                }
                              },
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(height: 10.0,),

                            TextFormField(
                              controller: CnicTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "CNIC No",
                                  hintText: "12345-1234567-1",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.add_card),
                                  labelStyle: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                  )),
                              validator: (value) {
                                bool CnicValid = RegExp(
                                    r"^[0-9]{5}-[0-9]{7}-[0-9]{1}$")
                                    .hasMatch(value!);
                                if (value!.isEmpty) {
                                  return "Enter CNIC Number";
                                } else if (!CnicValid) {
                                  return "Enter valid CNIC Number";
                                }
                              },
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(height: 10.0,),
                            TextFormField(
                              controller: JazzTextEditingController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  labelText: "Jazzcash Account",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_balance_sharp),
                                  labelStyle: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter JazzCash Account";
                                } else if (JazzTextEditingController.text.length <
                                    11) {
                                  return "Provided Correct Account No";
                                }
                              },
                              style: TextStyle(fontSize: 14.0),
                            ),

                            SizedBox(
                              height: 10.0,
                            ),
                            DividerWidget(),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Categories",
                                    style: TextStyle(
                                        fontSize: 30.0, fontFamily: "Signatra"),
                                  ),
                                  SizedBox(width: 45),
                                  GestureDetector(
                                    onTap: () => setState(() => _value = 0),
                                    child: Container(
                                      height: 56,
                                      width: 56,
                                      color: _value == 0
                                          ? Colors.limeAccent
                                          : Colors.grey[100],
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "images/car1.png",
                                            height: 35.0,
                                            width: 35.0,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "Car",
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 25),
                                  GestureDetector(
                                    onTap: () => setState(() => _value = 1),
                                    child: Container(
                                      height: 56,
                                      width: 56,
                                      color: _value == 1
                                          ? Colors.limeAccent
                                          : Colors.grey[100],
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "images/motorbike1.png",
                                            height: 35.0,
                                            width: 35.0,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "Bike",
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            DividerWidget(),
                            SizedBox(height: 25.0,),

                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  SaveInfo(context);

                                }

                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                              child: Container(
                                height: 50.0,
                                child: Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand-Bold",
                                        color: Colors.white),
                                  ),

                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                  ],
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }


  void SaveProfilepPic() async
  {

    if(_image==null)return;
    String userId=currentfirebaseUser!.uid;
    Reference referenceRoot= FirebaseStorage.instance.ref();
    Reference referenceDirImages=referenceRoot.child("profileImage");


    Reference referenceImageToUpload=referenceDirImages.child(userId);

    try{
      await referenceImageToUpload.putFile(File(_image!));
      imageUrl= await referenceImageToUpload.getDownloadURL();


    }catch(error){

      displayToastMessage(error.toString(), context);

    }


  }

  void SaveInfo(BuildContext context)
  {
    SaveProfilepPic();
    String userId=currentfirebaseUser!.uid;
    String ?mechanicType;
    if(_value==0){

      mechanicType="carMechanic";

    }
    else if(_value==1){
      mechanicType="bikeMechanic";
    }

    if (userId != null) {
    Map mechanicInfo={
      "mechanic_name":NameTextEditingController.text,
      "mechanic_cnic":CnicTextEditingController.text,
      "mechanic_Account":JazzTextEditingController.text,
      "mechanic_Type":mechanicType.toString(),
      "mechanic_image":imageUrl.toString(),
    };

    mechanicRef.child(userId).child("mechanic_details").set(mechanicInfo);
     Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  }}

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
            EdgeInsets.only(top: mq!.height * .03, bottom: mq!.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq!.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq!.width * .3, mq!.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image=image.path;
                          });

                          // APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq!.width * .3, mq!.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image=image.path;
                          });

                          // APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
