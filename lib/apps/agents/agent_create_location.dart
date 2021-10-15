import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:tagcash/apps/agents/agent_pick_location_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/common_methods.dart';
import 'package:tagcash/localization/language_constants.dart';

class AgentCreateScreen extends StatefulWidget {
  final int locationId;

  const AgentCreateScreen({Key key, this.locationId}) : super(key: key);

  @override
  _AgentCreateScreenState createState() => _AgentCreateScreenState();
}

class _AgentCreateScreenState extends State<AgentCreateScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final _formKey1 = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final addressController = TextEditingController();
  final maxTopupController = TextEditingController();
  final maxCashoutController = TextEditingController();
  final notesController = TextEditingController();
  final monStartController = TextEditingController();
  final monEndController = TextEditingController();
  final tueStartController = TextEditingController();
  final tueEndController = TextEditingController();
  final wedStartController = TextEditingController();
  final wedEndController = TextEditingController();
  final thuStartController = TextEditingController();
  final thuEndController = TextEditingController();
  final friStartController = TextEditingController();
  final friEndController = TextEditingController();
  final satStartController = TextEditingController();
  final satEndController = TextEditingController();
  bool _isVisible = true;
  bool _monCheck = false;
  bool _tueCheck = false;
  bool _wedCheck = false;
  bool _thuCheck = false;
  bool _friCheck = false;
  bool _satCheck = false;
  TimeOfDay selectedTimeStartMon = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndMon = TimeOfDay(hour: 21, minute: 00);
  TimeOfDay selectedTimeStartTue = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndTue = TimeOfDay(hour: 21, minute: 00);
  TimeOfDay selectedTimeStartWed = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndWed = TimeOfDay(hour: 21, minute: 00);
  TimeOfDay selectedTimeStartThu = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndThu = TimeOfDay(hour: 21, minute: 00);
  TimeOfDay selectedTimeStartFri = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndFri = TimeOfDay(hour: 21, minute: 00);
  TimeOfDay selectedTimeStartSat = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay selectedTimeEndSat = TimeOfDay(hour: 21, minute: 00);
  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;

  //String locationId;

  @override
  void initState() {
    super.initState();
    monStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartMon.hour, selectedTimeStartMon.minute));
    monEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndMon.hour, selectedTimeEndMon.minute));
    tueStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartTue.hour, selectedTimeStartTue.minute));
    tueEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndTue.hour, selectedTimeEndTue.minute));
    wedStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartWed.hour, selectedTimeStartWed.minute));
    wedEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndWed.hour, selectedTimeEndWed.minute));
    thuStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartThu.hour, selectedTimeStartThu.minute));
    thuEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndThu.hour, selectedTimeEndThu.minute));
    friStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartFri.hour, selectedTimeStartFri.minute));
    friEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndFri.hour, selectedTimeEndFri.minute));
    satStartController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeStartSat.hour, selectedTimeStartSat.minute));
    satEndController.text = CommonMethods.formatTime(DateTime(
        2020, 08, 1, selectedTimeEndSat.hour, selectedTimeEndSat.minute));
    if (widget.locationId > 0) getLocationDetails();
    checkLocation();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    maxCashoutController.dispose();
    maxTopupController.dispose();
    notesController.dispose();
    monStartController.dispose();
    monEndController.dispose();
    tueStartController.dispose();
    tueEndController.dispose();
    wedStartController.dispose();
    wedEndController.dispose();
    thuStartController.dispose();
    thuEndController.dispose();
    friStartController.dispose();
    friEndController.dispose();
    satStartController.dispose();
    satEndController.dispose();
    super.dispose();
  }

  checkLocation() async {
    // _isLoading = true;
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
    latitudeController.text = _locationData.latitude.toString();
    longitudeController.text = _locationData.longitude.toString();
  }

  Future _pickLocationTapped() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AgentPickLocationScreen(),
    ));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          String latitude = results['latitude'];
          String longitude = results['longitude'];
          latitudeController.text = latitude;
          longitudeController.text = longitude;
        }
      });
    }
  }

  void getLocationDetails() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['location_id'] = widget.locationId;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Agent/GetLocationDetailsFromId', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];
      nameController.text = responseMap['location_name'];
      maxTopupController.text = responseMap['max_topup'].toString();
      maxCashoutController.text = responseMap['max_cashout'].toString();
      addressController.text = responseMap['address'];
      latitudeController.text = responseMap['lat'].toString();
      longitudeController.text = responseMap['lng'].toString();
      notesController.text = responseMap['notes'];
      int visibility = 0;
      visibility = responseMap['visibility'];
      if (visibility == 1)
        _isVisible = true;
      else
        _isVisible = false;

      List<WorkDetails> workDetails =
          responseMap['work_details'].map<WorkDetails>((json) {
        return WorkDetails.fromJson(json);
      }).toList();
      for (int i = 0; i < workDetails.length; i++) {
        switch (workDetails[i].day) {
          case "Monday":
            _monCheck = true;
            monStartController.text = workDetails[i].fromTime;
            monEndController.text = workDetails[i].toTime;
            break;
          case "Tuesday":
            _tueCheck = true;
            tueStartController.text = workDetails[i].fromTime;
            tueEndController.text = workDetails[i].toTime;
            break;
          case "Wednesday":
            _wedCheck = true;
            wedStartController.text = workDetails[i].fromTime;
            wedEndController.text = workDetails[i].toTime;
            break;
          case "Thursday":
            _thuCheck = true;
            thuStartController.text = workDetails[i].fromTime;
            thuEndController.text = workDetails[i].toTime;
            break;
          case "Friday":
            _friCheck = true;
            friStartController.text = workDetails[i].fromTime;
            friEndController.text = workDetails[i].toTime;
            break;
          case "Saturday":
            _satCheck = true;
            satStartController.text = workDetails[i].fromTime;
            satEndController.text = workDetails[i].toTime;
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "agents"),
      ),
      body: Stack(children: [
        Container(
          margin: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, "agent_congrats"),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    context, "enter_name_to_display_on_map"),
                                labelText: getTranslated(
                                    context, "name_to_display_on_map"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(context,
                                      "please_enter_name_to_display_on_map");
                                }

                                if (isNumeric(value)) {
                                  return getTranslated(
                                      context, "dont_enter_a_number_as_name");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: CheckboxListTile(
                              //checkColor: Colors.red[600],
                              activeColor: kPrimaryColor,
                              value: _isVisible,
                              title: Text(getTranslated(context, "visibile")),
                              onChanged: (bool value) {
                                setState(() {
                                  _isVisible = value;
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: new Icon(
                              Icons.add_location,
                              size: 36,
                              color: kPrimaryColor,
                            ),
                            highlightColor: Colors.pink,
                            onPressed: () {
                              _pickLocationTapped();
                            },
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: latitudeController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "latitude"),
                                labelText: getTranslated(context, "latitude"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_location");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: longitudeController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "longitude"),
                                labelText: getTranslated(context, "longitude"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_location");
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_address"),
                          labelText: getTranslated(context, "address"),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(
                                context, "please_enter_address");
                          }

                          if (isNumeric(value)) {
                            return getTranslated(
                                context, "dont_enter_a_number_as_address");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: maxTopupController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "max_topup"),
                                labelText: getTranslated(context, "max_topup"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_max_topup");
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              controller: maxCashoutController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "max_cashout"),
                                labelText:
                                    getTranslated(context, "max_cashout"),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslated(
                                      context, "please_enter_max_cashout");
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: notesController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "enter_notes"),
                          labelText: getTranslated(context, "notes"),
                        ),
                        validator: (value) {
                          if (isNumeric(value)) {
                            return getTranslated(
                                context, "dont_enter_a_number_as_notes");
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              activeColor: kPrimaryColor,
                              value: _monCheck,
                              title: Text("Mon"),
                              onChanged: (bool value) {
                                setState(() {
                                  _monCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: monStartController,
                                readOnly: true,
                                enabled: _monCheck,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartMon,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartMon = picked;
                                      monStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartMon.hour,
                                              selectedTimeStartMon.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: monEndController,
                                enabled: _monCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndMon,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndMon = picked;
                                      monEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndMon.hour,
                                              selectedTimeEndMon.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              activeColor: kPrimaryColor,
                              value: _tueCheck,
                              title: Text("Tue"),
                              onChanged: (bool value) {
                                setState(() {
                                  _tueCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: tueStartController,
                                enabled: _tueCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartTue,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartTue = picked;
                                      tueStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartTue.hour,
                                              selectedTimeStartTue.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: tueEndController,
                                enabled: _tueCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndTue,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndTue = picked;
                                      tueEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndTue.hour,
                                              selectedTimeEndTue.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              activeColor: kPrimaryColor,
                              value: _wedCheck,
                              title: Text("Wed"),
                              onChanged: (bool value) {
                                setState(() {
                                  _wedCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: wedStartController,
                                enabled: _wedCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartWed,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartWed = picked;
                                      wedStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartWed.hour,
                                              selectedTimeStartWed.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: wedEndController,
                                enabled: _wedCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndWed,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndWed = picked;
                                      wedEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndWed.hour,
                                              selectedTimeEndWed.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              activeColor: kPrimaryColor,
                              value: _thuCheck,
                              title: Text("Thu"),
                              onChanged: (bool value) {
                                setState(() {
                                  _thuCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: thuStartController,
                                enabled: _thuCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartThu,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartThu = picked;
                                      thuStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartThu.hour,
                                              selectedTimeStartThu.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: thuEndController,
                                enabled: _thuCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndThu,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndThu = picked;
                                      thuEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndThu.hour,
                                              selectedTimeEndThu.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              activeColor: kPrimaryColor,
                              value: _friCheck,
                              title: Text("Fri"),
                              onChanged: (bool value) {
                                setState(() {
                                  _friCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: friStartController,
                                enabled: _friCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartFri,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartFri = picked;
                                      friStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartFri.hour,
                                              selectedTimeStartFri.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: friEndController,
                                enabled: _friCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndFri,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndFri = picked;
                                      friEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndFri.hour,
                                              selectedTimeEndMon.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              //checkColor: Colors.red[600],
                              activeColor: kPrimaryColor,
                              value: _satCheck,
                              title: Text("Sat"),
                              onChanged: (bool value) {
                                setState(() {
                                  _satCheck = value;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: satStartController,
                                enabled: _satCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeStartSat,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeStartSat = picked;
                                      satStartController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeStartSat.hour,
                                              selectedTimeStartSat.minute));
                                    });
                                }),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              getTranslated(context, "to"),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                                controller: satEndController,
                                enabled: _satCheck,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  final TimeOfDay picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTimeEndSat,
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: false),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null)
                                    setState(() {
                                      selectedTimeEndSat = picked;
                                      satEndController.text =
                                          CommonMethods.formatTime(DateTime(
                                              2020,
                                              08,
                                              1,
                                              selectedTimeEndSat.hour,
                                              selectedTimeEndSat.minute));
                                    });
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.all(0),
                              //checkColor: Colors.red[600],
                              activeColor: kPrimaryColor,
                              value: false,
                              title: Text("Sun"),
                              controlAffinity: ListTileControlAffinity
                                  .leading, //  <-- leading Checkbox
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 7,
                            child: Text(getTranslated(context, "closed")),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text(getTranslated(context, "save")),
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_formKey1.currentState.validate()) {
                              saveAgentLocationHandler();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: Loading()))
            : SizedBox(),
      ]),
    );
  }

  saveAgentLocationHandler() async {
    DateTime monStart = DateTime(
        2020, 08, 1, selectedTimeStartMon.hour, selectedTimeStartMon.minute);
    DateTime monEnd = DateTime(
        2020, 08, 1, selectedTimeEndMon.hour, selectedTimeEndMon.minute);

    if (!_monCheck &&
        !_tueCheck &&
        !_wedCheck &&
        !_thuCheck &&
        !_friCheck &&
        !_satCheck) {
      showSnackBar(getTranslated(context, "please_check_weekday"));
      return;
    }

    if (_monCheck && !monStart.isBefore(monEnd)) {
      showSnackBar(getTranslated(context, "on_monday_time"));
      return;
    }
    DateTime tueStart = DateTime(
        2020, 08, 1, selectedTimeStartTue.hour, selectedTimeStartTue.minute);
    DateTime tueEnd = DateTime(
        2020, 08, 1, selectedTimeEndTue.hour, selectedTimeEndTue.minute);

    if (_tueCheck && !tueStart.isBefore(tueEnd)) {
      showSnackBar(getTranslated(context, "on_tuesday_time"));
      return;
    }
    DateTime wedStart = DateTime(
        2020, 08, 1, selectedTimeStartWed.hour, selectedTimeStartWed.minute);
    DateTime wedEnd = DateTime(
        2020, 08, 1, selectedTimeEndWed.hour, selectedTimeEndWed.minute);

    if (_wedCheck && !wedStart.isBefore(wedEnd)) {
      showSnackBar(getTranslated(context, "on_wednesday_time"));
      return;
    }
    DateTime thuStart = DateTime(
        2020, 08, 1, selectedTimeStartThu.hour, selectedTimeStartThu.minute);
    DateTime thuEnd = DateTime(
        2020, 08, 1, selectedTimeEndThu.hour, selectedTimeEndThu.minute);

    if (_thuCheck && !thuStart.isBefore(thuEnd)) {
      showSnackBar(getTranslated(context, "on_thursday_time"));
      return;
    }
    DateTime friStart = DateTime(
        2020, 08, 1, selectedTimeStartFri.hour, selectedTimeStartFri.minute);
    DateTime friEnd = DateTime(
        2020, 08, 1, selectedTimeEndFri.hour, selectedTimeEndFri.minute);

    if (_friCheck && !friStart.isBefore(friEnd)) {
      showSnackBar(getTranslated(context, "on_friday_time"));
      return;
    }
    DateTime satStart = DateTime(
        2020, 08, 1, selectedTimeStartSat.hour, selectedTimeStartSat.minute);
    DateTime satEnd = DateTime(
        2020, 08, 1, selectedTimeEndSat.hour, selectedTimeEndSat.minute);

    if (_satCheck && !satStart.isBefore(satEnd)) {
      showSnackBar(getTranslated(context, "on_saturday_time"));
      return;
    }

    List<String> daysArr = [];
    if (_monCheck) {
      String strMon = '{' +
          '"day":"Monday","fromTime":"' +
          monStartController.text +
          '","toTime":"' +
          monEndController.text +
          '"}';
      daysArr.add(strMon);
    }
    if (_tueCheck) {
      String strTue = '{' +
          '"day":"Tuesday","fromTime":"' +
          tueStartController.text +
          '","toTime":"' +
          tueEndController.text +
          '"}';
      daysArr.add(strTue);
    }
    if (_wedCheck) {
      String strWed = '{' +
          '"day":"Wednesday","fromTime":"' +
          wedStartController.text +
          '","toTime":"' +
          wedEndController.text +
          '"}';
      daysArr.add(strWed);
    }
    if (_thuCheck) {
      String strThu = '{' +
          '"day":"Thursday","fromTime":"' +
          thuStartController.text +
          '","toTime":"' +
          thuEndController.text +
          '"}';
      daysArr.add(strThu);
    }
    if (_friCheck) {
      String strFri = '{' +
          '"day":"Friday","fromTime":"' +
          friStartController.text +
          '","toTime":"' +
          friEndController.text +
          '"}';
      daysArr.add(strFri);
    }
    if (_satCheck) {
      String strSat = '{' +
          '"day":"Saturday","fromTime":"' +
          satStartController.text +
          '","toTime":"' +
          satEndController.text +
          '"}';
      daysArr.add(strSat);
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['work_details'] = daysArr.toString();
    apiBodyObj['address'] = addressController.text.toString();
    apiBodyObj['lat'] = latitudeController.text.toString();
    apiBodyObj['lng'] = longitudeController.text.toString();
    apiBodyObj['location_name'] = nameController.text.toString();
    apiBodyObj['max_topup'] = maxTopupController.text.toString();
    apiBodyObj['max_cashout'] = maxCashoutController.text.toString();
    if (notesController.toString() != "")
      apiBodyObj['notes'] = notesController.text.toString();
    if (_isVisible)
      apiBodyObj['visibility'] = "1";
    else
      apiBodyObj['visibility'] = "0";
    Map<String, dynamic> response;
    if (widget.locationId > 0) {
      apiBodyObj['update_id'] = widget.locationId.toString();
      response =
          await NetworkHelper.request('Agent/UpdateAgentLocation', apiBodyObj);
    } else
      response = await NetworkHelper.request('Agent/AddLocations', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      //showSnackBar("Agent Location details added successfully");
      if (widget.locationId > 0)
        Navigator.of(context).pop({'status': 'updateSuccess'});
      else
        Navigator.of(context).pop({'status': 'createSuccess'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "permission_denied") {
        err = getTranslated(context, "permission_denied");
      } else if (response['error'] == "logged_user_is_not_a_verified_agent") {
        err = getTranslated(context, "logged_in_user_not_agent");
      } else if (response['error'] == "failed_to_add_agent_location") {
        err = getTranslated(context, "failed_add_agent_location");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "failed_to_update_agent_details") {
        err = getTranslated(context, "failed_update_agent_location");
      } else if (response['error'] == "update_id_not_found") {
        err = getTranslated(context, "update_id_not_found");
      } else {
        err = getTranslated(context, "an_error_ocured");
      }
      showSnackBar(err);
    }
  }

  showSnackBar(String message) {
    globalKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}

class WorkDetails {
  String day;
  String fromTime;
  String toTime;

  WorkDetails({this.day, this.fromTime, this.toTime});

  WorkDetails.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
  }
}
