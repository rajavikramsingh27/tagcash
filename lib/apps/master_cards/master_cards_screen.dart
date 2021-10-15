import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/master_cards/models/master_card.dart';
import 'package:tagcash/apps/master_cards/models/master_card_wallet.dart';
import 'package:tagcash/apps/master_cards/models/stop_reason.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'dart:math';
import 'package:tagcash/localization/language_constants.dart';

class MasterCardsScreen extends StatefulWidget {
  @override
  _MasterCardsScreenState createState() => _MasterCardsScreenState();
}

class _MasterCardsScreenState extends State<MasterCardsScreen> {
  Future<List<MasterCard>> masterCards;
  final globalKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  bool isLoading = false;
  final _controller = new PageController(viewportFraction: 1);

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;
  int k = 1;
  String selectedCardNo;
  String selectedCardStatus;
  String purchaseStatus = "";

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showBackView = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getPurchaseStatus();
    masterCards = masterCardsLoad();
//    checkLocation();
  }

  Color switchWithColor(final int i) {
    if (i % 5 == 0)
      return Colors.orangeAccent;
    else if (i % 4 == 0)
      return Colors.greenAccent;
    else if (i % 3 == 0)
      return Colors.cyan;
    else if (i % 2 == 0)
      return Colors.deepPurpleAccent;
    else
      return Colors.redAccent;
  }

  Future<List<MasterCard>> masterCardsLoad() async {
    print('MasterCardsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/ListCards');

    print(response);
    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<MasterCard> getData = responseList.map<MasterCard>((json) {
      return MasterCard.fromJson(json);
    }).toList();
    if (getData.length > 0) {
      selectedCardNo = getData[0].cardNo; //.replaceAll(new RegExp(r"\s+"), "");
      selectedCardStatus = getData[0].cardStatus;
    }
    return getData;
  }

  getPurchaseStatus() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/ShowHideButton');

    setState(() {
      isLoading = false;
    });
    if (response['card_creation'] == 'incomplete') {
      setState(() {
        purchaseStatus = response['card_creation'];
      });
//      declinedTryAgain = false;
    } else {
      purchaseStatus = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'master_cards'),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: FutureBuilder(
            future: masterCards,
            builder: (BuildContext context,
                AsyncSnapshot<List<MasterCard>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? new Column(
                      children: <Widget>[
                        (snapshot.data.length > 0)
                            ? Container(
                                height: 200,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints.expand(
                                      height: 200, width: 360),
                                  child: PageView.builder(
                                    itemCount: snapshot.data.length,
                                    controller: _controller,
                                    onPageChanged: (int index) {
                                      //setState(() => _index = index);
                                      setState(() {
                                        showBackView = false;
                                        _index = index;
                                        print("Index " + index.toString());
                                        selectedCardNo =
                                            snapshot.data[index].cardNo;
                                        //.replaceAll(new RegExp(r"\s+"), "");
                                        selectedCardStatus =
                                            snapshot.data[index].cardStatus;
                                      });
                                    },
                                    itemBuilder: (_, i) {
                                      return Transform.scale(
                                        scale: i == _index ? 1 : 0.9,
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                showBackView = !showBackView;
                                              });
                                            },
                                            child: Stack(
                                              children: [
                                                CreditCardWidget(
                                                  cardNumber: snapshot
                                                      .data[_index].cardNo,
                                                  expiryDate: snapshot
                                                      .data[_index].validDate,
                                                  cvvCode:
                                                      snapshot.data[_index].cvv,
                                                  cardHolderName: snapshot
                                                      .data[_index]
                                                      .cardHolderName,
                                                  showBackView: showBackView,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  obscureCardCvv: false,
                                                  obscureCardNumber: false,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      25.0),
                                                  child: AnimatedOpacity(
                                                    // If the widget is visible, animate to 0.0 (invisible).
                                                    // If the widget is hidden, animate to 1.0 (fully visible).
                                                    opacity: !showBackView
                                                        ? 1.0
                                                        : 0.0,
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    // The green box must be a child of the AnimatedOpacity widget.
                                                    child: Text(
                                                      snapshot.data[_index]
                                                          .cardType,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Container(
                                height: 160,
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'no_master_cards_found'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                )),
                        SizedBox(height: 15),
                        Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (snapshot.data.length > 1)
                              new DotsIndicator(
                                controller: _controller,
                                itemCount: snapshot.data.length,
                                onPageSelected: (int page) {
                                  _controller.animateToPage(
                                    page,
                                    duration: _kDuration,
                                    curve: _kCurve,
                                  );
                                },
                              ),
                            if (purchaseStatus == 'incomplete')
                              IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: kPrimaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: kBottomSheetShape,
                                          builder: (BuildContext context) {
                                            return CreateMasterCardBottomSheetWidget(
                                                onSuccess: (value) {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      getTranslated(context, 'success_create_master_card')),
                                                  duration: const Duration(
                                                      seconds: 3));
                                              globalKey.currentState
                                                  .showSnackBar(snackBar);
                                              if (snapshot.data.length > 0)
                                                _controller.jumpToPage(0);
                                              getPurchaseStatus();
                                              masterCards = masterCardsLoad();
                                            }, onFailure: (value) {
                                              String str = value;
                                              if (value ==
                                                  "transaction_id_not_found")
                                                str =
                                                    getTranslated(context, 'transaction_id_not_found');
                                              else if (value ==
                                                  "transaction_failed")
                                                str = getTranslated(context, 'transaction_failed');
                                              final snackBar = SnackBar(
                                                  content: Text(str),
                                                  duration: const Duration(
                                                      seconds: 3));
                                              globalKey.currentState
                                                  .showSnackBar(snackBar);
                                            });
                                          });
                                    });
                                  }),
                          ],
                        )),
                        if (snapshot.data.length > 0)
                          Column(
                            children: [
                              SizedBox(height: 10),
                              (snapshot.data[_index].cardStatus == 'stopped')
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          child: Text(getTranslated(context, 'unstop_card')),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: kBottomSheetShape,
                                                  builder:
                                                      (BuildContext context) {
                                                    return _UnStopCardBottomSheetWidget(
                                                        cardNo: selectedCardNo,
                                                        onSuccess: (value) {
                                                          final snackBar = SnackBar(
                                                              content: Text(
                                                                  getTranslated(context, 'success_unstop_master_card')),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3));
                                                          globalKey.currentState
                                                              .showSnackBar(
                                                                  snackBar);
                                                          _controller
                                                              .jumpToPage(0);
                                                          masterCards =
                                                              masterCardsLoad();
                                                        },
                                                        onFailure: (value) {
                                                          String str = value;
                                                          if (value ==
                                                              "card_details_not_found")
                                                            str =
                                                                getTranslated(context, 'card_details_not_found');
                                                          else if (value ==
                                                              "transaction_failed")
                                                            str =
                                                                getTranslated(context, 'transaction_failed');
                                                          final snackBar = SnackBar(
                                                              content:
                                                                  Text(str),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3));
                                                          globalKey.currentState
                                                              .showSnackBar(
                                                                  snackBar);
                                                        });
                                                  });
                                              //});
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          child: Text(getTranslated(context, 'stop_card')),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: kBottomSheetShape,
                                                  builder:
                                                      (BuildContext context) {
                                                    return _StopCardBottomSheetWidget(
                                                        cardNo: selectedCardNo,
                                                        onSuccess: (value) {
                                                          final snackBar = SnackBar(
                                                              content: Text(
                                                                  getTranslated(context, 'success_stop_master_card')),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3));
                                                          globalKey.currentState
                                                              .showSnackBar(
                                                                  snackBar);
                                                          _controller
                                                              .jumpToPage(0);
                                                          masterCards =
                                                              masterCardsLoad();
                                                        },
                                                        onFailure: (value) {
                                                          String str = value;
                                                          if (value ==
                                                              "card_details_not_found")
                                                            str =
                                                                getTranslated(context, 'card_details_not_found');
                                                          else if (value ==
                                                              "transaction_failed")
                                                            str =
                                                                getTranslated(context, 'transaction_failed');
                                                          final snackBar = SnackBar(
                                                              content:
                                                                  Text(str),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          3));
                                                          globalKey.currentState
                                                              .showSnackBar(
                                                                  snackBar);
                                                        });
                                                  });
                                              //});
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    child: Text(getTranslated(context, 'retire_card')),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Widget cancelButton = FlatButton(
                                        child: Text(getTranslated(context, 'no')),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      );
                                      Widget continueButton = FlatButton(
                                        child: Text(getTranslated(context, 'yes')),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          //Navigator.of(context).pop();
                                          //stopCardHandler(widget.cardNo,stopReason.reasonId.toString(),noteController.text);
                                          retireCardHandler(
                                              snapshot.data[_index].cardNo);
                                        },
                                      );

                                      AlertDialog alert = AlertDialog(
                                        title: Text(getTranslated(context, 'retire_card')),
                                        content: Text(
                                            getTranslated(context, 'retire_this_card')),
                                        actions: [
                                          continueButton,
                                          cancelButton,
                                        ],
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: kBottomSheetShape,
                                            builder: (BuildContext context) {
                                              return _UpdateBearerBottomSheetWidget(
                                                  cardNo: selectedCardNo,
                                                  onSuccess: (value) {
                                                    final snackBar = SnackBar(
                                                        content: Text(
                                                            getTranslated(context, 'bearer_update_success')),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3));
                                                    globalKey.currentState
                                                        .showSnackBar(snackBar);
                                                    _controller.jumpToPage(0);
                                                    masterCards =
                                                        masterCardsLoad();
                                                  },
                                                  onFailure: (value) {
                                                    String str = value;
                                                    if (value ==
                                                        "card_details_not_found")
                                                      str =
                                                          getTranslated(context, 'card_details_not_found');
                                                    else if (value ==
                                                        "transaction_failed")
                                                      str =
                                                          getTranslated(context, 'transaction_failed');
                                                    final snackBar = SnackBar(
                                                        content: Text(str),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3));
                                                    globalKey.currentState
                                                        .showSnackBar(snackBar);
                                                  });
                                            });
                                      });
                                    },
                                    textColor: Colors.white,
                                    color: kPrimaryColor,
                                    child: Text(getTranslated(context, 'update_bearer')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (purchaseStatus == '')
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(getTranslated(context, 'purchase_master_card')),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: kBottomSheetShape,
                                        builder: (BuildContext context) {
                                          return PurchaseMasterCardBottomSheetWidget(
                                              onSuccess: (value) {
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    getTranslated(context, 'success_purchase_master_card')),
                                                duration:
                                                    const Duration(seconds: 3));
                                            globalKey.currentState
                                                .showSnackBar(snackBar);
                                            if (snapshot.data.length > 0)
                                              _controller.jumpToPage(0);
                                            getPurchaseStatus();
                                            masterCards = masterCardsLoad();
                                          }, onFailure: (value) {
                                            String str = value;
                                            if (value == "insufficient_balance")
                                              str = getTranslated(context, 'insufficient_balance');
                                            else if (value == "invalid_id")
                                              str = getTranslated(context, 'invalid_id');
                                            else if (value ==
                                                "wallet_transfer_failed")
                                              str = getTranslated(context, 'wallet_transfer_failed');
                                            final snackBar = SnackBar(
                                                content: Text(str),
                                                duration:
                                                    const Duration(seconds: 3));
                                            globalKey.currentState
                                                .showSnackBar(snackBar);
                                          });
                                        });
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(children: [
                      Container(height: 160, child: Center(child: Loading())),
                      SizedBox(height: 15),
                      Center(
                        child: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: kPrimaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: kBottomSheetShape,
                                    builder: (BuildContext context) {
                                      return CreateMasterCardBottomSheetWidget(
                                          onSuccess: (value) {
                                        final snackBar = SnackBar(
                                            content: Text(
                                                getTranslated(context, 'success_create_master_card')),
                                            duration:
                                                const Duration(seconds: 3));
                                        globalKey.currentState
                                            .showSnackBar(snackBar);
                                        if (snapshot.data.length > 0)
                                          _controller.jumpToPage(0);
                                        getPurchaseStatus();
                                        masterCards = masterCardsLoad();
                                      }, onFailure: (value) {
                                        String str = value;
                                        if (value == "transaction_id_not_found")
                                          str = getTranslated(context, 'transaction_id_not_found');
                                        else if (value == "transaction_failed")
                                          str = getTranslated(context, 'transaction_failed');
                                        final snackBar = SnackBar(
                                            content: Text(str),
                                            duration:
                                                const Duration(seconds: 3));
                                        globalKey.currentState
                                            .showSnackBar(snackBar);
                                      });
                                    });
                              });
                            }),
                      ),
                    ]);
              // : Center(child: Loading());
            },
          ),
        ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: Loading()))
            : SizedBox(),
      ]),
