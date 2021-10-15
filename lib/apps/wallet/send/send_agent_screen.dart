import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import '../models/agent.dart';

class SendAgentScreen extends StatefulWidget {
  final Wallet wallet;

  const SendAgentScreen({Key key, this.wallet}) : super(key: key);

  @override
  _SendAgentScreenState createState() => _SendAgentScreenState();
}

class _SendAgentScreenState extends State<SendAgentScreen> {
  bool isLoading = false;
  MapboxMapController controller;

  Future<List<Agent>> agentsListData;

  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  bool nearbyAgentStat = false;
  Agent activeAgent;

  @override
  void initState() {
    super.initState();
    checkLocation();
    agentsListData = agentsListLoad();
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
      locationAvailable = true;
    });
  }

  nearbyStatChange(bool value) {
    setState(() {
      nearbyAgentStat = value;
    });
    agentsListData = agentsListLoad();
  }

  Future<List<Agent>> agentsListLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    String apiUrl;
    if (nearbyAgentStat) {
      apiBodyObj['lat'] = _locationData.latitude.toString();
      apiBodyObj['lng'] = _locationData.longitude.toString();
      apiUrl = 'Agent/GetNearestAgents';
    } else {
      apiUrl = 'Agent/GetAllAgentLocations';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    setState(() {
      isLoading = false;
    });
    List responseList = response['result'];

    List<Agent> getData = responseList.map<Agent>((json) {
      return Agent.fromJson(json);
    }).toList();

    return getData;
  }

  agentDetailClickHandle(Agent agent) {
    activeAgent = agent;

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
                      '${getTranslated(context, 'maximum_cashout')} : ${agent.maxCashout}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      height: 200.0,
                      child: MapboxMap(
                        accessToken: AppConstants.mapboxKey,
                        onMapCreated: _onMapCreated,
                        onStyleLoadedCallback: _onStyleLoaded,
                        zoomGesturesEnabled: false,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(agent.latitude, agent.longitude),
                          zoom: 14.0,
                        ),
                      ),
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
                  )
                ],
              ),
            ),
          );
        });
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/custom-icon.png");

    controller.addSymbol(SymbolOptions(
      geometry: LatLng(activeAgent.latitude, activeAgent.longitude),
      iconImage: 'assetImage',
      iconSize: 1.5,
    ));
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          locationAvailable
              ? Row(
                  children: [
                    Checkbox(
                      value: nearbyAgentStat,
                      onChanged: (bool value) {
                        nearbyStatChange(value);
                      },
                    ),
                    Text(getTranslated(context, 'agents_nearby'))
                  ],
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(getTranslated(context, 'visit_agent_for_cash_out')),
          ),
          Expanded(
            child: Container(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: Loading(),
                      ),
                    )
                  : FutureBuilder(
                      future: agentsListData,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Agent>> snapshot) {
                        if (snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(
                                          snapshot.data[index].locationName),
                                      subtitle:
                                          Text(snapshot.data[index].address),

                                      // <WhileString Value="{distance}" Test="IsNotEmpty">
                                      //     <Tag.DistanceDisplay DistanceValue="{distance}" Dock="Right" />
                                      // </WhileString>

                                      onTap: () => agentDetailClickHandle(
                                          snapshot.data[index]),
                                    ),
                                  );
                                },
                              )
                            : SizedBox();
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
