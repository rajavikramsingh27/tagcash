

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:mobx/mobx.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/models/events.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/utils/eventBus_utils.dart';

import './widgets/add_emoji.dart';
import '../constant.dart';
import './Profile.dart';
import '../../../components/wallets_dropdown.dart';
import '../../../models/wallet.dart';
import '../../../services/networking.dart';
import '../models/SocketEvent.dart';
import './contacts_picker.dart';
import './current-location.dart';
import '../bloc/conversation_bloc.dart';
import '../models/chat_model.dart';
import '../models/receiver.dart';
import '../models/thread.dart';
import './widgets/record-ui/recording-widget.dart';
import './widgets/chat_message/chat-message.dart';
import '../utils/core/parsing.dart';
import '../../../providers/perspective_provider.dart';
import '../../../models/app_constants.dart' as AppConstants;
import '../../../providers/user_provider.dart';

final _bloc = ConversationBloc();

// ignore: must_be_immutable
class ConversationScreen extends StatefulWidget {
  Map<String, dynamic> data;
  String source;

  ConversationScreen({
    Key key,
    @required this.data,
    this.source,
  });

  @override
  _ConversationScreenState createState() =>
      _ConversationScreenState(this.source, this.data);
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  String title;
  String msg;
  String message = "";
  String source;
  String fromWalletId;
  int me;
  int withUser;
  String name;
  ChatModel chatModel;
  int lastItemIndex;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final _textController = TextEditingController();
  final mycontroller = TextEditingController();
  TextEditingController amountVideoController =
      TextEditingController(text: "1");
  final notecontroller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  ReceiverModel reciver;
  Thread thread;
  Widget micOrSendIcon = IconButton(
    onPressed: () {},
    icon: Icon(Icons.mic),
    color: Colors.green,
  );

  bool _isComposing = false;
  String img;
  Map<String, dynamic> data;
  //for multi delete
  bool isDeleteSelected = false;
  int selectedLength = 0;
  bool enableTapOrLongPress = false;
  List<dynamic> threadObjList = [];
  // File imageFile;
  bool isuploading;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int activeWalletId;
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;
  String videoChargeObj;
  String activeCurrencyCode;
  final _notecontroller = TextEditingController();
  var isCall = false;
  bool isEmojiEnabled = false;
  bool iskeyboardEnabled = false;
  // var isHidden;
  // bool firstThreadWithoutDate = true;
  dynamic lastDateStored;
  int lastDate;
  var isShowDateLabel = false;
  _ConversationScreenState(this.source, this.data);

