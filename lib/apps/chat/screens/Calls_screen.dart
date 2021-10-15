import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:provider/provider.dart';

import '../bloc/conversation_bloc.dart';
import '../models/SocketEvent.dart';
import '../models/call_history.dart';
import './call_info_screen.dart';
import './widgets/video_call_dialog.dart';
import '../../../providers/user_provider.dart';
import '../../../models/app_constants.dart' as AppConstants;

class CallsScreen extends StatefulWidget {
  final bool isHasCalls;
  final bool isSearchAddFloatingButton;
  final int me;
  final ConversationBloc _bloc;
  CallsScreen(
      this._bloc, this.me, this.isHasCalls, this.isSearchAddFloatingButton);

  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;
  TextEditingController amountVideoController =
      TextEditingController(text: "1");

  List<dynamic> uniqCalls = [];
  List<dynamic> uniqueRoomIds = [];
  List<dynamic> repeatedCalls = [];
  String videoChargeObj;
  bool isCall;

  @override
  void initState() {
    checkIsCall();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (widget._bloc.callHistoryModel != null) {
      uniqueRoomIds = List();
      widget._bloc.callHistoryModel.forEach(
        (u) {
          if (uniqueRoomIds.contains(u.roomId)) {
            // print('this is dublicate..');
            repeatedCalls.add(u);
          } else
            uniqueRoomIds.add(u.roomId);
          // print(uniqueRoomIds.contains(u.roomId));
        },
      );

      uniqueRoomIds.forEach((u) {
        print(u);
        uniqCalls.add(widget._bloc.callHistoryModel
            .firstWhere((element) => element.roomId == u));
      });
      print('ok');
      print(repeatedCalls.length);
      // print(uniqueroomIds.length);
      // print(widget._bloc.callHistoryModel.length);
      // print(uniqCalls[0].roomId);
    }

    super.didChangeDependencies();
  }

  checkIsCall() {
    if (widget._bloc.chargePerMinAmount == '' &&
            widget._bloc.chargePerSession == '' ||
        widget._bloc.chargePerMinAmount == '0' &&
            widget._bloc.chargePerSession == '0' ||
        widget._bloc.chargePerMinAmount == null &&
            widget._bloc.chargePerSession == null) {
      isCall = false;
    } else {
      isCall = true;
    }
  }

  calculateVideoCharge(String _time, String _amount, bool isMinute) {
    setState(() {
      // if (_time == '') {
      //   _time = '60';
      // }
       if (isMinute) {
        _time = '1';
      }
      this.videoChargeObj = {
        jsonEncode('time'): _time,
        jsonEncode('amount'): _amount,
        jsonEncode('isMinute'): isMinute.toString(),
      }.toString();
      var b = jsonDecode(videoChargeObj);
      print(b);
    });
  }

