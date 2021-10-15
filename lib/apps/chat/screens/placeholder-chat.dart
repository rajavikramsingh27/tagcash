import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../bloc/conversation_bloc.dart';
import '../../../models/user_data.dart';

// ignore: must_be_immutable
class PlaceholderChat extends StatelessWidget {
  final String chatServerUrl = "https://chat.tagcash.com/";
  final String videolink = 'https://jitsi.tagcash.com/';
  final String text;
  final String alignMsg;
  final String msg;
  final String docId;
  final String title;
  final int type;
  final Color textColor;
  final Color bgColor;
  final int status;
  final String roomId;
  final String msgId;
  final int senderId;
  final int index;
  ConversationBloc bloc;
  UserData user;
  int id;
  int with_Id;

  PlaceholderChat(
      {this.text,
      this.msg,
      this.alignMsg,
      this.textColor,
      this.bgColor,
      this.type,
      this.docId,
      this.title,
      this.status,
      this.roomId,
      this.msgId,
      this.senderId,
      this.bloc,
      this.id,
      this.index,
      // ignore: non_constant_identifier_names
      this.with_Id});

  String paymentcharge = '1';
  String paymentcurrency = 'PHP';

  _makeContent(context) {
    switch (this.type) {
      case 1:
        return Container(
          alignment: this.alignMsg == 'right'
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SkeletonAnimation(
                  child: Container(
                    height: 25,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[300]),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 2:
        if (this.docId.isNotEmpty) {
          return Container(
              alignment: this.alignMsg == 'right'
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: SkeletonAnimation(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  color: Colors.grey[300],
                  height: 250,
                  width: 350,
                ),
              ));
        } else {
          return Container();
        }
        break;
      case 3:
        if (this.docId.isNotEmpty) {
          return Container(
              alignment: this.alignMsg == 'right'
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: SkeletonAnimation(
                  child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: EdgeInsets.all(1),
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 2,
                    )
                  ],
                ),
                child: Container(
                  color: Colors.grey[300],
                  height: 150,
                  width: 350,
                ),
              )));
        } else {
          return Container();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return this._makeContent(context);
  }
}
