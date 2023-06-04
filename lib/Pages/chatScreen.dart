import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../AllWidgets/message_card.dart';

import '../Models/UserDetail.dart';
import '../Models/message.dart';
import '../main.dart';
import 'RegistertionScreen.dart';


class ChatScreen extends StatefulWidget {
  // const ChatScreen({Key? key}) : super(key: key);
  final UserDetails userDetails;
  ChatScreen ({required this.userDetails});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // List<Message> _list = [];

  List<Message> _messages = [];
  String ?userRequestId;
  String ?_image;
  String? imageUrl;
  TextEditingController _textController =TextEditingController();
  // String reciverId=mechanicId.toString();
  String currentUser= FirebaseAuth.instance.currentUser!.uid.toString();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Listen for new messages
    userRequestId = widget.userDetails!.user_request_id.toString();
    newRequestsRef.child(userRequestId!).child("messages").onChildAdded.listen((event) {
      setState(() {
        Message message=Message();
        // DataSnapshot snapshot=event.snapshot;
        // Map<String,dynamic>messageMap=snapshot.value;
        if(event.snapshot.value == null){
          return;
        }
        if(event.snapshot.child("message").value!= null)
        {
          message.msg=event.snapshot.child("message").value.toString();
        }
        if(event.snapshot.child("sender").value!= null)
        {
          message.senderId=event.snapshot.child("sender").value.toString();
        }
        if(event.snapshot.child("timestamp").value!= null)
        {
          message.timeStamp=event.snapshot.child("timestamp").value.toString();
        }if(event.snapshot.child("type").value!= null)
        {
          message.type=event.snapshot.child("type").value.toString();
        }
        _messages.add(message);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(context),
        ),

        backgroundColor: const Color.fromARGB(255, 234, 248, 255),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  if(_messages.isNotEmpty){
                      return MessageCard(message: _messages[index]);
                  // return ListTile(
                  //   title: Text('Message:${_messages[index].msg}'),
                  // );
                  }
                  else{
                    return const Center(
                                      child: Text('Say Hii! 👋',
                                          style: TextStyle(fontSize: 20)),
                                    );

                  }

                  //
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
          return Row(
            children: [
              //back button
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                  const Icon(Icons.arrow_back, color: Colors.black54)),

              //user profile picture
          widget.userDetails.User_photo!=null?


              CachedNetworkImage(
                imageUrl: widget.userDetails.User_photo.toString(),
                imageBuilder: (context, imageProvider) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                )
              :
          const CircleAvatar(
          child: Icon(CupertinoIcons.person)),

              //for adding some space
              const SizedBox(width: 10),

              //user name & last seen time
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //user name
                  Text(widget.userDetails.User_name.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),

                  //for adding some space
                  const SizedBox(height: 2),


                ],
              )
            ],
          );
  }
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: 'Type Something...',
                            hintStyle: TextStyle(color: Colors.blueAccent),
                            border: InputBorder.none),
                      )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                            SendPic();

                          });
                        }

                        // Picking multiple images
                        // final List<XFile> images =
                        // await picker.pickMultiImage(imageQuality: 70);
                        //
                        //
                        //
                        // // uploading & sending image one by one
                        // for (var i in images) {
                        //   log('Image Path: ${i.path}');
                        //   setState(() => _isUploading = true);
                        //   await APIs.sendChatImage(widget.user, File(i.path));
                        //   setState(() => _isUploading = false);
                        // }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                            SendPic();

                          });
                        }
                        // final ImagePicker picker = ImagePicker();
                        //
                        // // Pick an image
                        // final XFile? image = await picker.pickImage(
                        //     source: ImageSource.camera, imageQuality: 70);
                        // if (image != null) {
                        //   log('Image Path: ${image.path}');
                        //   setState(() => _isUploading = true);
                        //
                        //   await APIs.sendChatImage(
                        //       widget.user, File(image.path));
                        //   setState(() => _isUploading = false);
                        // }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () {
              sendMessage();
            },
            minWidth: 0,
            padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  void sendMessage(){
    if (_textController.text.isNotEmpty) {
      final timeStamp= DateTime.now().millisecondsSinceEpoch.toString();
      Map chatinfo={
        'message':_textController.text.toString(),
        'sender':currentUser,
        'type':'text',
        'timeStamp': timeStamp.toString(),
      };

      newRequestsRef.child(userRequestId!).child("messages").push().set(chatinfo).then((value){
        _textController.clear();
      });
    }
  }
  void SendPic() async
  {

    if(_image==null)return;
    String userId=currentUser;
    Reference referenceRoot= FirebaseStorage.instance.ref();
    Reference referenceDirImages=referenceRoot.child("chatimage");


    Reference referenceImageToUpload=referenceDirImages.child(userId);

    try{
      await referenceImageToUpload.putFile(File(_image!));
      imageUrl= await referenceImageToUpload.getDownloadURL();
      if (imageUrl!.isNotEmpty) {
        final timeStamp= DateTime.now().millisecondsSinceEpoch.toString();
        Map chatinfo={
          'message':imageUrl,
          'sender':currentUser,
          'type':'image',
          'timeStamp': timeStamp.toString(),
        };

        newRequestsRef.child(userRequestId!).child("messages").push().set(chatinfo).then((value){
          _textController.clear();
        });
      }




    }catch(error){

      displayToastMessage(error.toString(), context);

    }


  }
}
