import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:tagcash/apps/buy_load/buy_load_screen.dart';
import 'package:tagcash/apps/buy_sell/buy_sell_crypto_screen.dart';
import 'package:tagcash/apps/debit_cards/debit_cards_screen.dart';
import 'package:tagcash/apps/pay_bills/pay_bill_screen.dart';
import 'package:tagcash/apps/wallet/add_wallet_screen.dart';
import 'package:tagcash/apps/wallet/family_member_screen.dart';
import 'package:tagcash/apps/wallet/models/transaction.dart';
import 'package:tagcash/apps/wallet/receive/buy_cred_screen.dart';
import 'package:tagcash/apps/wallet/wallet_receive_screen.dart';
import 'package:tagcash/apps/wallet/wallet_send_screen.dart';
import 'package:tagcash/apps/wallet/wallet_transactions_screen.dart';
import 'package:tagcash/components/exportStatement.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/currency_format.dart';
import 'package:tagcash/utils/currency_utils.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../constants.dart';

class WalletInfo extends StatefulWidget {
  final bool businessSite;
  final Function(String) transactionsRefresh;

  const WalletInfo({
    Key key,
    this.transactionsRefresh,
    this.businessSite,
  }) : super(key: key);

  @override
  _WalletInfoState createState() => _WalletInfoState();
}

class _WalletInfoState extends State<WalletInfo> {
  List<Wallet> walletsListData;

  Wallet activeWallet;
  bool isLoading = true;

  bool familyMemberPossible = false;