//
    );
  }

//  void onCreditCardModelChange(CreditCardModel creditCardModel) {
//    setState(() {
//      //cardNumber = creditCardModel.cardNumber;
//      expiryDate = creditCardModel.expiryDate;
//      cardHolderName = creditCardModel.cardHolderName;
////      cvvCode = creditCardModel.cvvCode;
////      isCvvFocused = creditCardModel.isCvvFocused;
//    });
//  }

  retireCardHandler(String cardNo) async {
    print("retireCardHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_number'] =
        cardNo.toString().replaceAll(new RegExp(r"\s+"), "");

    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/RetireCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
          content: Text(getTranslated(context, 'success_retire_master_card')),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
      _controller.jumpToPage(0);
      masterCards = masterCardsLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      String str = response['error'];
      if (str == "card_details_not_found")
        str = getTranslated(context, 'card_details_not_found');
      else if (str == "transaction_failed") str = getTranslated(context, 'transaction_failed');
      final snackBar =
          SnackBar(content: Text(str), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class PurchaseMasterCardBottomSheetWidget extends StatefulWidget {
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  PurchaseMasterCardBottomSheetWidget({this.onSuccess, this.onFailure});

  @override
  _PurchaseMasterCardBottomSheetWidgetState createState() =>
      _PurchaseMasterCardBottomSheetWidgetState();
}

class _PurchaseMasterCardBottomSheetWidgetState
    extends State<PurchaseMasterCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final currencyItems = {
    '1': 'PHP',
    '7': 'TAG',
  };
  String currency = '1';
  bool isLoading = false;
  MasterCardWallet masterCardWallet;
  Future<List<MasterCardWallet>> masterCardWallets;

  //TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    masterCardWallets = masterCardWalletLoad();
  }

  Future<List<MasterCardWallet>> masterCardWalletLoad() async {
    print('masterCardWalletLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/GetWalletTypesForPurchase');

    print(response);
    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<MasterCardWallet> getData = responseList.map<MasterCardWallet>((json) {
      return MasterCardWallet.fromJson(json);
    }).toList();

    return getData;
  }

  Widget _masterCardsWalletsList() {
    return FutureBuilder(
        future: masterCardWallets,
        builder: (BuildContext context,
            AsyncSnapshot<List<MasterCardWallet>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<MasterCardWallet>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, 'select_wallet')),
                  value: masterCardWallet,
                  onChanged: (MasterCardWallet value) {
                    setState(() {
                      masterCardWallet = value;
                      //amountController.text = masterCardWallet.amount;
                    });
                  },
                  items: snapshot.data.map((MasterCardWallet masterWallet) {
                    return DropdownMenuItem<MasterCardWallet>(
                      value: masterWallet,
                      child: Text(masterWallet.walletName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _masterCardsWalletsList(),
                  ),
                  SizedBox(width: 20),
                  (masterCardWallet != null)
                      ? Expanded(
                          flex: 1,
                          child: Text(
                            getTranslated(context, 'price')+': '+masterCardWallet.amount,
                            style: TextStyle(
                              fontSize: 24,
                              //fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),textAlign: TextAlign.center,
                          ),
                        )
                      : Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_address'),
                  labelText: getTranslated(context, 'address'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_address');
                  }
                  if (isNumeric(value)) {
                    return getTranslated(context, 'dont_enter_a_number_as_address');
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text(
                getTranslated(context, 'card_purchase_gofer'),
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'buy_card_now')),
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            if (masterCardWallet == null) {
                              Navigator.of(context).pop();
                              widget.onFailure(getTranslated(context, 'please_select_a_wallet'));
                            } else
                              purchaseHandler();
                          }
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  purchaseHandler() async {
    print("purchaseHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['address'] = addressController.text;
    //apiBodyObj['wallet_id'] = currency;
    apiBodyObj['pcm_id'] = masterCardWallet.pcmId;
    Map<String, dynamic> response =
        await NetworkHelper.request('Tutuka/PurchaseCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess('success');
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();

      widget.onFailure(response['error']);
    }
  }
}

class CreateMasterCardBottomSheetWidget extends StatefulWidget {
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  CreateMasterCardBottomSheetWidget({this.onSuccess, this.onFailure});

  @override
  _CreateMasterCardBottomSheetWidgetState createState() =>
      _CreateMasterCardBottomSheetWidgetState();
}

class _CreateMasterCardBottomSheetWidgetState
    extends State<CreateMasterCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();
  final expiryDateController = TextEditingController();

//  final monthController = TextEditingController();
//  final yearController = TextEditingController();
  final cvvController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 5,
                  left: 5,
                  right: 5),
              child: Form(
                  key: _formKey,
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'create_virtual_card'),
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
//                    TextFormField(
//                      controller: numberController,
//                      keyboardType: TextInputType.number,
//                      inputFormatters: [
//                        FilteringTextInputFormatter.digitsOnly,
//                        LengthLimitingTextInputFormatter(16),
//                        new CardNumberInputFormatter()
//                      ],
//                      decoration: InputDecoration(
//                        hintText: 'xxxx xxxx xxxx xxxx',
//                        labelText: 'Enter card number',
//                      ),
//                      validator: (value) {
//                        if (value.isEmpty) {
//                          return 'Please enter card number';
//                          // return 'Enter valid amount';
//                        }
//                        return null;
//                      },
//                    ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 20,
                                child: Text(
                                  getTranslated(context, 'expiry'),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Expanded(
                                flex: 40,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  controller: expiryDateController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'yyyy/mm/dd',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                    new CardMonthInputFormatter()
                                  ],
                                  //validator: CardUtils.validateDate,
                                ),
                              ),
                              //   SizedBox(width: 10),
//                        Expanded(
//                          flex: 40,
//                          child: TextFormField(
//                            controller: cvvController,
//                            keyboardType: TextInputType.number,
//                            obscureText: true,
//                            decoration: InputDecoration(
//                              hintText: 'Enter cvv',
//                            ),
//                            inputFormatters: [
//                              FilteringTextInputFormatter.digitsOnly,
//                              LengthLimitingTextInputFormatter(4),
//                            ],
//                            validator: (value) {
//                              if (value.isEmpty) {
//                                return 'Please enter cvv';
//                                // return 'Enter valid amount';
//                              }
//                              if (value.length < 3 || value.length > 4) {
//                                return "CVV is invalid";
//                              }
//                              return null;
//                            },
//                          ),
//                        ),
                            ],
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: isLoading
                                ? Center(child: Loading())
                                : RaisedButton(
                                    child: Text(getTranslated(context, 'create')),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        createHandler();
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ))))
        ]);
  }

  bool isValidDate(String input) {
    final date = DateTime.parse(input);
    final originalFormatString = toOriginalFormatString(date);
    return input == originalFormatString;
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  createHandler() async {
    print("createHandler");

    DateTime now = DateTime.now();
    List<String> dte = expiryDateController.text.split('/');
    var inputFormat = DateFormat('yyyy/MM/dd');
    var inputDate = inputFormat.parse(expiryDateController.text.toString());
    var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    var outputDate = outputFormat.format(inputDate);
    DateTime parseDt = DateTime.parse(outputDate);
    print(now.toString());
    print(outputDate.toString());
    if (!isValidDate(expiryDateController.text.replaceAll('/', ''))) {
      Navigator.of(context).pop();

      widget.onFailure(getTranslated(context, 'enter_a_valid_date'));
      return;
    }
    if (now.isAfter(parseDt)) {
      Navigator.of(context).pop();

      widget.onFailure(getTranslated(context, 'enter_a_future_date'));
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['expiry_date'] = expiryDateController.text.replaceAll('/', '');
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/CreateLinkedCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess('success');
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();

      widget.onFailure(response['error']);
    }
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.red,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = new StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
      if (nonZeroIndex % 6 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
class _UpdateBearerBottomSheetWidget extends StatefulWidget {
  String cardNo;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  _UpdateBearerBottomSheetWidget({this.cardNo, this.onSuccess, this.onFailure});

  @override
  _UpdateBearerBottomSheetWidgetState createState() =>
      _UpdateBearerBottomSheetWidgetState();
}

class _UpdateBearerBottomSheetWidgetState
    extends State<_UpdateBearerBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_first_name'),
                  labelText: getTranslated(context, 'first_name'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_first_name');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_last_name'),
                  labelText: getTranslated(context, 'last_name'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_last_name');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: mobileController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_mobile'),
                  labelText: getTranslated(context, 'mobile'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_mobile');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? Center(child: Loading())
                  : RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          updateHandler(widget.cardNo, firstNameController.text,
                              lastNameController.text, mobileController.text);
                        }
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: kPrimaryColor,
                      child: Text(getTranslated(context, 'update'), style: TextStyle(fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  updateHandler(
      String cardNo, String firstName, String lastName, String mobile) async {
    print("updateHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['bearer_first_name'] = firstName;
    apiBodyObj['bearer_last_name'] = lastName;
    apiBodyObj['bearer_mobile_no'] = mobile;
    apiBodyObj['card_number'] =
        cardNo.toString().replaceAll(new RegExp(r"\s+"), "");
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/UpdateBearerDetails', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess("success");
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onFailure(response['error']);
    }
  }
}

class _StopCardBottomSheetWidget extends StatefulWidget {
  String cardNo;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  _StopCardBottomSheetWidget({this.cardNo, this.onSuccess, this.onFailure});

  @override
  _StopCardBottomSheetWidgetState createState() =>
      _StopCardBottomSheetWidgetState();
}

class _StopCardBottomSheetWidgetState
    extends State<_StopCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();

  StopReason stopReason;
  Future<List<StopReason>> stopReasons;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    stopReasons = stopReasonsLoad();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<List<StopReason>> stopReasonsLoad() async {
    print('stopReasonsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/GetCardStopReason');

    print(response);
    List responseList = response['result']['arr'];
    setState(() {
      isLoading = false;
    });
    List<StopReason> getData = responseList.map<StopReason>((json) {
      return StopReason.fromJson(json);
    }).toList();

    return getData;
  }

  Widget _stopReasonsList() {
    return FutureBuilder(
        future: stopReasons,
        builder:
            (BuildContext context, AsyncSnapshot<List<StopReason>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<StopReason>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, 'select_reason')),
                  value: stopReason,
                  onChanged: (StopReason value) {
                    setState(() {
                      stopReason = value;
                    });
                  },
                  items: snapshot.data.map((StopReason stopReason) {
                    return DropdownMenuItem<StopReason>(
                      value: stopReason,
                      child: Text(stopReason.reason),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _stopReasonsList(),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: getTranslated(context, 'enter_notes'),
                    labelText: getTranslated(context, 'notes'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'stop_card')),
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          stopCardHandler(widget.cardNo, stopReason.reasonId,
                              noteController.text);
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  stopCardHandler(String cardNo, String reasonId, String notes) async {
    print("stopCardHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_number'] =
        cardNo.toString().replaceAll(new RegExp(r"\s+"), "");
    apiBodyObj['reason_id'] = reasonId;
    apiBodyObj['note'] = notes;

    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/StopCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess('success');
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onFailure(response['error']);
    }
  }
}

class _UnStopCardBottomSheetWidget extends StatefulWidget {
  String cardNo;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  _UnStopCardBottomSheetWidget({this.cardNo, this.onSuccess, this.onFailure});

  @override
  _UnStopCardBottomSheetWidgetState createState() =>
      _UnStopCardBottomSheetWidgetState();
}

class _UnStopCardBottomSheetWidgetState
    extends State<_UnStopCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: getTranslated(context, 'enter_notes'),
                    labelText: getTranslated(context, 'notes'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'unstop_card')),
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          unStopCardHandler(widget.cardNo, noteController.text);
                        },
                      ),
              ),
            ],
          ),
        ));
  }

  unStopCardHandler(String cardNo, String notes) async {
    print("unStopCardHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_number'] =
        cardNo.toString().replaceAll(new RegExp(r"\s+"), "");
    apiBodyObj['note'] = notes;

    Map<String, dynamic> response =
        await NetworkHelper.request('tutuka/UnstopCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onSuccess('success');
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      widget.onFailure(response['error']);
    }
  }
}
