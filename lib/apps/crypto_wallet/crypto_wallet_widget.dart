import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_list_modal.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_receive_view.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_send_btc_view.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_send_eth.dart';
import 'package:tagcash/apps/crypto_wallet/crytpo_wallet_send_xlm.dart';
import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/apps/crypto_wallet/services/CryptoNetworking.dart';
import 'package:tagcash/apps/crypto_wallet/utils/BTC.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_information.dart';
import 'package:tagcash/apps/crypto_wallet/utils/ETH.dart';
//import 'package:tagcash/apps/crypto_wallet/utils/XLM.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletWidget extends StatefulWidget {
  @override
  _CryptoWalletWidget createState() => _CryptoWalletWidget();
}

class _CryptoWalletWidget extends State<CryptoWalletWidget> {
  bool isWalletLogin = false;
  bool isLoading = true;

  CryptoWalletUtils cryptoWalletUtils = CryptoWalletUtils();

  @override
  void initState() {
    super.initState();
    // cryptoWalletUtils.removeWallet();
    checkWalletLogin();
  }

  void checkWalletLogin() async {
    try {
      bool walletLogin = await cryptoWalletUtils.isWalletLogin();
      setState(() {
        isWalletLogin = walletLogin;
        isLoading = false;
      });
    } catch (err) {
      print(err);
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? CryptoShimer()
        : (isWalletLogin)
            ? CryptoWalletInfo()
            : CryptoWalletSetup();
  }
}

class CryptoWalletSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeStat, child) {
      return Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
          padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 0),
          decoration: BoxDecoration(
              color: themeStat.isDarkMode
                  ? Colors.grey.withOpacity(.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8)),
          height: 210,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 25),
                Text(
                    getTranslated(context,
                        "you_don_t_have_any_wallet_please_setup_a_crypto_wallet"),
                    textAlign: TextAlign.center),
                SizedBox(height: 25),
                RaisedButton.icon(
                  icon: Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: Text(
                    getTranslated(context, 'setup_wallet'),
                    textScaleFactor: 1,
                  ),
                  color: themeStat.isDarkMode
                      ? Color(0xFF1F1E1E)
                      : Color(0xFFDDDADA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    // side: BorderSide(color: Colors.red),
                  ),
                  textColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/crypto');
                  },
                ),
              ],
            ),
          ));
    });
  }
}

class CryptoShimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400],
      highlightColor: Colors.grey[100],
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
        height: 210,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class CryptoWalletInfo extends StatefulWidget {
  _CryptoWalletInfo createState() => _CryptoWalletInfo();
}

class _CryptoWalletInfo extends State<CryptoWalletInfo> {
  CryptoWalletUtils cryptoWalletUtils = CryptoWalletUtils();
  bool isLoading = true;
  WalletDataModel walletDataModel;
  TagbondModel walletModel;
  Wallets defaultWallet;

  @override
  void initState() {
    super.initState();
    _fetchWalletDetails();

    /// register
    // FBroadcast.instance().register(XLM.XLM_BALANCE_UPDATE,
    //     (value, callback) async {
    //   String xlmBalance = await walletModel.getXLMBalance();
    //   walletBalanceUpdate(XLM.SYMBOL, xlmBalance);
    // });
    FBroadcast.instance().register(BTC.BTC_BALANCE_UPDATE,
        (value, callback) async {
      BTCBalanceDetails bTCBalanceDetails =
          await walletModel.getBTCBalance(walletModel.getBTCAddress());
      walletBalanceUpdate(BTC.SYMBOL, bTCBalanceDetails.getFinalBalance());
    });

    FBroadcast.instance().register(ETH.ETH_BALANCE_UPDATE,
        (value, callback) async {
      String ethBalance = await walletModel.getETHBalance();
      walletBalanceUpdate(ETH.SYMBOL, ethBalance);
    });
  }

  walletBalanceUpdate(String symbol, String balance) {
    if (defaultWallet.symbol == symbol) {
      setState(() {
        defaultWallet.balance = balance;
      });
    }
  }

  void _fetchWalletDetails() async {
    walletModel = await cryptoWalletUtils.loadWallet();
    walletDataModel = await CryptoNetworking.getWalletData(
        walletModel.getBTCAddress(),
        walletModel.getETHAddress(),
        walletModel.getXMLAddress());

    defaultWallet = walletDataModel.wallets.elementAt(0);

    setState(() {
      isLoading = false;
    });
    walletModel.startSocketForWallet();
    print("ETH Balance => " + await walletModel.getETHBalance());
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? CryptoShimer()
        : Consumer<ThemeProvider>(builder: (context, themeStat, child) {
            return RefreshIndicator(
              onRefresh: () => Future<void>.value(),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 0),
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 0),
                    decoration: BoxDecoration(
                      color: themeStat.isDarkMode
                          ? Colors.grey.withOpacity(.3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showActiveWalletList();
                            },
                            child: Row(children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        defaultWallet.symbol,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(
                                                fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        defaultWallet.balance,
                                        // CurrencyFormat.format(activeWallet),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(
                                                fontSize: 34,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 30,
                                      ),
                                      SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              child: Row(
                                children: [
                                  RaisedButton.icon(
                                    icon: Icon(
                                      Icons.add,
                                      size: 20,
                                    ),
                                    label: Text(
                                      getTranslated(context, 'receive'),
                                      textScaleFactor: 1,
                                    ),
                                    color: themeStat.isDarkMode
                                        ? Color(0xFF1F1E1E)
                                        : Color(0xFFDDDADA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      // side: BorderSide(color: Colors.red),
                                    ),
                                    textColor:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              showReceiveView(
                                                  context, defaultWallet));
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  RaisedButton.icon(
                                    icon: Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                    ),
                                    label: Text(
                                      getTranslated(context, 'send'),
                                      textScaleFactor: 1,
                                    ),
                                    color: themeStat.isDarkMode
                                        ? Color(0xFF1F1E1E)
                                        : Color(0xFFDDDADA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    textColor:
                                        Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            if (defaultWallet.symbol == "BTC") {
                                              return showBTCSendView(
                                                  context, defaultWallet);
                                            } else if (defaultWallet.symbol ==
                                                "XLM") {
                                              return showXLMSendView(
                                                  context, defaultWallet);
                                            } else {
                                              return showETHSendView(
                                                  context, defaultWallet);
                                            }
                                          });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width: 60,
                                    child: RaisedButton(
                                      child: Text(
                                        getTranslated(context, 'more'),
                                        textScaleFactor: 1,
                                      ),
                                      color: themeStat.isDarkMode
                                          ? Color(0xFF1F1E1E)
                                          : Color(0xFFDDDADA),
                                      elevation: 0,
                                      padding: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      textColor:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                showInformationView(
                                                    context, defaultWallet));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Expanded(
                            //   child: Opacity(
                            //     opacity: .5,
                            //     child: Text('Transactions'),
                            //   ),
                            // ),
                            TextButton(
                              child: Text(
                                getTranslated(context, 'see_transactions'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              onPressed: () => {
                                Navigator.pushNamed(
                                    context, "/crypto/wallet/details",
                                    arguments: {'defaultWallet': defaultWallet})
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
  }

  showActiveWalletList() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return WalletListModal(walletDataModel.wallets, onWalletClick);
        });
  }

  void onWalletClick(Wallets wallets) {
    setState(() {
      this.defaultWallet = wallets;
    });
  }
}
