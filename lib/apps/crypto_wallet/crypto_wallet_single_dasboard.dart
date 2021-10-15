import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_information.dart';
import 'package:tagcash/apps/crypto_wallet/models/TagbondModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/TransactionModel.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';
import 'package:tagcash/apps/crypto_wallet/services/CryptoNetworking.dart';
import 'package:tagcash/apps/crypto_wallet/utils/BTC.dart';
import 'package:tagcash/apps/crypto_wallet/utils/CryptoWalletUtils.dart';
//import 'package:tagcash/apps/crypto_wallet/utils/XLM.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/theme_provider.dart';

class CryptoWalletSingleDashboardScreen extends StatefulWidget {
  _CryptoWalletSingleDashboardScreen createState() =>
      _CryptoWalletSingleDashboardScreen();
}

class _CryptoWalletSingleDashboardScreen
    extends State<CryptoWalletSingleDashboardScreen> {
  Wallets defaultWallet;
  List<TransactionModel> txnList = [];
  bool isLoading = true;
  CryptoWalletUtils cryptoWalletUtils = CryptoWalletUtils();
  TagbondModel walletModel;
  ScrollController scrollController;
  bool isLoadinNextpage = false;
  bool isLoadMore = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());

    cryptoWalletUtils.loadWallet().then((value) => walletModel = value);

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
  }

  walletBalanceUpdate(String symbol, String balance) {
    if (defaultWallet.symbol == symbol) {
      setState(() {
        defaultWallet.balance = balance;
      });
    }
  }

  void loadNextPage() async {
    setState(() {
      isLoadinNextpage = true;
      isLoading = true;
    });
    if (txnList.isNotEmpty) {
      final List<TransactionModel> txn = await CryptoNetworking.transactionList(
          defaultWallet.symbol, defaultWallet.address,
          nextPage: txnList.last.nextPage.toString());
      setState(() {
        txnList.addAll(txn);
        isLoading = false;
        isLoadinNextpage = false;
        if (isLoadMore && txn.length <= 0) {
          isLoadMore = false;
        }
      });
    } else {
      setState(() {
        isLoadinNextpage = false;
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 500 &&
        isLoadinNextpage == false &&
        isLoadMore) {
      loadNextPage();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void fetchData() async {
    final List<TransactionModel> txn = await CryptoNetworking.transactionList(
        defaultWallet.symbol, defaultWallet.address);
    setState(() {
      txnList = txn;
      isLoading = false;
    });
  }

  Future<Null> _onRefresh() async {
    final List<TransactionModel> txn = await CryptoNetworking.transactionList(
        defaultWallet.symbol, defaultWallet.address);
    setState(() {
      txnList = txn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    this.defaultWallet = arguments['defaultWallet'];

    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'crypto_wallet'),
        ),
        body: Container(
            child: Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: scrollController,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 25.0),
                          child: getTopContent()),
                      Padding(
                          padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                          child: getTransactionList()),
                      (isLoading)
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 2,
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: CircularProgressIndicator()),
                            )
                          : SizedBox(height: 0)
                    ]))));
  }

  Container getTopContent() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: kUserBackColor),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Colors.white))),
              child: Row(
                children: <Widget>[
                  Text(getTranslated(context, "balance"),
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.subtitle1.fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(defaultWallet.symbol,
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontSize,
                              color: Colors.white)),
                      SizedBox(width: 10),
                      Text(defaultWallet.balance,
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(width: 15),
                      GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    showInformationView(
                                        context, defaultWallet));
                          },
                          child: Icon(Icons.info_outline,
                              color: kPrimaryColor, size: 24))
                    ],
                  ))
                ],
              ))
        ],
      ),
    );
  }

  ListView getTransactionList() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        // scrollDirection: Axis.horizontal,
        itemCount: txnList.length,
        itemBuilder: (context, index) {
          return Container(
              width: double.maxFinite,
              child: Card(
                  margin: EdgeInsets.only(top: 4, bottom: 4, left: 0, right: 0),
                  child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: kTextLightColor),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: (Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100])),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: 2,
                                            color: kPrimaryColor,
                                            style: BorderStyle.solid)),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(txnList[index].id,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        Provider.of<ThemeProvider>(
                                                                    context)
                                                                .isDarkMode
                                                            ? Colors.grey[100]
                                                            : Colors
                                                                .grey[800])),
                                            Text(txnList[index].createDate,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Provider.of<ThemeProvider>(
                                                                    context)
                                                                .isDarkMode
                                                            ? Colors.grey[100]
                                                            : Colors.grey[800]))
                                          ])))),
                          Container(
                              padding: EdgeInsets.only(left: 10),
                              width: 90,
                              child: Center(
                                  child: Text(txnList[index].balance,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: (txnList[index].isSpent())
                                              ? kPrimaryColor
                                              : Colors.green[900]))))
                        ],
                      ))));
        });
  }
}
