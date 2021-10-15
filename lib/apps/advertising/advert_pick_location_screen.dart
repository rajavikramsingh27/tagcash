import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/localization/language_constants.dart';

class AdvertPickLocationScreen extends StatefulWidget {
  @override
  _AdvertPickLocationScreenState createState() =>
      _AdvertPickLocationScreenState();
}

class _AdvertPickLocationScreenState extends State<AdvertPickLocationScreen> {
  bool isLoading = false;
  MapboxMapController controller;

  final globalKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  LocationData _locationData;
  double latitude = 0.0;
  double longitude = 0.0;
  bool locationAvailable = false;

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
    latitude = _locationData.latitude;
    longitude = _locationData.longitude;
    setState(() {
      locationAvailable = true;
    });
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/map_marker.png");

    controller.addSymbol(SymbolOptions(
      geometry: LatLng(_locationData.latitude, _locationData.longitude),
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
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "advertising"),
      ),
      body: Stack(
        overflow: Overflow.visible,
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
                        zoomGesturesEnabled: false,
                        myLocationEnabled: false,
                        onMapClick: (point, LatLng coordinates) {
                          //addMarkerToSelectedPoint(coordinates);
                          latitude = coordinates.latitude;
                          longitude = coordinates.longitude;
//                          addImageFromAsset(
//                              'assetImage', "assets/images/map_marker.png");
                          //controller.clearSymbols();
                          if (controller != null) {
                            controller.removeSymbol(controller.symbols.elementAt(0));
                          }
                          controller.addSymbol(SymbolOptions(
                            geometry: LatLng(
                                coordinates.latitude, coordinates.longitude),
                            iconImage: 'assetImage',
                            iconSize: 1.5,
                          ));
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              _locationData.latitude, _locationData.longitude),
                          zoom: 14.0,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'status': 'success',
                            'latitude': latitude.toString(),
                            'longitude': longitude.toString()
                          });
                        },
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: kPrimaryColor,
                        child: Text(getTranslated(context, "add_location"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                )
              : Expanded(
                  child: Container(
                  color: Colors.blueGrey[200],
                )),
        ],
      ),
    );
  }
}
