
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/SocketEvent.dart';
import '../models/node_user.dart';
import '../network/clients.dart';
import '../../../models/app_constants.dart' as AppConstants;
import '../models/chat_model.dart';
import '../models/conversation.dart';
import '../models/message_model.dart';
import '../models/thread.dart';
import '../../../services/networking.dart';
import '../../../utils/validator.dart';
// This is the class used by rest of your codebase
// Include generated file
part './conversation_bloc.g.dart';

// This is the class used by rest of your codebase
class ConversationBloc = _ConversationBloc with _$ConversationBloc;

abstract class _ConversationBloc with Store {
  IO.Socket socket;
  String chatServerUrl = AppConstants.getChatServerUrl();

  String myNodeId = "";
  int myTagcashId;

  String otherUserNodeId = "";
  String sessionTime = '0';

  String chargePerMinAmount = 'null';
  String chargeCurrencyId;
  String chargePerSession = '0';
  // String minutePerSession = '0';

  File image;

  @observable
  bool isPreviousChatLoaded = false;

  @observable
  var isLong;

  @observable
  var isLat;

  @observable
  var isLocationEnded = false;

  @observable
  List<dynamic> conversations = [];

  List<String> loadedEvents = [];
  ChatModel chatModel;

  @observable
  Map<dynamic, dynamic> rooms;

  @observable
  Conversation chat;

  @observable
  List<dynamic> callHistoryModel;

  @observable
  NodeUser nodeUser;

  // @observable
  // String test = 'abc';

  Function callback;

  @observable
  FutureStatus chatStatus = FutureStatus.pending;

  @observable
  FutureStatus searchStatus = FutureStatus.pending;

  @observable
  List searchResults = [];

  @observable
  String unblockResults;

  @observable
  String transcationid;

  @observable
  String notes;

  @observable
  String lastmsgId;

  @observable
  String amount;

  @observable
  dynamic conversationRaw;

  @observable
  int searchOffset = 0;

  @observable
  int searchLimit = 20;

  @observable
  String msgId;

  @observable
  BuildContext context;

  @observable
  FutureStatus roomStatus = FutureStatus.pending;

  @observable
  FutureStatus convStatus = FutureStatus.pending;

  @observable
  String currentRoom = "";

  @observable
  String payloadText;

  @observable
  bool reachedEnd = false;

  @observable
  bool isblocked;

  @observable
  bool block;
  @observable
  bool unblock;
  @observable
  bool chatvalue;

  @observable
  FutureStatus logstatus = FutureStatus.pending;

  @observable
  FutureStatus reloadStatus = FutureStatus.fulfilled;

  @observable
  int lastItemIndex;

  @action
  Future<void> initSocket(id, {source = 'chat', Map userData}) async {
    this.chatStatus = FutureStatus.pending;
    try {
      this.socket = IO.io(
          '${this.chatServerUrl}user?user_id=' + id.toString(),
          <String, dynamic>{
            'transports': ['websocket'],
            'extraHeaders': {'foo': 'bar'} // optional
          });

      this.socket.on(SocketEvent.CONNECT, (_) {
        if (source == 'chat') {
          print("loading converstation.....");
          socket.emit(SocketEvent.LOAD_CONVERSATIONS, {'tagcash_id': id});
        } else {
          print("joining room from tagcash.....");
          this.joinRoomFromSearch(userData);
        }
      });

      if (!loadedEvents.contains(SocketEvent.BROADCASTED_MESSAGSE_TOCLIENTS)) {
        this.socket.on(SocketEvent.BROADCASTED_MESSAGSE_TOCLIENTS,
            broadcastMessageToClients);
      }

      if (!loadedEvents.contains(SocketEvent.MESSAGE_TO_CLIENTS)) {
        this.socket.on(SocketEvent.MESSAGE_TO_CLIENTS, messageToClients);
      }

      this.socket.on(SocketEvent.ROOM_HISTORY, rooomHistory);

      this.socket.on(SocketEvent.LOAD_CONVERSATIONS, loadConversations);

      this.socket.on(SocketEvent.DISCONNECT, (_) => print('disconnect'));
    } catch (e) {
      print(e);
      this.chatStatus = FutureStatus.rejected;
    }
  }

