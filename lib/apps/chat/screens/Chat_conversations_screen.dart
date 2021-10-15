import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../bloc/conversation_bloc.dart';
import './MessageScreen.dart';
import '../models/chat_model.dart';
import '../../../models/app_constants.dart' as AppConstants;

class ChatConversationsScreen extends StatefulWidget {
  final ConversationBloc bloc;
  final int me;
  final String searchTerm;
  final Function submitSearch;
  bool enableAutoValidate;
  ChatConversationsScreen(this.bloc, this.me, this.searchTerm,
      this.submitSearch, this.enableAutoValidate);

  @override
  _ChatConversationsScreenState createState() =>
      _ChatConversationsScreenState();
}

class _ChatConversationsScreenState extends State<ChatConversationsScreen> {
  Widget _getLatestMessage(chatModel) {
    switch (chatModel.messageDetail.type) {
      case 1:
        return Text(
          chatModel.messageDetail.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: (chatModel.unreadCount == 0
                  ? FontWeight.normal
                  : FontWeight.bold)),
        );
        break;
      case 2:
        return Row(
          children: [
            const Icon(
              Icons.image,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            const Text('Photo')
          ],
        );
        break;
      case 3:
        return Row(
          children: [
            const Icon(
              Icons.payment,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            // Text('TXN ID: ${chatModel.messageDetail.docId}')
            Text('TRANSFERRED ${chatModel.messageDetail.message}')
          ],
        );
        break;
      case 4:
        return Row(
          children: [
            const Icon(
              Icons.mic,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            const Text('0:00')
          ],
        );
        break;
      case 5:
        var contactObj = jsonDecode(chatModel.messageDetail.message);
        return Row(
          children: [
            const Icon(
              Icons.account_box,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            Text(contactObj['contactName']),
          ],
        );
        break;
      case 6:
        //var msgOnj = json.decode(chatModel.messageDetail.message);
        return Text(
          'Payment Transferred',
          style: TextStyle(
              fontWeight: (chatModel.unreadCount == 0
                  ? FontWeight.normal
                  : FontWeight.bold)),
        );
        break;
      case 7:
        return Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            const Text('Location'),
          ],
        );
        break;
      case 8:
        return Row(
          children: [
            const Icon(
              Icons.file_copy,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            const Text('DOCUMENT'),
          ],
        );
        break;
      case 9:
        return Row(
          children: [
            const Icon(
              Icons.payment,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 2,
            ),
            // Text('TXN ID: ${chatModel.messageDetail.docId}')
            Text('PAYMENT REQUEST')
          ],
        );
        break;
      default:
        return Text(
          chatModel.messageDetail.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: (chatModel.unreadCount == 0
                  ? FontWeight.normal
                  : FontWeight.bold)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
              child: widget.bloc.conversations.length <= 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("There are no conversations"),
                          this.widget.searchTerm == null ||
                                  this.widget.searchTerm == ""
                              ? Container()
                              : RaisedButton(
                                  elevation: 0,
                                  onPressed: () {
                                    widget.submitSearch(
                                        this.widget.searchTerm, context);
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
                                          text: "'${this.widget.searchTerm}' ",
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
                                        AppConstants.getUserImagePath() +
                                            (_chatModel.receiver.tagcashId ==
                                                    this.widget.me
                                                ? _chatModel.sender.tagcashId
                                                    .toString()
                                                : _chatModel.receiver.tagcashId
                                                    .toString()) +
                                            "?kycImage=0",
                                      ),
                                    ),
                                    onTap: () {
                                      widget.bloc.clearUnreadHistory(
                                          _chatModel.roomId);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => MessageScreen(
                                                  title: _chatModel.contactName,
                                                  bloc: widget.bloc,
                                                  chatModel: _chatModel,
                                                  me: this.widget.me,
                                                  withUser: (_chatModel.sender
                                                              .tagcashId ==
                                                          this.widget.me
                                                      ? _chatModel
                                                          .receiver.tagcashId
                                                      : _chatModel.sender
                                                          .tagcashId)))).then(
                                          (value) {
                                        //this.bloc.isPreviousChatLoaded = false;
                                        widget.bloc
                                            .reloadMainConversations(widget.me);
                                        // setState(() =>
                                        //     this.searchTerm = "");
                                      });
                                    },
                                    title: Row(
                                      children: <Widget>[
                                        Flexible(
                                            child:
                                                Text(_chatModel.contactName)),
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        Text(
                                          _chatModel.datetime.toString(),
                                          style: TextStyle(fontSize: 12.0),
                                        ),
                                      ],
                                    ),
                                    subtitle: _getLatestMessage(_chatModel),
                                    trailing: _chatModel.unreadCount == 0
                                        ? Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14.0,
                                          )
                                        : Stack(
                                            // right: 0,
                                            // top: 0,
                                            children: [
                                              new Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: new BoxDecoration(
                                                  color: Colors.green[800],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                constraints: BoxConstraints(
                                                  minWidth: 20,
                                                  minHeight: 20,
                                                ),
                                                child: Text(
                                                  _chatModel.unreadCount
                                                      .toString(),
                                                  style: new TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          )),
                              ],
                            );
                          },
                        ),
                      ),
                    ))
        ],
      ),
    );
  }
}
