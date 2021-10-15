import 'package:flutter/material.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/dating/models/dating_user_details.dart';
import 'package:tagcash/apps/dating/models/chat_message.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:tagcash/components/custom_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingISendMessageScreen extends StatefulWidget {
  bool isLoading = false;
  final String profileId;
  final String profileNickname;
  final DatingUserDetails datingUserDetails;
  FocusNode sellFocusNode;

  DatingISendMessageScreen(
      {@required this.profileId,
      @required this.profileNickname,
      @required this.datingUserDetails});

  @override
  _DatingISendMessageScreen createState() =>
      _DatingISendMessageScreen(profileId, profileNickname);
}

class _DatingISendMessageScreen extends State<DatingISendMessageScreen> {
  bool messageSendingPossible = true;
  bool networkCompleteFlag = true;
  final _formKey = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldState>();
  bool enableAutoValidate = false;
  bool saveClickPossible = true;
  File _imageFile;
  final picker = ImagePicker();
  FocusNode sellFocusNode;
  TextEditingController _amountController;
  int offsetApi = 0;
  bool _isLoading = false;
  final scrollController = ScrollController();
  List<ChatMessageModel> messageList = new List<ChatMessageModel>();
  List<ChatMessageModel> originalmessageList = new List<ChatMessageModel>();
  TextEditingController textEditingController;
  String profileNickname;
  String profileId;
  String senderImageUrl;
  int walletId;