  @action
  Future<void> tagtalkLogin(userData, {source = 'chat'}) async {
    try {
      var me = await RestApiClientService.shared.loginUser(userData);
      print('nmode');
      this.chargePerMinAmount = me.chargePerMinAmount.toString();
      this.chargeCurrencyId = me.chargeCurrencyId.toString();
      this.chargePerSession = me.chargePerSession.toString();
      this.sessionTime = me.minutePerSession.toString();
      if (me.nodeId.isNotEmpty) {
        this.myNodeId = me.nodeId;
        this.myTagcashId = me.tagcashId;
        this.initSocket(me.tagcashId, source: source);
      } else {}
    } catch (e) {
      print(e);
      this.logstatus = FutureStatus.rejected;
    }
  }

  @action
  Future<void> historyOfVideoCalls(tagcashId) async {
    try {
      this.chatStatus = FutureStatus.pending;
      callHistoryModel = await RestApiClientService.shared
          .callHistory({"tagcash_id": tagcashId});
      callHistoryModel = callHistoryModel
          .where((element) =>
              element.toTagcashId == this.myTagcashId ||
              element.fromTagcashId == this.myTagcashId)
          .toList();

      this.chatStatus = FutureStatus.fulfilled;
      print('hii this is response');
      print(callHistoryModel);
    } catch (e) {
      print(e);
      this.logstatus = FutureStatus.rejected;
    }
  }

  @action
  Future<void> tagtalkLoginFromTagcash(Map<dynamic, dynamic> myTagcashData,
      Map<dynamic, dynamic> otherUserTagcashData) async {
    try {
      this.convStatus = FutureStatus.pending;
      var me = await RestApiClientService.shared.loginUser(myTagcashData);
      print('nmode user');
      this.chargePerMinAmount = me.chargePerMinAmount.toString();
      this.chargeCurrencyId = me.chargeCurrencyId.toString();
      this.chargePerSession = me.chargePerSession.toString();
      this.sessionTime = me.minutePerSession.toString();
      if (me.nodeId.isNotEmpty) {
        this.myNodeId = me.nodeId;
        this.myTagcashId = me.tagcashId;
        var user =
            await RestApiClientService.shared.loginUser(otherUserTagcashData);
        if (user.nodeId.isNotEmpty) {
          var data = {
            'with_userId': user.nodeId,
            'withUserTagcashId': user.tagcashId,
            'user_id': me.nodeId,
            'tagcash_id': me.tagcashId
          };
          this.initSocket(me.tagcashId, source: 'tagcash', userData: data);
        } else {
          print("NODEID WAS EMPTY");
        }
      } else {
        print("MAIN NODE IS WAS EMPTY");
      }
    } catch (e) {
      this.convStatus = FutureStatus.rejected;
      this.logstatus = FutureStatus.rejected;
    }
  }

  @action
  Future blockUser(id, context, source) async {
    var apiBodyObj = {'id': id.toString(), 'type': 'user'};
    var data = await NetworkHelper.request("block/add", apiBodyObj);
    if (data['status'] == 'success' || data['error'] == 'already_blocked') {
      deleteConversataion(id, context, source);
    }
  }

  @action
  Future unBlockUser(id, context, source) async {
    var apiBodyObj = {'id': id.toString(), 'type': 'user'};
    var response = await NetworkHelper.request("block/remove", apiBodyObj);
    if (response['status'] == 'success' && response.containsKey('result')) {
      this.unblockResults = response['result'];
      if (source == 'chatdata') {
        Navigator.pushNamed(context, '/chat');
      } else {
        Navigator.pop(context);
      }
    }
  }