  Widget videoCallDialogBody(walletName, myId, withId, roomId) {
    return SingleChildScrollView(child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(children: [
        !isCall
            ? Column(
                children: [
                  Text(
                    'To start a call ',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Please set the charge from chat settings',
                    style: TextStyle(color: Colors.red),
                  )
                ],
              )
            : widget._bloc.chargePerMinAmount == '0'
                ?
                // it is session call
                Text(
                    'Charge to receive call per SESSION will be ' +
                        walletName +
                        ' ' +
                        widget._bloc.chargePerSession.toString(),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                : Text(
                    'Charge to receive call per MINUTE will be ' +
                        walletName +
                        ' ' +
                        widget._bloc.chargePerMinAmount.toString(),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
        Column(
          children: <Widget>[
            // TextFormField(
            //   controller: amountVideoController,
            //   keyboardType: TextInputType.number,

            //   inputFormatters: <TextInputFormatter>[
            //     // ignore: deprecated_member_use
            //     WhitelistingTextInputFormatter.digitsOnly
            //   ],
            //   decoration: InputDecoration(
            //       prefixIcon: Padding(
            //         padding:
            //             const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
            //         child: Text('PHP'),
            //       ),
            //       labelText: 'Charging Amount',
            //       suffix: Text('/Minute')),
            //   // validator: (value) {
            //   //   if (value.isEmpty) {
            //   //     return 'Please enter amount';
            //   //     // return 'Enter valid amount';
            //   //   }
            //   //   return null;
            //   // },
            // ),
            CheckboxListTile(
              // checkColor: Colors.red,
              title: Text("Audio Only"),
              value: isAudioOnly,
              onChanged: (bool value) {
                setState(() => isAudioOnly = value);
              },
            ),
            CheckboxListTile(
              title: Text("Audio Muted"),
              value: isAudioMuted,
              onChanged: (bool value) {
                print(value);
                setState(() => isAudioMuted = value);
              },
            ),
            CheckboxListTile(
              title: Text("Video Muted"),
              value: isVideoMuted,
              onChanged: (bool value) {
                setState(() => isVideoMuted = value);
              },
            ),
            Divider(
              height: 36.0,
              thickness: 2.0,
            ),
            SizedBox(
              height: 48.0,
              width: double.maxFinite,
              child: RaisedButton(
                onPressed: !isCall
                    ? null
                    : () async {
                        var isMinute;
                        var amount;
                        if (widget._bloc.chargePerMinAmount == '0') {
                          isMinute = false;
                          amount = widget._bloc.chargePerSession;
                        } else {
                          isMinute = true;
                          amount = widget._bloc.chargePerMinAmount;
                        }
                        calculateVideoCharge(widget._bloc.sessionTime.toString(),
                            amount.toString(), isMinute);
                        _joinMeeting(myId, withId, roomId);

                        // Navigator.pop(context);
                      },
                child: Text(
                  "Start Call",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ]);
    }));
  }

  void videocall(myId, withId, roomId) {
    var walletName;
    if (int.parse(widget._bloc.chargeCurrencyId) == 1) {
      walletName = 'PHP';
    }
    if (int.parse(widget._bloc.chargeCurrencyId) == 7) {
      walletName = 'TAGX';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
             
             return VideoCallDialog(
                  videoCallDialogBody(walletName, myId, withId, roomId));
            }),
          );
        });
  }

  // void videocall(myId, withId, roomId) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           content: StatefulBuilder(
  //               builder: (BuildContext context, StateSetter setState) {
  //             return Stack(
  //               overflow: Overflow.visible,
  //               children: <Widget>[
  //                 Positioned(
  //                   right: -40.0,
  //                   top: -40.0,
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: CircleAvatar(
  //                       child: Icon(Icons.close),
  //                       backgroundColor: Colors.red,
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 16.0,
  //                   ),
  //                   child: SingleChildScrollView(
  //                     child: Column(
  //                       children: <Widget>[
  //                         TextFormField(
  //                           controller: amountVideoController,
  //                           keyboardType: TextInputType.number,
  //                           inputFormatters: <TextInputFormatter>[
  //                             // ignore: deprecated_member_use
  //                             WhitelistingTextInputFormatter.digitsOnly
  //                           ],
  //                           decoration: InputDecoration(
  //                               prefixIcon: Padding(
  //                                 padding:
  //                                     const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
  //                                 child: Text('PHP'),
  //                               ),
  //                               labelText: 'Charging Amount',
  //                               suffix: Text('/Minute')),
  //                         ),
  //                         CheckboxListTile(
  //                           // checkColor: Colors.red,
  //                           title: Text("Audio Only"),
  //                           value: isAudioOnly,
  //                           onChanged: (bool value) {
  //                             setState(() => isAudioOnly = value);
  //                           },
  //                         ),
  //                         CheckboxListTile(
  //                           title: Text("Audio Muted"),
  //                           value: isAudioMuted,
  //                           onChanged: (bool value) {
  //                             setState(() => isAudioMuted = value);
  //                           },
  //                         ),
  //                         CheckboxListTile(
  //                           title: Text("Video Muted"),
  //                           value: isVideoMuted,
  //                           onChanged: (bool value) {
  //                             setState(() => isVideoMuted = value);
  //                           },
  //                         ),
  //                         Divider(
  //                           height: 36.0,
  //                           thickness: 2.0,
  //                         ),
  //                         SizedBox(
  //                           height: 48.0,
  //                           width: double.maxFinite,
  //                           child: RaisedButton(
  //                             onPressed: () {
  //                               _joinMeeting(myId, withId, roomId);

  //                               Navigator.of(context).pop();
  //                               print('this is loaded1');
  //                               widget._bloc.historyOfVideoCalls(myId);
  //                               print('this is loaded3');
  //                             },
  //                             child: Text(
  //                               "Start Call",
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                             color: Colors.red,
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           height: 10.0,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           }),
  //         );
  //       });
  // }
 _joinMeeting(myId, withId, roomId) async {
    String subjecttext = 'Tagcash Video Call';
    String serverUrl = SocketEvent.JITSI_SERVER_URL;

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
     var userData =
        Provider.of<UserProvider>(context, listen: false).userData.toMap();
    userData['user_name'] = userData['firstName'];

    try{
       // Define meetings options here
    var options = JitsiMeetingOptions(room: roomId)
      ..serverURL = serverUrl
      ..subject = subjecttext
      // ..token = token
      ..userDisplayName = userData['user_firstname'] + userData['user_lastname']
      // ..userEmail = emailText.text
      // ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      // ..audioOnly = isAudioOnly
      // ..audioMuted = isAudioMuted
      // ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": '',
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": ''}
      };

    debugPrint("JitsiMeetingOptions: $options");
    
         await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: (message) {
          // it shows connecting loader
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: (message) {
          // call when join is connected with other person
          debugPrint("${options.room} joined with message: $message");
          // String amountText;
          // if (videoChargeOb['amount'] == 0) {
          //   amountText = '0';
          // } else {
          //   amountText = videoChargeOb['amount'].toString();
          // }
          widget._bloc.sendMessage({
            "to_tagcash_id": withId,
            "from_tagcash_id": this.widget.me,
            "toDocId": withId,
            // "imageUrl": imageUrl,
            "convId": widget._bloc.currentRoom,
            "type": 6,
            "payload": this.videoChargeObj
          });
        }, onConferenceTerminated: (message) {
          widget._bloc.updateMessageStatus(widget._bloc.lastmsgId);
          debugPrint("${options.room} terminated with message: $message");
        }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
      // JitsiMeet.closeMeeting();
    } catch (error) {
      debugPrint("error: $error");
    }
    }


