import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:provider/provider.dart';

import '../bloc/conversation_bloc.dart';
import '../models/SocketEvent.dart';
import './Searchlist.dart';
import './widgets/video_call_dialog.dart';
import '../../../components/app_top_bar.dart';
import '../../../providers/user_provider.dart';
import '../models/chat_model.dart';
import '../../../models/app_constants.dart' as AppConstants;

class AddVideoCallScreen extends StatefulWidget {
  final ConversationBloc bloc;
  final int me;
  AddVideoCallScreen(
    this.bloc,
    this.me,
  );

  @override
  _AddVideoCallScreenState createState() => _AddVideoCallScreenState();
}

class _AddVideoCallScreenState extends State<AddVideoCallScreen> {
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;
  String searchTerm = '';
  TextEditingController amountVideoController =
      TextEditingController(text: "1");
  String videoChargeObj;
  bool isCall;

  @override
  void initState() {
    checkIsCall();
    super.initState();
  }

  searchClicked(String searchKey) {
    this.searchTerm = searchKey;

    // controller.add({'tab': _tabController.index, 'search': searchKey});

    widget.bloc.filterConversations(searchKey);
  }

  Widget _getAppBar() {
    return AppTopBar(
      title: 'Select Contact',
      appBar: AppBar(),
      onSearch: searchClicked,
    );
  }

  checkIsCall() {
    if (widget.bloc.chargePerMinAmount == '' &&
            widget.bloc.chargePerSession == '' ||
        widget.bloc.chargePerMinAmount == '0' &&
            widget.bloc.chargePerSession == '0' ||
        widget.bloc.chargePerMinAmount == null &&
            widget.bloc.chargePerSession == null) {
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
            : widget.bloc.chargePerMinAmount == '0'
                ?
                // it is session call
                Text(
                    'Charge to receive call per SESSION will be ' +
                        walletName +
                        ' ' +
                        widget.bloc.chargePerSession.toString(),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold))
                : Text(
                    'Charge to receive call per MINUTE will be ' +
                        walletName +
                        ' ' +
                        widget.bloc.chargePerMinAmount.toString(),
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
                        if (widget.bloc.chargePerMinAmount == '0') {
                          isMinute = false;
                          amount = widget.bloc.chargePerSession;
                        } else {
                          isMinute = true;
                          amount = widget.bloc.chargePerMinAmount;
                        }
                        calculateVideoCharge(widget.bloc.sessionTime.toString(),
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
    if (int.parse(widget.bloc.chargeCurrencyId) == 1) {
      walletName = 'PHP';
    }
    if (int.parse(widget.bloc.chargeCurrencyId) == 7) {
      walletName = 'TAGX';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return VideoCallDialog(videoCallDialogBody(walletName, myId, withId, roomId));
            }),
          );
        });
  }

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

    try {
      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomId)
        ..serverURL = serverUrl
        ..subject = subjecttext
        // ..token = token
        ..userDisplayName =
            userData['user_firstname'] + userData['user_lastname']
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
          widget.bloc.sendMessage({
            "to_tagcash_id": withId,
            "from_tagcash_id": this.widget.me,
            "toDocId": withId,
            // "imageUrl": imageUrl,
            "convId": widget.bloc.currentRoom,
            "type": 6,
            "payload": this.videoChargeObj
          });
        }, onConferenceTerminated: (message) {
          widget.bloc.updateMessageStatus(widget.bloc.lastmsgId);
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

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          return Scaffold(
            appBar: _getAppBar(),
            body: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: widget.bloc.conversations.length <= 0 ||
                              widget.bloc.conversations == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("There are no conversations"),
                                  RaisedButton(
                                    elevation: 0,
                                    onPressed: () {
                                      this.searchTerm.isEmpty
                                          ? print("term is empty")
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SearchList(
                                                    searchText: this.searchTerm,
                                                    isSearchAdd: false,
                                                    bloc: widget.bloc,
                                                    me: widget.me),
                                              ),
                                            ).then(
                                              (value) {
                                                widget.bloc
                                                    .reloadMainConversations(
                                                        widget.me);
                                                print('loaded');
                                                setState(() {
                                                  // this._textController.text =
                                                  //     "";
                                                  this.searchTerm = "";
                                                });
                                                Navigator.pop(context);
                                              },
                                            );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Search ',
                                          ),
                                          TextSpan(
                                            text: "'$searchTerm' ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: 'across Tagcash',
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(
                              child: Observer(
                                builder: (_) => ListView.separated(
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 70,
                                  ),
                                  itemCount: widget.bloc.conversations.length,
                                  itemBuilder: (context, index) {
                                    ChatModel _chatModel =
                                        widget.bloc.conversations[index];
                                    return Column(
                                      children: <Widget>[
                                        ListTile(
                                            leading: CircleAvatar(
                                              radius: 24.0,
                                              backgroundImage: NetworkImage(
                                                AppConstants
                                                        .getUserImagePath() +
                                                    (_chatModel.receiver
                                                                .tagcashId ==
                                                            this.widget.me
                                                        ? _chatModel
                                                            .sender.tagcashId
                                                            .toString()
                                                        : _chatModel
                                                            .receiver.tagcashId
                                                            .toString()) +
                                                    "?kycImage=0",
                                              ),
                                            ),
                                            onTap: () {
                                              var withId;
                                              if (_chatModel
                                                      .receiver.tagcashId ==
                                                  this.widget.me) {
                                                withId =
                                                    _chatModel.sender.tagcashId;
                                              } else {
                                                withId = _chatModel
                                                    .receiver.tagcashId;
                                              }
                                              print(widget.me);
                                              print(withId);
                                              print(_chatModel.roomId);
                                              videocall(
                                                  this.widget.bloc.myTagcashId,
                                                  withId,
                                                  _chatModel.roomId);
                                            },
                                            title: Row(
                                              children: <Widget>[
                                                Flexible(
                                                    child: Text(_chatModel
                                                        .contactName)),
                                                SizedBox(
                                                  width: 16.0,
                                                ),
                                                Text(
                                                  _chatModel.datetime,
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ],
                                            ),
                                            trailing: Icon(
                                              Icons.video_call,
                                              color: Colors.black,
                                            )),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ))
                ],
              ),
            ),
          );
        },
      );
}