  @action
  Future deleteConversataion(id, context, source) async {
    if (this.chat != null && this.chat.room != null) {
      var response = await RestApiClientService.shared.deleteconversation(
          {"roomId": this.chat.room.id.toString(), "tagcash_id": id});

      if (response['success'] == true) {
        if (source == 'chatdata') {
          Navigator.pushNamed(context, '/chat');
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      if (source == 'chatdata') {
        Navigator.pushNamed(context, '/chat');
      } else {
        Navigator.pop(context);
      }
    }
  }

  @action
  Future<String> uploadRecording(image) async {
    final http.Response response = await http.post(
      Uri.parse('https://chat.tagcash.com/api/upload-image'),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'mime-type': 'audio/mp3'
      },
      body: {
        'image': image,
        'senderId': this.myNodeId,
        'receiverId': this.otherUserNodeId,
        'conversationId': this.currentRoom,
        'extension': '.mp3' //mp3
        //  var data = await RestApiClientService.shared.uploadImage(apiBodyObj);
      },
    );
    var res = json.decode(response.body);
    if (res['success'] == true) {
      return res['data']['img_url'];
    } else {
      return 'null';
    }
  }

  @action
  Future<String> uploadDoc(file, _ext) async {
    var imageCode = "\"$file\"";
    var body = {};
    body["image"] = imageCode;
    body["conversationId"] = currentRoom;
    body["extension"] = _ext;
    final http.Response response = await http.post(
      Uri.parse('https://chat.tagcash.com/api/upload-image'),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: body,
    );
    this.convStatus = FutureStatus.fulfilled;
    var res = json.decode(response.body);
    if (res['success'] == true) {
      print(res['data']);
      return res['data']['img_url'];
    } else {
      return '';
    }
  }

  @action
  Future<String> uploadImage(image) async {
    final http.Response response = await http.post(
      Uri.parse('https://chat.tagcash.com/api/upload-image'),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: {
        'image': image,
        'senderId': this.myNodeId,
        'receiverId': this.otherUserNodeId,
        'conversationId': this.currentRoom,
        'extension': '.png' // .jpeg // .png
        //  var data = await RestApiClientService.shared.uploadImage(apiBodyObj);
      },
    );
    var res = json.decode(response.body);
    if (res['success'] == true) {
      return res['data']['img_url'];
    } else {
      return 'null';
    }
  }

  @action
  Future<void> reloadMainConversations(id) async {
    this.chatStatus = FutureStatus.pending;
    this.currentRoom = null;
    socket.emit(SocketEvent.LOAD_CONVERSATIONS, {'tagcash_id': id});
  }

  @action
  Future<void> updateMainConversation(data) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('MM-dd');

    this.conversations = this.conversations.map((e) {
      if (e.roomId == data['chatDetails']['roomId']) {
        e.datetime = formatter.format(now);
        e.messageDetail = MessageModel.fromJson(data['chatDetails']);
        if (data['chatDetails']['roomId'] != this.currentRoom) {
          e.unreadCount++;
        }
      }
      return e;
    }).toList();
  }

  @action
  Future<void> updateChat(message) async {
    var tempChat = this.chat;
    tempChat.history.threads.insert(0, Thread.fromJson(message));
    this.chat = tempChat;
    calculateThreadlist();
  }

  @action
  Future<void> updateDeletedChat(deleteObj) async {
    var tempChat = this.chat;
    // var deletedThread= tempChat.history.threads.where((element) => element.id == deleteObj['_id']);
    tempChat.history.threads
        .removeWhere((element) => element.id == deleteObj['_id']);

    this.chat = tempChat;
  }

  leaveRoom() {
    this.socket.emit(SocketEvent.LEAVE_ROOM, {"convId": this.chat.room.id});
  }

  @action
  clearConversationSearch() {
    this.conversations =
        this.conversationRaw.map((e) => ChatModel.fromJson(e)).toList();
  }

  @action
  filterConversations(String searchText) {
    if (searchText.isNotEmpty) {
      this.chatStatus = FutureStatus.pending;
      this.conversations = this
          .conversations
          .where((chatModel) =>
              chatModel.contactName.toLowerCase().contains(searchText))
          .toList();
    } else {
      clearConversationSearch();
    }
    this.chatStatus = FutureStatus.fulfilled;
  }