  Widget _showAddcallMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  'To start calling, tap at',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
              Icon(
                Icons.video_call,
                size: 20.0,
                color: Colors.grey,
              ),
              Text(
                ' the',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            ],
          ),
          Text(
            ' bottom of your screen.',
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: uniqCalls == null || uniqCalls.length == 0
                ? _showAddcallMessage()
                : Container(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        indent: 70,
                      ),
                      itemCount: uniqCalls.length,
                      itemBuilder: (context, index) {
                        CallHistoryModel _callHistoryModel = uniqCalls[index];
                        List<dynamic> repeatSinglecalls = repeatedCalls
                            .where((element) =>
                                element.roomId == _callHistoryModel.roomId)
                            .toList();
                        return Column(
                          children: <Widget>[
                            ListTile(
                                leading: CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage: NetworkImage(
                                    AppConstants.getUserImagePath() +
                                        (_callHistoryModel.receiver.tagcashId ==
                                                this.widget.me
                                            ? _callHistoryModel.sender.tagcashId
                                                .toString()
                                            : _callHistoryModel
                                                .receiver.tagcashId
                                                .toString()) +
                                        "?kycImage=0",
                                  ),
                                ),
                                onTap: () {
                                  repeatSinglecalls.insert(
                                      0, _callHistoryModel);
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => CallInfoScreen(
                                          repeatSinglecalls,
                                          widget._bloc,
                                          widget.me),
                                    ),
                                  )
                                      .then(
                                    (value) {
                                      widget._bloc.historyOfVideoCalls(
                                          widget._bloc.myTagcashId);
                                      print('loaded');
                                      // setState(() {
                                      //   // this._textController.text = "";
                                      //   // widget.searchTerm = "";
                                      // });
                                    },
                                  );
                                },
                                title: _callHistoryModel.toTagcashId ==
                                        widget._bloc.myTagcashId
                                    ? Text(_callHistoryModel.sender.firstname +
                                        ' ' +
                                        _callHistoryModel.sender.lastname)
                                    : _callHistoryModel.fromTagcashId ==
                                            widget._bloc.myTagcashId
                                        ? Text(_callHistoryModel
                                                .receiver.firstname +
                                            ' ' +
                                            _callHistoryModel.receiver.lastname)
                                        : Container(),
                                subtitle: Row(
                                  children: [
                                    _callHistoryModel.toTagcashId ==
                                            widget._bloc.myTagcashId
                                        ? Icon(
                                            Icons.call_received,
                                            size: 15,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            Icons.call_made,
                                            size: 15,
                                            color: Colors.green,
                                          ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    repeatSinglecalls == null ||
                                            repeatSinglecalls.length == 0
                                        ? Text('(1)')
                                        : Text('(' +
                                            '${repeatSinglecalls.length + 1}' +
                                            ')'),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(_callHistoryModel.createdDate),
                                  ],
                                ),
                                trailing: IconButton(
                                    icon: Icon(
                                      Icons.video_call,
                                      // color: Colors.black,
                                    ),
                                    onPressed: () {
                                      var toId;
                                      if (_callHistoryModel.toTagcashId ==
                                          widget._bloc.myTagcashId) {
                                        toId = _callHistoryModel.fromTagcashId;
                                      } else {
                                        toId = _callHistoryModel.toTagcashId;
                                      }
                                      videocall(this.widget.me, toId,
                                          _callHistoryModel.roomId);
                                    })),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