  String currencyCode;
  List<Wallet> walletsList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    sellFocusNode = FocusNode();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
          // You're at the top.

        } else {
          // You're at the bottom.


          int sentMessageLength = 0;
          /*This code is required here, otherwise the newly added messages(with ID 1) will added to the messa
         * whole messages list and will cause duplication when do load more pagination
         * For example we load 10 messages and add 4 extara messages from user side, but when do load
         * more pagination the total message list count will be 18
         * */
          messageList.forEach((message) {
            if (message.id == "1") {
              sentMessageLength++;
            }
          });
          if (sentMessageLength > 0) {
            scrollController.jumpTo(scrollController.position.minScrollExtent);
            offsetApi = 0;
            messageList.clear();
          } else {
            offsetApi = offsetApi + 10;
          }
          loadMoreMessages();
        }
      }
    });
    textEditingController = TextEditingController();
    loadMessagesProcessHandler();
  }

  showSnackBar(String message) {
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFe44933),
        content: Text(message),
      ),
    );
    */
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[600]));
  }

  void loadUserProfile(String userId) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = userId;
    // apiBodyObj['id'] = "16060";
    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      List responseList = response['result'];
      Map userDetail = responseList[0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailUserScreen(
            userData: responseList[0],
          ),
        ),
      );
    }
  }

  void loadMoreMessages() {
    //  offsetApi = offsetApi + 10;
    loadMessagesProcessHandler();
  }

  _DatingISendMessageScreen(profileId, profileNickname) {
    this.profileId = profileId;
    this.profileNickname = profileNickname;
  }

  void addNewMessage() {
    if (textEditingController.text.trim().isNotEmpty) {}
  }

  String getMessageDateTime(String messageSentDateTime) {
    List<String> spliiedDatetime = messageSentDateTime.split(" ");
    DateTime now = DateTime.now();
    DateTime serverDateTime = DateTime.parse(spliiedDatetime[0]);
    int difference = now.difference(serverDateTime).inDays;

    if (difference > 0) {
      DateFormat messageDateTimeFormat = DateFormat('dd-MM-yyyy').add_jm();
      DateTime serverDateTime = DateTime.parse(messageSentDateTime);
      String formattedDateTime = messageDateTimeFormat.format(serverDateTime);

      return formattedDateTime;
    } else {
      DateFormat messageDateTimeFormat = DateFormat('dd-MM-yyyy').add_jm();
      DateTime serverDateTime = DateTime.parse(messageSentDateTime);
      String formattedDateTime = messageDateTimeFormat.format(serverDateTime);

      List<String> spliiedDatetime = formattedDateTime.split(" ");
      return spliiedDatetime[1] + " " + spliiedDatetime[2];
    }
  }

  void loadMessagesProcessHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['to_profile_id'] = profileId;
    apiBodyObj['page_count'] = "10";
    apiBodyObj['page_offset'] = offsetApi.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/GetMessages', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {

      senderImageUrl = response['image_urls']["sender_image"];
      List responseList = response['messages'];
      responseList.forEach((message) {

        DateFormat messageDateTimeFormat = DateFormat('dd-MM-yyyy').add_jm();
        DateTime serverDateTime = DateTime.parse(message["created_date"]);
        String formattedDateTime = messageDateTimeFormat.format(serverDateTime);

        String messageId = message["_id"]["\$id"];
        String messageType = message["message_type"];

        String messageDateTime = getMessageDateTime(message["created_date"]);
        String profileImageUrl = message["profile_image_url"];
        bool ownMessageStatus = true;
        if (message["own_message"] == 1) {
          ownMessageStatus = true;
        } else {
          ownMessageStatus = false;
        }
        String fileImageUrl;
        String messageComment;
        String messageSenderTagcashId;
        String voucherCode;
        bool voucherRedeemed = true;
        switch (messageType) {
          case "image":
            fileImageUrl = message["message"];
            messageComment = message["message"].toString();
            break;
          case "text":
            fileImageUrl = null;
            messageComment = message["message"].toString();
            break;
          case "tag-profile":

            fileImageUrl = null;
            if (ownMessageStatus == true) {
              messageComment = message["message"].toString();
              messageSenderTagcashId = response["profile_tagcash_ids"]
                      ["sender-tagcashuserid"]
                  .toString();
            } else {
              messageSenderTagcashId = response["profile_tagcash_ids"]
                      ["receivertgacashuserid"]
                  .toString();
              messageComment = response["profile_nick_names"]
                      ["receiver_nick_name"] +
                  " shared TAG Profile";
            }
            break;
          case "send-money":

            fileImageUrl = null;
            voucherCode = message["message"].toString();
            List<String> messageMoneyTypeList = voucherCode.split("-");
            String moneyCurrenyCode = messageMoneyTypeList[0].toString();
            if (ownMessageStatus == true) {

              messageComment = "Sent " +
                  message["voucher_details"]["voucher_data"]["voucher_amount"]
                      .toString() +
                  " " +
                  moneyCurrenyCode;
            } else {

              int voucherStatus =
                  message["voucher_details"]["voucher_data"]["voucher_status"];
              if (voucherStatus == 1) {
                voucherRedeemed = false;
                messageComment = response["profile_nick_names"]
                        ["receiver_nick_name"] +
                    " has sent you " +
                    message["voucher_details"]["voucher_data"]["voucher_amount"]
                        .toString() +
                    " " +
                    moneyCurrenyCode +
                    "  Click here to add to your wallet";
              } else if (voucherStatus == 2) {
                voucherRedeemed = true;
                messageComment = "Received " +
                    message["voucher_details"]["voucher_data"]["voucher_amount"]
                        .toString() +
                    " " +
                    moneyCurrenyCode +
                    " from " +
                    response["profile_nick_names"]["receiver_nick_name"];
              } else if (voucherStatus == 3) {
                voucherRedeemed = true;
                messageComment = "Send Money expired";
              } else if (voucherStatus == 0) {
                voucherRedeemed = true;
                messageComment = "Send Money expired";
              } else {
                voucherRedeemed = true;
                messageComment = "Send Money expired";
              }
            }
            break;
        }

        ChatMessageModel newMessage = ChatMessageModel(
            comment: messageComment,
            image: profileImageUrl,
            sendingStatus: "sent-success",
            dateTime: messageDateTime,
            time: messageDateTime,
            ownStatus: ownMessageStatus,
            id: messageId,
            type: messageType,
            imgfilepathUrl: fileImageUrl,
            tagcashSenderId: messageSenderTagcashId,
            voucherCode: voucherCode,
            voucherRedeemStatus: voucherRedeemed);
        messageList.add(newMessage);
      });
    }
  }

  Future<int> checkVoucherIsRedeemed(String voucherCode) async {
    setState(() {
      networkCompleteFlag = false;
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['voucher'] = voucherCode;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Voucher/GetVoucherDetailsFromVoucherId', apiBodyObj);

    setState(() {
      _isLoading = false;
      networkCompleteFlag = true;
    });
    if (response["status"] == "success") {

      if (response['result']['voucher_status'] == 1) {
        return 1;
      } else if (response['result']['voucher_status'] == 2) {
        return 2;
      } else if (response['result']['voucher_status'] == 3) {
        return 3;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  void sendMessageProcessHandler() async {

    if (textEditingController.text.trim().isNotEmpty) {
      DateTime now = DateTime.now();
      //  String formattedDate = DateFormat('yyyy-MM-dd  j:m:s').format(now);
      DateFormat dateFormat = DateFormat('yyyy-MM-dd').add_jm();
      String formattedDate = dateFormat.format(now);

      DateFormat dateFormatYear = DateFormat('yyyy-MM-dd').add_Hm();
      String formattedDateYear = dateFormatYear.format(now);

      List<String> spliiedDatetime = formattedDate.split(" ");

      ChatMessageModel newMessage = ChatMessageModel(
        comment: textEditingController.text.trim().toString(),
        image: senderImageUrl,
        sendingStatus: "sending-success",
        dateTime: spliiedDatetime[0],
        time: spliiedDatetime[1] + " " + spliiedDatetime[2],
        ownStatus: true,
        id: "1",
        type: "text",
        imgfilepathUrl: null,
        tagcashSenderId: null,
      );

      setState(() {
        if (messageList.length > -1) {
          originalmessageList.clear();
          originalmessageList.addAll(messageList.reversed.toList());
          originalmessageList.add(newMessage);
          List<ChatMessageModel> reversedList =
              originalmessageList.reversed.toList();
          reversedList.forEach((country) {

          });
          messageList.clear();
          messageList.addAll(reversedList);

          textEditingController.text = "";
        } else {

        }
      });
    }
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['to_profile_id'] = profileId;
    apiBodyObj[' message_type'] = "text";
    apiBodyObj[' message'] = messageList.first.comment.toString();
    messageSendingPossible = false;
    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/SendMessage', apiBodyObj);

    if (response["status"] == "success") {

      messageSendingPossible = true;
      ChatMessageModel currentMessage = originalmessageList.last;
      String image = currentMessage.image;
      String comment = currentMessage.comment;
      String sendingStatus = "sent-success";
      String dateTime = currentMessage.dateTime;
      String time = currentMessage.time;
      ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-success",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "text",
          imgfilepathUrl: null,
          tagcashSenderId: null,
          voucherCode: null,
          voucherRedeemStatus: false);

      originalmessageList.remove(currentMessage);
      originalmessageList.add(newMessage);
      List<ChatMessageModel> reversedList =
          originalmessageList.reversed.toList();
      reversedList.forEach((country) {

      });
      messageList.clear();
      messageList.addAll(reversedList);
    } else {

      messageSendingPossible = true;
      ChatMessageModel currentMessage = originalmessageList.last;
      String image = currentMessage.image;
      String comment = currentMessage.comment;
      String sendingStatus = "sent-failed";
      String dateTime = currentMessage.dateTime;
      String time = currentMessage.time;
      ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-failed",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "text",
          tagcashSenderId: null,
          voucherRedeemStatus: false);
      originalmessageList.remove(currentMessage);
      originalmessageList.add(newMessage);
      List<ChatMessageModel> reversedList =
          originalmessageList.reversed.toList();

      reversedList.forEach((country) {

      });
      messageList.clear();
      messageList.addAll(reversedList);
      if (response["error"] == "insufficient_cred_balance_to_send_message") {
        showSnackBar(getTranslated(context, "dating_insufficient_balance"));
      }
    }
    setState(() {
      messageList.forEach((country) {

      });
    });
  }

  Future getImage(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Color(0xFFe44933),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      );

      if (croppedFile != null) {
        setImage(_imageFile = croppedFile, croppedFile.path);
      }
    }
  }

  void setImage(File imageFile, String filePath) {

    addImagetoMessageList(filePath);
  }

  void addImagetoMessageList(String imageFilePath) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd').add_jm();
    String formattedDate = dateFormat.format(now);

    DateFormat dateFormatYear = DateFormat('yyyy-MM-dd').add_Hm();
    String formattedDateYear = dateFormatYear.format(now);

    List<String> spliiedDatetime = formattedDate.split(" ");

    ChatMessageModel newMessage = ChatMessageModel(
        comment: "image-no comment",
        image: senderImageUrl,
        sendingStatus: "sending-success",
        dateTime: spliiedDatetime[0],
        time: spliiedDatetime[1] + " " + spliiedDatetime[2],
        ownStatus: true,
        id: "1",
        type: "image",
        imgfilepathUrl: imageFilePath,
        tagcashSenderId: null,
        voucherRedeemStatus: false);
    setState(() {
      if (messageList.length > -1) {
        originalmessageList.clear();
        originalmessageList.addAll(messageList.reversed.toList());
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      } else {

      }
    });
    Map<String, dynamic> fileData;
    if (_imageFile != null) {
      var file = _imageFile;
      String basename = path.basename(file.path);
      fileData = {};
      fileData['key'] = 'file_data';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
    }
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Messaging/UploadMessageFile', apiBodyObj, fileData);

    if (response['status'] == 'success') {

      /**Here call another API to send image name to message send API*/
      sendImagenameProcessHandler(response["image_name"]);
    } else {
      ChatMessageModel currentMessage = originalmessageList.last;
      String image = currentMessage.image;
      String comment = currentMessage.comment;
      String sendingStatus = "sent-failed";
      String dateTime = currentMessage.dateTime;
      String time = currentMessage.time;
      String filepathimage = currentMessage.imgfilepathUrl;
      ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-failed",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "image",
          imgfilepathUrl: filepathimage,
          tagcashSenderId: null,
          voucherRedeemStatus: false);
      originalmessageList.remove(currentMessage);
      originalmessageList.add(newMessage);
      List<ChatMessageModel> reversedList =
          originalmessageList.reversed.toList();
      reversedList.forEach((country) {

      });
      messageList.clear();
      messageList.addAll(reversedList);
    }
    setState(() {
      messageList.forEach((country) {

      });
    });
  }

  void sendImagenameProcessHandler(String imageName) async {

    messageSendingPossible = false;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['to_profile_id'] = profileId;
    apiBodyObj[' message_type'] = "image";
    apiBodyObj[' message'] = imageName;
    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/SendMessage', apiBodyObj);

    if (response['status'] == 'success') {

      messageSendingPossible = true;
      setState(() {
        ChatMessageModel currentMessage = originalmessageList.last;
        String image = currentMessage.image;
        String comment = currentMessage.comment;

        String dateTime = currentMessage.dateTime;
        String time = currentMessage.time;
        String fileImagepath = currentMessage.imgfilepathUrl;
        ChatMessageModel newMessage = ChatMessageModel(
            comment: comment,
            image: image,
            sendingStatus: "sent-success",
            dateTime: dateTime,
            time: time,
            ownStatus: true,
            id: "1",
            type: "image",
            imgfilepathUrl: fileImagepath,
            tagcashSenderId: null,
            voucherRedeemStatus: false);
        originalmessageList.remove(currentMessage);
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      });
    } else {

      messageSendingPossible = true;
      ChatMessageModel currentMessage = originalmessageList.last;
      String image = currentMessage.image;
      String comment = currentMessage.comment;

      String dateTime = currentMessage.dateTime;
      String time = currentMessage.time;
      String filepathimage = currentMessage.imgfilepathUrl;
      ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-failed",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "image",
          imgfilepathUrl: filepathimage,
          tagcashSenderId: null,
          voucherRedeemStatus: false);
      originalmessageList.remove(currentMessage);
      originalmessageList.add(newMessage);
      List<ChatMessageModel> reversedList =
          originalmessageList.reversed.toList();
      reversedList.forEach((country) {

      });
      messageList.clear();
      messageList.addAll(reversedList);
    }
  }

  void selectImageClicked() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined),
                            Text(
                              getTranslated(context, "camera"),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        getImage(ImageSource.camera);
                      }),
                  SizedBox(width: 30),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo),
                            Text(
                              getTranslated(context,"dating_gallery"),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      }),
                ],
              ),
            ),
          );
        });
  }

  void showMessageOptions() {
    setState(() {
      sellFocusNode.canRequestFocus = false;
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
              child: Column(
                children: [
                  const Divider(
                    height: 4,
                    color: Colors.white,
                    thickness: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(
                        getTranslated(context, 'dating_message_sendmoney'),
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      color: Colors.grey[500],
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      textColor: Colors.black,
                      onPressed: () {
                        sendMoneyProcessHandler();
                      },
                    ),
                  ),
                  const Divider(
                    height: 4,
                    color: Colors.black,
                    thickness: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(
                        getTranslated(context, 'dating_message_sendimage'),
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      color: Colors.grey[500],
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      textColor: Colors.black,
                      onPressed: () {

                        Navigator.pop(context);
                        selectImageClicked();
                      },
                    ),
                  ),
                  const Divider(
                    height: 4,
                    color: Colors.black,
                    thickness: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(
                        getTranslated(context,"dating_buy_gift"),
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      color: Colors.grey[500],
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      textColor: Colors.black,
                      onPressed: () {},
                    ),
                  ),
                  const Divider(
                    height: 4,
                    color: Colors.black,
                    thickness: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: double.infinity,
                    child: RaisedButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Text(
                        getTranslated(context, 'dating_share_tagprofile'),
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      color: Colors.grey[500],
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.pop(context);
                        shareTagProfileProcessHandler();
                      },
                    ),
                  ),
                  const Divider(
                    height: 4,
                    color: Colors.black,
                    thickness: 0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void shareTagProfileProcessHandler() async {

    DateTime now = DateTime.now();
    //  String formattedDate = DateFormat('yyyy-MM-dd  j:m:s').format(now);
    DateFormat yearDateFormat = DateFormat('yyyy-MM-dd').add_jm();
    String formattedDate = yearDateFormat.format(now);
    DateFormat yearDateFormatHm = DateFormat('yyyy-MM-dd').add_Hm();
    String formattedDateYear = yearDateFormatHm.format(now);

    List<String> spliiedDatetime = formattedDate.split(" ");

    ChatMessageModel newMessage = ChatMessageModel(
        comment: getTranslated(context, "dating_shared_mytagprofile"),
        image: senderImageUrl,
        sendingStatus: "sending-success",
        dateTime: spliiedDatetime[0],
        time: spliiedDatetime[1] + " " + spliiedDatetime[2],
        ownStatus: true,
        id: "1",
        type: "tag-profile",
        imgfilepathUrl: null);
    setState(() {
      if (messageList.length > -1) {
        originalmessageList.clear();
        originalmessageList.addAll(messageList.reversed.toList());
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        messageList.clear();
        messageList.addAll(reversedList);
        textEditingController.text = "";
      } else {

      }
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['to_profile_id'] = profileId;
    apiBodyObj['message_type'] = "tag-profile";
    apiBodyObj[' message'] = "Shared My TAG Profile";
    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/SendMessage', apiBodyObj);

    if (response['status'] == 'success') {

      setState(() {
        ChatMessageModel currentMessage = originalmessageList.last;
        String image = currentMessage.image;
        String comment = currentMessage.comment;
        String sendingStatus = "sent-success";
        String dateTime = currentMessage.dateTime;
        String time = currentMessage.time;
        ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-success",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "tag-profile",
          imgfilepathUrl: null,
        );

        originalmessageList.remove(currentMessage);
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      });
    } else {

      setState(() {
        ChatMessageModel currentMessage = originalmessageList.last;
        String image = currentMessage.image;
        String comment = currentMessage.comment;
        String sendingStatus = "sent-failed";
        String dateTime = currentMessage.dateTime;
        String time = currentMessage.time;
        ChatMessageModel newMessage = ChatMessageModel(
          comment: comment,
          image: image,
          sendingStatus: "sent-failed",
          dateTime: dateTime,
          time: time,
          ownStatus: true,
          id: "1",
          type: "tag-profile",
        );
        originalmessageList.remove(currentMessage);
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();

        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      });
    }
  }

  void messageOnClickProcessHandler([ChatMessageModel obj]) {

    if (obj.type == "tag-profile") {
      if (obj.ownStatus == false) {

        loadUserProfile(obj.tagcashSenderId);
      }
    } else if (obj.type == "send-money") {
      if (obj.ownStatus == false) {

        if (obj.voucherRedeemStatus == false) {

          voucherRedeemProcessHandler(obj.voucherCode);
        }
      }
    } else if (obj.type == "image") {

      showImage(obj.imgfilepathUrl);
    }

  }

  void sendMoneyProcessHandler() {

    _amountController.text = "";
    Navigator.pop(context);
    buildWalletRow(Wallet row) {
      return Card(
          child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        title: Text(
          row.walletName,
        ),
        subtitle: Text(row.currencyCode),
        onTap: () {
          setState(() {

            walletId = row.walletId;
            currencyCode = row.currencyCode;
          });

          Navigator.of(context).pop(true);
        },
      ));
    }

    ListView buildWalletList(data) {
      return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: data.length,
          itemBuilder: (context, i) {
            return buildWalletRow(data[i]);
          });
    }

    Future<List<Wallet>> getWalletList() async {

      if (walletsList.length == 0) {
        Map<String, dynamic> response =
            await NetworkHelper.request('wallet/list');

        if (response["status"] == "success") {
          List responseList = response['result'];
          List<Wallet> getData = responseList.map<Wallet>((json) {
            return Wallet.fromJson(json);
          }).toList();
          walletsList = getData;
          return getData;
        }
      }
      return walletsList;
    }

    popupElements(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              getTranslated(context, 'choose_wallet'),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Center(
            child: SizedBox(
              width: 40,
              height: 2.5,
              child: DecoratedBox(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          Container(
            height: 360.0, // Change as per your requirement
            // width: 300.0, // Change as per your requirement
            child: FutureBuilder<List<Wallet>>(
              future: getWalletList(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                if (snapshot.hasData) {
                  List<Wallet> data = snapshot.data;
                  return buildWalletList(data);
                }
                return Center(
                  child: new SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: const CircularProgressIndicator()),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget dialogContent(BuildContext context) {
      return Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: 15.0,
              ),
              margin: EdgeInsets.only(top: 13.0, right: 8.0),
              decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.grey[800]
                      : Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 0.0,
                      offset: Offset(0.0, 0.0),
                    ),
                  ]),
              child: popupElements(context),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget paymentWalletDialog(BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      );
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState
                  /*You can rename this!*/) {
            return Container(
                child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Container(
                      child: Form(
                          key: _formKey,
                          autovalidateMode: enableAutoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              Text(
                                  getTranslated(context, "dating_voucher_text"),
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.normal,
                                  )),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  FlatButton(
                                    height: 44,
                                    minWidth: 100,
                                    onPressed: () async {
                                      final result = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              paymentWalletDialog(context));
                                      if (result) {
                                        setState(() => {});
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      //side: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          (currencyCode == null ||
                                                  currencyCode == 'null' ||
                                                  currencyCode.isEmpty)
                                              ? getTranslated(
                                                  context, "select_wallet")
                                              : currencyCode,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: 25),
                                  Expanded(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return getTranslated(
                                              context, 'enter_a_valid_amount');
                                        }
                                        if (walletId == null) {
                                          return getTranslated(
                                              context, 'dating_select_wallet');
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      controller: _amountController,
                                      decoration: InputDecoration(
                                        labelText:
                                            getTranslated(context, 'amount'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    label: getTranslated(context, "dating_send_money"),
                                    onPressed: saveClickPossible
                                        ? () {
                                            setState(() {

                                              enableAutoValidate = true;
                                            });
                                            if (_formKey.currentState
                                                .validate()) {


                                              voucherGenerateProcess();
                                            } else {

                                            }
                                          }
                                        : null,
                                  ))
                            ],
                          )),
                    )),
              ),
            ));
          });
        });


  }

  void voucherGenerateProcess() async {

    Navigator.pop(context);
    FocusScope.of(context).requestFocus(new FocusNode());

    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> response;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['open'] = "1";
    apiBodyObj['voucher_count'] = "1";
    apiBodyObj['unique_code'] = "1";
    apiBodyObj['redemption_per_user'] = "1";
    apiBodyObj['amount'] = _amountController.text.toString();

    apiBodyObj['wallet_id'] = walletId.toString();
    apiBodyObj['expiration_type'] = "2";
    apiBodyObj['expires_at'] = "7";
    apiBodyObj['redemption_charge_creator'] = "redeemer";
    response = await NetworkHelper.request('voucher/generate', apiBodyObj);


    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {

      List<dynamic> voucherCodeArray = response['result']["codes"].toList();
      //String voucherCode=voucherCodeArray.replaceAll(RegExp('[’]’'), "");

      addMoneyToMessageList(voucherCodeArray[0]);
    } else {
      if (response["error"] == 'insuffcient_balance') {
        showSnackBar(getTranslated(context, "insufficient_balance"));
      } else {
        showSnackBar(getTranslated(context, "dating_voucher_error"));
      }
    }
/*Check this voucher code is redeemed or not*/
  }

  void voucherRedeemProcessHandler(String voucherCode) async {

    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['voucher'] = voucherCode;
    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/redeem', apiBodyObj);
    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {

      offsetApi = 0;
      messageList.clear();
      loadMoreMessages();
    } else {
      if (response['error'] == 'invalid_or_expired_voucher') {
        showSnackBar(getTranslated(context, "dating_voucher_invalid"));
      } else if (response['error'] == 'expired_voucher') {
        showSnackBar(getTranslated(context, "dating_voucher_expired"));
      } else if (response['error'] == 'Insufficient') {
        showSnackBar(getTranslated(context, "dating_voucher_insufficientfund"));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  void addMoneyToMessageList(String voucherCode) async {
    DateTime now = DateTime.now();
    //  String formattedDate = DateFormat('yyyy-MM-dd  j:m:s').format(now);
    DateFormat yearDateFormat = DateFormat('yyyy-MM-dd').add_jm();
    String formattedDate = yearDateFormat.format(now);
    DateFormat yearDateFormatHm = DateFormat('yyyy-MM-dd').add_Hm();
    List<String> spliiedDatetime = formattedDate.split(" ");

    ChatMessageModel newMessage = ChatMessageModel(
      comment: "Sending " +
          _amountController.text.toString() +
          " " +
          currencyCode +
          " to " +
          profileNickname,
      image: senderImageUrl,
      sendingStatus: "sending-success",
      dateTime: spliiedDatetime[0],
      time: spliiedDatetime[1] + " " + spliiedDatetime[2],
      ownStatus: true,
      id: "1",
      type: "send-money",
      imgfilepathUrl: null,
    );
    setState(() {
      if (messageList.length > -1) {
        originalmessageList.clear();
        originalmessageList.addAll(messageList.reversed.toList());
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        messageList.clear();
        messageList.addAll(reversedList);
        textEditingController.text = "";
      } else {

      }
    });
    messageSendingPossible = false;
    Map<String, String> apiBodyObj = {};
    apiBodyObj['to_profile_id'] = profileId;
    apiBodyObj['message_type'] = "send-money";
    //apiBodyObj[' message'] = "Sent "+_amountController.text.toString()+" PHP "+voucherCode;
    apiBodyObj[' message'] = voucherCode;
    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/SendMessage', apiBodyObj);

    if (response['status'] == 'success') {

      messageSendingPossible = true;
      setState(() {
        ChatMessageModel currentMessage = originalmessageList.last;
        String image = currentMessage.image;
        String comment = currentMessage.comment;

        String dateTime = currentMessage.dateTime;
        String time = currentMessage.time;
        ChatMessageModel newMessage = ChatMessageModel(
            comment: "Sent " +
                _amountController.text.toString() +
                " " +
                currencyCode +
                " to " +
                profileNickname,
            image: image,
            sendingStatus: "sent-success",
            dateTime: dateTime,
            time: time,
            ownStatus: true,
            id: "1",
            type: "send-money",
            imgfilepathUrl: null);
        originalmessageList.remove(currentMessage);
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      });
    } else {

      messageSendingPossible = true;
      setState(() {
        ChatMessageModel currentMessage = originalmessageList.last;
        String image = currentMessage.image;
        String comment = currentMessage.comment;
        String dateTime = currentMessage.dateTime;
        String time = currentMessage.time;
        ChatMessageModel newMessage = ChatMessageModel(
            comment: comment,
            image: image,
            sendingStatus: "sent-failed",
            dateTime: dateTime,
            time: time,
            ownStatus: true,
            id: "1",
            type: "send-money");
        originalmessageList.remove(currentMessage);
        originalmessageList.add(newMessage);
        List<ChatMessageModel> reversedList =
            originalmessageList.reversed.toList();
        reversedList.forEach((country) {

        });
        messageList.clear();
        messageList.addAll(reversedList);
      });
    }
  }

  void handleWalletChange(Wallet wallet) {
    setState(() {

      walletId = wallet.walletId;
      currencyCode = wallet.currencyCode;
      _amountController.text = "1200";
    });
  }

  void showImage(String imagePath) {

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20.0),
              child: imagePath.startsWith("https:")
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      placeholder: (context, url) => Container(
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : Image.file(
                      File(imagePath),
                    ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget sendMessageWidget() {}
    Widget buildMessageTextField() {
      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Container(
            height: 50.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: new Container(
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border(
                              top: BorderSide(color: Color(0XFF7E7A78)),
                              bottom: BorderSide(color: Color(0XFF7E7A78)),
                              right: BorderSide(color: Color(0XFF7E7A78)),
                              left: BorderSide(color: Color(0XFF7E7A78)),
                            ),
                            color: Colors.white,
                          ),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(4, 0, 60, 0),
                            child: new TextField(
                              focusNode: sellFocusNode,
                              controller: textEditingController,
                              onTap: () {
                                Timer(
                                    Duration(milliseconds: 300),
                                    () => scrollController.jumpTo(
                                        scrollController
                                            .position.minScrollExtent));
                              },
                              textAlign: TextAlign.start,
                              decoration: new InputDecoration(
                                hintText: getTranslated(
                                    context, 'dating_typehere_sendmessage'),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 48,
                          width: 60,
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: IconButton(
                                icon: RawMaterialButton(
                                  onPressed: () {

                                    showMessageOptions();
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.grey[800],
                                  child: Icon(
                                    Icons.add,
                                    size: 26.0,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(0),
                                  shape: CircleBorder(),
                                ),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              // top: BorderSide(color: Color(0XFF7E7A78)),
                              // bottom: BorderSide(color: Color(0XFF7E7A78)),
                              right: BorderSide(color: Color(0XFF7E7A78)),
                              // left: BorderSide(color: Color(0XFFFFFFFF)),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50.0,
                  child: InkWell(
                    onTap: messageSendingPossible
                        ? () {
                            sendMessageProcessHandler();
                          }
                        : null,
                    child: Icon(
                      Icons.send,
                      color: Color(0xFFdd482a),
                      size: 36.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: profileNickname,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: messageList.length,
                      itemBuilder: (BuildContext context, int index) {
                        ChatMessageModel obj = messageList[index];
                        String imagefilePathUrl = obj.imgfilepathUrl;
                        return GestureDetector(
                          child: Padding(
                              padding: obj.ownStatus
                                  ? const EdgeInsets.fromLTRB(40, 10, 0, 0)
                                  : const EdgeInsets.fromLTRB(0, 10, 40, 0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    child: CachedNetworkImage(
                                      imageUrl: obj.image,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 60.0,
                                        height: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          Container(width: 60, height: 60),
                                      errorWidget: (context, url, error) =>
                                          CircleAvatar(
                                        child: Icon(Icons.person,
                                            color: Colors.white, size: 28),
                                        backgroundColor: Colors.grey,
                                        radius: 26,
                                      ),
                                    ),
                                    onTap: () {

                                      if (!obj.ownStatus)
                                        Navigator.pop(context);
                                    },
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          ConditionalSwitch.single<String>(
                                            context: context,
                                            valueBuilder:
                                                (BuildContext context) =>
                                                    obj.type,
                                            caseBuilders: {
                                              'text': (BuildContext context) =>
                                                  Expanded(
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                              color: Colors
                                                                  .green[100],
                                                              shape: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.0,
                                                              )),
                                                      child: Container(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .fromLTRB(8,
                                                                      6, 2, 2),
                                                              child: Text(
                                                                  obj.comment),
                                                            ),
                                                            Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                // Align however you like (i.e .centerRight, centerLeft)
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          2,
                                                                          4,
                                                                          2),
                                                                  child: Text(
                                                                      obj.time,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                      )),
                                                                ))
                                                          ])),
                                                    ),
                                                  ),
                                              'image': (BuildContext context) =>
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width: 140,
                                                          height: 140,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0XFFB6B2B2),
                                                            image:
                                                                DecorationImage(
                                                              image: imagefilePathUrl
                                                                      .startsWith(
                                                                          'https')
                                                                  ? CachedNetworkImageProvider(obj
                                                                      .imgfilepathUrl)
                                                                  : FileImage(
                                                                      File(obj
                                                                          .imgfilepathUrl)),
                                                              fit: BoxFit.fill,
                                                            ),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0XFFFFFF),
                                                              width: 2,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        Text(obj.time,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Montserrat',
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                              'tag-profile': (BuildContext
                                                      context) =>
                                                  Expanded(
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                              color: Colors
                                                                  .green[100],
                                                              shape: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.0,
                                                              )),
                                                      child: Container(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .fromLTRB(8,
                                                                      6, 2, 2),
                                                              child: Text(
                                                                  obj.comment,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  )),
                                                            ),
                                                            Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                // Align however you like (i.e .centerRight, centerLeft)
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          2,
                                                                          4,
                                                                          2),
                                                                  child: Text(
                                                                      obj.time,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                      )),
                                                                ))
                                                          ])),
                                                    ),
                                                  ),
                                              'send-money': (BuildContext
                                                      context) =>
                                                  Expanded(
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                              color: Colors
                                                                  .green[100],
                                                              shape: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.0,
                                                              )),
                                                      child: Container(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .fromLTRB(8,
                                                                      6, 2, 2),
                                                              child: Text(
                                                                  obj.comment,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  )),
                                                            ),
                                                            Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                // Align however you like (i.e .centerRight, centerLeft)
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          2,
                                                                          4,
                                                                          2),
                                                                  child: Text(
                                                                      obj.time,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                      )),
                                                                ))
                                                          ])),
                                                    ),
                                                  ),
                                            },
                                            fallbackBuilder:
                                                (BuildContext context) =>
                                                    new SizedBox(),
                                          ),
                                          SizedBox(width: 4),
                                          ConditionalSwitch.single<String>(
                                            context: context,
                                            valueBuilder:
                                                (BuildContext context) =>
                                                    obj.sendingStatus,
                                            caseBuilders: {
                                              'sending-success': (BuildContext
                                                      context) =>
                                                  new SizedBox(
                                                      width: 10.0,
                                                      height: 10.0,
                                                      child:
                                                          const CircularProgressIndicator()),
                                              'sent-success':
                                                  (BuildContext context) =>
                                                      new SizedBox(),
                                              'sent-failed':
                                                  (BuildContext context) =>
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        radius: 10,
                                                        child:
                                                            Icon(Icons.error),
                                                      ),
                                            },
                                            fallbackBuilder:
                                                (BuildContext context) =>
                                                    new SizedBox(),
                                          ),
                                        ],
                                      ),
                                      onTap: () {

                                        messageOnClickProcessHandler(obj);
                                      },
                                    ),
                                  )
                                ],
                              )),
                        );
                      }),
                ),
                buildMessageTextField(),
              ],
            ),
            _isLoading ? Center(child: Loading()) : SizedBox()
          ],
        ));
  }
}