  @action
  filterCallHistory(String searchText) {
    if (searchText.isNotEmpty) {
      this.chatStatus = FutureStatus.pending;
      this.callHistoryModel = this
          .callHistoryModel
          .where((callHisModel) =>
              callHisModel.sender.firstname
                  .toLowerCase()
                  .contains(searchText) ||
              callHisModel.receiver.firstname
                  .toLowerCase()
                  .contains(searchText))
          .toList();

      print(this.callHistoryModel.length);
      print(searchText);
    } else {
      historyOfVideoCalls(this.myTagcashId);
    }
    this.chatStatus = FutureStatus.fulfilled;
  }

  loadConversations(results) async {
    this.chatStatus = FutureStatus.fulfilled;
    this.convStatus = FutureStatus.pending;
    if (results['success'] == true) {
      if (results['data'].length > 0) {
        this.conversationRaw = results['data'];
        this.conversations =
            results['data'].map((e) => ChatModel.fromJson(e)).toList();
        print('raw');
        print(conversationRaw[0]);
        print('okji');
        // this.chat.history.threads.where()
        print(conversationRaw[0]['message_date']);
        await this.calculateThreadlist();
        this.convStatus = FutureStatus.fulfilled;
      }
    }
    this.historyOfVideoCalls(this.myTagcashId);
  }

  clearSearch() {
    this.searchResults = [];
    this.searchOffset = 0;
    this.nodeUser = null;
    this.logstatus = FutureStatus.pending;
  }

  resetSearchValues() {
    this.nodeUser = null;
    this.logstatus = FutureStatus.pending;
  }

  @action
  Future<void> searchUser(searchKey) async {
    this.clearSearch();
    Map<String, String> apiBodyObj = {};
    var searchMail = false;
    apiBodyObj = {
      'count': this.searchLimit.toString(),
      'offset': this.searchOffset.toString(),
    };
    if (Validator.isMobile(searchKey)) {
      apiBodyObj['mobile'] = searchKey;
    } else if (Validator.isEmail(searchKey)) {
      searchMail = true;
      apiBodyObj['email'] = searchKey;
    } else if (Validator.isNumber(searchKey)) {
      apiBodyObj['id'] = searchKey;
    } else {
      apiBodyObj['name'] = searchKey;
    }
    this.searchStatus = FutureStatus.pending;
    this.searchResults = [];
    try {
      var response = await NetworkHelper.request('user/searchuser', apiBodyObj);
      this.searchStatus = FutureStatus.fulfilled;
      if (response['status'] == 'success' && response.containsKey('result')) {
        this.searchResults = response['result'];
        this.searchOffset = this.searchOffset + response['result'].length;
      } else if (response['status'] == 'failed' &&
          response.containsKey('error')) {}
    } catch (e) {
      this.searchStatus = FutureStatus.rejected;
    }
  }

  @action
  Future<void> loginToTagtalk(int index) async {
    this.logstatus = FutureStatus.pending;
    this.nodeUser = null;
    try {
      var userData = this.searchResults[index];
      userData['user_id'] = userData['id'].toString();
      userData['avatar'] = {'avatar': "", 'upload_status': true};
      this.nodeUser = await RestApiClientService.shared.loginUser(userData);
      print('nmode user');
      print(nodeUser.chargePerMinAmount);
      this.logstatus = FutureStatus.fulfilled;
    } catch (e) {
      print(e);
      this.logstatus = FutureStatus.rejected;
    }
  }

  @action
  Future<void> loadMoreConversation(context) async {
    this.convStatus = FutureStatus.pending;
    if (this.chat.history.hasNextPage) {
      try {
        var historyResponse =
            await RestApiClientService.shared.reloadConversation({
          "roomId": this.chat.room.id.toString(),
          "page": this.chat.history.nextPage.toString()
        });
        this.chat.history.threads = new List.from(this.chat.history.threads)
          ..addAll(historyResponse.threads);
        this.chat.history.hasNextPage = historyResponse.hasNextPage;
        this.chat.history.hasPrevPage = historyResponse.hasPrevPage;
        this.chat.history.limit = historyResponse.limit;
        this.chat.history.nextPage = historyResponse.nextPage;
        this.chat.history.page = historyResponse.page;
        this.chat.history.pagingCounter = historyResponse.pagingCounter;
        this.chat.history.prevPage = historyResponse.prevPage;
        this.chat.history.totalDocs = historyResponse.totalDocs;
        this.chat.history.totalPages = historyResponse.totalPages;
        await this.calculateThreadlist();
        this.isPreviousChatLoaded = true;
        this.convStatus = FutureStatus.fulfilled;
      } catch (e) {
        this.convStatus = FutureStatus.rejected;
      }
    } else {
      this.convStatus = FutureStatus.fulfilled;
      this.reachedEnd = true;
    }
  }

