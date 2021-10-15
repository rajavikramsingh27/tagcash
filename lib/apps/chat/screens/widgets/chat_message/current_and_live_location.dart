import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/conversation_bloc.dart';
import '../../location-snippet.dart';
import '../../sender-live-location-on-receiver.dart';
import '../../sender-live-location.dart';

// ignore: must_be_immutable
class CurrentAndLiveLocation extends StatefulWidget {
  final String alignMsg;
  final String address;
  ConversationBloc bloc;
  int withId;
  int id;
  dynamic latlongObj;
  dynamic latLongLiveObj;
  final String date;

  CurrentAndLiveLocation(this.alignMsg, this.address, this.bloc, this.withId,
      this.id, this.latlongObj, this.latLongLiveObj, this.date);
  @override
  _CurrentAndLiveLocationState createState() => _CurrentAndLiveLocationState();
}

class _CurrentAndLiveLocationState extends State<CurrentAndLiveLocation> {
  bool isLocationEnded = false;
  String address = '';

  _launchMaps(latlongObj) async {
    String url =
        'https://www.google.com/maps/search/?api=1&query=${latlongObj['latitude']},${latlongObj['longitude']}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 500.0,
            child: widget.latLongLiveObj['isLive'] == true
                ? Card(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Container(
                              width: double.infinity,
                              // height: 200.0,
                              child: InkWell(
                                onTap: () {
                                  // ignore: unnecessary_statements
                                  isLocationEnded
                                      ? null
                                      : widget.alignMsg == 'left'
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SenderLiveLocationOnReceiver(
                                                        widget.bloc),
                                              ),
                                            )
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SenderLiveLocation(
                                                  this.widget.alignMsg,
                                                  this.widget.bloc,
                                                  this.widget.withId,
                                                  this.widget.id,
                                                  this.widget.bloc.currentRoom,
                                                ),
                                              ),
                                            );
                                },
                                child: Column(
                                  children: [
                                    CachedNetworkImage(
                                      height: 150,
                                      width: 400,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          'https://i1.wp.com/insightpropertygroup.com/wp-content/uploads/map-bg-blur.jpg?fit=1600%2C584&ssl=1',
                                      placeholder: (context, url) => Container(
                                          height: 150,
                                          width: 300,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        isLocationEnded
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'Live location ended',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  // color: Theme.of(context).accentColor,
                                  onPressed: () {
                                    setState(() {
                                      var lat = jsonEncode("latitude");
                                      var long = jsonEncode("longitude");
                                      var isCordinate =
                                          jsonEncode("isCordinate");
                                      widget.bloc.sendMessage({
                                        "to_tagcash_id": widget.withId,
                                        "from_tagcash_id": widget.id,
                                        "toDocId": widget.withId,
                                        "convId": widget.bloc.currentRoom,
                                        "doc_id": 'locationSharing',
                                        "type": 7,
                                        "payload": {
                                          lat: null.toString(),
                                          long: null.toString(),
                                          isCordinate: true.toString()
                                        }.toString(),
                                      });
                                    });
                                  },
                                  child: Text(
                                    'Stop Sharing',
                                  ),
                                ),
                              )
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      _launchMaps(widget.latlongObj);
                    },
                    child: Stack(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  child: LocationSnippet(
                                      this.widget.bloc,
                                      this.widget.withId,
                                      this.widget.id,
                                      this.widget.bloc.currentRoom,
                                      widget.latlongObj),
                                ),
                              ),
                              !kIsWeb
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      child: Column(
                                        children: [
                                          Text(
                                            widget.address,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.blue),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            widget.address,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed: () {
                                            _launchMaps(widget.latlongObj);
                                          },
                                          child: Text('View Full Map'),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                        Positioned(
                          child: Text(
                            widget.date,
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          right: 10,
                          bottom: 10,
                        ),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
