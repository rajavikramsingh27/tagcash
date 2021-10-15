import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/pin_verify.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/device.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class LinkDevicesScreen extends StatefulWidget {
  const LinkDevicesScreen({Key key}) : super(key: key);

  @override
  _LinkDevicesScreenState createState() => _LinkDevicesScreenState();
}

class _LinkDevicesScreenState extends State<LinkDevicesScreen> {
  Future<List<Device>> devicesList;
  bool isLoading = false;
  bool multipleDevice = false;

  List<Device> deleteDevices = [];

  @override
  void initState() {
    super.initState();

    devicesList = loadDevicesList();
  }

  Future<List<Device>> loadDevicesList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('user/ListDevices');

    setState(() {
      isLoading = false;
    });

    List responseList = response['result'];
    List<Device> getData = responseList.map<Device>((json) {
      return Device.fromJson(json);
    }).toList();

    if (getData.length > 1) {
      multipleDevice = true;
    } else {
      multipleDevice = false;
    }
    setState(() {});

    String thisDevice = AppConstants.deviceId;

    return getData.where((item) => item.uniqueId != thisDevice).toList();
  }

  void deleteAllDevices() {
    deleteDevices = [];
    devicesList.then((value) => deleteDevices = value);
    validateUserPin();
  }

  void deleteSingleDevice(Device device) {
    deleteDevices = [];
    deleteDevices.add(device);
    validateUserPin();
  }

  void validateUserPin() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              child: PinVerify(
                onPinEntered: (String pinValue) {
                  Navigator.pop(context);
                  deleteDevicesClickHandle(pinValue);
                },
              ),
            ),
          );
        });
  }

  void deleteDevicesClickHandle(String pin) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['pin'] = pin;

    List deviceIdList = [];
    for (var item in deleteDevices) {
      deviceIdList.add(item.id);
    }
    apiBodyObj['id'] = jsonEncode(deviceIdList);

    Map<String, dynamic> response =
        await NetworkHelper.request('user/DeleteDevices', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      devicesList = loadDevicesList();
      showSnackBar(getTranslated(context, 'device_removed'));
    } else {
      if (response['error'] == 'wrong_pin') {
        showSnackBar(getTranslated(context, 'incorrect_pin'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: SvgPicture.asset(
                        'assets/svg/devices.svg',
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      getTranslated(context, 'current_session'),
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(fontSize: 18),
                    ),
                    // SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        Icons.phone_android,
                        size: 34,
                      ),
                      title: Text(AppConstants.appName),
                      subtitle: Text(AppConstants.deviceName),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              multipleDevice
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: OutlineButton(
                            textColor: Colors.red,
                            child: Text(
                              getTranslated(
                                  context, 'terminate_all_other_sessions'),
                              style: TextStyle(fontSize: 18),
                            ),
                            onPressed: () => deleteAllDevices(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            getTranslated(context, 'other_devices'),
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(fontSize: 18),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              FutureBuilder(
                future: devicesList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Device>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            Device device = snapshot.data[index];

                            return Column(
                              children: [
                                Opacity(
                                  opacity: device.status == 'active' ? 1.0 : .5,
                                  child: ListTile(
                                    title: Text(device.appName),
                                    subtitle: Text(device.mobileName),
                                    trailing: Text(device.lastActive.isNotEmpty
                                        ? Jiffy(device.lastActive).fromNow()
                                        : ''),
                                    onTap: () => deleteSingleDevice(device),
                                  ),
                                ),
                                const Divider(
                                  thickness: 1,
                                ),
                              ],
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
              multipleDevice
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTranslated(context, 'tap_session_terminate')),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            getTranslated(
                                context, 'device_dont_recognize_message'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
