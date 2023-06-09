import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/message.dart';
import '../main.dart';
class MessageCard extends StatefulWidget {
  Message message;

  MessageCard({Key? key,required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();

}

class _MessageCardState extends State<MessageCard> {

  String currentUser= FirebaseAuth.instance.currentUser!.uid.toString();
  @override
  Widget build(BuildContext context) {
    bool isMe =currentUser== widget.message.senderId;
    return InkWell(
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == 'image'
                    ? 9
                    : 8),
            margin: EdgeInsets.symmetric(
                horizontal: 50, vertical: 10),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type== 'text'?

            //show text
            Text(
              widget.message.msg.toString(),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
            :

            // show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onTap: (){
                  final imageProvider = Image.network(widget.message.msg.toString()).image;
                  showImageViewer(context, imageProvider, onViewerDismissed: () {
                    print("dismissed");
                  });
                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg.toString(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
            ),

          ),
        ),

        //message time
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
                widget.message.type == 'image'
                ? 9
                : 8
            ),
            margin: EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type== 'text'
                ?
            //show text
            Text(
              widget.message.msg.toString(),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :
            //show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onTap: (){
                  final imageProvider = Image.network(widget.message.msg.toString()).image;
                  showImageViewer(context, imageProvider, onViewerDismissed: () {
                    print("dismissed");
                  });
                },
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg.toString(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // // bottom sheet for modifying message details
  // void _showBottomSheet(bool isMe) {
  //   showModalBottomSheet(
  //       context: context,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(20), topRight: Radius.circular(20))),
  //       builder: (_) {
  //         return ListView(
  //           shrinkWrap: true,
  //           children: [
  //             //black divider
  //             Container(
  //               height: 4,
  //               margin: EdgeInsets.symmetric(
  //                   vertical: mq.height * .015, horizontal: mq.width * .4),
  //               decoration: BoxDecoration(
  //                   color: Colors.grey, borderRadius: BorderRadius.circular(8)),
  //             ),
  //
  //             widget.message.type == Type.text
  //                 ?
  //             //copy option
  //             _OptionItem(
  //                 icon: const Icon(Icons.copy_all_rounded,
  //                     color: Colors.blue, size: 26),
  //                 name: 'Copy Text',
  //                 onTap: () async {
  //                   await Clipboard.setData(
  //                       ClipboardData(text: widget.message.msg))
  //                       .then((value) {
  //                     //for hiding bottom sheet
  //                     Navigator.pop(context);
  //
  //                     Dialogs.showSnackbar(context, 'Text Copied!');
  //                   });
  //                 })
  //                 :
  //             //save option
  //             _OptionItem(
  //                 icon: const Icon(Icons.download_rounded,
  //                     color: Colors.blue, size: 26),
  //                 name: 'Save Image',
  //                 onTap: () async {
  //                   try {
  //                     log('Image Url: ${widget.message.msg}');
  //                     await GallerySaver.saveImage(widget.message.msg,
  //                         albumName: 'We Chat')
  //                         .then((success) {
  //                       //for hiding bottom sheet
  //                       Navigator.pop(context);
  //                       if (success != null && success) {
  //                         Dialogs.showSnackbar(
  //                             context, 'Image Successfully Saved!');
  //                       }
  //                     });
  //                   } catch (e) {
  //                     log('ErrorWhileSavingImg: $e');
  //                   }
  //                 }),
  //
  //             //separator or divider
  //             if (isMe)
  //               Divider(
  //                 color: Colors.black54,
  //                 endIndent: mq.width * .04,
  //                 indent: mq.width * .04,
  //               ),
  //
  //             //edit option
  //             if (widget.message.type == Type.text && isMe)
  //               _OptionItem(
  //                   icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
  //                   name: 'Edit Message',
  //                   onTap: () {
  //                     //for hiding bottom sheet
  //                     Navigator.pop(context);
  //
  //                     _showMessageUpdateDialog();
  //                   }),
  //
  //             //delete option
  //             if (isMe)
  //               _OptionItem(
  //                   icon: const Icon(Icons.delete_forever,
  //                       color: Colors.red, size: 26),
  //                   name: 'Delete Message',
  //                   onTap: () async {
  //                     await APIs.deleteMessage(widget.message).then((value) {
  //                       //for hiding bottom sheet
  //                       Navigator.pop(context);
  //                     });
  //                   }),
  //
  //             //separator or divider
  //             Divider(
  //               color: Colors.black54,
  //               endIndent: mq.width * .04,
  //               indent: mq.width * .04,
  //             ),
  //
  //             //sent time
  //             _OptionItem(
  //                 icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
  //                 name:
  //                 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
  //                 onTap: () {}),
  //
  //             //read time
  //             _OptionItem(
  //                 icon: const Icon(Icons.remove_red_eye, color: Colors.green),
  //                 name: widget.message.read.isEmpty
  //                     ? 'Read At: Not seen yet'
  //                     : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
  //                 onTap: () {}),
  //           ],
  //         );
  //       });
  // }
  //
  // //dialog for updating message content
  // void _showMessageUpdateDialog() {
  //   String updatedMsg = widget.message.msg;
  //
  //   showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         contentPadding: const EdgeInsets.only(
  //             left: 24, right: 24, top: 20, bottom: 10),
  //
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20)),
  //
  //         //title
  //         title: Row(
  //           children: const [
  //             Icon(
  //               Icons.message,
  //               color: Colors.blue,
  //               size: 28,
  //             ),
  //             Text(' Update Message')
  //           ],
  //         ),
  //
  //         //content
  //         content: TextFormField(
  //           initialValue: updatedMsg,
  //           maxLines: null,
  //           onChanged: (value) => updatedMsg = value,
  //           decoration: InputDecoration(
  //               border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(15))),
  //         ),
  //
  //         //actions
  //         actions: [
  //           //cancel button
  //           MaterialButton(
  //               onPressed: () {
  //                 //hide alert dialog
  //                 Navigator.pop(context);
  //               },
  //               child: const Text(
  //                 'Cancel',
  //                 style: TextStyle(color: Colors.blue, fontSize: 16),
  //               )),
  //
  //           //update button
  //           MaterialButton(
  //               onPressed: () {
  //                 //hide alert dialog
  //                 Navigator.pop(context);
  //                 APIs.updateMessage(widget.message, updatedMsg);
  //               },
  //               child: const Text(
  //                 'Update',
  //                 style: TextStyle(color: Colors.blue, fontSize: 16),
  //               ))
  //         ],
  //       ));
  // }
}