  @action
  Future<void> changeRequestStatus(String msgID, status, index) async {
    try {
      this.chatStatus = FutureStatus.pending;
      var changeReqReponse = await RestApiClientService.shared
          .changeRequestStatus({"_id": msgID, "status": status});
      print('this is change status response');
      print(changeReqReponse);

      this.chat.history.threads[index].status =
          changeReqReponse['data']['message_obj']['status'];
    } catch (e) {
      print('this is error in changeRequestStatus');
    }
  }

  @action
  Future<void> setCharge(
      mytagId, chargeAmount, currencyCode, isMinute, newSessionTime) async {
    try {
      print(this.myTagcashId);
      print(this.myTagcashId.runtimeType);
      int charge_per_min;
      int charge_per_session;
      int minute_per_session;
      if (isMinute) {
        charge_per_min = int.parse(chargeAmount);
        charge_per_session = 0;
      } else {
        charge_per_session = int.parse(chargeAmount);
        charge_per_min = 0;
        // this.sessionTime = 15;
        minute_per_session = int.parse(newSessionTime);
      }
      var setChargeResponse = await RestApiClientService.shared.setCharge({
        "user_id": mytagId,
        "charge_per_min": charge_per_min,
        "charge_currency_id": currencyCode,
        "charge_per_session": charge_per_session,
        "min_per_session": minute_per_session
      });
      print('set charge response');
      print(setChargeResponse.chargePerSession);
      print(setChargeResponse.minutePerSession);
      return true;
    } catch (e) {
      print('this is error in setChargeResponse');
    }
  }

  getDate(now, incomingDate, yesterDay) {
    DateFormat formatter = DateFormat('dd MMMM y');
    if (now.day == incomingDate.day) {
      return 'TODAY';
    } else {
      if (yesterDay.day == incomingDate.day) {
        return 'YESTERDAY';
      } else {
        return formatter.format(incomingDate);
      }
    }
  }

  @action
  Future<void> calculateThreadlist() {
    this.convStatus = FutureStatus.pending;
    var lastDateStored;

    var lastDate;
    var previousThread;
    DateTime now = DateTime.now();
    var yesterDay = DateTime.now().subtract(Duration(days: 1));
    var firstTime = true;
    for (var i = 0; i < this.chat.history.threads.length; i++) {
      if (i == 0) {
        DateTime now = DateTime.now();
        var yesterDay = DateTime.now().subtract(Duration(days: 1));
        var incomingDate =
            DateTime.parse(this.chat.history.threads[i].createdDate).toUtc();
        lastDateStored = getDate(now, incomingDate, yesterDay);
        lastDate = incomingDate.day;
      }

      var datetime;
      DateTime now = DateTime.now();

      var incomingDate =
          DateTime.parse(this.chat.history.threads[i].createdDate).toUtc();
      DateFormat formatNew = DateFormat('h:mm a');
      datetime = formatNew.format(incomingDate.toLocal()).toString();
      // logic
      var yesterDay = DateTime.now().subtract(Duration(days: 1));

      if (lastDate != incomingDate.day) {
        lastDate = incomingDate.day;
        if (firstTime) {
          previousThread = this.chat.history.threads[i];
          firstTime = false;
        } else {
          DateTime previousDate = DateTime.parse(previousThread.createdDate);
          lastDateStored = getDate(now, previousDate, yesterDay);
          previousThread = this.chat.history.threads[i];
        }
        this.chat.history.threads[i].isVisible = 'true';
        this.chat.history.threads[i].sortedDate = lastDateStored;
      } else {
        lastDate = incomingDate.day;
      }
    }
    this.convStatus = FutureStatus.fulfilled;
  }

