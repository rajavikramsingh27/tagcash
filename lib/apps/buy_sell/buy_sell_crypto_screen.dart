import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/components/loading.dart';
import 'dart:async';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/buy_sell/model/crypto_wallet.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class BuySellCryptoCurrencyScreen extends StatefulWidget {
  @override
  _BuySellCryptoCurrencyScreenState createState() =>
      _BuySellCryptoCurrencyScreenState();
}

class _BuySellCryptoCurrencyScreenState
    extends State<BuySellCryptoCurrencyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode sellFocusNode;
  FocusNode buyFocusNode;
  bool saveClickPossible = true;
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  String cryptoCurrencySellAmount = "0.00";
  String cryptoCurrencyBuyAmount = "0.00";
  double rateinPHP;
  Wallet phpWallet;
  String conversionRate = "";
  List<CryptoWallet> walletsListData;
  Future<CryptoWallet> buyOrSellCryptoActiveWallet;
  CryptoWallet activeWallet;
  bool isLoading = false;
  bool _autoFocusBuy = false;
  bool _autoFocusSell = true;
  bool _isCryptoSellFlag = true;

  TextEditingController _phpBuyAmountController;
  TextEditingController _phpSellAmountController;

  @override
  void initState() {
    super.initState();
    sellFocusNode = FocusNode();
    buyFocusNode = FocusNode();
    _phpBuyAmountController = TextEditingController();
    _phpSellAmountController = TextEditingController();
    loadPHPCryptoWallets();
  }

  void loadPHPCryptoWallets() {
    loadPHPWallet().then((Wallet wvalue) {
      phpWallet = wvalue;
      loadCryptoWalletsAndConvertRate();
    }).catchError((error) => showMessage(error));
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sellFocusNode.dispose();
    buyFocusNode.dispose();
    _phpBuyAmountController.dispose();
    _phpSellAmountController.dispose();
    super.dispose();
  }

  void calculateSellCryptoCurrencyAmount() {
    var formattedCryptoAmount = "0.00";
    if (_phpSellAmountController.text != "") {
      double phpAmount = double.parse(_phpSellAmountController.text);
      double cryptoAmount = (1 / rateinPHP) * phpAmount;
      var numberFormat = new NumberFormat("###,###.00000000",
          "en-US"); //Now we are calculating for 8 decimal points
      formattedCryptoAmount = numberFormat.format(cryptoAmount);
      if (cryptoAmount < 1) {
        formattedCryptoAmount = "0" + formattedCryptoAmount;
      }
    }
    setState(() {
      cryptoCurrencySellAmount = formattedCryptoAmount.toString();
    });
  }

  void calculateBuylCryptoCurrencyAmount() {
    var formattedCryptoAmount = "0.00";
    if (_phpBuyAmountController.text != "") {
      double phpAmount = double.parse(_phpBuyAmountController.text);
      double cryptoAmount = (1 / rateinPHP) * phpAmount;
      var numberFormat = new NumberFormat("###,###.00000000",
          "en-US"); //Now we are calculating for 8 decimal points
      formattedCryptoAmount = numberFormat.format(cryptoAmount);
      if (cryptoAmount < 1) {
        formattedCryptoAmount = "0" + formattedCryptoAmount;
      }
    }
    setState(() {
      cryptoCurrencyBuyAmount = formattedCryptoAmount.toString();
    });
  }

  void loadCryptoWalletsAndConvertRate() {
    buyOrSellCryptoActiveWallet = loadCryptoCurrenciesWallet();
    buyOrSellCryptoActiveWallet.then((CryptoWallet walletValue) {
      activeWallet = walletValue;
      fetchCurrencyConversionRate();
    }).catchError((error) => showMessage(error));
  }

  void fetchCurrencyConversionRate() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    if(_isCryptoSellFlag==true) {//If CryptoCurrency is selling then from wallet ID is CryptoWalletID
      apiBodyObj['from_wallet_id'] = activeWallet.id;
      apiBodyObj['to_wallet_id'] = "1";
    }
    else{//If CryptoCurrency is buying then from wallet ID is PHP
      apiBodyObj['from_wallet_id'] = "1";
      apiBodyObj['to_wallet_id'] = activeWallet.id;
    }
    Map<String, dynamic> response = await NetworkHelper.request(
        'buySellCrypto/CoingeckoExchangeRate', apiBodyObj);
    if (response['status'] == "success") {
      buyOrSellCryptoActiveWallet.then((CryptoWallet wvalue) {
        if(_isCryptoSellFlag==true) {//Selling Cryptowallet against PHP (For buying and selling Crypto, the PHP rates are different
          //So we put this condition here// )
          rateinPHP = response['result'];
          print(rateinPHP);
        }
        else{
          double rate=response['result'];
          rateinPHP=1/rate;
          print(rateinPHP);
          //If the process is buying then we got the response in CryptoWallet to PHP conversion
        }
        // var numberFormat = new NumberFormat("###,###.00000000", "en-US");
        // String formattedPHPRate = numberFormat.format(rateinPHP);

        String rate = NumberFormat.currency(name: '').format(rateinPHP);
        conversionRate = "1" + wvalue.currencyCode + " = " + "PHP " + rate;
      });
    } else {
      if (response['error'] == 'request_failed') {
        showMessage(getTranslated(context, "buysellcrypto_request_failed"));
      } else if (response['error'] == 'invalid_from_wallet_id_mapping') {
        showMessage(
            getTranslated(context, "buysellcrypto_inavlid_fromwalletid"));
      } else if (response['error'] == 'invalid_to_wallet_id_mapping') {
        showMessage(getTranslated(context, "buysellcrypto_invalid_towalletid"));
      } else if (response['error'] == 'request_not_completed') {
        showMessage(
            getTranslated(context, "buysellcrypto_request_notcompleted"));
      } else if (response['error'] == 'coin_gecko_connection_failed') {
        showMessage(getTranslated(context, "buysellcrypto_connection_failed"));
      } else {
        showMessage(getTranslated(context, "buysellcrypto_unspecified_error"));
      }
    }
    setState(() {
      if (_isCryptoSellFlag) {
        sellFocusNode.requestFocus();
      } else {
        buyFocusNode.requestFocus();
      }
      isLoading = false;
    });
  }

  Future<CryptoWallet> loadCryptoCurrenciesWallet() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('BuySellCrypto/CryptoWallets', apiBodyObj);
    if (response['status'] == "success") {
      List responseList = response['result'];
      if (responseList.length > 0) {
        List<CryptoWallet> getData = responseList.map<CryptoWallet>((json) {
          return CryptoWallet.fromJson(json);
        }).toList();
        walletsListData = getData;
        setState(() {
          isLoading = false;
          conversionRate = "1" + walletsListData[0].currencyCode + " = ";
        });
        return walletsListData[0];
      } else {
        showMessage("No crypto wallets found");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw (response['error']); /*No Specific Error*/

    }
  }

  Future<Wallet> loadPHPWallet() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    apiBodyObj['wallet_type'] = '[0]';
    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);
    if (response['status'] == "success") {
      List responseList = response['result'];
      List<Wallet> getData = responseList.map<Wallet>((json) {
        return Wallet.fromJson(json);
      }).toList();
      phpWallet = getData.firstWhere((wallet) => wallet.walletId == 1);
      setState(() {
        isLoading = false;
      });
      return phpWallet;
    } else {
      setState(() {
        isLoading = false;
      });
      throw (response["error"]);
    }
  }

  void cryptoCurrencyBuyOrSellProcessHandler() async {
    if (_isCryptoSellFlag && !Validator.isAmount(cryptoCurrencySellAmount)) {
      sellFocusNode.requestFocus();
      return;
    }
    if (!_isCryptoSellFlag &&
        !Validator.isAmount(_phpBuyAmountController.text)) {
      buyFocusNode.requestFocus();
      return;
    }

    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    if (_isCryptoSellFlag == true) {
      apiBodyObj['from_wallet_id'] = activeWallet.id;
      apiBodyObj['to_wallet_id'] = phpWallet.walletId.toString();
      apiBodyObj['from_wallet_amount'] = cryptoCurrencySellAmount;
    } else {
      apiBodyObj['from_wallet_id'] = phpWallet.walletId.toString();
      apiBodyObj['to_wallet_id'] = activeWallet.id;
      apiBodyObj['from_wallet_amount'] =
          _phpBuyAmountController.text.toString();
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('BuySellCrypto/Exchange', apiBodyObj);
    isLoading = false;
    _phpSellAmountController.text = "";
    _phpBuyAmountController.text = "";
    cryptoCurrencySellAmount = "0.00";
    cryptoCurrencyBuyAmount = "0.00";
    if (_isCryptoSellFlag) {
      sellFocusNode.requestFocus();
    } else {
      buyFocusNode.requestFocus();
    }
    setState(() {});
    if (response['status'] == "success") {
      if (_isCryptoSellFlag == true) {
        Fluttertoast.showToast(
            msg: '${activeWallet.walletName} sold successfully');
      } else {
        Fluttertoast.showToast(
            msg: '${activeWallet.walletName} bought successfully');
      }

      loadPHPCryptoWallets();
    } else {
      if (response['error'] == 'amount_too_big') {
        showMessage(getTranslated(context, "buysellcrypto_amount_big"));
      } else if (response['error'] == 'invalid_amount') {
        showMessage(getTranslated(context, "buysellcrypto_invalid_amount"));
      } else if (response['error'] == 'crypto_merchant_conf_missing') {
        showMessage(getTranslated(context, "buysellcrypto_merchant_missing"));
      } else if (response['error'] == 'insufficient_amount') {
        showMessage('Insufficient amount');
      } else {
        TransferError.errorHandle(context, response['error']);
      }
    }
  }

  void walletSelectClick(index) {
    _phpSellAmountController.text = "";
    _phpBuyAmountController.text = "";
    buyOrSellCryptoActiveWallet = getSelectedWallet(index);
    setState(() {});
    /* Call AN API to convert new crypto currency to PHP */

    buyOrSellCryptoActiveWallet.then((CryptoWallet wvalue) {
      activeWallet = wvalue;
      fetchCurrencyConversionRate();
    });
  }

  Future<CryptoWallet> getSelectedWallet(index) async {
    return walletsListData[index];
  }

  void sellCryptoProcessHandler() async {
    cryptoCurrencyBuyOrSellProcessHandler();
  }

  void showCryptoCurrenciesClickHandler() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: walletsListData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(walletsListData[index].walletName),
                  subtitle: Text(walletsListData[index].currencyCode),
                  leading: CircleAvatar(
                    child: FittedBox(
                        child: Text(walletsListData[index].currencyCode)),
                  ),
                  trailing: Text(walletsListData[index].balanceAmount),
                  onTap: () {
                    walletSelectClick(index);
                    Navigator.pop(context);
                  },
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget sellCryptoCurencySection = Container(
      child: FutureBuilder(
          /*here it is Future Builder required, otherwise in the initial loading , it will cause null errors*/
          future: buyOrSellCryptoActiveWallet,
          builder:
              (BuildContext context, AsyncSnapshot<CryptoWallet> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
            }

            if (snapshot.hasData) {
              var cryptoBalanceAmount =
                  double.parse(snapshot.data.balanceAmount.toString());
              var numberFormat = new NumberFormat("###,###.00000000", "en-US");
              String formattedCryptoBalance =
                  numberFormat.format(cryptoBalanceAmount);
              return Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                        child: Text(
                      getTranslated(context, "buysellcrypto_sell") +
                          " " +
                          snapshot.data.walletName.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                snapshot.data.currencyCode,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Icon(Icons.arrow_drop_down, size: 44),
                            ],
                          ),
                          onTap: () {
                            //  FocusScope.of(context).requestFocus(FocusNode());
                            showCryptoCurrenciesClickHandler();
                          },
                        ),
                        Text(
                          cryptoCurrencySellAmount,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Color(0xFFA2A1A1),
                              ),
                        ),
                      ],
                    ),
                    Text(
                      getTranslated(context, "buysellcrypto_balance") +
                          formattedCryptoBalance,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.autorenew,
                            color: Colors.grey,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCryptoSellFlag = false;
                              buyFocusNode.requestFocus();
                              print("fetch currency conversion for buying");
                              fetchCurrencyConversionRate();
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFFA2A1A1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                conversionRate,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: Colors.white),
                              ))),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "PHP",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: sellFocusNode,
                            //autofocus: _autoFocusSell,
                            textAlign: TextAlign.end,

                            style: Theme.of(context).textTheme.headline5,

                            controller: _phpSellAmountController,

                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              border: InputBorder.none,
                              labelText: "",
                              hintText: "",
                            ),
                            onChanged: (text) {
                              calculateSellCryptoCurrencyAmount();
                            },
                          ),
                        ),
                      ],
                    ),
                    Text(
                      getTranslated(context, "buysellcrypto_balance") +
                          NumberFormat.currency(name: '')
                              .format(phpWallet.balanceAmount),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(
                        getTranslated(context, 'buysellcrypto_sellnow'),
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        cryptoCurrencyBuyOrSellProcessHandler();
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                //this is needed, other wise causing error
                width: 0,
                height: 0,
              );
            }
          }),
    );

    Widget buyCryptoCurencySection = Container(
      child: FutureBuilder(
          future: buyOrSellCryptoActiveWallet,
          builder:
              (BuildContext context, AsyncSnapshot<CryptoWallet> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
            }

            if (snapshot.hasData) {
              var cryptoBalanceAmount =
                  double.parse(snapshot.data.balanceAmount.toString());
              var numberFormat = new NumberFormat("###,###.00000000", "en-US");
              String formattedCryptoBalance =
                  numberFormat.format(cryptoBalanceAmount);
              return Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                        child: Text(
                      getTranslated(context, "buysellcrypto_buy") +
                          " " +
                          snapshot.data.walletName.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    // SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "PHP",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: buyFocusNode,
                            // autofocus: _autoFocusBuy,
                            textAlign: TextAlign.end,
                            onChanged: (text) {
                              calculateBuylCryptoCurrencyAmount();
                            },
                            style: Theme.of(context).textTheme.headline5,

                            controller: _phpBuyAmountController,

                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              border: InputBorder.none,
                              labelText: "",
                              hintText: "",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      getTranslated(context, 'buysellcrypto_balance') +
                          NumberFormat.currency(name: '')
                              .format(phpWallet.balanceAmount),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.autorenew,
                            color: Colors.grey,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCryptoSellFlag = true;
                              sellFocusNode.requestFocus();
                              print("fetch currency conversion for selling");
                              fetchCurrencyConversionRate();
                            });
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFFA2A1A1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                conversionRate,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: Colors.white),
                              ))),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                snapshot.data.currencyCode,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Container(
                                child: Icon(Icons.arrow_drop_down, size: 44),
                              ),
                            ],
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            showCryptoCurrenciesClickHandler();
                          },
                        ),
                        Text(
                          cryptoCurrencyBuyAmount,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Color(0xFFA2A1A1),
                              ),
                        ),
                      ],
                    ),
                    Text(
                      getTranslated(context, "buysellcrypto_balance") +
                          " " +
                          formattedCryptoBalance,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(
                        getTranslated(context, 'buysellcrypto_buynow'),
                      ),
                      onPressed: saveClickPossible
                          ? () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              cryptoCurrencyBuyOrSellProcessHandler();
                            }
                          : null,
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                //this is needed, other wise causing error
                width: 0,
                height: 0,
              );
            }
          }),
    );
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "buysellcrypto_title"),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                //sellCryptoCurencySection,
                _isCryptoSellFlag
                    ? sellCryptoCurencySection
                    : buyCryptoCurencySection
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
