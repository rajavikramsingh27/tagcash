
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import './contact-widget.dart';
import './current_and_live_location.dart';
import './document_widget.dart';
import './image_widget.dart';
import './payment_card.dart';
import './record-widget.dart';
import './text-widget.dart';
import './voucher-card.dart';
import '../../../bloc/conversation_bloc.dart';
import '../../../models/SocketEvent.dart';
import '../../../models/thread.dart';
import '../../../../../models/user_data.dart';
import '../../../../../models/app_constants.dart' as AppConstants;


// ignore: must_be_immutable
class ChatMessage extends StatefulWidget {
  final String uniqMessageId;
  final String text;
  final String alignMsg;
  final String msg;
  final String docId;
  final String title;
  final int type;
  final String date;
  final Color textColor;
  final Color bgColor;
  int status;
  final String roomId;
  final String msgId;
  final int senderId;
  int index;
  Function onItemSelectFn;
  Function onItemDeSelectFn;
  bool enableTapOrLongPress;
  ConversationBloc bloc;
  int id;
  int withId;

  ChatMessage({
        this.uniqMessageId,
      this.onItemSelectFn,
      this.onItemDeSelectFn,
      this.enableTapOrLongPress,
      this.text,
      this.msg,
      this.alignMsg,
      this.textColor,
      this.bgColor,
      this.type,
      this.date,
      this.docId,
      this.title,
      this.status,
      this.roomId,
      this.msgId,
      this.senderId,
      this.bloc,
      this.id,
      this.index,
      // ignore: non_constant_identifier_names
      this.withId
      });

  static final Map<RoomNameConstraintType, RoomNameConstraint>
      customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
              .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final String chatServerUrl = AppConstants.getChatServerUrl();

  final String videolink = 'https://jitsi.tagcash.com/';

  UserData user;

  String address = '';

  String paymentcharge = '1';

  String paymentcurrency = 'PHP';
  var latLongLiveObj;

  bool isSelected = false;
  var count = 0;
  Thread thread;
  var isHidden;
  var videoChargeObj;

