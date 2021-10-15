import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../bloc/conversation_bloc.dart';
import '../../../models/app_constants.dart' as AppConstants;

class LocationSnippet extends StatefulWidget {
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;
  final dynamic locationdata;
  const LocationSnippet(
      this.bloc, this.withUser, this.me, this.currentRoom, this.locationdata);
  @override
  _LocationSnippetState createState() => _LocationSnippetState();
}

class _LocationSnippetState extends State<LocationSnippet> {
  bool isLoading = false;
  MapboxMapController controller;

  final globalKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  dynamic _locationData;
  bool locationAvailable = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _locationData = widget.locationdata;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/map_marker.png");
    controller.addSymbol(SymbolOptions(
      geometry: LatLng(_locationData['latitude'], _locationData['longitude']),
      iconImage: 'assetImage',
      iconSize: 1.5,
    ));
  }

  //Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        locationAvailable
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MapboxMap(
                      accessToken: AppConstants.mapboxKey,
                      onMapCreated: _onMapCreated,
                      onStyleLoadedCallback: _onStyleLoaded,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_locationData['latitude'],
                            _locationData['longitude']),
                        zoom: 14.0,
                      ),
                    ),
                  ),
                ],
              )
            : Expanded(
                child: Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  color: Colors.blueGrey[200],
                ),
              ),
      ],
    );
  }
}
