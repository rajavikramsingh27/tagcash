import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../bloc/conversation_bloc.dart';
import './chat_profile_about.dart';
import '../widgets/chat_message/zoom_image.dart';
import '../../../../providers/perspective_provider.dart';
import '../../../../models/app_constants.dart' as AppConstants;

class ChatProfile extends StatefulWidget {
  String fullName;
  ConversationBloc bloc;
  ChatProfile(this.fullName, this.bloc);

  @override
  _ChatProfileState createState() => _ChatProfileState();
}

class _ChatProfileState extends State<ChatProfile> {
  File _image;
  bool isuploading = false;

  Future getImagefromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      // maxHeight: 480,
      // maxWidth: 640
    );
    _image = File(pickedFile.path);
    List imageBytes = _image.readAsBytesSync();
    String imageB64 = base64Encode(imageBytes);

    if (_image != null) {
      setState(() {
        isuploading = true;
      });
      var imgUrl = await widget.bloc.uploadImage(imageB64);
      print(imgUrl);
      // var apiObj = {
      //   "to_tagcash_id": this.withUser,
      //   "from_tagcash_id": this.me,
      //   "toDocId": this.withUser,
      //   'doc_id': imgUrl,
      //   "convId": widget.bloc.currentRoom,
      //   "type": 2,
      //   "payload": ''
      // };
      // widget.bloc.sendMessage(apiObj);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                ? Colors.black
                : Colors.blue,
        title: Text('Chat Profile'),
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            child: Container(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ZoomImageScreen(
                                imageUrl: AppConstants.getUserImagePath(),
                                userName: this.widget.fullName)),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      child: ClipOval(
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                            imageUrl: AppConstants.getUserImagePath(),
                            placeholder: (context, url) => Container(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    margin: EdgeInsets.only(left: 30),
                    height: 150,
                    alignment: Alignment.bottomRight,
                    child: Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        // elevation: 0,
                        onPressed: () {
                          getImagefromGallery();
                        },
                        color: Colors.black,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                        ),
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: Icon(
                Icons.account_circle,
                size: 26,
               color: Colors.red,
              ),
            ),
            trailing: Icon(Icons.edit),
            onTap: () {},
            title: Text(
              'Name',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[60]
                  ),
            ),
            subtitle: Text(widget.fullName,
                style: TextStyle(
                  fontSize: 16,
                  // color: Colors.black,
                )),
          ),
          Divider(
            height: 1.0,
          ),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: Icon(
                Icons.info,
                size: 26,
              color: Colors.red,
              ),
            ),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatProfileAbout(),
                ),
              );
            },
            title: Text(
              'About',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[60]),
            ),
            subtitle: Text('Available',
                style: TextStyle(
                  fontSize: 16,
                  // color: Colors.black,
                )),
          ),
          Divider(
            height: 1.0,
          ),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: Icon(
                Icons.supervised_user_circle,
                size: 26,
               color: Colors.red
              ),
            ),
            trailing: Icon(Icons.edit),
            onTap: () {},
            title: Text(
              'Role',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[60]),
            ),
            subtitle: Text('Owner',
                style: TextStyle(
                  fontSize: 16,
                  // color: Colors.black,
                )),
          ),
        ],
      ),
    );
  }
}
