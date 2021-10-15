import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tagcash/apps/agents/agent_apply_screen.dart';
import 'package:tagcash/apps/agents/agent_locations_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/apps/wallet/models/agent.dart';

class AgentLocationsMapScreen extends StatefulWidget {
  @override
  _AgentLocationsMapScreenState createState() =>
      _AgentLocationsMapScreenState();
}

class _AgentLocationsMapScreenState extends State<AgentLocationsMapScreen> {
  bool isLoading = false;
  MapboxMapController controller;

  Future<List<Agent>> agentsListData;

  final globalKey = GlobalKey<ScaffoldState>();
  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  bool nearbyAgentStat = false;
  Agent activeAgent;
  String agentStatus;

  @override
  void initState() {
    super.initState();
    checkLocation();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
      locationAvailable = true;
    });

    agentsListData = agentsListLoad();
    getAgentStatus();
  }

  Future<List<Agent>> agentsListLoad() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    String apiUrl;
    apiBodyObj['lat'] = _locationData.latitude.toString();
    apiBodyObj['lng'] = _locationData.longitude.toString();
    apiUrl = 'Agent/GetNearestAgents';
    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);
    setState(() {
      isLoading = false;
    });

    List responseList = response['result'];
    List<Agent> getData = responseList.map<Agent>((json) {
      return Agent.fromJson(json);
    }).toList();
    for (int i = 0; i < getData.length; i++) {
      addImageFromAsset('assetImage', "assets/images/map_marker.png");

      controller.addSymbol(
          SymbolOptions(
            geometry: LatLng(getData[i].latitude, getData[i].longitude),
            iconImage: 'assetImage',
            iconSize: 1.5,
          ),
          {'sym': getData[i]});
    }
    return getData;
  }

  agentDetailClickHandle(Agent agent) {}

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onSymbolTapped(Symbol symbol) {
    Agent agent = symbol.data['sym'];

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.locationName,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    agent.address,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      getTranslated(context, "max_topup")+' : ${agent.maxTopup}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      getTranslated(context, "max_cashout")+' : ${agent.maxCashout}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: agent.workDetails.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(agent.workDetails[index].day,
                                  style: Theme.of(context).textTheme.subtitle2),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(agent.workDetails[index].fromTime),
                            ),
                            Flexible(
                              flex: 1,
                              child: Text(agent.workDetails[index].toTime),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Text(agent.notes,
                      style: Theme.of(context).textTheme.bodyText2),
                ],
              ),
            ),
          );
        });
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/map_marker.png");

    controller.addSymbol(SymbolOptions(
      geometry: LatLng(activeAgent.latitude, activeAgent.longitude),
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
        title: getTranslated(context, "agents"),
      ),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              locationAvailable
                  ? Expanded(
                      child: MapboxMap(
                        accessToken: AppConstants.mapboxKey,
                        onMapCreated: _onMapCreated,
                        onStyleLoadedCallback: _onStyleLoaded,
                        zoomGesturesEnabled: false,
                        myLocationEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              _locationData.latitude, _locationData.longitude),
                          zoom: 14.0,
                        ),
                      ),
                    )
                  : Expanded(
                      child: Container(
                      color: Colors.blueGrey[200],
                    )),
              (agentStatus != null)
                  ? (agentStatus == 'accepted')
                      ? Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AgentLocationsScreen(),
                                ),
                              );
                            },
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            color: kPrimaryColor,
                            child: Text(getTranslated(context, "my_agent_details"),
                                style: TextStyle(fontSize: 16)),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: RaisedButton(
                            onPressed: () {
                              getKYCLevel();
                            },
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            color: kPrimaryColor,
                            child: Text(getTranslated(context, "become_an_agent"),
                                style: TextStyle(fontSize: 16)),
                          ),
                        )
                  : Container(),
            ],
          ),
          isLoading
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Loading()),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  getAgentStatus() async {
//    setState(() {
//      isLoading = true;
//    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/GetAgentStatus');

    if (response['status'] == 'success') {
      setState(() {
        agentStatus = response['agent_status'];
        //isLoading = false;
      });
    } else {}
    // checkLocation();
  }

  int verificationLevel = 0;

  getKYCLevel() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/GetLevel');

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      verificationLevel = response['result']['verification_level'];
      if (verificationLevel >= 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgentApplyScreen(
                //verificationLevel: verificationLevel,
                ),
          ),
        );
      } else {
        final snackBar = SnackBar(
            content: Text(getTranslated(context, "level_3_verified_agent")),
            duration: const Duration(seconds: 3));
        globalKey.currentState.showSnackBar(snackBar);
      }
    } else {}
  }
}

//class GetAgentStatus extends StatefulWidget {
//  GetAgentStatus({this.onProgress, this.onFailed});
//
//  ValueChanged<bool> onProgress;
//  ValueChanged<bool> onFailed;
//
//  @override
//  _GetAgentStatusState createState() => _GetAgentStatusState();
//}
//
//class _GetAgentStatusState extends State<GetAgentStatus> {
//  String agentStatus;
//  int verificationLevel = 0;
//
//  @override
//  void initState() {
//    super.initState();
//    getAgentStatus();
//  }
//
//
//
//  getKYCLevel() async {
//
//    widget.onProgress(true);
//    Map<String, dynamic> response =
//        await NetworkHelper.request('verification/GetLevel');
//
//    if (response['status'] == 'success') {
//      verificationLevel = response['result']['verification_level'];
//      if (verificationLevel >= 3) {
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => AgentApplyScreen(
//                //verificationLevel: verificationLevel,
//                ),
//          ),
//        );
//      } else {
//        widget.onFailed(true);
//      }
//      widget.onProgress(false);
//    } else {
//      widget.onProgress(false);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return
//  }
//}
