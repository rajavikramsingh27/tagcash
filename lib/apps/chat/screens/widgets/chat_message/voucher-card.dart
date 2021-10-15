import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../bloc/conversation_bloc.dart';
import '../../../models/chat_model.dart';
import '../../../../../components/dialog.dart';
import '../../../../../localization/language_constants.dart';
import '../../../../../services/networking.dart';

// ignore: must_be_immutable
class VoucherCard extends StatefulWidget {
  int index;
  final String roomId;
  final dynamic reqMoneyAmount;
  final String alignMsg;
  final String reqMoneyNote;
  int status;
  ConversationBloc _bloc;
  int reqMoneyFromId;
  String uniqMessageId;
  VoucherCard(
      this.index,
      this.roomId,
      this.alignMsg,
      this.reqMoneyAmount,
      this.reqMoneyNote,
      this.status,
      this._bloc,
      this.reqMoneyFromId,
      this.uniqMessageId);

  @override
  _VoucherCardState createState() => _VoucherCardState();
}

class _VoucherCardState extends State<VoucherCard> {
  int payedReqUserID;
  String uniqIdMsg;

  @override
  void initState() {
    // TODO: implement initState
    this.uniqIdMsg = widget.uniqMessageId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    // getIDFromList(reqMoneyFromId) async {
    //   // setState(() {
    //   //   isLoading = true;
    //   //   transferClickPossible = false;
    //   // });

    //   // String amountValue = _amountController.text;
    //   // amountValue = amountValue.replaceAll(',', '');

    //   Map<String, String> apiBodyObj = {};

    //   // apiBodyObj['access_token'] = AppConstants.accessToken;
    //   // apiBodyObj['wallet'] = activeWalletId.toString();
    //   // apiBodyObj['remarks'] = _notesController.text;

    //   // apiBodyObj['to_type'] = 'user';
    //   // apiBodyObj['to_user'] = withUser;

    //   Map<String, dynamic> response =
    //       await NetworkHelper.request('credit/ListRequests', apiBodyObj);
    //   print('ok.........');
    //   var notes = jsonDecode(reqMoneyNote);

    //   response['result'].forEach(
    //     (element) {
    //       if (element['request_from_id'] == reqMoneyFromId &&
    //           element['remarks'] == notes) {
    //         this.payedReqUserID = element['id'];
    //         print(element['id']);
    //         return;
    //       }
    //     },
    //   );
    //   // setState(() {
    //   //   isLoading = false;
    //   //   transferClickPossible = true;
    //   // });

    //   if (response['status'] == 'success') {
    //     //   String notesValues = _notesController.text;
    //     // notesValues = notesValues.replaceAll(',', '');

    //     // var amount = jsonEncode("amount");
    //     // var walletId = jsonEncode("walletId");
    //     // var notes = jsonEncode("notes");

    //     // var apiObj = {
    //     //   "to_tagcash_id": this.withUser,
    //     //   "from_tagcash_id": this.me,
    //     //   "toDocId": this.withUser,
    //     //   "convId": this.bloc.currentRoom,
    //     //   "type": 9,
    //     //   "payload": {
    //     //     amount: amountValue.toString(),
    //     //     walletId: activeWalletId.toString(),
    //     //     notes: jsonEncode(_notesController.text),
    //     //   }.toString(),
    //     // };
    //     // this.bloc.sendMessage(apiObj);

    //     //  Navigator.pop(context);
    //     // showSnackBar('Fund request send');

    //     // _amountController.text = '';
    //     // _notesController.text = '';
    //   } else {
    //     if (response['error'] == 'invalid_user_can_not_lend_from_yourself') {
    //       showSimpleDialog(context,
    //           title: 'Request failed', message: 'Can not lend from yourself.');
    //     } else if (response['error'] == 'invalid_user') {
    //       showSnackBar('Not a valid user');
    //     } else {
    //       showSnackBar(getTranslated(context, 'error_occurred'));
    //     }
    //   }
    // }

    _declineReq(userRequestId) async {
      print(userRequestId);
      // setState(() {
      //   isLoading = true;
      //   transferClickPossible = false;
      // });

      // String amountValue = _amountController.text;
      // amountValue = amountValue.replaceAll(',', '');
      // var userRequestId = jsonDecode(userRequestid);

      Map<String, String> apiBodyObj = {};
      print('p1');

      // apiBodyObj['access_token'] = AppConstants.accessToken;
      // apiBodyObj['wallet'] = activeWalletId.toString();
      // apiBodyObj['remarks'] = _notesController.text;

      // apiBodyObj['to_type'] = 'user';
      // apiBodyObj['to_user'] = withUser;
      dynamic response = await NetworkHelper.request(
          '/credit/Declinerequest/$userRequestId', apiBodyObj);
      print('p1');
      print(userRequestId);
      print('ok22');
      print('p1');
      print(response);
      print(response.runtimeType);

      // setState(() {
      //   isLoading = false;
      //   transferClickPossible = true;
      // });

      if (response['status'] == 'success') {
        // if (response.runtimeType == String) {
        await widget._bloc.changeRequestStatus(this.uniqIdMsg, 4, widget.index);

        widget._bloc.joinRoom(widget.roomId);
      } else {
        if (response['error'] == 'invalid_user_can_not_lend_from_yourself') {
          showSimpleDialog(context,
              title: 'Request failed', message: 'Can not lend from yourself.');
        } else if (response['error'] == 'invalid_user') {
          showSnackBar('Not a valid user');
        } else {
          showSnackBar(getTranslated(context, 'error_occurred'));
        }
      }
    }

    requestsCreateHandler(userRequestId) async {
      // setState(() {
      //   isLoading = true;
      //   transferClickPossible = false;
      // });

      // String amountValue = _amountController.text;
      // amountValue = amountValue.replaceAll(',', '');
      // var userRequestId = jsonDecode(userRequestid);

      Map<String, String> apiBodyObj = {};
      print('p1');

      // apiBodyObj['access_token'] = AppConstants.accessToken;
      // apiBodyObj['wallet'] = activeWalletId.toString();
      // apiBodyObj['remarks'] = _notesController.text;

      // apiBodyObj['to_type'] = 'user';
      // apiBodyObj['to_user'] = withUser;

      dynamic response = await NetworkHelper.request(
          'credit/Approverequest/$userRequestId', apiBodyObj);
      print('p1');
      print(userRequestId);
      print('ok22');
      print('p1');
      print(response);

      // setState(() {
      //   isLoading = false;
      //   transferClickPossible = true;
      // });

      if (response['status'] == 'success') {
        // widget._bloc.changeRequestStatus(this.uniqIdMsg, 3);
        await widget._bloc.changeRequestStatus(this.uniqIdMsg, 3, widget.index);

        widget._bloc.joinRoom(widget.roomId);

        //   String notesValues = _notesController.text;
        // notesValues = notesValues.replaceAll(',', '');

        // var amount = jsonEncode("amount");
        // var walletId = jsonEncode("walletId");
        // var notes = jsonEncode("notes");

        // var apiObj = {
        //   "to_tagcash_id": this.withUser,
        //   "from_tagcash_id": this.me,
        //   "toDocId": this.withUser,
        //   "convId": this.bloc.currentRoom,
        //   "type": 9,
        //   "payload": {
        //     amount: amountValue.toString(),
        //     walletId: activeWalletId.toString(),
        //     notes: jsonEncode(_notesController.text),
        //   }.toString(),
        // };
        // this.bloc.sendMessage(apiObj);

        // Navigator.pop(context);
        // showSnackBar('Fund request send');

        // _amountController.text = '';
        // _notesController.text = '';
      } else {
        if (response['error'] == 'invalid_user_can_not_lend_from_yourself') {
          showSimpleDialog(context,
              title: 'Request failed', message: 'Can not lend from yourself.');
        } else if (response['error'] == 'invalid_user') {
          showSnackBar('Not a valid user');
        } else {
          showSnackBar(getTranslated(context, 'error_occurred'));
        }
      }
    }

    ChatModel _chatModel = widget._bloc.conversations[0];

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.alignMsg == 'right'
              ? Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  padding: EdgeInsets.only(top: 10, bottom: 0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          // widget.reqMoneyFromId.toString() +
                          //     this.widget.status.toString() +
                          'PHP' + ' ' + widget.reqMoneyAmount,
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 20),
                        ),
                        subtitle: Container(
                          margin: EdgeInsets.only(top: 5, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jsonDecode(widget.reqMoneyNote),
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //  this.status== 1?Container():
                                  Row(
                                    children: [
                                      this.widget.status == 3
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.green,
                                            )
                                          : this.widget.status == 4
                                              ? Icon(
                                                  Icons.error_outline,
                                                  size: 14,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.arrow_upward,
                                                  size: 14,
                                                ),
                                      SizedBox(width: 5),
                                      this.widget.status == 3
                                          ? Text(
                                              'You were paid',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          : this.widget.status == 4
                                              ? Text(
                                                  'Request Declined',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : Text(
                                                  'Request Sent',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                    ],
                                  ),
                                  // this.status == 1
                                  //     ? Text(
                                  //         'Approved'+ this.status.toString(),
                                  //         style:
                                  //             TextStyle(color: Colors.orange),
                                  //       )
                                  //     :
                                  this.widget.status == 1 ||
                                          this.widget.status == 2
                                      ? Text(
                                          'Pending',
                                          style:
                                              TextStyle(color: Colors.orange),
                                        )
                                      : Text(widget
                                          ._bloc
                                          .chat
                                          .history
                                          .threads[widget.index]
                                          .createdDateFormatted),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider(
                      //   height: 1,
                      // ),
                      // Container(
                      //   alignment: Alignment.center,
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      //   width: double.infinity,
                      //   child: this.status == 3
                      //       ? Text(
                      //           'Pending',
                      //           style: TextStyle(color: Colors.orange),
                      //         )
                      //       : Row(
                      //           // mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Icon(Icons.check_circle_outline,
                      //                 size: 14, color: Colors.green),
                      //             SizedBox(
                      //               width: 5,
                      //             ),
                      //             Text(
                      //               'Accepted',
                      //               style: TextStyle(color: Colors.green),
                      //             ),
                      //           ],
                      //         ),
                      // )
                    ],
                  ),
                )
              : Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  padding: EdgeInsets.only(top: 10, bottom: 0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          // widget.reqMoneyFromId.toString() +
                          //     "  " +
                          //     this.widget.status.toString() +
                          'PHP' + ' ' + widget.reqMoneyAmount,
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 20),
                        ),
                        subtitle: Container(
                          margin: EdgeInsets.only(top: 5, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // this.status==1 ?  Row(
                                  //     children: [
                                  //       Icon(
                                  //         Icons.approval,
                                  //         size: 14,
                                  //       ),
                                  //       SizedBox(width: 5),
                                  //       Text(
                                  //         'Request Approved' + this.status.toString(),
                                  //         style: TextStyle(
                                  //           fontSize: 14,
                                  //           color: Colors.green,
                                  //           fontWeight: FontWeight.normal,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ) :

                                  Row(
                                    children: [
                                      this.widget.status == 3
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.green,
                                            )
                                          : this.widget.status == 4
                                              ? Icon(
                                                  Icons.error_outline,
                                                  size: 14,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.arrow_downward,
                                                  size: 14,
                                                ),
                                      SizedBox(width: 5),
                                      this.widget.status == 3
                                          ? Text(
                                              'You paid',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            )
                                          : this.widget.status == 4
                                              ? Text(
                                                  'Request Declined',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : Text(
                                                  'Request Received',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                    ],
                                  ),
                                  Text(widget
                                      ._bloc
                                      .chat
                                      .history
                                      .threads[widget.index]
                                      .createdDateFormatted),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      this.widget.status == 3 || this.widget.status == 4
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlatButton(
                                  onPressed: () {
                                    _declineReq(widget.reqMoneyFromId);
                                  },
                                  child: Text(
                                    'Decline',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: Colors.red),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    // _bloc.changeRequestStatus(
                                    //     _bloc.myTagcashId.toString(), reqMoneyFromId.toString());
                                    // print(reqMoneyFromId);
                                    // var tockeId = await getIDFromList(reqMoneyFromId);

                                    requestsCreateHandler(
                                        widget.reqMoneyFromId);
                                    print(this.uniqIdMsg);
                                  },
                                  child: Text(
                                    // _chatModel.messageDetail.status.toString() +
                                    'Pay',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: Colors.green),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