  @override
  void didChangeDependencies() {
    var userData;
    userData =
        Provider.of<UserProvider>(context, listen: false).userData.toMap();
    userData['user_id'] = userData['id'];
    setState(() {
      this.me = Parsing.intFrom(userData['id']);
      // this.myUserData = userData;
    });
    this.data['user_id'] = this.data['id'];
    _bloc.tagtalkLoginFromTagcash(userData, this.data);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool isKeyboardVisible) {
      setState(() {
        this.iskeyboardEnabled = isKeyboardVisible;
      });

      if (isKeyboardVisible && isEmojiEnabled) {
        setState(() {
          isEmojiEnabled = false;
        });
      }
    });

    defaultWalletLoad();
    checkIsCall();

    setState(() {
      this.withUser = Parsing.intFrom(this.data['id']);
      this.title = this.data['name'] != null
          ? this.data['name']
          : "${this.data['user_firstname']} ${this.data['user_lastname']}";
    });

    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  emojiSelected(emoji, cat) {
    setState(() {
      this._textController.text = _textController.text + emoji.emoji;
      _isComposing = true;
      this.micOrSendIcon = Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoButton(
              // child: Text('Send'),
              child: Icon(
                Icons.send,
                color: Colors.green,
              ),
              // icon: Icon(Icons.send, color: Colors.grey)),
              onPressed: _isComposing
                  ? () => this._handleSubmitted(_textController.text)
                  : null,
            )
          : IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.green,
              ),
              onPressed: _isComposing
                  ? () => this._handleSubmitted(_textController.text)
                  : null,
            );
    });
  }

  void onClickedEmoji() async {
    if (isEmojiEnabled) {
      _focusNode.requestFocus();
    } else if (iskeyboardEnabled) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(Duration(milliseconds: 100));
    }
    toggleEmojiKeyboard();
  }

  Future toggleEmojiKeyboard() async {
    if (iskeyboardEnabled) {
      FocusScope.of(context).unfocus();
    }

    if (mounted) {
      setState(() {
        isEmojiEnabled = !isEmojiEnabled;
      });
    }
  }

  Future<bool> onBackPress() {
    if (isEmojiEnabled) {
      toggleEmojiKeyboard();
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _bloc.leaveRoom();
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  checkIsCall() {
    if (_bloc.chargePerMinAmount == '' && _bloc.chargePerSession == '' ||
        _bloc.chargePerMinAmount == '0' && _bloc.chargePerSession == '0' ||
        _bloc.chargePerMinAmount == null && _bloc.chargePerSession == null) {
      print('text here');
      isCall = false;
    } else {
      isCall = true;
    }
  }

  void getWallet(Wallet wallet) async {
    print('this is wallet id');
    print(wallet.walletId);
    setState(() {
      this.activeWalletId = wallet.walletId;
    });
  }

  void defaultWalletLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('user/DefaultWallet', apiBodyObj);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (responseMap.containsKey('wallet_id')) {
        setState(() {
          activeWalletId = int.parse(responseMap['wallet_id']);
        });

        activeCurrencyCode = responseMap['currency_code'];
      }
    }
  }

  void callback(context) {
    AlertDialog(
      title: Text('Alert'),
      content: Text('There are no more conversations'),
    );
  }

  void loadMore(context) {
    _bloc.loadMoreConversation(context);
  }

  File _image;
  final picker = ImagePicker();

  _joinMeeting() async {
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
      var options = JitsiMeetingOptions(room: _bloc.currentRoom)
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
          "userInfo": {"displayName": this.title}
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
          _bloc.sendMessage({
            "to_tagcash_id": this.withUser,
            "from_tagcash_id": this.me,
            "toDocId": this.withUser,
            // "imageUrl": imageUrl,
            "convId": _bloc.currentRoom,
            "type": 6,
            "payload": this.videoChargeObj
          });
        }, onConferenceTerminated: (message) {
          _bloc.updateMessageStatus(_bloc.lastmsgId);
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

  void paymentSuccess() {
    setState(() {
      _amountController.text = '';
      _notecontroller.text = '';
    });

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
      context: context,
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
          onPressed: () {
            _bloc.convStatus = FutureStatus.fulfilled;
            Navigator.pop(context);
          },
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  void paymentFailed() {
    setState(() {
      _notecontroller.text = '';
      _amountController.text = '';
    });
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
          onPressed: () {
            _bloc.convStatus = FutureStatus.fulfilled;
            Navigator.pop(context);
          },
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  void payment() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: WalletsDropdown(
                            currencyCode: ValueNotifier<String>(
                                activeWalletId.toString()),
                            onSelected: (wallet) => getWallet(wallet),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              // ignore: deprecated_member_use
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              icon: const Icon(Icons.person),
                              hintText: 'Enter amount',
                              labelText: 'Amount',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter amount';
                                // return 'Enter valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _notecontroller,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.notes),
                              labelText: 'Notes',
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              onPressed: () {
                                // paymentSuccess();
                                _bloc.convStatus = FutureStatus.pending;

                                _bloc.paymentWithFromWallet(
                                    this.fromWalletId,
                                    this._amountController.text,
                                    this.withUser,
                                    _notecontroller.text,
                                    this.title,
                                    this.me,
                                    this.paymentFailed,
                                    this.paymentSuccess);

                                Navigator.pop(context);
                              },
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              child: Text(
                                'Submit',
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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

  void videocall() {
    var walletName;
    if (int.parse(_bloc.chargeCurrencyId) == 1) {
      walletName = 'PHP';
    }
    if (int.parse(_bloc.chargeCurrencyId) == 7) {
      walletName = 'TAGX';
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Positioned(
                    right: -40.0,
                    top: -40.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.close),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        !isCall
                            ? Column(
                                children: [
                                  Text(
                                    'To start a call ',
                                    style:
                                        Theme.of(context).textTheme.headline6,
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
                            : _bloc.chargePerMinAmount == '0'
                                ?
                                // it is session call
                                Text(
                                    'Charge to receive call per SESSION will be ' +
                                        walletName +
                                        ' ' +
                                        _bloc.chargePerSession.toString(),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold))
                                : Text(
                                    'Charge to receive call per MINUTE will be ' +
                                        walletName +
                                        ' ' +
                                        _bloc.chargePerMinAmount.toString(),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
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
                              // thickness: 2.0,
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
                                        if (_bloc.chargePerMinAmount == '0') {
                                          isMinute = false;
                                          amount = _bloc.chargePerSession;
                                        } else {
                                          isMinute = true;
                                          amount = _bloc.chargePerMinAmount;
                                        }
                                        calculateVideoCharge(
                                            _bloc.sessionTime.toString(),
                                            amount.toString(),
                                            isMinute);
                                        _joinMeeting();

                                        Navigator.pop(context);
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
                      ]),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }

  void onSendMessage(track) async {
    // print('this is path $recordingFile');

    _bloc.convStatus = FutureStatus.pending;
    File rcordFile = File(track.trackPath);
    print(rcordFile);
    List<int> imageBytes = await rcordFile.readAsBytes();
    print(imageBytes);
    String soundB64 = base64Encode(imageBytes);
    print(soundB64);

    if (rcordFile != null) {
      // setState(() {
      //   isUploading = true;
      //   isEnabled = false;
      // });
      var soundUrl = await _bloc.uploadRecording(soundB64);
      print('this is live url $soundUrl');
      // setState(() {
      //   isUploading = false;
      //   isEnabled = true;
      // });

      _bloc.sendMessage(
        {
          "to_tagcash_id": this.withUser,
          "from_tagcash_id": me,
          "toDocId": this.withUser,
          'doc_id': soundUrl,
          "convId": _bloc.currentRoom,
          "type": 4,
          "payload": ' '
        },
      );
      _bloc.convStatus = FutureStatus.fulfilled;
    }
  }

  void startRecording() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: RecordingWidget(_bloc, this.withUser, this.me,
                _bloc.currentRoom, onSendMessage),
          );
        });
  }

  void _showSelectionDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () {
                        getImagefromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImagefromcamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Provider.of<PerspectiveProvider>(context)
                        .getActivePerspective() ==
                    'user'
                ? Colors.black
                : Colors.blue,
            // ? kUserBackColor
            // : kMerchantBackColor,
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Image',
                      style: TextStyle(color: Colors.white),
                    ),

                    onTap: () {
                      // _showSelectionDialog(context);
                      Navigator.pop(context);
                      _showSelectionDialog();
                      // getImage();
                    }),

                // onTap: () => showFilePicker(FileType.IMAGE)),
                // DocumentPicker(
                //     _bloc, this.withUser, this.me, _bloc.currentRoom),

                ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Location',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CurrentLocationScreen(
                              _bloc, this.withUser, this.me, _bloc.currentRoom),
                        ),
                      );
                    }),
                ListTile(
                    leading: Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Pay',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      payment();
                    }),
                // onTap: () => showFilePicker(FileType.VIDEO)),
                ContactPicker(_bloc, this.withUser, this.me, _bloc.currentRoom),
              ],
            ),
          );
        });
  }

  Future getImagefromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    _bloc.convStatus = FutureStatus.pending;

    pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 480,
        maxWidth: 640
    );

    _bloc.convStatus = FutureStatus.fulfilled;

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    List imageBytes = croppedFile.readAsBytesSync();
    String imageB64 = base64Encode(imageBytes);

    if (croppedFile != null) {
      setState(() {
        isuploading = true;
      });
      var imgUrl = await _bloc.uploadImage(imageB64);
      var apiObj = {
        "to_tagcash_id": this.withUser,
        "from_tagcash_id": this.me,
        "toDocId": this.withUser,
        'doc_id': imgUrl,
        "convId": _bloc.currentRoom,
        "type": 2,
        "payload": ''
      };
      _textController.clear();
      _bloc.sendMessage(apiObj);
    }
  }

  Future getImagefromcamera() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    _bloc.convStatus = FutureStatus.pending;
    pickedFile = await imagePicker.getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxHeight: 480,
        maxWidth: 640);
    _bloc.convStatus = FutureStatus.fulfilled;
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    print(croppedFile);
    print('this is croppedFile');
    List imageBytes = croppedFile.readAsBytesSync();
    String imageB64 = base64Encode(imageBytes);
    if (croppedFile != null) {
      setState(() {
        isuploading = true;
      });
      var imgUrl = await _bloc.uploadImage(imageB64);
      var apiObj = {
        "to_tagcash_id": this.withUser,
        "from_tagcash_id": this.me,
        "toDocId": this.withUser,
        'doc_id': imgUrl,
        "convId": _bloc.currentRoom,
        "type": 2,
        "payload": '',
      };
      _textController.clear();
      _bloc.sendMessage(apiObj);
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.lightGreenAccent),
      child: Container(
        margin: EdgeInsets.only(right: 5.0, left: 15.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: EdgeInsets.only(left: 0, bottom: 0),
            height: 60,
            width: double.infinity,
            // color: Colors.white,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showAttachmentBottomSheet(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onChanged: (String text) {
                      setState(() {
                        _isComposing = text.length > 0;
                        if (_textController.text.isNotEmpty) {
                          this.micOrSendIcon =
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? CupertinoButton(
                                      // child: Text('Send'),
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.green,
                                      ),
                                      // icon: Icon(Icons.send, color: Colors.grey)),
                                      onPressed: _isComposing
                                          ? () => this._handleSubmitted(
                                              _textController.text)
                                          : null,
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.green,
                                      ),
                                      onPressed: _isComposing
                                          ? () => this._handleSubmitted(
                                              _textController.text)
                                          : null,
                                    );
                        } else {
                          this.micOrSendIcon = GestureDetector(
                              onLongPress: () {
                                startRecording();
                              },
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.mic),
                                color: Colors.green,
                              ));
                        }
                      });
                    },
                    onSubmitted: _isComposing ? _handleSubmitted : null,
                    decoration:
                        InputDecoration.collapsed(hintText: 'Send a message'),
                    focusNode: _focusNode,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      //this.isEmojiEnabled = !isEmojiEnabled;
                      onClickedEmoji();
                    });
                  },
                  child: Icon(
                    Icons.emoji_emotions,
                    color: Colors.blueGrey,
                  ),
                ),
                GestureDetector(
                  onLongPress: () {
                    startRecording();
                  },
                  child: this.micOrSendIcon,
                ),

                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: Container(
                //     margin:
                //         EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                //     child: GestureDetector(
                //       onLongPress: () {
                //         startRecording();
                //       },
                //       child: this.micOrSendIcon,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    _bloc.sendMessage({
      "to_tagcash_id": this.withUser,
      "from_tagcash_id": this.me,
      "toDocId": this.withUser,
      "convId": _bloc.currentRoom,
      "type": 1,
      "payload": text,
    });
    setState(() {
      this.micOrSendIcon = IconButton(
        onPressed: () {},
        icon: Icon(Icons.mic),
        color: Colors.green,
      );
    });
  }

  void _handleProfileClick() {
    if (Provider.of<LayoutProvider>(context, listen: false).lauoutMode == 3) {
      Map profileData = {};
      profileData['withUser'] = withUser.toString();
      profileData['title'] = this.title;
      profileData['bloc'] = _bloc;
      profileData['me'] = this.me;

      EventBusUtils.getInstance().fire(ProfileClickedEvent(profileData));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  withUser: withUser.toString(),
                  title: this.title,
                  bloc: _bloc,
                  me: this.me,
                )),
      );
    }
  }

  Widget _getAppBar() {
    return AppBar(
      backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: isDeleteSelected
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  this.isDeleteSelected = false;
                  this.threadObjList = [];
                  _bloc.joinRoom(this.chatModel.roomId);
                });
              },
            )
          : IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
      title: isDeleteSelected
          ? Text('$selectedLength')
          : Center(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: GestureDetector(
                      onTap: () => _handleProfileClick(),
                      child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageUrl: AppConstants.getUserImagePath() +
                            this.withUser.toString() +
                            "?kycImage=0",
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    this.title,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
      actions: isDeleteSelected
          ? <Widget>[
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteDialog(this.threadObjList);
                  print('done ........');
                },
              )
            ]
          : <Widget>[
              GestureDetector(
                  child: Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.video_call)),
                  onTap: () {
                    videocall();
                  })
            ],
    );
  }

  Future<void> _showDeleteDialog(msgObj) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: msgObj.length > 1
                ? Text('Do you want to delete these messages?')
                : Text("Do you want to delete this message?"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                "Delete",
              ),
              onPressed: () {
                //Navigator.pop(context);
                // Thread thread = _bloc.chat.history.threads[index];
                // print('this is message object');
                // print(thread.toMap());
                Navigator.of(context).pop();
                print(threadObjList[0].message);
                this.threadObjList.forEach((element) {
                  print(element.message);
                  _bloc.deleteMessage(_bloc.myTagcashId, element.toMap());
                });
                setState(() {
                  this.isDeleteSelected = false;
                  this.threadObjList = [];
                });
                _bloc.joinRoom(this.chatModel.roomId);
              },
            ),
          ],
        );
      },
    );
  }

  onItemDeSelectFn(Thread threadObj) {
    print('it is deselect');
    print(this.threadObjList.length);
    setState(() {
      this.threadObjList.removeWhere((element) => element.id == threadObj.id);
      selectedLength = threadObjList.length;
    });
    if (this.threadObjList.length == 0) {
      setState(() {
        this.isDeleteSelected = false;
        this.enableTapOrLongPress = false;
      });
    }
    print(this.threadObjList.length);
  }

  onItemSelectFn(Thread threadObj) {
    print(threadObj);
    this.threadObjList.add(threadObj);
    print(this.threadObjList.length);
    if (mounted) {
      setState(() {
        this.isDeleteSelected = true;
        this.enableTapOrLongPress = true;
        selectedLength = threadObjList.length;
      });
    }
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) => Observer(builder: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_bloc.isPreviousChatLoaded) {
            int scrollpos = this.lastItemIndex;
            print(scrollpos);
            itemScrollController.jumpTo(index: scrollpos);
          }
        });
        switch (_bloc.convStatus) {
          case FutureStatus.pending:
            return Scaffold(
              appBar: _getAppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 5,
                    ),
                    Text("loading...")
                  ],
                ),
              ),
            );

          case FutureStatus.rejected:
            return Scaffold(
              appBar: _getAppBar(),
              // appBar: AppTopBar(appBar: AppBar(), title: this.title),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Something went wrong!',
                      style: TextStyle(color: Colors.red),
                    ),
                    RaisedButton(
                      child: const Text('Tap to try again'),
                      onPressed: () => _bloc.joinRoom(this.chatModel.roomId),
                    )
                  ],
                ),
              ),
            );
          case FutureStatus.fulfilled:
            return Scaffold(
              appBar: _getAppBar(),
              body: NotificationListener<ScrollNotification>(
                // ignore: missing_return
                onNotification: (scrollNotification) {
                  this.lastItemIndex =
                      itemPositionsListener.itemPositions.value.last.index;
                  if (lastItemIndex == _bloc.chat.history.threads.length - 1) {
                    // // _scrollController.offset;
                    loadMore(context);
                    // // return true;
                  }
                },
                child: Column(
                  children: <Widget>[
                    _bloc.reachedEnd == true
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            color: Colors.yellow,
                            child: (_bloc.reachedEnd
                                ? Text("No more messages")
                                : Text("")),
                          )
                        : Container(),
                    Flexible(
                      child: Scrollbar(
                        child: Observer(
                          builder: (_) => ScrollablePositionedList.builder(
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              padding: EdgeInsets.all(3.0),
                              reverse: true,
                              itemCount: _bloc.chat.history.threads.length,
                              itemBuilder: (_, int index) {
                                Thread thread =
                                    _bloc.chat.history.threads[index];
                                var datetime;
                                DateTime now = DateTime.now();
                                var incomingDate =
                                    DateTime.parse(thread.createdDate).toUtc();
                                DateFormat formatNew = DateFormat('h:mm a');
                                datetime = formatNew
                                    .format(incomingDate.toLocal())
                                    .toString();
                                datetime = formatNew
                                    .format(incomingDate.toLocal())
                                    .toString();

                                if (thread.isVisible == 'true') {
                                  return Column(
                                    children: [
                                      ChatMessage(
                                        uniqMessageId: thread.id,
                                        //for multi delete
                                        onItemSelectFn: onItemSelectFn,
                                        onItemDeSelectFn: onItemDeSelectFn,
                                        enableTapOrLongPress:
                                            enableTapOrLongPress,
                                        //for multi delete
                                        type: thread.type,
                                        date: datetime,
                                        text: thread.message,
                                        msg: thread.message,
                                        // msg: thread.message,
                                        docId: thread.docId,
                                        title: this.title,
                                        status: thread.status,
                                        roomId: thread.roomId,
                                        msgId: _bloc.lastmsgId,
                                        senderId: thread.senderInfo.tagcashId,
                                        bloc: _bloc,
                                        withId: this.withUser,
                                        id: this.me,
                                        index: index,
                                        textColor:
                                            (thread.senderInfo.tagcashId ==
                                                    this.me
                                                ? Colors.white
                                                : Colors.black),
                                        bgColor: (thread.senderInfo.tagcashId ==
                                                this.me
                                            ? Colors.red
                                            : Colors.white),
                                        alignMsg:
                                            (thread.senderInfo.tagcashId ==
                                                    this.me
                                                ? 'right'
                                                : 'left'),
                                      ),
                                      Container(
                                        height: 40,
                                        child: Chip(
                                            padding: EdgeInsets.all(0),
                                            label: Text(
                                              thread.sortedDate.toString(),
                                              style: TextStyle(fontSize: 10),
                                            )),
                                      ),
                                    ],
                                  );
                                } else {
                                  return ChatMessage(
                                    uniqMessageId: thread.id,
                                    //for multi delete
                                    onItemSelectFn: onItemSelectFn,
                                    onItemDeSelectFn: onItemDeSelectFn,
                                    enableTapOrLongPress: enableTapOrLongPress,
                                    //for multi delete
                                    type: thread.type,
                                    date: datetime,
                                    text: thread.message,
                                    msg: thread.message,
                                    docId: thread.docId,
                                    title: this.title,
                                    status: thread.status,
                                    roomId: thread.roomId,
                                    msgId: _bloc.lastmsgId,
                                    senderId: thread.senderInfo.tagcashId,
                                    bloc: _bloc,
                                    withId: this.withUser,
                                    id: this.me,
                                    index: index,
                                    textColor:
                                        (thread.senderInfo.tagcashId == this.me
                                            ? Colors.white
                                            : Colors.black),
                                    bgColor:
                                        (thread.senderInfo.tagcashId == this.me
                                            ? Colors.red
                                            : Colors.white),
                                    alignMsg:
                                        (thread.senderInfo.tagcashId == this.me
                                            ? 'right'
                                            : 'left'),
                                  );
                                }
                              }),
                        ),
                      ),
                    ),
                    Divider(height: 1.0),
                    Column(
                      children: [
                        Container(
                          decoration:
                              BoxDecoration(color: Theme.of(context).cardColor),
                          child: _buildTextComposer(),
                        ),
                        isEmojiEnabled
                            ? Offstage(
                                child: AddEmoji(emojiSelected),
                                offstage: !isEmojiEnabled,
                              )
                            : SizedBox()
                      ],
                    ),
                  ],
                ),
              ),
            );
        }
      });
}
