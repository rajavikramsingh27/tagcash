import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:location/location.dart';
import 'package:tagcash/apps/advertising/ad_video_screen.dart';
import 'package:tagcash/apps/debit_cards/card_utils.dart';
import 'package:tagcash/apps/debit_cards/debit_card_transactions_screen.dart';
import 'package:tagcash/apps/debit_cards/models/debit_card.dart';
import 'package:tagcash/apps/debit_cards/models/debit_wallet.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'dart:math';
import 'package:tagcash/localization/language_constants.dart';

class DebitCardsScreen extends StatefulWidget {
  @override
  _DebitCardsScreenState createState() => _DebitCardsScreenState();
}

class _DebitCardsScreenState extends State<DebitCardsScreen> {
  Future<List<DebitCard>> debitCards;
  final globalKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  bool isLoading = false;
  final _controller = new PageController(viewportFraction: 1);

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;
  int k = 1;
  String selectedId;
  String selectedCardNo;
  String selectedCardStatus;
  String selectedCardBalance;

  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  String adUrl;
  String adType;
  bool adLoading = true;
  Timer _timer;
  int _start = 10;
  bool showBackView = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();
    debitCards = debitCardsLoad();
    //checkLocation();
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  checkLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);

    setState(() {
      locationAvailable = true;
    });

    getAd();
  }

  getAd() async {
    print('getAd');
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    String apiUrl;
    apiBodyObj['latitude'] = _locationData.latitude.toString();
    apiBodyObj['longitude'] = _locationData.longitude.toString();
    apiUrl = 'Advertisement/GetAd';
    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);
    setState(() {
      isLoading = false;

      if (response['result']['video_url'] != "") {
        adUrl = response['result']['video_url'];
        adType = 'video';
      } else if (response['result']['image_name'] != "") {
        adUrl = response['result']['image_name'];
        adType = 'image';
        startTimer();
      }
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            setState(() {
              adLoading = false;
            });
          });
        } else {
          setState(() {
            print(_start.toString());
            _start--;
          });
        }
      },
    );
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

  Future<List<DebitCard>> debitCardsLoad() async {
    print('DebitCardsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/ListUserCards');

    print(response);
    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<DebitCard> getData = responseList.map<DebitCard>((json) {
      return DebitCard.fromJson(json);
    }).toList();
    if (getData.length > 0) {
      selectedId = getData[0].id;
      selectedCardNo = getData[0].cardNo; //.replaceAll(new RegExp(r"\s+"), "");
      selectedCardStatus = getData[0].cardStatus;
      selectedCardBalance = getData[0].cardBalance.toString();
    }
    return getData;
  }

//  void onCreditCardModelChange(CreditCardModel creditCardModel) {
//    setState(() {
//      cardNumber = creditCardModel.cardNumber;
//      expiryDate = creditCardModel.expiryDate;
//      cardHolderName = creditCardModel.cardHolderName;
//      cvvCode = creditCardModel.cvvCode;
//      isCvvFocused = creditCardModel.isCvvFocused;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'debit_cards'),
        ),
        body:
//        (adLoading == false)
//            ?
            Stack(children: [
          FutureBuilder(
            future: debitCards,
            builder: (BuildContext context,
                AsyncSnapshot<List<DebitCard>> snapshot) {
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
                                        selectedId = snapshot.data[index].id;
                                        selectedCardNo =
                                            snapshot.data[index].cardNo;
                                        //.replaceAll(new RegExp(r"\s+"), "");
                                        selectedCardStatus =
                                            snapshot.data[index].cardStatus;

                                        selectedCardBalance = snapshot
                                            .data[index].cardBalance
                                            .toString();
                                      });
                                    },
                                    itemBuilder: (_, i) {
                                      return Transform.scale(
                                        scale: i == _index ? 1 : 0.9,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (showBackView)
                                                showBackView = false;
                                              else
                                                showBackView = true;
                                            });
                                          },
                                          child: CreditCardWidget(
                                            cardNumber:
                                                snapshot.data[_index].cardNo,
                                            expiryDate: snapshot
                                                    .data[_index].expiryMonth
                                                    .toString() +
                                                '/' +
                                                snapshot.data[_index].expiryYear
                                                    .toString(),
                                            cvvCode: snapshot.data[_index].cvv
                                                .toString(),
                                            cardHolderName:
                                                snapshot.data[_index].cardName,
                                            showBackView: showBackView,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            obscureCardCvv: false,
                                            obscureCardNumber: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Container(
                                height: 160,
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'no_debit_cards'),
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
                                          return CreateDebitCardBottomSheetWidget(
                                              onSuccess: (value) {
                                            final snackBar = SnackBar(
                                                content: Text(getTranslated(
                                                    context,
                                                    'success_create_debit_card')),
                                                duration:
                                                    const Duration(seconds: 3));
                                            globalKey.currentState
                                                .showSnackBar(snackBar);
                                            if (snapshot.data.length > 0)
                                              _controller.jumpToPage(0);
                                            debitCards = debitCardsLoad();
                                          }, onFailure: (value) {
                                            final snackBar = SnackBar(
                                                content: Text(value),
                                                duration:
                                                    const Duration(seconds: 3));
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
                              if (selectedCardStatus == 'inactive')
                                Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              SizedBox(height: 10),
                              Text(
                                getTranslated(context, 'card_balance') +
                                    ' - ' +
                                    selectedCardBalance +
                                    ' PHP',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    child: Text(
                                        getTranslated(context, 'rename_card')),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      //reLoadHandler();
                                      setState(() {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: kBottomSheetShape,
                                            builder: (BuildContext context) {
                                              return RenameCardBottomSheetWidget(
                                                  id: selectedId,
                                                  onSuccess: (value) {
                                                    final snackBar = SnackBar(
                                                        content: Text(getTranslated(
                                                            context,
                                                            'renamed_debit_card')),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3));
                                                    globalKey.currentState
                                                        .showSnackBar(snackBar);
                                                    _controller.jumpToPage(0);
                                                    debitCards =
                                                        debitCardsLoad();
                                                  },
                                                  onFailure: (value) {
                                                    final snackBar = SnackBar(
                                                        content: Text(value),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3));
                                                    globalKey.currentState
                                                        .showSnackBar(snackBar);
                                                  });
                                            });
                                      });
                                    },
                                  ),
                                ),
                              ),
                              //SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    child: Text(
                                        getTranslated(context, 'reload_card')),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      //reLoadHandler();
                                      setState(() {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: kBottomSheetShape,
                                            builder: (BuildContext context) {
                                              return ReloadCardBottomSheetWidget(
                                                  id: selectedId,
                                                  onSuccess: (value) {
                                                    final snackBar = SnackBar(
                                                        content: Text(getTranslated(
                                                            context,
                                                            'success_load_debit_card')),
                                                        duration:
                                                            const Duration(
                                                                seconds: 3));
                                                    globalKey.currentState
                                                        .showSnackBar(snackBar);
                                                    _controller.jumpToPage(0);
                                                    debitCards =
                                                        debitCardsLoad();
                                                  },
                                                  onFailure: (value) {
                                                    String str = value;
                                                    if (value ==
                                                        "insufficient_balance")
                                                      str = getTranslated(
                                                          context,
                                                          'insufficient_balance');
                                                    else if (value ==
                                                        "ctbc_sign_on_request_failed")
                                                      str = getTranslated(
                                                          context,
                                                          'ctbc_sign_on_request_failed');
                                                    else if (value ==
                                                        "ctbc_post_transaction_failed")
                                                      str = getTranslated(
                                                          context,
                                                          'ctbc_post_transaction_failed');
                                                    else if (value ==
                                                        "wallet_transfer_failed")
                                                      str = getTranslated(
                                                          context,
                                                          'wallet_transfer_failed');
                                                    else if (value ==
                                                        "ctbc_process_transaction_failed")
                                                      str = getTranslated(
                                                          context,
                                                          'ctbc_process_transaction_failed');
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
                                  ),
                                ),
                              ),
                              (selectedCardStatus == 'active')
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          child: Text(getTranslated(context,
                                              'disconnect_from_account')),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            disconnectCardHandler();
                                          },
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          child: Text(getTranslated(
                                              context, 'activate_card')),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            activateCardHandler();
                                          },
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    child: Text(getTranslated(
                                        context, 'transaction_report')),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DebitCardTransactionsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              child: Text(getTranslated(
                                  context, 'purchase_debit_card')),
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                setState(() {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: kBottomSheetShape,
                                      builder: (BuildContext context) {
                                        return PurchaseDebitCardBottomSheetWidget(
                                            onSuccess: (value) {
                                          final snackBar = SnackBar(
                                              content: Text(getTranslated(
                                                  context,
                                                  'success_purchase_debit_card')),
                                              duration:
                                                  const Duration(seconds: 3));
                                          globalKey.currentState
                                              .showSnackBar(snackBar);
                                          if (snapshot.data.length > 0)
                                            _controller.jumpToPage(0);
                                          debitCards = debitCardsLoad();
                                        }, onFailure: (value) {
                                          String str = value;
                                          if (value == "insufficient_balance")
                                            str = getTranslated(context,
                                                'insufficient_balance');
                                          else if (value ==
                                              "card_details_not_found")
                                            str = getTranslated(
                                                context, 'no_cards_available');
                                          else if (value == "invalid_id")
                                            str = getTranslated(
                                                context, 'invalid_id');
                                          else if (value ==
                                              "wallet_transfer_failed")
                                            str = getTranslated(context,
                                                'wallet_transfer_failed');
                                          else if (value ==
                                              "invalid_purchase_id")
                                            str = getTranslated(
                                                context, 'invalid_purchase_id');
                                          else
                                            str = value;
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
                                      return CreateDebitCardBottomSheetWidget(
                                          onSuccess: (value) {
                                        final snackBar = SnackBar(
                                            content: Text(getTranslated(context,
                                                'success_create_debit_card')),
                                            duration:
                                                const Duration(seconds: 3));
                                        globalKey.currentState
                                            .showSnackBar(snackBar);
                                        if (snapshot.data.length > 0)
                                          _controller.jumpToPage(0);
                                        debitCards = debitCardsLoad();
                                      }, onFailure: (value) {
                                        final snackBar = SnackBar(
                                            content: Text(value),
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
//            : Stack(children: [
//                if (adType == 'video')
//                  AdVideoScreen(
//                    video: adUrl,
//                    onFinishPlaying: (value) {
//                      //deleteLoanHandler();
//                      setState(() {
//                        adLoading = false;
//                      });
//                    },
//                  ),
//                if (adType == 'image')
//                  Stack(alignment: Alignment.bottomCenter, children: [
//                    Center(
//                      child: Padding(
//                          padding: const EdgeInsets.all(5.0),
//                          child: SizedBox(
//                            width: double.infinity,
//                            child: ClipRRect(
//                              borderRadius: BorderRadius.circular(5.0),
//                              child: Image.network(
//                                adUrl,
//                                height: 500.0,
//                                //width: 48.0,
//                                fit: BoxFit.fitWidth,
//                              ),
//                            ),
//                          )),
//                    ),
//                    Padding(
//                      child: Container(
//                        padding: EdgeInsets.all(10),
//                        decoration: BoxDecoration(
//                          color: kPrimaryColor,
//                          shape: BoxShape.circle,
//                        ),
//                        //child: Center(
//                        child: Text("$_start",
//                            style: TextStyle(
//                                fontSize: 17,
//                                fontWeight: FontWeight.bold,
//                                color: Colors.white)),
//                      ),
//                      padding: EdgeInsets.only(bottom: 20),
//                    )
//                  ])
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: Loading()))
              : SizedBox(),
        ]));
  }

  disconnectCardHandler() async {
    print("disconnectCardHandler");
    print(selectedCardNo);
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_no'] =
        selectedCardNo.toString().replaceAll(new RegExp(r"\s+"), "");

    Map<String, dynamic> response = await NetworkHelper.request(
        'CTBC/DisconnectCardFromAccount', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
          content: Text(getTranslated(context, 'disconnect_debit_card')),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);

      _controller.jumpToPage(0);
      debitCards = debitCardsLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
          content: Text(response['error']),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  activateCardHandler() async {
    print("activateCardHandler");
    print(selectedCardNo);
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_no'] = selectedCardNo;

    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/ActivateCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
          content: Text(getTranslated(context, 'activate_debit_card')),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);

      _controller.jumpToPage(0);
      debitCards = debitCardsLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      final snackBar = SnackBar(
          content: Text(response['error']),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class PurchaseDebitCardBottomSheetWidget extends StatefulWidget {
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  PurchaseDebitCardBottomSheetWidget({this.onSuccess, this.onFailure});

  @override
  _PurchaseDebitCardBottomSheetWidgetState createState() =>
      _PurchaseDebitCardBottomSheetWidgetState();
}

class _PurchaseDebitCardBottomSheetWidgetState
    extends State<PurchaseDebitCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final currencyItems = {
    '1': 'PHP',
    '7': 'TAG',
  };
  String currency = '1';
  bool isLoading = false;
  DebitWallet debitWallet;
  Future<List<DebitWallet>> debitWallets;
  TextEditingController amountController = TextEditingController();

  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    debitWallets = debitWalletsLoad();
  }

  Future<List<DebitWallet>> debitWalletsLoad() async {
    print('debitWalletsLoad');
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/GetWalletTypesForPurchase');

    print(response);
    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<DebitWallet> getData = responseList.map<DebitWallet>((json) {
      return DebitWallet.fromJson(json);
    }).toList();

    return getData;
  }

  Widget _debitWalletsList() {
    return FutureBuilder(
        future: debitWallets,
        builder:
            (BuildContext context, AsyncSnapshot<List<DebitWallet>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<DebitWallet>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, 'select_wallet')),
                  value: debitWallet,
                  onChanged: (DebitWallet value) {
                    setState(() {
                      debitWallet = value;
                      amountController.text = debitWallet.amount;
                    });
                  },
                  items: snapshot.data.map((DebitWallet debitWallet) {
                    return DropdownMenuItem<DebitWallet>(
                      value: debitWallet,
                      child: Text(debitWallet.walletName),
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
                    child: _debitWalletsList(),
                  ),
                  SizedBox(width: 20),
                  (debitWallet != null)
                      ? Expanded(
                          flex: 1,
                          child: Text(
                            getTranslated(context, 'price') +
                                ': ' +
                                debitWallet.amount,
                            style: TextStyle(
                              fontSize: 24,
                              //fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
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
                    return getTranslated(
                        context, 'dont_enter_a_number_as_address');
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
                            if (debitWallet == null) {
                              Navigator.of(context).pop();
                              widget.onFailure(getTranslated(
                                  context, 'please_select_a_wallet'));
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
    apiBodyObj['pcm_id'] = debitWallet.pcmId;
    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/PurchaseCard', apiBodyObj);

    print(response);
    if (response['status'] == 'success') {
      //String res = response['result'];
      setState(() {
        isLoading = false;
      });
//      Navigator.of(context).pop();
//      widget.onSuccess('success');
      connectHandler(response['result']['purchase_id']);
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();

      widget.onFailure(response['error']);
    }
  }

  connectHandler(String purchaseId) async {
    print("connectHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['purchase_id'] = purchaseId;
    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/ConnectCardDynamically', apiBodyObj);

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

class CreateDebitCardBottomSheetWidget extends StatefulWidget {
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  CreateDebitCardBottomSheetWidget({this.onSuccess, this.onFailure});

  @override
  _CreateDebitCardBottomSheetWidgetState createState() =>
      _CreateDebitCardBottomSheetWidgetState();
}

class _CreateDebitCardBottomSheetWidgetState
    extends State<CreateDebitCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();
  final accountNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final nameController = TextEditingController();

//  final monthController = TextEditingController();
//  final yearController = TextEditingController();
  final cvvController = TextEditingController();

  bool isLoading = false;

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
              SizedBox(height: 10),
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  new CardNumberInputFormatter()
                ],
                decoration: InputDecoration(
                  hintText: 'xxxx xxxx xxxx xxxx',
                  labelText: getTranslated(context, 'enter_card_no'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_card_no');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_acc_no'),
                  labelText: getTranslated(context, 'enter_acc_no'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'please_enter_acc_no');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'enter_card_holder_name'),
                  labelText: getTranslated(context, 'enter_card_holder_name'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(
                        context, 'please_enter_card_holder_name');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
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
                        hintText: 'mm/yy',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        new CardMonthInputFormatter()
                      ],
                      validator: CardUtils.validateDate,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 40,
                    child: TextFormField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'enter_cvv'),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value.isEmpty) {
                          return getTranslated(context, 'please_enter_cvv');
                          // return 'Enter valid amount';
                        }
                        if (value.length < 3 || value.length > 4) {
                          return getTranslated(context, 'cvv_is_invalid');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'connect_card')),
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
              SizedBox(height: 10),
            ],
          ),
        ));
  }

  createHandler() async {
    print("createHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['card_no'] =
        numberController.text.toString().replaceAll(new RegExp(r"\s+"), "");

    List<String> expiryDate =
        CardUtils.getExpiryDate(expiryDateController.text.toString());
    apiBodyObj['expiry_month'] = expiryDate[0];
    apiBodyObj['expiry_year'] = expiryDate[1];
    apiBodyObj['cvv'] = cvvController.text.toString();
    apiBodyObj['account_no'] = accountNumberController.text.toString();
    apiBodyObj['card_name'] = nameController.text.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/ConnectCardToAccount', apiBodyObj);

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
      if (response['error'] == 'card_number_already_exist')
        widget.onFailure(getTranslated(context, 'card_number_already_exist'));
      else
        widget.onFailure(response['error']);
    }
  }
}

class ReloadCardBottomSheetWidget extends StatefulWidget {
  String id;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  ReloadCardBottomSheetWidget({this.id, this.onSuccess, this.onFailure});

  @override
  _ReloadCardBottomSheetWidgetState createState() =>
      _ReloadCardBottomSheetWidgetState();
}

class _ReloadCardBottomSheetWidgetState
    extends State<ReloadCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  final amountController = TextEditingController();
  final remarksController = TextEditingController();
  String accountNumber = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAccountNumber();
    //checkLocation();
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
              SizedBox(height: 10),
              Text(
                getTranslated(context, 'acc_no') + ": " + '${accountNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 20,
                    child: Text(
                      "PHP",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 40,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, 'enter_amount'),
                        labelText: getTranslated(context, 'enter_amount'),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value.isEmpty) {
                          return getTranslated(context, 'please_enter_amount');
                          // return 'Enter valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: remarksController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'remarks'),
                  labelText: getTranslated(context, 'remarks'),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'reload_card')),
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            if (accountNumber == "") {
                              Navigator.of(context).pop();

                              widget.onFailure(
                                  getTranslated(context, 'acc_no_not_found'));
                            } else
                              reLoadHandler();
                          }
                        },
                      ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ));
  }

  getAccountNumber() async {
    print("getAccountNumber");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
//    apiBodyObj['amount'] = '10';
//    apiBodyObj['acc'] = '001045337688';
    apiBodyObj['id'] = widget.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/GetAccountNumber', apiBodyObj);

    print(response);
//    if (response['status'] == 'success') {
    //String res = response['result'];
    setState(() {
      isLoading = false;
      accountNumber = response['account_no'];
    });
//    } else {
//      setState(() {
//        isLoading = false;
//      });
//    }
  }

  reLoadHandler() async {
    print("reLoadHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
//    apiBodyObj['amount'] = '10';
//    apiBodyObj['acc'] = '001045337688';
    apiBodyObj['id'] = widget.id.toString();
    apiBodyObj['amount'] = amountController.text.toString();
    apiBodyObj['acc'] = accountNumber;
    apiBodyObj['wallet_id'] = '1';
    if (remarksController.text.isNotEmpty)
      apiBodyObj['remark'] = remarksController.text.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Deposit/CTBCCardLoad', apiBodyObj);

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
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class RenameCardBottomSheetWidget extends StatefulWidget {
  String id;
  ValueChanged<String> onSuccess;
  ValueChanged<String> onFailure;

  RenameCardBottomSheetWidget({this.id, this.onSuccess, this.onFailure});

  @override
  _RenameCardBottomSheetWidgetState createState() =>
      _RenameCardBottomSheetWidgetState();
}

class _RenameCardBottomSheetWidgetState
    extends State<RenameCardBottomSheetWidget> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  bool isLoading = false;

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
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: getTranslated(context, 'entr_name'),
                  labelText: getTranslated(context, 'entr_name'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return getTranslated(context, 'enter_name');
                    // return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: Loading())
                    : RaisedButton(
                        child: Text(getTranslated(context, 'rename_card')),
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            renameHandler();
                          }
                        },
                      ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ));
  }

  renameHandler() async {
    print("renameHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['id'] = widget.id.toString();
    apiBodyObj['card_name'] = nameController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('CTBC/RenameCard', apiBodyObj);

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
      if (response['error'] == 'card_number_already_exist')
        widget.onFailure(getTranslated(context, 'card_number_already_exist'));
      else
        widget.onFailure(response['error']);
    }
  }
}