  @override
  void initState() {
    super.initState();

    allWalletListLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      checkUserVerified();
    }
  }

  void checkUserVerified() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/GetLevel');

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      var verifivationlevel = responseMap['verification_level'];

      if (verifivationlevel >= 3) {
        familyMemberPossible = true;
      }

      setState(() {});
    }
  }

  allWalletListLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    apiBodyObj['wallet_type'] = '[0,1,3,4]';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();

    setState(() {
      activeWallet = getData[0];
      isLoading = false;
      walletsListData = getData.toList();
    });
    if (widget.businessSite) {
      widget.transactionsRefresh(activeWallet.walletId.toString());
    }
  }

  Future<void> walletDataRefresh() {
    updateWalletBalance();
    return Future.value();
  }

  updateWalletBalance() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['wallet_type_id'] = activeWallet.walletId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();

    setState(() {
      activeWallet = getData[0];
      isLoading = false;
    });
    if (widget.businessSite) {
      widget.transactionsRefresh(activeWallet.walletId.toString());
    }

    updateWalletListData();
  }

  updateWalletListData() {
    for (Wallet w in walletsListData) {
      if (w.walletId == activeWallet.walletId) {
        w.balanceAmount = activeWallet.balanceAmount;
        setState(() {});
      }
    }
  }

  walletSelectClick(Wallet selectWallet) {
    setState(() {
      activeWallet = selectWallet;
    });

    if (widget.businessSite) {
      widget.transactionsRefresh(activeWallet.walletId.toString());
    }
  }

  addMoneyClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletReceiveScreen(
          wallet: activeWallet,
        ),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  removeWallet(Wallet selectWallet) async {
    Navigator.pop(context);
    setState(() {
      walletsListData.remove(selectWallet);
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'wallet/delete/' + selectWallet.walletId.toString());
  }

  sendClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletSendScreen(
          wallet: activeWallet,
        ),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  buyCredClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyCredScreen(
          wallet: activeWallet,
        ),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  moreClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.businessSite && activeWallet.walletId == 1) ...[
                    Text(
                      getTranslated(context, 'Wallet_operated_tagcash'),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 20),
                  ],
                  if (!widget.businessSite) ...[
                    ElevatedButton(
                      onPressed: () => allTransactionsClicked(),
                      child: Text(getTranslated(context, 'transactions')),
                    ),
                    SizedBox(height: 10),
                  ],
                  ElevatedButton(
                    onPressed: () => exportReportClickHandle(),
                    child: Text(getTranslated(context, 'statement')),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showActiveWalletInfo();
                    },
                    child: Text(getTranslated(context, 'details_more')),
                  ),
                  SizedBox(height: 10),

                  activeWallet.walletId == 1
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () => buySellCrypto(),
                            child: Text(getTranslated(
                                context, 'buy_sell_crypto_currency')),
                          ),
                        )
                      : SizedBox(),
                  if (activeWallet.walletId == 1) ...[
                    familyMemberPossible
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed: () => manageFamilyMember(),
                              child: Text(
                                  getTranslated(context, 'family_account')),
                            ),
                          )
                        : SizedBox(),
                    ElevatedButton(
                      onPressed: () => debitCardsModuleLoad(),
                      child: Text(getTranslated(context, 'visa_debit_card')),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => buyloadModuleLoad(),
                      child: Text(getTranslated(context, 'buy_load')),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => payBillModuleLoad(),
                      child: Text(getTranslated(context, 'pay_bills')),
                    )
                  ],
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: Text('Exchange'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: Text('Buy crypto currency'),
                  // ),
                ],
              ),
            ),
          );
        });
  }

  void exportReportClickHandle() {
    Navigator.pop(context);

    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: ExportStatement(
                walletId: activeWallet.walletId.toString(),
              ),
            ),
          );
        });
  }

  showActiveWalletInfo() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(activeWallet.walletName),
                    subtitle: Text(activeWallet.currencyCode),
                    leading: activeWallet.walletTypeNumeric == 0
                        ? CurrencyUtils.countryCodeToImage(
                            activeWallet.currencyCode)
                        : CircleAvatar(
                            child: FittedBox(
                                child: Text(activeWallet.currencyCode)),
                          ),
                  ),
                  Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(120),
                      2: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          Text(
                            getTranslated(context, 'balance'),
                          ),
                          Text(
                            NumberFormat.currency(name: '')
                                .format(activeWallet.balanceAmount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            getTranslated(context, 'available'),
                          ),
                          Text(
                              NumberFormat.currency(name: '').format(
                                  activeWallet.balanceAmount -
                                      activeWallet.promisedAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      activeWallet.familyBalanceAmount != 0
                          ? TableRow(
                              children: [
                                Text(
                                  getTranslated(context, 'family_account'),
                                ),
                                Text(
                                    NumberFormat.currency(name: '').format(
                                        activeWallet.familyBalanceAmount),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                              ],
                            )
                          : TableRow(children: [
                              Text(
                                '',
                              ),
                              Text(
                                '',
                              ),
                            ]),
                      TableRow(
                        children: [
                          Text(
                            getTranslated(context, 'wallet_id'),
                          ),
                          Text(activeWallet.walletId.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            getTranslated(context, 'wallet_type'),
                          ),
                          Text(activeWallet.walletType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            getTranslated(context, 'wallet_name'),
                          ),
                          Text(activeWallet.walletName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                    ],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    title: Text(
                        getTranslated(context, 'stellar_issuer_address'),
                        style: Theme.of(context).textTheme.bodyText1),
                    subtitle: Text(activeWallet.stellarIssuerAddress,
                        style: Theme.of(context).textTheme.subtitle1),
                    trailing: IconButton(
                      icon: Icon(Icons.copy_outlined),
                      onPressed: () =>
                          addressCopyClicked(activeWallet.stellarIssuerAddress),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(activeWallet.walletDescription,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void addressCopyClicked(String address) {
    Clipboard.setData(ClipboardData(text: address));
    Fluttertoast.showToast(
        msg: getTranslated(context, 'copied_clipboard'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  buySellCrypto() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuySellCryptoCurrencyScreen(),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  manageFamilyMember() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyMemberScreen(wallet: activeWallet),
      ),
    );
  }

  buyloadModuleLoad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyLoadScreen(),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  debitCardsModuleLoad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebitCardsScreen(),
      ),
    );
  }

  payBillModuleLoad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayBillScreen(),
      ),
    ).whenComplete(() => updateWalletBalance());
  }

  allTransactionsClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletTransactionsScreen(
          filters: TransactionFilters(fromWalletId: activeWallet.walletId),
        ),
      ),
    );
  }

  addWalletClicked() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWalletScreen(),
      ),
    ).then((value) {
      if (value != null) {
        allWalletListLoad();
      }
    });
  }

  showWalletsList() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getTranslated(context, 'accounts'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontSize: 20),
                      ),
                    ),
                    // RaisedButton.icon(
                    //   icon: Icon(
                    //     Icons.add,
                    //     size: 20,
                    //   ),
                    //   label: Text(
                    //     'Add',
                    //     textScaleFactor: 1,
                    //   ),
                    //   color: Colors.grey.withOpacity(.5),
                    //   elevation: 0,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12.0),
                    //   ),
                    //   textColor: Theme.of(context).colorScheme.primary,
                    //   onPressed: () {
                    //     addWalletClicked();
                    //   },
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: walletsListData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        key: ValueKey(index),
                        actionPane: SlidableDrawerActionPane(),
                        enabled: walletsListData[index].balanceAmount == 0
                            ? true
                            : false,
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => removeWallet(walletsListData[index]),
                          ),
                        ],
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(walletsListData[index].walletName),
                              Text(
                                ' (${walletsListData[index].currencyCode})',
                                style: Theme.of(context).textTheme.bodyText2,
                              )
                            ],
                          ),
                          subtitle: Text(
                              CurrencyFormat.format(walletsListData[index])),
                          leading: walletsListData[index].walletTypeNumeric == 0
                              ? CurrencyUtils.countryCodeToImage(
                                  walletsListData[index].currencyCode)
                              : CircleAvatar(
                                  child: FittedBox(
                                      child: Text(
                                          walletsListData[index].currencyCode)),
                                ),
                          onTap: () {
                            walletSelectClick(walletsListData[index]);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer(
            duration: Duration(seconds: 2),
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 0),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        : Consumer<ThemeProvider>(builder: (context, themeStat, child) {
            return RefreshIndicator(
              onRefresh: walletDataRefresh,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: 10, right: 10, top: 16, bottom: 0),
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 6, bottom: 10),
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
                              showWalletsList();
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    activeWallet.walletTypeNumeric == 0
                                        ? CurrencyUtils.countryCodeToImage(
                                            activeWallet.currencyCode)
                                        : Text(
                                            activeWallet.currencyCode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w300),
                                          ),
                                    SizedBox(width: 4),
                                    buildBalanceArea(context),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                  if (activeWallet.walletTypeNumeric != 4) ...[
                                    RaisedButton.icon(
                                      icon: Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                      label: Text(
                                        getTranslated(context, 'add_money'),
                                        textScaleFactor: 1,
                                      ),
                                      color: themeStat.isDarkMode
                                          ? Color(0xFF1F1E1E)
                                          : Color(0xFFDDDADA),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        // side: BorderSide(color: Colors.red),
                                      ),
                                      textColor:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        addMoneyClicked();
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      textColor:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        sendClicked();
                                      },
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                  if (!UniversalPlatform.isIOS &&
                                      activeWallet.walletTypeNumeric == 4) ...[
                                    RaisedButton.icon(
                                      icon: Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                      label: Text(
                                        getTranslated(context, 'buy_home'),
                                        textScaleFactor: 1,
                                      ),
                                      color: themeStat.isDarkMode
                                          ? Color(0xFF1F1E1E)
                                          : Color(0xFFDDDADA),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        // side: BorderSide(color: Colors.red),
                                      ),
                                      textColor:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () {
                                        buyCredClicked();
                                      },
                                    ),
                                    SizedBox(width: 10),
                                  ],
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
                                        moreClicked();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
  }

  Widget buildBalanceArea(BuildContext context) {
    if (activeWallet.balanceAmount <= 0 &&
        activeWallet.familyBalanceAmount > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getTranslated(context, 'family_account'),
              style: Theme.of(context).textTheme.overline),
          Text(
            activeWallet.familyBalanceAmount.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      return Text(
        CurrencyFormat.format(activeWallet),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .headline5
            .copyWith(fontSize: 34, fontWeight: FontWeight.bold),
      );
    }
  }
}