  @override
  void dispose() {
    timer.cancel();
    _timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  void paymentSuccess() {
    var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(color: Colors.red, fontSize: 16),
    );

    Alert(
      style: alertStyle,
      title: "Payment successful",
      desc: "Transaction completed successfully.",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          radius: BorderRadius.circular(0.0),
          onPressed: null,
        ),
      ],
      context: null,
    ).show();
  }

  Timer _timer;

  Timer timer;

  bool isTimerStop = false;

  int timeUsed;

  startTimer(ctx, videoAmount, videoTime, isMinute) {
    int _start;
    // int amount = int.parse(this.widget.msg);
    // int amount = videoAmount;
    if (!isMinute) {
      _start = videoTime * 60;
    } else {
      _start = 60;
    }
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        timer.cancel();
        _timer.cancel();
        if (!isMinute) {
          this.closeMeeting(timer, _timer);
        } else {
          if (videoAmount > 0) {
            this.widget.bloc.paymentOfVideo(
                  videoAmount,
                  this.widget.withId,
                  'notes',
                  this.widget.title,
                  this.widget.id,
                  this.closeMeeting(timer, _timer),
                  this.continueTinmer(ctx, videoAmount, videoTime, isMinute),
                );
          }
        }
      } else {
        print('pending time {$_start}');
        _start--;
        if (this.isTimerStop) {
          print('han me ruk gya ontime');
          timer.cancel();
          _timer.cancel();
          this.timeUsed = _start;
        }
      }
    });
  }

  continueTinmer(ctx, videoAmount, videoTime, isMinute) {
    this.startTimer(ctx, videoAmount, videoTime, isMinute);
  }

  closeMeeting(timer, _timer) {
    timer.cancel();
    _timer.cancel();
    JitsiMeet.closeMeeting();
  }

  answerMeeting(roomId, context, videoAmount, videoTime, isMinute) async {
    String subjecttext = 'Tagcash Video Call';
    String serverUrl = SocketEvent.JITSI_SERVER_URL;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
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

    //     var userData =
    //     Provider.of<UserProvider>(context, listen: false).userData.toMap();
    // userData['user_name'] = userData['firstName'];

    // Define meetings options here
    var options = JitsiMeetingOptions(room: this.widget.roomId)
      ..serverURL = serverUrl
      ..subject = subjecttext
      ..userDisplayName = 'this.userdata.firstName + this.userdata.lastName'
      //   ..userDisplayName =
      // userData['user_firstname'] + userData['user_lastname']
      ..userEmail = 'emailText.text'
      ..iosAppBarRGBAColor = 'iosAppBarRGBAColor.text'
      // ..audioOnly = true
      // ..audioMuted = true
      // ..videoMuted = true
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": this.widget.roomId,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": this.widget.title}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
            if (videoAmount > 0) {
              this.startTimer(context, videoAmount, videoTime, isMinute);
            }
          },
          onConferenceTerminated: (message) {
            setState(() {
              this.isTimerStop = true;
            });
            this.widget.bloc.updateMessageStatus(widget.msgId);
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }

  void paymentFailed() {
    var alertStyle = AlertStyle(
      // animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(color: Colors.red, fontSize: 16),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: "Payment Unsuccessful",
      desc: "Transaction was declined.",
      buttons: [
        DialogButton(
          color: Colors.red,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  getAddress(dynamic latlongObj) async {
    final coordinates =
        new Coordinates(latlongObj['latitude'], latlongObj['longitude']);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String address = "${first.addressLine}";
    if (mounted) {
      setState(() {
        this.address = address;
      });
    }
  }

  void _showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Wifi"),
              content: Text("Wifi not detected. Please activate it."),
            ));
  }

  _makeContent(context) {
    Widget _getLayoutWidget(Widget child) {

      return Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.symmetric(vertical: 1),
          width: isSelected ? double.infinity : null,
          color: isSelected ? Colors.grey[200] : null,
          alignment: this.widget.alignMsg == 'right'
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          child: isHidden == null || isHidden.length == 0
              ? child
              : isHidden.length == 2 && isHidden[1] == widget.bloc.myTagcashId
              ? this.widget.alignMsg == 'left' && isHidden.length == 2
              ? Container(
            // width: 220,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: this.widget.bgColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ],
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Row(
                children: [
                  Icon(
                    Icons.block,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'This message was deleted',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
              : Container(width: 0, height: 0)
              : isHidden[0] == widget.bloc.myTagcashId
              ? this.widget.alignMsg == 'left' && isHidden.length == 2
              ? Container(
            // width: 220,
            constraints: BoxConstraints(
              maxWidth:
              MediaQuery.of(context).size.width * 0.80,
            ),
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: this.widget.bgColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ],
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Row(
                children: [
                  Icon(
                    Icons.block,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'This message was deleted',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
              : Container(width: 0, height: 0)
              : child);
    }

    Widget selectUnselectLayout(child) {
      if (this
                  .widget
                  .bloc
                  .chat
                  .history
                  .threads[widget.index]
                  .isHiddenFor
                  .length ==
              0 ||
          this.widget.bloc.chat.history.threads[widget.index].isHiddenFor ==
              null) {
        this.isHidden = [];
      } else {
        this.isHidden =
            this.widget.bloc.chat.history.threads[widget.index].isHiddenFor;
      }
      return widget.enableTapOrLongPress
          ? InkWell(
              onTap: () {
                this.thread =
                    this.widget.bloc.chat.history.threads[widget.index];
                if (this.mounted) {
                  setState(() {
                    isSelected = !isSelected;
                  });
                }
                if (count == 0) {
                  widget.onItemSelectFn(this.thread);
                  if (this.mounted) {
                    setState(() {
                      count = 1;
                    });
                  }
                } else {
                  widget.onItemDeSelectFn(this.thread);
                  if (this.mounted) {
                    setState(() {
                      count = 0;
                    });
                  }
                }
              },
              child: _getLayoutWidget(child),
            )
          : InkWell(
              onTap: () {
                if (this.mounted) {
                  setState(
                    () {
                      isSelected = false;
                      widget.onItemDeSelectFn(this.thread);
                      count = 0;
                    },
                  );
                }
              },
              onLongPress: () {
                this.thread =
                    this.widget.bloc.chat.history.threads[widget.index];
                if (this.mounted) {
                  setState(() {
                    isSelected = !isSelected;
                  });
                }
                if (count == 0) {
                  widget.onItemSelectFn(this.thread);
                  if (this.mounted) {
                    setState(() {
                      count = 1;
                    });
                  }
                } else {
                  widget.onItemDeSelectFn(this.thread);
                  if (this.mounted) {
                    setState(() {
                      count = 0;
                    });
                  }
                }
              },
              child: _getLayoutWidget(child),
            );
    }

    switch (this.widget.type) {
      case 1:
        return selectUnselectLayout(TextWidget(widget.bgColor, widget.textColor,
            widget.text, widget.date, widget.alignMsg));
        break;
      case 2:
        if (this.widget.docId.isNotEmpty) {
          return selectUnselectLayout(
            ImageWidget(
                this.chatServerUrl,
                this.widget.title,
                this.widget.docId,
                this.widget.bgColor,
                widget.date,
                widget.alignMsg),
          );
        } else {
          return Container(width: 0, height: 0);
        }
        break;
      case 3:
        if (this.widget.docId.isNotEmpty) {
          return selectUnselectLayout(
            PaymentCard(widget.msg, widget.title, widget.docId, widget.date),
          );
        } else {
          return Container(width: 0, height: 0);
        }
        break;

      case 4:
        // recording
        return selectUnselectLayout(
          RecordWidget(widget.docId, widget.date, widget.alignMsg),
        );
        break;
      case 5:
        if (this.widget.msg.isNotEmpty) {
          var contactObj = jsonDecode(this.widget.msg);
          return selectUnselectLayout(
            ContactWidget(widget.alignMsg, widget.docId, chatServerUrl,
                contactObj, widget.date),
          );
        }
        break;

      case 6:
        //  if (this.status != 1 &&
        // this.senderId.compareTo(AppConstants.userId) != 0)
        if (this.widget.status != 1 &&
            this.widget.senderId.compareTo(widget.id) != 0) {
          this.videoChargeObj = jsonDecode(this.widget.msg);
          String sessionOrMin = '';
          if (videoChargeObj['isMinute']) {
            sessionOrMin = 'per minute.';
          } else {
            sessionOrMin = 'for this session.';
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AlertDialog(
              elevation: 0,
              title: Text(this.widget.title),
              content: Column(
                children: [
                  kIsWeb
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                color: Colors.white54,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.60 *
                                      0.70,
                                  height: MediaQuery.of(context).size.width *
                                      0.60 *
                                      0.70,
                                  child: JitsiMeetConferencing(
                                    extraJS: [
                                      // extraJs setup example
                                      '<script>function echo(){console.log("echo!!!")};</script>',
                                      '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                    ],
                                  ),
                                )),
                          ))
                      : SizedBox(),
                  videoChargeObj['isMinute']
                      ? Text(
                          "You will be charged PHP ${videoChargeObj['amount']} per minute")
                      : Text(
                          'For this ${videoChargeObj['time']} min Session, you will be charged - PHP ${videoChargeObj['amount']}'),
                ],
              ),
              actions: [
                FlatButton(
                  child: Text(
                    "Answer",
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    if (kIsWeb) {
                        Navigator.pop(context, true);
                    } else {
                      int amount;
                      bool isMinute;
                      int time;
                      setState(() {
                        amount = videoChargeObj['amount'];
                        time = videoChargeObj['time'];
                        isMinute = videoChargeObj['isMinute'];
                      });
                      if (amount <= 0) {
                        answerMeeting(this.widget.roomId, context, amount, time,
                            isMinute);
                        Navigator.pop(context, true);
                      } else {
                        // answerMeeting(
                        //     this.widget.roomId, context, amount, time, isMinute);
                        this.widget.bloc.paymentOfVideo(
                              amount,
                              this.widget.withId,
                              'notes',
                              this.widget.title,
                              this.widget.id,
                              () => {print('insufficient balance')},
                              answerMeeting(this.widget.roomId, context, amount,
                                  time, isMinute),
                            );
                        Navigator.pop(context, true);
                      }
                    }
                  },
                ),
                FlatButton(
                  child: const Text("Decline",
                      style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        } else {
          return Container(width: 0, height: 0);
        }
        break;

      case 7:
        if (this.widget.msg.isNotEmpty) {
          setState(() {
            latLongLiveObj = jsonDecode(this.widget.msg);
          });

          if (latLongLiveObj['isCordinate'] == true) {
            // if (latLongLiveObj['latitude'] == null) {
            //   setState(() {
            //     // widget.bloc.isLocationEnded = true;
            //     this.isLocationEnded = true;
            //   });
            // }
            return Container(width: 0, height: 0);
          } else {
            var latlongObj = jsonDecode(this.widget.msg);

            getAddress(latlongObj);

            return selectUnselectLayout(
              CurrentAndLiveLocation(
                  widget.alignMsg,
                  this.address,
                  widget.bloc,
                  widget.withId,
                  widget.id,
                  latlongObj,
                  latLongLiveObj,
                  widget.date),
            );
          }
        }
        break;
      case 8:
        var fileObj = jsonDecode(this.widget.msg);
        print(fileObj['dateTime']);
        print(fileObj['dateTime'].runtimeType);
        Widget mainIcon = Icon(Icons.insert_drive_file);
        if (fileObj['extension'] == '.docx') {
          mainIcon = Icon(
            Icons.insert_drive_file,
            color: Colors.red,
            size: 18,
          );
        }
        if (fileObj['extension'] == '.doc') {
          mainIcon = Icon(
            Icons.insert_drive_file,
            color: Colors.red,
            size: 18,
          );
        }
        if (fileObj['extension'] == '.jpg' ||
            fileObj['extension'] == '.png' ||
            fileObj['extension'] == '.jpeg') {
          mainIcon = Icon(
            Icons.image,
            color: Colors.red,
            size: 18,
          );
        }
        if (fileObj['extension'] == '.mp3') {
          mainIcon = Icon(
            Icons.headset,
            color: Colors.red,
            size: 18,
          );
        }
        if (fileObj['extension'] == '.docx') {
          mainIcon = Icon(
            Icons.insert_drive_file,
            color: Colors.red,
            size: 18,
          );
        }
        if (fileObj['extension'] == '.pdf') {
          mainIcon = Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 18,
          );
        }
        return selectUnselectLayout(DocumentWidget(
            mainIcon,
            this.chatServerUrl,
            widget.docId,
            fileObj['fileName'],
            fileObj['extension'],
            fileObj['dateTime'],
            widget.date));
        break;
      case 9:
        var requestMoneyObj = jsonDecode(this.widget.msg);
        var reqMoneyNote = jsonEncode(requestMoneyObj['notes']);
        var reqMoneyAmount = requestMoneyObj['amount'].toString();
        var reqMoneyFromId = requestMoneyObj['requestFromId'];

        return selectUnselectLayout(
          VoucherCard(
              widget.index,
              widget.roomId,
              widget.alignMsg,
              reqMoneyAmount,
              reqMoneyNote,
              widget.status,
              widget.bloc,
              reqMoneyFromId,
              widget.uniqMessageId),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return this._makeContent(context);
  }
}

