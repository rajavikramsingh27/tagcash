import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/conversation_bloc.dart';

class SenderLiveLocationOnReceiver extends StatefulWidget {
  ConversationBloc bloc;
  SenderLiveLocationOnReceiver(this.bloc);

  @override
  _SenderLiveLocationOnReceiverState createState() =>
      _SenderLiveLocationOnReceiverState();
}

class _SenderLiveLocationOnReceiverState
    extends State<SenderLiveLocationOnReceiver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('widget.title'),
        ),
        body: LeafletMap(widget.bloc));
  }
}

class LeafletMap extends StatefulWidget {
  ConversationBloc bloc;
  LeafletMap(this.bloc);
  @override
  _LeafletMapState createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> {
  void initState() {
    startTimerReceiver();
    super.initState();
  }

  bool isStopped = false;
  Timer _timer;
  Timer timer;
  bool isTimerStop = false;
  int timeUsed;
  var _lat;
  var _long;

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
        print(_long);
        print(_long);

        print(_long);
        print(_long);
        print(_long);
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

  stopTimer(Timer timer, Timer _timer) {
    timer.cancel();
    _timer.cancel();
  }

  _continueTinmerReceiver() {
    this.startTimerReceiver();
  }

  @override
  Widget build(BuildContext context) {
    return widget.bloc.isLat == null
        ? Text('hi')
        : Column(
            children: [
              Text('${widget.bloc.isLat}'),
              Container(
                height: 400,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(_lat, _long),
                    zoom: 17.0,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                            width: 30.0,
                            height: 30.0,
                            point: new LatLng(_lat, _long),
                            builder: (ctx) => MyWidget()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("MyWidget.build()");
    return Image.network(
        'https://cdn2.iconfinder.com/data/icons/social-media-8/128/pointer.png');
  }
}
