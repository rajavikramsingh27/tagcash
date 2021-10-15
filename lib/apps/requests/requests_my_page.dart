import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/wallets_dropdown.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'models/request.dart';

class RequestsMyPage extends StatefulWidget {
  const RequestsMyPage({Key key}) : super(key: key);

  @override
  _RequestsMyPageState createState() => _RequestsMyPageState();
}

class _RequestsMyPageState extends State<RequestsMyPage> {
  Future<List<Request>> requestsDataList;

  @override
  void initState() {
    super.initState();

    requestsDataList = requestsListLoad();
  }

  void refreshList() {
    requestsDataList = requestsListLoad();
    setState(() {});
  }

  Future<List<Request>> requestsListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['send'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('Credit/ListRequests', apiBodyObj);

    List responseList = response['result'];

    List<Request> getData = responseList.map<Request>((json) {
      return Request.fromJson(json);
    }).toList();

    return getData;
  }

  requestsClicked(Request request) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: RequestDetails(request: request),
            ),
          );
        }).then((value) {
      if (value != null) {
        refreshList();
      }
    });
  }

  void requestsCreateClickHandler() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: RequestsCreate(),
              ),
            ),
          );
        }).then((value) {
      if (value != null) {
        refreshList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => requestsCreateClickHandler(),
        child: Icon(Icons.add),
      ),
      body: Container(
        child: FutureBuilder(
          future: requestsDataList,
          builder:
              (BuildContext context, AsyncSnapshot<List<Request>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Opacity(
                        opacity:
                            snapshot.data[index].status == 'Pending' ? 1 : 0.5,
                        child: ListTile(
                          title: Text(
                              '${snapshot.data[index].requestAmount} ${snapshot.data[index].currencyCode}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data[index].requestToName),
                              Text(DateFormat('dd MMM yyy').format(
                                DateTime.parse(
                                    snapshot.data[index].requestDate),
                              )),
                            ],
                          ),
                          trailing:
                              Text(snapshot.data[index].status.toUpperCase()),
                          onTap: () => requestsClicked(snapshot.data[index]),
                        ),
                      );
                    },
                  )
                : Center(child: Loading());
          },
        ),
      ),
    );
  }
}

enum SendTarget { user, merchant }

class RequestsCreate extends StatefulWidget {
  const RequestsCreate({
    Key key,
  }) : super(key: key);

  @override
  _RequestsCreateState createState() => _RequestsCreateState();
}

class _RequestsCreateState extends State<RequestsCreate> {
  final _formKey = GlobalKey<FormState>();

  bool enableAutoValidate = false;
  bool transferClickPossible = true;
  bool isLoading = false;
  SendTarget sendTargetSelected = SendTarget.user;
  String defaultCurrencyCode;
  Wallet activeWallet;

  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void sendTargetChangeHandler(SendTarget value) {
    setState(() {
      sendTargetSelected = value;
    });
  }

  setWallet(wallet) {
    activeWallet = wallet;
  }

  requestsCreateHandler() async {
    if (activeWallet == null) {
      Fluttertoast.showToast(
          msg: getTranslated(context, "request_select_wallet"));

      return;
    }
    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['wallet'] = activeWallet.walletId.toString();
    apiBodyObj['remarks'] = _notesController.text;

    if (sendTargetSelected == SendTarget.user) {
      apiBodyObj['to_type'] = 'user';
    } else {
      apiBodyObj['to_type'] = 'community';
    }
    apiBodyObj['to_user'] = _idController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('Credit/Requestfunds', apiBodyObj);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });

    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      Fluttertoast.showToast(
          msg: getTranslated(context, "request_success_msg"));

      // _amountController.text = '';
      // _notesController.text = '';
    } else {
      if (response['error'] == 'invalid_user_can_not_lend_from_yourself') {
        showSimpleDialog(context,
            title: getTranslated(context, "request_failed"),
            message: getTranslated(context, "request_faild_msg"));
      } else if (response['error'] == 'invalid_user') {
        Fluttertoast.showToast(msg: getTranslated(context, "reques_not_group"));
      } else {
        Fluttertoast.showToast(msg: getTranslated(context, "error_occurred"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getTranslated(context, "requests"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: WalletsDropdown(
                      currencyCode: ValueNotifier<String>('PHP'),
                      onSelected: (wallet) {
                        activeWallet = wallet;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: getTranslated(context, "reward_amount"),
                      ),
                      validator: (value) {
                        if (!Validator.isAmount(value)) {
                          var msg =
                              getTranslated(context, "request_valid_amount");
                          return msg;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Radio(
                      value: SendTarget.user,
                      groupValue: sendTargetSelected,
                      onChanged: sendTargetChangeHandler,
                    ),
                    Text(
                      getTranslated(context, "request_user"),
                    ),
                    SizedBox(width: 20),
                    Radio(
                      value: SendTarget.merchant,
                      groupValue: sendTargetSelected,
                      onChanged: sendTargetChangeHandler,
                    ),
                    Text(
                      getTranslated(context, "request_group"),
                    )
                  ],
                ),
              ),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: sendTargetSelected == SendTarget.user
                      ? getTranslated(context, "request_id_or_email")
                      : getTranslated(context, "request_groupid"),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return sendTargetSelected == SendTarget.user
                        ? getTranslated(context, "request_valid_email")
                        : getTranslated(context, "request_valid_group_id");
                  }
                  return null;
                },
              ),
              TextFormField(
                minLines: 3,
                maxLines: 5,
                controller: _notesController,
                decoration: InputDecoration(
                  icon: Icon(Icons.note),
                  labelText: getTranslated(context, "notes"),
                  hintText: getTranslated(context, "transaction_notes"),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    requestsCreateHandler();
                  }
                },
                child: Text(
                  getTranslated(context, "request_send"),
                ),
              ),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}

class RequestDetails extends StatefulWidget {
  final Request request;
  const RequestDetails({
    Key key,
    this.request,
  }) : super(key: key);

  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  bool isLoading = false;

  void declineRequestClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'credit/Declinerequest/' + widget.request.id.toString());

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      Fluttertoast.showToast(
          msg: getTranslated(context, "request_deleted_successfully"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                getTranslated(context, "request_pay"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 10),
              Text(
                widget.request.requestToName,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${widget.request.requestAmount} ${widget.request.currencyCode}',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
              Text(DateFormat('dd MMM yyy').format(
                DateTime.parse(widget.request.requestDate),
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.request.status.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Text(
                widget.request.remarks,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              widget.request.status == 'Pending'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: () => declineRequestClickHandler(),
                        child: Text(getTranslated(context, "request_delete")),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
