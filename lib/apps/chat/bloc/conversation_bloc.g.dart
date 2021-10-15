// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_bloc.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ConversationBloc on _ConversationBloc, Store {
  final _$isPreviousChatLoadedAtom =
      Atom(name: '_ConversationBloc.isPreviousChatLoaded');

  @override
  bool get isPreviousChatLoaded {
    _$isPreviousChatLoadedAtom.reportRead();
    return super.isPreviousChatLoaded;
  }

  @override
  set isPreviousChatLoaded(bool value) {
    _$isPreviousChatLoadedAtom.reportWrite(value, super.isPreviousChatLoaded,
        () {
      super.isPreviousChatLoaded = value;
    });
  }

  final _$conversationsAtom = Atom(name: '_ConversationBloc.conversations');

  @override
  List<dynamic> get conversations {
    _$conversationsAtom.reportRead();
    return super.conversations;
  }

  @override
  set conversations(List<dynamic> value) {
    _$conversationsAtom.reportWrite(value, super.conversations, () {
      super.conversations = value;
    });
  }

  final _$roomsAtom = Atom(name: '_ConversationBloc.rooms');

  @override
  Map<dynamic, dynamic> get rooms {
    _$roomsAtom.reportRead();
    return super.rooms;
  }

  @override
  set rooms(Map<dynamic, dynamic> value) {
    _$roomsAtom.reportWrite(value, super.rooms, () {
      super.rooms = value;
    });
  }

  final _$chatAtom = Atom(name: '_ConversationBloc.chat');

  @override
  Conversation get chat {
    _$chatAtom.reportRead();
    return super.chat;
  }

  @override
  set chat(Conversation value) {
    _$chatAtom.reportWrite(value, super.chat, () {
      super.chat = value;
    });
  }

  final _$nodeUserAtom = Atom(name: '_ConversationBloc.nodeUser');

  @override
  NodeUser get nodeUser {
    _$nodeUserAtom.reportRead();
    return super.nodeUser;
  }

  @override
  set nodeUser(NodeUser value) {
    _$nodeUserAtom.reportWrite(value, super.nodeUser, () {
      super.nodeUser = value;
    });
  }

  final _$chatStatusAtom = Atom(name: '_ConversationBloc.chatStatus');

  @override
  FutureStatus get chatStatus {
    _$chatStatusAtom.reportRead();
    return super.chatStatus;
  }

  @override
  set chatStatus(FutureStatus value) {
    _$chatStatusAtom.reportWrite(value, super.chatStatus, () {
      super.chatStatus = value;
    });
  }

  final _$searchStatusAtom = Atom(name: '_ConversationBloc.searchStatus');

  @override
  FutureStatus get searchStatus {
    _$searchStatusAtom.reportRead();
    return super.searchStatus;
  }

  @override
  set searchStatus(FutureStatus value) {
    _$searchStatusAtom.reportWrite(value, super.searchStatus, () {
      super.searchStatus = value;
    });
  }

  final _$searchResultsAtom = Atom(name: '_ConversationBloc.searchResults');

  @override
  List<dynamic> get searchResults {
    _$searchResultsAtom.reportRead();
    return super.searchResults;
  }

  @override
  set searchResults(List<dynamic> value) {
    _$searchResultsAtom.reportWrite(value, super.searchResults, () {
      super.searchResults = value;
    });
  }

  final _$unblockResultsAtom = Atom(name: '_ConversationBloc.unblockResults');

  @override
  String get unblockResults {
    _$unblockResultsAtom.reportRead();
    return super.unblockResults;
  }

  @override
  set unblockResults(String value) {
    _$unblockResultsAtom.reportWrite(value, super.unblockResults, () {
      super.unblockResults = value;
    });
  }

  final _$transcationidAtom = Atom(name: '_ConversationBloc.transcationid');

  @override
  String get transcationid {
    _$transcationidAtom.reportRead();
    return super.transcationid;
  }

  @override
  set transcationid(String value) {
    _$transcationidAtom.reportWrite(value, super.transcationid, () {
      super.transcationid = value;
    });
  }

  final _$notesAtom = Atom(name: '_ConversationBloc.notes');

  @override
  String get notes {
    _$notesAtom.reportRead();
    return super.notes;
  }

  @override
  set notes(String value) {
    _$notesAtom.reportWrite(value, super.notes, () {
      super.notes = value;
    });
  }

  final _$lastmsgIdAtom = Atom(name: '_ConversationBloc.lastmsgId');

  @override
  String get lastmsgId {
    _$lastmsgIdAtom.reportRead();
    return super.lastmsgId;
  }

  @override
  set lastmsgId(String value) {
    _$lastmsgIdAtom.reportWrite(value, super.lastmsgId, () {
      super.lastmsgId = value;
    });
  }

  final _$amountAtom = Atom(name: '_ConversationBloc.amount');

  @override
  String get amount {
    _$amountAtom.reportRead();
    return super.amount;
  }

  @override
  set amount(String value) {
    _$amountAtom.reportWrite(value, super.amount, () {
      super.amount = value;
    });
  }

  final _$conversationRawAtom = Atom(name: '_ConversationBloc.conversationRaw');

  @override
  dynamic get conversationRaw {
    _$conversationRawAtom.reportRead();
    return super.conversationRaw;
  }

  @override
  set conversationRaw(dynamic value) {
    _$conversationRawAtom.reportWrite(value, super.conversationRaw, () {
      super.conversationRaw = value;
    });
  }

  final _$searchOffsetAtom = Atom(name: '_ConversationBloc.searchOffset');

  @override
  int get searchOffset {
    _$searchOffsetAtom.reportRead();
    return super.searchOffset;
  }

  @override
  set searchOffset(int value) {
    _$searchOffsetAtom.reportWrite(value, super.searchOffset, () {
      super.searchOffset = value;
    });
  }

  final _$searchLimitAtom = Atom(name: '_ConversationBloc.searchLimit');

  @override
  int get searchLimit {
    _$searchLimitAtom.reportRead();
    return super.searchLimit;
  }

  @override
  set searchLimit(int value) {
    _$searchLimitAtom.reportWrite(value, super.searchLimit, () {
      super.searchLimit = value;
    });
  }

  final _$msgIdAtom = Atom(name: '_ConversationBloc.msgId');

  @override
  String get msgId {
    _$msgIdAtom.reportRead();
    return super.msgId;
  }

  @override
  set msgId(String value) {
    _$msgIdAtom.reportWrite(value, super.msgId, () {
      super.msgId = value;
    });
  }

  final _$contextAtom = Atom(name: '_ConversationBloc.context');

  @override
  BuildContext get context {
    _$contextAtom.reportRead();
    return super.context;
  }

  @override
  set context(BuildContext value) {
    _$contextAtom.reportWrite(value, super.context, () {
      super.context = value;
    });
  }

  final _$roomStatusAtom = Atom(name: '_ConversationBloc.roomStatus');

  @override
  FutureStatus get roomStatus {
    _$roomStatusAtom.reportRead();
    return super.roomStatus;
  }

  @override
  set roomStatus(FutureStatus value) {
    _$roomStatusAtom.reportWrite(value, super.roomStatus, () {
      super.roomStatus = value;
    });
  }

  final _$convStatusAtom = Atom(name: '_ConversationBloc.convStatus');

  @override
  FutureStatus get convStatus {
    _$convStatusAtom.reportRead();
    return super.convStatus;
  }

  @override
  set convStatus(FutureStatus value) {
    _$convStatusAtom.reportWrite(value, super.convStatus, () {
      super.convStatus = value;
    });
  }

  final _$currentRoomAtom = Atom(name: '_ConversationBloc.currentRoom');

  @override
  String get currentRoom {
    _$currentRoomAtom.reportRead();
    return super.currentRoom;
  }

  @override
  set currentRoom(String value) {
    _$currentRoomAtom.reportWrite(value, super.currentRoom, () {
      super.currentRoom = value;
    });
  }

  final _$payloadTextAtom = Atom(name: '_ConversationBloc.payloadText');

  @override
  String get payloadText {
    _$payloadTextAtom.reportRead();
    return super.payloadText;
  }

  @override
  set payloadText(String value) {
    _$payloadTextAtom.reportWrite(value, super.payloadText, () {
      super.payloadText = value;
    });
  }

  final _$reachedEndAtom = Atom(name: '_ConversationBloc.reachedEnd');

  @override
  bool get reachedEnd {
    _$reachedEndAtom.reportRead();
    return super.reachedEnd;
  }

  @override
  set reachedEnd(bool value) {
    _$reachedEndAtom.reportWrite(value, super.reachedEnd, () {
      super.reachedEnd = value;
    });
  }

  final _$isblockedAtom = Atom(name: '_ConversationBloc.isblocked');

  @override
  bool get isblocked {
    _$isblockedAtom.reportRead();
    return super.isblocked;
  }

  @override
  set isblocked(bool value) {
    _$isblockedAtom.reportWrite(value, super.isblocked, () {
      super.isblocked = value;
    });
  }

  final _$blockAtom = Atom(name: '_ConversationBloc.block');

  @override
  bool get block {
    _$blockAtom.reportRead();
    return super.block;
  }

  @override
  set block(bool value) {
    _$blockAtom.reportWrite(value, super.block, () {
      super.block = value;
    });
  }

  final _$unblockAtom = Atom(name: '_ConversationBloc.unblock');

  @override
  bool get unblock {
    _$unblockAtom.reportRead();
    return super.unblock;
  }

  @override
  set unblock(bool value) {
    _$unblockAtom.reportWrite(value, super.unblock, () {
      super.unblock = value;
    });
  }

  final _$chatvalueAtom = Atom(name: '_ConversationBloc.chatvalue');

  @override
  bool get chatvalue {
    _$chatvalueAtom.reportRead();
    return super.chatvalue;
  }

  @override
  set chatvalue(bool value) {
    _$chatvalueAtom.reportWrite(value, super.chatvalue, () {
      super.chatvalue = value;
    });
  }

  final _$logstatusAtom = Atom(name: '_ConversationBloc.logstatus');

  @override
  FutureStatus get logstatus {
    _$logstatusAtom.reportRead();
    return super.logstatus;
  }

  @override
  set logstatus(FutureStatus value) {
    _$logstatusAtom.reportWrite(value, super.logstatus, () {
      super.logstatus = value;
    });
  }

  final _$reloadStatusAtom = Atom(name: '_ConversationBloc.reloadStatus');

  @override
  FutureStatus get reloadStatus {
    _$reloadStatusAtom.reportRead();
    return super.reloadStatus;
  }

  @override
  set reloadStatus(FutureStatus value) {
    _$reloadStatusAtom.reportWrite(value, super.reloadStatus, () {
      super.reloadStatus = value;
    });
  }

  final _$initSocketAsyncAction = AsyncAction('_ConversationBloc.initSocket');

  @override
  Future<void> initSocket(dynamic id,
      {dynamic source = 'chat', Map<dynamic, dynamic> userData}) {
    return _$initSocketAsyncAction
        .run(() => super.initSocket(id, source: source, userData: userData));
  }

  final _$tagtalkLoginAsyncAction =
      AsyncAction('_ConversationBloc.tagtalkLogin');

  @override
  Future<void> tagtalkLogin(dynamic userData, {dynamic source = 'chat'}) {
    return _$tagtalkLoginAsyncAction
        .run(() => super.tagtalkLogin(userData, source: source));
  }

  final _$tagtalkLoginFromTagcashAsyncAction =
      AsyncAction('_ConversationBloc.tagtalkLoginFromTagcash');

  @override
  Future<void> tagtalkLoginFromTagcash(Map<dynamic, dynamic> myTagcashData,
      Map<dynamic, dynamic> otherUserTagcashData) {
    return _$tagtalkLoginFromTagcashAsyncAction.run(() =>
        super.tagtalkLoginFromTagcash(myTagcashData, otherUserTagcashData));
  }

  final _$blockUserAsyncAction = AsyncAction('_ConversationBloc.blockUser');

  @override
  Future<dynamic> blockUser(dynamic id, dynamic context, dynamic source) {
    return _$blockUserAsyncAction
        .run(() => super.blockUser(id, context, source));
  }

  final _$unBlockUserAsyncAction = AsyncAction('_ConversationBloc.unBlockUser');

  @override
  Future<dynamic> unBlockUser(dynamic id, dynamic context, dynamic source) {
    return _$unBlockUserAsyncAction
        .run(() => super.unBlockUser(id, context, source));
  }

  final _$deleteConversataionAsyncAction =
      AsyncAction('_ConversationBloc.deleteConversataion');

  @override
  Future<dynamic> deleteConversataion(
      dynamic id, dynamic context, dynamic source) {
    return _$deleteConversataionAsyncAction
        .run(() => super.deleteConversataion(id, context, source));
  }

  final _$uploadImageAsyncAction = AsyncAction('_ConversationBloc.uploadImage');

  @override
  Future<String> uploadImage(dynamic image) {
    return _$uploadImageAsyncAction.run(() => super.uploadImage(image));
  }

  final _$reloadMainConversationsAsyncAction =
      AsyncAction('_ConversationBloc.reloadMainConversations');

  @override
  Future<void> reloadMainConversations(dynamic id) {
    return _$reloadMainConversationsAsyncAction
        .run(() => super.reloadMainConversations(id));
  }

  final _$updateMainConversationAsyncAction =
      AsyncAction('_ConversationBloc.updateMainConversation');

  @override
  Future<void> updateMainConversation(dynamic data) {
    return _$updateMainConversationAsyncAction
        .run(() => super.updateMainConversation(data));
  }

  final _$updateChatAsyncAction = AsyncAction('_ConversationBloc.updateChat');

  @override
  Future<void> updateChat(dynamic message) {
    return _$updateChatAsyncAction.run(() => super.updateChat(message));
  }

  final _$searchUserAsyncAction = AsyncAction('_ConversationBloc.searchUser');

  @override
  Future<void> searchUser(dynamic searchTerm) {
    return _$searchUserAsyncAction.run(() => super.searchUser(searchTerm));
  }

  final _$loginToTagtalkAsyncAction =
      AsyncAction('_ConversationBloc.loginToTagtalk');

  @override
  Future<void> loginToTagtalk(int index) {
    return _$loginToTagtalkAsyncAction.run(() => super.loginToTagtalk(index));
  }

  final _$loadMoreConversationAsyncAction =
      AsyncAction('_ConversationBloc.loadMoreConversation');

  @override
  Future<void> loadMoreConversation(dynamic context) {
    return _$loadMoreConversationAsyncAction
        .run(() => super.loadMoreConversation(context));
  }

  final _$deleteMessageAsyncAction =
      AsyncAction('_ConversationBloc.deleteMessage');

  @override
  Future<void> deleteMessage(dynamic tagcashId, dynamic messageOBJ) {
    return _$deleteMessageAsyncAction
        .run(() => super.deleteMessage(tagcashId, messageOBJ));
  }

  final _$paymentAsyncAction = AsyncAction('_ConversationBloc.payment');

  @override
  Future<dynamic> payment(
      dynamic amount,
      dynamic toid,
      dynamic notes,
      dynamic recieverTitle,
      dynamic myId,
      dynamic callback,
      dynamic successcallback) {
    return _$paymentAsyncAction.run(() => super.payment(
        amount, toid, notes, recieverTitle, myId, callback, successcallback));
  }

  final _$paymentOfVideoAsyncAction =
      AsyncAction('_ConversationBloc.paymentOfVideo');

  @override
  Future<dynamic> paymentOfVideo(
      dynamic amount,
      dynamic toid,
      dynamic notes,
      dynamic recieverTitle,
      dynamic myId,
      dynamic callback,
      dynamic successcallback) {
    return _$paymentOfVideoAsyncAction.run(() => super.paymentOfVideo(
        amount, toid, notes, recieverTitle, myId, callback, successcallback));
  }

  final _$_ConversationBlocActionController =
      ActionController(name: '_ConversationBloc');

  @override
  dynamic clearConversationSearch() {
    final _$actionInfo = _$_ConversationBlocActionController.startAction(
        name: '_ConversationBloc.clearConversationSearch');
    try {
      return super.clearConversationSearch();
    } finally {
      _$_ConversationBlocActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic filterConversations(String searchText) {
    final _$actionInfo = _$_ConversationBlocActionController.startAction(
        name: '_ConversationBloc.filterConversations');
    try {
      return super.filterConversations(searchText);
    } finally {
      _$_ConversationBlocActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isPreviousChatLoaded: ${isPreviousChatLoaded},
conversations: ${conversations},
rooms: ${rooms},
chat: ${chat},
nodeUser: ${nodeUser},
chatStatus: ${chatStatus},
searchStatus: ${searchStatus},
searchResults: ${searchResults},
unblockResults: ${unblockResults},
transcationid: ${transcationid},
notes: ${notes},
lastmsgId: ${lastmsgId},
amount: ${amount},
conversationRaw: ${conversationRaw},
searchOffset: ${searchOffset},
searchLimit: ${searchLimit},
msgId: ${msgId},
context: ${context},
roomStatus: ${roomStatus},
convStatus: ${convStatus},
currentRoom: ${currentRoom},
payloadText: ${payloadText},
reachedEnd: ${reachedEnd},
isblocked: ${isblocked},
block: ${block},
unblock: ${unblock},
chatvalue: ${chatvalue},
logstatus: ${logstatus},
reloadStatus: ${reloadStatus}
    ''';
  }
}
