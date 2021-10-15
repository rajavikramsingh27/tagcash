// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:live_location/live_location.dart';

// import 'package:location_permissions/location_permissions.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:tagcash/models/app_constants.dart' as AppConstants;

// class LocationExample extends StatefulWidget {
//   @override
//   _LocationExampleState createState() => _LocationExampleState();
// }

// class _LocationExampleState extends State<LocationExample> {
//   double _latitude;
//   double _longitude;

//   /// initialize state.
//   @override
//   void initState() {
//     super.initState();
//     requestLocationPermission();

//     /// On first run the location will be null
//     /// so it called in every 15 seconds to get location
//     LiveLocation.start(15);

//     getLocation();
//   }

//   Future<void> getLocation() async {
//     try {
//       LiveLocation.onChange.listen((values) => setState(() {
//             _latitude = double.tryParse(values.latitude);
//              _longitude = double.tryParse(values.longitude);
//           }));
//     } on PlatformException catch (e) {
//       print('PlatformException $e');
//     }
//   }

//   void requestLocationPermission() async {
//     PermissionStatus permission =
//         await LocationPermissions().requestPermissions();
//     print('permissions: $permission');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Live Location Plugin'),
//           centerTitle: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               MapboxMap(
//                         accessToken: AppConstants.mapboxKey,
//                         // onMapCreated: _onMapCreated,
//                         // onStyleLoadedCallback: _onStyleLoaded,
//                         zoomGesturesEnabled: true,
//                         myLocationEnabled: true,
//                         initialCameraPosition: CameraPosition(
//                           target: LatLng(
//                               _latitude, _longitude),
//                           zoom: 14.0,
//                         ),
//                       ),
//             ],
//             // child:

//             // Center(
//             //     child: Column(
//             //   children: <Widget>[
//             //     // Text('Latitude: $_latitude',
//             //     // style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//             //     // ),
//             //     // Text('Longitude: $_longitude',
//             //     //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//             //     // ),

//             //   ],
//             // )),
//           // ),
//         ),
//       ),
//     ));
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:live_location/live_location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart';
import 'package:location_permissions/location_permissions.dart';

import '../bloc/conversation_bloc.dart';
import '../../../models/app_constants.dart' as AppConstants;


class SenderLiveLocation extends StatefulWidget {
  final String alignMsg;
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;
  // final dynamic locationdata;
  const SenderLiveLocation(
      this.alignMsg, this.bloc, this.withUser, this.me, this.currentRoom);
  @override
  _SenderLiveLocationState createState() => _SenderLiveLocationState();
}

class _SenderLiveLocationState extends State<SenderLiveLocation> {
  double _latitude;
  double _longitude;
  var _lat;
  var _long;

  ConversationBloc _bloc;

  MapboxMapController controller;

  /// initialize state.
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    if (this.widget.alignMsg == 'right') {
      LiveLocation.start(1);
      getLocation();
      startTimerSender();
    } else {
      // this._lat = 31.104815;
      // this._long = 77.173401;
      // LiveLocation.start(1);
      // getLocation();
      startTimerReceiver();
    }
  }

  bool isStopped = false;
  Timer _timer;
  Timer timer;
  bool isTimerStop = false;
  int timeUsed;

  startTimerReceiver() {
    int _start = 1;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) async {
      if (_start == 0) {
        stopTimer(timer, _timer);
        setState(() {
          // this._lat = widget.bloc.isLat;
          // this._long = widget.bloc.isLong;
          this._lat = widget.bloc.isLat;
          this._long = widget.bloc.isLong;
        });

        print('receiver sec over');
        print(widget.bloc.isLat);
        print(_long);
        print('sec over');
        _continueTinmerReceiver();
      } else {
        _start--;
        print('receiver latitude changed');

        print(_lat);
        print(_long);
        if (isStopped) {
          stopTimer(timer, _timer);
        }
      }
    });
  }

  startTimerSender() {
    int _start = 1;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) async {
      if (_start == 0) {
        stopTimer(timer, _timer);
        print('sec over');
        print(_latitude);
        var res = await _sendMessageObj();
        _continueTinmerSender();
      } else {
        _start--;
        print('latitude changed');
        if (isStopped) {
          stopTimer(timer, _timer);
        }
      }
    });
  }

  Future _sendMessageObj() async {
    // print(widget.withUser);
    // print(widget.me);
    // print(widget.bloc.currentRoom);
    // print(_latitude);
    // print(_longitude);

    var lat = jsonEncode("latitude");
    var long = jsonEncode("longitude");
    var isCordinate = jsonEncode("isCordinate");
    widget.bloc.sendMessage({
      "to_tagcash_id": widget.withUser,
      "from_tagcash_id": widget.me,
      "toDocId": widget.withUser,
      "convId": widget.bloc.currentRoom,
      "doc_id": 'locationSharing',
      "type": 7,
      "payload": {
        lat: _latitude.toString(),
        long: _longitude.toString(),
        isCordinate: true.toString()
      }.toString(),
    });
    this._lat = widget.bloc.isLat;
    this._long = widget.bloc.isLong;
  }

  stopTimer(Timer timer, Timer _timer) {
    timer.cancel();
    _timer.cancel();
  }

  _continueTinmerSender() {
    this.startTimerSender();
  }

  _continueTinmerReceiver() {
    this.startTimerReceiver();
  }

  _stopSharing() {
    isStopped = true;
    LiveLocation.stop();
    this.controller.dispose();
    timer.cancel();
    _timer.cancel();
  }

  @override
  dispose() {
    this.controller.dispose();
    timer.cancel();
    _timer.cancel();
    LiveLocation.stop();
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  Future<void> getLocation() async {
    try {
      LiveLocation.onChange.listen((values) => setState(() {
            _latitude = double.tryParse(values.latitude);
            _longitude = double.tryParse(values.longitude);
          }));
    } on PlatformException catch (e) {
      print('error in livelocation $e');
    }
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/map_marker.png");
    controller.addSymbol(SymbolOptions(
      geometry: LatLng(_lat, _long),
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

  void requestLocationPermission() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    print('permissions: $permission');
  }

  @override
  Widget build(BuildContext context) {
    return
        //  MaterialApp(
        //   home:
        Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Text(
            'Latitude: $_lat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          Text(
            'Longitude: $_long',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          _long == null
              ? Container(
                  height: MediaQuery.of(context).size.height -
                      300.0 *
                          0.7, //height: MediaQuery.of(context).size.height -220.0 * 0.7,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                  color: Colors.blueGrey[200],
                )
              : Container(
                  height: MediaQuery.of(context).size.height -
                      300.0 *
                          0.7, //height: MediaQuery.of(context).size.height -220.0 * 0.7,
                  child: MapboxMap(
                    accessToken: AppConstants.mapboxKey,
                    onMapCreated: _onMapCreated,
                    onStyleLoadedCallback:
                        this.widget.alignMsg == 'right' ? null : _onStyleLoaded,
                    zoomGesturesEnabled: true,
                    myLocationEnabled:
                        this.widget.alignMsg == 'right' ? true : false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_lat, _long),
                      zoom: 14.0,
                    ),
                  ),
                ),
          SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text('Stop Sharing'),
                onPressed: _stopSharing),
          ),
        ],
      ),
    );
    // ),
    // );
  }
}
