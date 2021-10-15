import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../bloc/conversation_bloc.dart';
import './block_list.dart';
import './charge_to_receive_call_screen.dart';
import './chat_profile.dart';
import '../../../../models/app_constants.dart' as AppConstants;
import '../../../../providers/perspective_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../constants.dart';

class ChatSettingsScreen extends StatefulWidget {
  ConversationBloc bloc;
  ChatSettingsScreen(this.bloc);

  @override
  _ChatSettingsScreenState createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  TextEditingController amountVideoController =
      TextEditingController(text: '1');
  String fullName;

  GlobalKey<FormState> _videoChargeKey = GlobalKey<FormState>();
  @override
  void initState() {
    var userData =
        Provider.of<UserProvider>(context, listen: false).userData.toMap();
    this.fullName = userData['user_firstname'] + userData['user_lastname'];
    print(userData);

    // TODO: implement initState
    super.initState();
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure you want to delete ALL chats and their messages?',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('DELETE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear messages in chats?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Messages in all chats will disappear forever.',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('CLEAR MESSAGES'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: kBottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
              height: 120,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.remove_circle_outline),
                    title: Text('Clear all chats',
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showConfirmationDialog();
                    },
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete all chats',
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirmationDialog();
                    },
                  )
                ],
              )),
        );
      },
    );
  }

  void videoChargeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: kBottomSheetShape,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Stack(
                children: [
                  Form(
                    key: _videoChargeKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Video call charge',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          controller: amountVideoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefix: Container(
                                margin: EdgeInsets.only(right: 10.0),
                                child: Text('PHP ')),
                            labelText: 'Charge to receive calls per session',
                            // suffix: Text('/Minute'),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: amountVideoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            // prefix: Container(
                            //     margin: EdgeInsets.only(right: 10.0),
                            //     child: Text('PHP ')),
                            labelText: 'charge to receive calls per minute',
                            suffix: Text('/Minute'),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            color: kPrimaryColor,
                            textColor: Colors.white,
                            child: Text('SAVE'),
                            onPressed: () {
                              if (_videoChargeKey.currentState.validate()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageUrl: AppConstants.getUserImagePath(),
                      placeholder: (context, url) => Container(
                        // width: 40,
                        // height: 40,
                        child: Center(
                          child: Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Available',
                        style: TextStyle(fontSize: 14, color: Colors.grey[70]),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.create),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatProfile(this.fullName, widget.bloc),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView(children: [
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.block,
                          size: 26,
                          color: Colors.red,
                          // color: Provider.of<PerspectiveProvider>(context)
                          //             .getActivePerspective() ==
                          //         'user'
                          //     ? Colors.black
                          //     : Colors.blue,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlockList(),
                          ),
                        );
                      },
                      title: Text(
                        'Block list',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text('Block, unblock contacts'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14.0,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.payment,
                          size: 26,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        // videoChargeBottomSheet();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChargeToReceiveCallScreen(widget.bloc),
                          ),
                        );
                      },
                      title: Text(
                        'Video call charge',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text('Charge to receive calls'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14.0,
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.history,
                          size: 26,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        clearHistoryBottomSheet();
                      },
                      title: Text(
                        'Chat history',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text('Delete, clear'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14.0,
                      ),
                    ),
                  ],
                )
              ]),
            )
          ],
        ),
    );
  }
}
