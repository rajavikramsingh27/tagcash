import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobx/mobx.dart';

import '../bloc/conversation_bloc.dart';
import '../../../components/app_top_bar.dart';
import '../../../models/app_constants.dart' as AppConstants;

class CurrentLocationScreen extends StatefulWidget {
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;

  CurrentLocationScreen(this.bloc, this.withUser, this.me, this.currentRoom);
  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  bool isLoading = false;
  MapboxMapController controller;

  final globalKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  LocationData _locationData;
  double latitude = 0.0;
  double longitude = 0.0;
  bool locationAvailable = false;
  bool isEnabledShareButton = false;
  @override
  void initState() {
    super.initState();
    checkLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    setState(() {
      isEnabledShareButton = true;
      locationAvailable = true;
    });
    print(_locationData.latitude);
    print(_locationData.longitude);
    latitude = _locationData.latitude;
    longitude = _locationData.longitude;
    setState(() {
      locationAvailable = true;
    });
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  //Adds an asset image to the currently displayed style
  // Future<void> addImageFromAsset(String name, String assetName) async {
  //   final ByteData bytes = await rootBundle.load(assetName);
  //   final Uint8List list = bytes.buffer.asUint8List();
  //   return controller.addImage(name, list);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'SHARE LOCATION',
      ),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          locationAvailable
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: MapboxMap(
                        accessToken: AppConstants.mapboxKey,
                        onMapCreated: _onMapCreated,
                        // onStyleLoadedCallback: _onStyleLoaded,
                        zoomGesturesEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              _locationData.latitude, _locationData.longitude),
                          zoom: 14.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          // SizedBox(
                          //   width: double.infinity,
                          //   child:
                          //   RaisedButton.icon(
                          //     icon: Icon(Icons.location_on),
                          //     onPressed: isEnabledShareButton
                          //         ? () {
                          //             var lat = jsonEncode("latitude");
                          //             var long = jsonEncode("longitude");
                          //             var isLive = jsonEncode("isLive");
                          //             var isCordinate =
                          //                 jsonEncode("isCordinate");
                          //             var isSharing = jsonEncode("isSharing");
                          //             widget.bloc.sendMessage({
                          //               "to_tagcash_id": widget.withUser,
                          //               "from_tagcash_id": widget.me,
                          //               "toDocId": widget.withUser,
                          //               "convId": widget.bloc.currentRoom,
                          //               "type": 7,
                          //               "payload": {
                          //                 lat:
                          //                     _locationData.latitude.toString(),
                          //                 long: _locationData.longitude
                          //                     .toString(),
                          //                 isLive: true.toString(),
                          //                 isCordinate: false.toString(),
                          //                 isSharing: true.toString(),
                          //               }.toString(),
                          //             });
                          //             Navigator.of(context).pop();
                          //             Navigator.of(context).pop();

                          //             // Navigator.of(context).push(
                          //             //   MaterialPageRoute(
                          //             //     builder: (_) => LocationExample(
                          //             //       widget.withUser,
                          //             //       widget.me,
                          //             //       widget.bloc.currentRoom,
                          //             //     ),
                          //             //   ),
                          //             // );
                          //           }
                          //         : null,
                          //     color: Theme.of(context).accentColor,
                          //     textColor: Colors.white,
                          //     padding: const EdgeInsets.all(10.0),
                          //     // color: kPrimaryColor,
                          //     label: const Text(
                          //       'Share live location',
                          //       style: TextStyle(fontSize: 16),
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 5,
                          // ),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton.icon(
                              icon: Icon(Icons.gps_fixed),
                              onPressed: isEnabledShareButton
                                  ? () {
                                      widget.bloc.convStatus =
                                          FutureStatus.pending;
                                      var lat = jsonEncode("latitude");
                                      var long = jsonEncode("longitude");
                                      var isCordinate =
                                          jsonEncode("isCordinate");
                                      var isLive = jsonEncode("isLive");
                                      widget.bloc.sendMessage(
                                        {
                                          "to_tagcash_id": widget.withUser,
                                          "from_tagcash_id": widget.me,
                                          "toDocId": widget.withUser,
                                          "convId": widget.bloc.currentRoom,
                                          "type": 7,
                                          "payload": {
                                            lat: _locationData.latitude
                                                .toString(),
                                            long: _locationData.longitude
                                                .toString(),
                                            isCordinate: false.toString(),
                                            isLive: false.toString(),
                                          }.toString(),
                                        },
                                      );
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      widget.bloc.convStatus =
                                          FutureStatus.fulfilled;
                                    }
                                  : null,
                              color: Theme.of(context).accentColor,
                              textColor: Colors.white,
                              padding: const EdgeInsets.all(10.0),
                              // color: kPrimaryColor,
                              label: const Text(
                                'Send your current location',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      color: Colors.blueGrey[200],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
