import 'package:flutter/material.dart';
import 'package:tagcash/services/networking.dart';
import 'dart:async';
import 'package:tagcash/apps/dating/models/inbox_outbox_model.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:tagcash/apps/dating/send_message_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingInboxOutboxScreen extends StatefulWidget {
  @override
  _DatingInboxOutboxScreen createState() => _DatingInboxOutboxScreen();
}

class _DatingInboxOutboxScreen extends State<DatingInboxOutboxScreen> {
  final scrollController = ScrollController();
  int offsetApi = 0;
  bool hasMore;
  bool _isLoading;
  bool refreshFlag = true;
  bool isLoading = false;
  List<MessageInboxOutboxData> _unreaddata;
  StreamController<List<MessageInboxOutboxData>> _unreadstreamcontroller;

  bool _isUnreadFlag = true;
  bool _isInboxFlag = false;
  bool _isOutboxFlag = false;
  Color _unreadSelectedColor = Colors.grey;
  Color _unreadSelectedTextColor = Colors.white;
  Color _inboxSelectedColor = Colors.white;
  Color _inboxSelectedTextColor = Colors.black;
  Color _outboxSelectedColor = Colors.white;
  Color _outboxSelectedTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
    loadUnreadMessages();
  }

  void loadUnreadMessages() {
    _unreaddata = List<MessageInboxOutboxData>();
    _unreadstreamcontroller =
        StreamController<List<MessageInboxOutboxData>>.broadcast();
    _isLoading = false;
    hasMore = true;
    loadUnreadMoreItems();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {

        offsetApi = offsetApi + 20;
        loadUnreadMoreItems();
      }
    });
  }

  loadUnreadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _unreaddata = List<MessageInboxOutboxData>();
      _unreadstreamcontroller.add(_unreaddata);
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;
    loadInboxOutboxListData().then((res) {
      _isLoading = false;
      _unreaddata.addAll(res);
      hasMore = (res.length == 20);

      _unreadstreamcontroller.add(_unreaddata);
    });
  }

  Future<List<MessageInboxOutboxData>> loadInboxOutboxListData() async {

    setState(() {
      if (refreshFlag == true) {
        hasMore = false;
        isLoading = true;
        offsetApi = 0;
      } else {
        hasMore = true;
        isLoading = false;
      }
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['page_count'] = '20';
    apiBodyObj['page_offset'] = offsetApi.toString();
    if (_isInboxFlag == true) {
      apiBodyObj['message_overview_type'] = 'inbox';
    } else if (_isOutboxFlag == true) {
      apiBodyObj['message_overview_type'] = 'outbox';
    } else if (_isUnreadFlag == true) {
      apiBodyObj['message_overview_type'] = 'unread';
    } else {
      apiBodyObj['message_overview_type'] = 'inbox';
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('Messaging/messageOverview', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == "success") {
      List responseList = response['result'];
      List<MessageInboxOutboxData> getData =
          responseList.map<MessageInboxOutboxData>((json) {
        return MessageInboxOutboxData.fromJson(json);
      }).toList();
      return getData;
    } else {

      return null;
    }
  }

  Future<void> dataRefresh() {
    _isLoading = false;
    hasMore = true;
    offsetApi = 0;
    refreshFlag = true;
    loadUnreadMoreItems(clearCachedData: true);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    Widget unreadWidgetSection = Stack(children: [
      ListView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          StreamBuilder(
              stream: _unreadstreamcontroller.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                if (snapshot.hasData) {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < snapshot.data.length) {
                          MessageInboxOutboxData obj = snapshot.data[index];
                          String lastmessage = obj.lastMessage.toString();
                          String lastmessageType = obj.lastMessageType;
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: GestureDetector(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            (obj.profileUrl != null)
                                                ? CachedNetworkImage(
                                                    imageUrl: obj.profileUrl,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                                width: 60,
                                                                height: 60),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      width: 60,
                                                      height: 60,
                                                      child: Icon(Icons.person,
                                                          color: Colors.grey,
                                                          size: 48),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    child: Icon(Icons.person,
                                                        color: Colors.grey,
                                                        size: 48),
                                                  ),
                                            obj.onlineStatus == 1
                                                ? Container(
                                                    width: 6,
                                                    height: 60,
                                                    color: Colors.green,
                                                  )
                                                : Container(
                                                    width: 6,
                                                    height: 60,
                                                    color: Colors.red,
                                                  ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  4, 0, 0, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(obj.nickName,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  ConditionalSwitch.single<int>(
                                                    context: context,
                                                    valueBuilder: (BuildContext
                                                            context) =>
                                                        obj.genderId,
                                                    caseBuilders: {
                                                      1: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/" +
                                                                  getTranslated(context, "dating_male")+"/" +
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      2: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/" +
                                                                  getTranslated(context, "dating_female")+"/" +
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      3: (BuildContext
                                                              context) =>
                                                          Text(
                                                              obj.age.toString() +
                                                                  "/"+getTranslated(context, "dating_transgender") +"/"+
                                                                  obj.cityName,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                    },
                                                    fallbackBuilder: (BuildContext
                                                            context) =>
                                                        Text(
                                                            getTranslated(context,"dating_noneofthecase_matched")),
                                                  ),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  ConditionalSwitch.single<
                                                      String>(
                                                    context: context,
                                                    valueBuilder: (BuildContext
                                                            context) =>
                                                        lastmessageType,
                                                    caseBuilders: {
                                                      "text": (BuildContext
                                                              context) =>
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .6,
                                                            child: Text(
                                                                "\"" +
                                                                    obj
                                                                        .lastMessage.toString() +
                                                                    "\"",
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                )),
                                                          ),
                                                      "image": (BuildContext
                                                              context) =>
                                                          Text(
                                                              "\"" +
                                                                  getTranslated(context, "dating_sent_image") +
                                                                  "\"",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      "send-money": (BuildContext
                                                              context) =>
                                                          Text(
                                                              "\"" +
                                                                  getTranslated(context,"dating_sent_money") +
                                                                  "\"",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                      "tag-profile": (BuildContext
                                                              context) =>
                                                          Text(
                                                              "\"" +
                                                                  getTranslated(context,"dating_shared_tagprofile") +
                                                                  "\"",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              )),
                                                    },
                                                    fallbackBuilder: (BuildContext
                                                            context) =>
                                                        Text(
                                                            getTranslated(context,"dating_noneofthecase_matched")),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ])),
                              onTap: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DatingISendMessageScreen(
                                      profileId: obj.id,
                                      profileNickname: obj.nickName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (hasMore) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return SizedBox(
                            width: 0,
                            height: 0,
                          );
                        }
                      });
                } else {
                  return SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
              }),
        ],
      ),
    ]);


    return RefreshIndicator(
        onRefresh: dataRefresh,
        child: Stack(children: [
          ListView(children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(children: [
                Expanded(
                    child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78)),
                                right: BorderSide(color: Color(0XFF7E7A78)),
                                left: BorderSide(color: Color(0XFF7E7A78)),
                              ),
                              color: _unreadSelectedColor),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
                              child: Text(getTranslated(context,"dating_unread"),
                                  style: TextStyle(
                                    color: _unreadSelectedTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            _unreadSelectedColor = Colors.grey;
                            _unreadSelectedTextColor = Colors.white;
                            _inboxSelectedColor = Colors.white;
                            _inboxSelectedTextColor = Colors.black;
                            _outboxSelectedColor = Colors.white;
                            _outboxSelectedTextColor = Colors.black;
                            _isUnreadFlag = true;
                            _isInboxFlag = false;
                            _isOutboxFlag = false;
                            loadUnreadMoreItems(clearCachedData: true);
                          });
                        })),
                Expanded(
                    child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                              ),
                              border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78)),
                                right: BorderSide(color: Color(0XFF7E7A78)),
                                left: BorderSide(color: Color(0XFF7E7A78)),
                              ),
                              color: _inboxSelectedColor),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
                              child: Text(getTranslated(context,"dating_inbox"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _inboxSelectedTextColor,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            _inboxSelectedColor = Colors.grey;
                            _inboxSelectedTextColor = Colors.white;
                            _unreadSelectedColor = Colors.white;
                            _unreadSelectedTextColor = Colors.black;
                            _outboxSelectedColor = Colors.white;
                            _outboxSelectedTextColor = Colors.black;
                            _isUnreadFlag = false;
                            _isInboxFlag = true;
                            _isOutboxFlag = false;
                            loadUnreadMoreItems(clearCachedData: true);
                          });
                        })),
                Expanded(
                    child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              border: Border(
                                top: BorderSide(color: Color(0XFF7E7A78)),
                                bottom: BorderSide(color: Color(0XFF7E7A78)),
                                right: BorderSide(color: Color(0XFF7E7A78)),
                                left: BorderSide(color: Color(0XFF7E7A78)),
                              ),
                              color: _outboxSelectedColor),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
                              child: Text(getTranslated(context,"dating_outbox"),
                                  style: TextStyle(
                                    color: _outboxSelectedTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                        onTap: () {

                          setState(() {
                            _outboxSelectedColor = Colors.grey;
                            _outboxSelectedTextColor = Colors.white;
                            _inboxSelectedColor = Colors.white;
                            _inboxSelectedTextColor = Colors.black;
                            _unreadSelectedColor = Colors.white;
                            _unreadSelectedTextColor = Colors.black;
                            _isUnreadFlag = false;
                            _isInboxFlag = false;
                            _isOutboxFlag = true;
                            loadUnreadMoreItems(clearCachedData: true);
                          });
                        })),
              ]),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: unreadWidgetSection,
            )
          ]),
          isLoading ? Center(child: CircularProgressIndicator()) : SizedBox()
        ]));
  }
}