  @action
  Future<void> deleteMessage(tagcashId, messageOBJ) async {
    try {
      this.chatStatus = FutureStatus.pending;
      var deleteMessageResponse = await RestApiClientService.shared
          .deleteMessage({"tagcash_id": tagcashId, "message": messageOBJ});
      print('hii this is response');
      print(deleteMessageResponse);
      updateDeletedChat(deleteMessageResponse['data']);
      this.chatStatus = FutureStatus.fulfilled;
      // this.deleteMessageObj =  deleteMessageResponse['data'].map((e) => DeleteMessage.fromJson(e)).toList();
      // var user=this.conversations.where((element) =>
      //     element.tagcashId ==
      //     deleteMessageResponse['data']['is_hidden_for'][0]);
      //         var deletedmessage =  .chat.history.threads.where(
      //     (element) => element.id == deleteMessageResponse['data']['_id']);
    } catch (e) {
      print('this is error in deleteMessage');
    }
  }

  @action
  Future payment(amount, toid, notes, recieverTitle, myId, callback,
      successcallback) async {
    var apiBodyObj = {
      'amount': amount,
      'to_wallet_id': '1',
      'to_id': toid.toString(),
      'to_type': '1',
      'narration': notes
    };
    var response = await NetworkHelper.request("wallet/transfer", apiBodyObj);
    if (response['status'] == 'success') {
      var data = {
        "to_tagcash_id": toid,
        "from_tagcash_id": myId,
        "toDocId": toid,
        'doc_id': response['result']['transaction_id'],
        "convId": this.currentRoom,
        "type": 3,
        "payload":
            "${response['result']['transfer_currency']} ${response['result']['transfer_amount']}",
        "message":
            "Successfully Paid ${response['result']['transfer_amount']} To $recieverTitle",
      };
      if (response['result']['transaction_id'] != null) {
        successcallback();
        this.sendMessage(data);
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  @action
  Future paymentWithFromWallet(fromWalletId, amount, toid, notes, recieverTitle,
      myId, callback, successcallback) async {
    var apiBodyObj = {
      'amount': amount,
      'from_wallet_id': fromWalletId,
      'to_wallet_id': '1',
      'to_id': toid.toString(),
      'to_type': '1',
      'narration': notes
    };
    var response = await NetworkHelper.request("wallet/transfer", apiBodyObj);
    if (response['status'] == 'success') {
      var data = {
        "to_tagcash_id": toid,
        "from_tagcash_id": myId,
        "toDocId": toid,
        'doc_id': response['result']['transaction_id'],
        "convId": this.currentRoom,
        "type": 3,
        "payload":
            "${response['result']['transfer_currency']} ${response['result']['transfer_amount']}",
        "message":
            "Successfully Paid ${response['result']['transfer_amount']} To $recieverTitle",
      };
      if (response['result']['transaction_id'] != null) {
        successcallback();
        this.sendMessage(data);
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  @action
  Future paymentOfVideo(amount, toid, notes, recieverTitle, myId, callback,
      successcallback) async {
    var apiBodyObj = {
      'amount': amount,
      'to_wallet_id': '1',
      'to_id': toid.toString(),
      'to_type': '1',
      'narration': notes
    };
    var response = await NetworkHelper.request("wallet/transfer", apiBodyObj);
    if (response['status'] == 'success') {
      var data = {
        "to_tagcash_id": toid,
        "from_tagcash_id": myId,
        "toDocId": toid,
        'doc_id': response['result']['transaction_id'],
        "convId": this.currentRoom,
        "type": 3,
        "payload":
            "${response['result']['transfer_currency']} ${response['result']['transfer_amount']}",
        "message":
            "Successfully Paid ${response['result']['transfer_amount']} To $recieverTitle",
      };
      if (response['result']['transaction_id'] != null) {
        this.sendMessage(data);
        successcallback();
      } else {
        print('transaction id null');
        callback();
      }
    } else {
      print('status is not success');
      callback();
    }
  }

  rooomHistory(data) async {
    this.reachedEnd = false;
    this.convStatus = FutureStatus.fulfilled;
    if (data['success']) {
      this.currentRoom = data['room']['_id']; //this.chat.room.id;
      this.chat = Conversation.fromJson(data);
    }
  }

  broadcastMessageToClients(payload) {
    print(
        '******** ${SocketEvent.BROADCASTED_MESSAGSE_TOCLIENTS} ***********************');
    print(payload['data']);
    this.updateMainConversation(payload['data']);
    if (!loadedEvents.contains(SocketEvent.BROADCASTED_MESSAGSE_TOCLIENTS)) {
      loadedEvents.add(SocketEvent.BROADCASTED_MESSAGSE_TOCLIENTS);
    }
  }

  // Future<AudioPlayer> playLocalAsset() async {
  //   AudioCache cache = new AudioCache();
  //   return await cache.play("images/chat.mp3");
  // }

  messageToClients(data) {
    if (this.chat.history.threads[0].id != data['data']['chatDetails']['_id']) {
      if (data['data']['senderinfo']['user_id'] != this.myTagcashId) {
        appendMessage(data);
      }
    }
  }

  appendMessage(data) {
    var message = data['data'];
    // SystemSound.play(SystemSoundType.alert);
    print('****************** messageToClients is called *******************');
    print(message['chatDetails']['message']);
    print(message['chatDetails']['_id']);
    if (message['chatDetails']['doc_id'] == 'locationSharing') {
      var latLongLiveObj = jsonDecode(message['chatDetails']['message']);
      if (latLongLiveObj['isCordinate'] == true) {
        if (latLongLiveObj['latitude'] == null) {
          isLocationEnded = true;
        }
        print('hi ji');
        print(latLongLiveObj['latitude']);
        this.isLong = latLongLiveObj['longitude'];
        this.isLat = latLongLiveObj['latitude'];
      }
    }

    //play sound if user receives message
    // if (this.conversationRaw[0]['senderinfo']['_id'] ==
    //     message['chatDetails']['receiverId']) {
    //   this.playLocalAsset();
    // }
    if (this.chat != null) {
      if (this.chat.room.id == message['chatDetails']['roomId']) {
        message['chatDetails']['senderinfo'] = message['senderinfo'];
        this.updateChat(message['chatDetails']);
      }
      lastmsgId = message['chatDetails']['_id'];
    }
    if (!loadedEvents.contains(SocketEvent.MESSAGE_TO_CLIENTS)) {
      loadedEvents.add(SocketEvent.MESSAGE_TO_CLIENTS);
    }
  }

  updateMessageStatus(msgId) {
    this.socket.emit(SocketEvent.UPDATE_MESSAGE_HISTORY, {"_id": msgId});
  }

  removeMessageToClientEvent() {
    this.socket.emit(SocketEvent.LEAVE_ROOM, {"convId": this.chat.room.id});
  }

  joinRoom(String roomId) {
    this.convStatus = FutureStatus.pending;
    this.socket.emit(SocketEvent.JOIN_ROOM, {"convId": roomId});
  }

  joinRoomFromSearch(Map data) {
    this.convStatus = FutureStatus.pending;
    this.socket.emit(SocketEvent.JOIN_ROOM, data);
  }

  handleAckResponse(dynamic response) {
    print('****************** handleAckResponse is called *******************');
    print(response);
    if (response['success']) {
      this.appendMessage(response['data']);
    } else {
      print("There was an error");
    }
  }

  sendMessage(Map message) {
    // message['type'] = '6';
    this
        .socket
        .emitWithAck(SocketEvent.SEND_MESSAGE, message, ack: handleAckResponse);
  }

  clearUnreadHistory(String roomId) {
    this.socket.emit(SocketEvent.CLEAR_UNREAD_HISTORY, {"convId": roomId});
    this.conversations = this.conversations.map((e) {
      if (e.roomId == roomId) {
        e.unreadCount = 0;
      }
      return e;
    }).toList();
  }
}
