import 'package:flutter/material.dart';
import 'package:tagcash/apps/create_currency/create_currency_screen.dart';
import 'package:tagcash/apps/create_currency/currency_details_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/create_currency/models/token.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/utils/common_methods.dart';
import 'package:tagcash/apps/create_currency/currency_manage_screen.dart';

class CurrenciesListScreen extends StatefulWidget {
  @override
  _CurrenciesListScreenState createState() => _CurrenciesListScreenState();
}

class _CurrenciesListScreenState extends State<CurrenciesListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<List<Token>> tokens;

  @override
  void initState() {
    super.initState();

    tokens = getTokensList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future<List<Token>> getTokensList() async {
    print(
        '============================getting created currency ============================');
    var apiBodyObj = {
      "new_call": "1",
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/MyTokens', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['result'];
      List<Token> getData = responseList.map<Token>((json) {
        return Token.fromJson(json);
      }).toList();
      return getData;
    } else {
      var error = response["error"];

      var message = '';
      if (error == "please_switch_to_merchant") {
        message = getTranslated(context, "please_switch_to_merchant_account");
      } else if (error == "exchange allowded values 0or1or2") {
        message = getTranslated(context, "exchange_allowded_values_0or1or2");
      } else if (error == 'request_failed') {
        message = getTranslated(context, "request_failed");
      } else if (error == "no_active_plan_found") {
        message = getTranslated(context, "no_active_plan_found");
      } else {
        message = getTranslated(context, "error_occurred");
      }

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: new Text(getTranslated(context, 'error') + ': ' + message),
        duration: new Duration(seconds: 3),
      ));
    }
    return [];
  }

  Future<void> refreshTokenList() {
    getTokensList();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "create_currency_manage_tokens"),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: FutureBuilder<List<Token>>(
          future: tokens,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Token> data = snapshot.data;
              return _buildTokenList(data);
            } else if (snapshot.hasError) {
              //return Text("${snapshot.error}");
              print("${snapshot.error}");
            }
            return Center(child: Loading());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => CreateCurrencyScreen(),
//            ),
//          ).then((val) => {
//                setState(() {
//                  tokens = getTokensList();
//                })
//              });
          _createButtonTapped();
        },
        child: Icon(Icons.add),
        tooltip: getTranslated(context, "create_reward"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  RefreshIndicator _buildTokenList(_tokensList) {
    return RefreshIndicator(
        onRefresh: refreshTokenList,
        child: ListView.builder(
            itemCount: _tokensList.length,
            itemBuilder: (context, i) {
              return _buildRow(_tokensList[i]);
            }));
  }

  _buildRow(Token row) {
    return Card(
        child: ListTile(
      contentPadding: EdgeInsets.all(10),
      title: Text(row.walletName),
      subtitle: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: [
          Expanded(
              flex: 6, // 60%
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              color: Colors.red, style: BorderStyle.solid))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.currencyCode,
                        ),
                        Text(row.communityName),
                      ]))),
          Expanded(
              flex: 4, // 40%
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  CommonMethods.removeTrailingZeros(row.balanceAmount),
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  row.canIssueMoreLater
                      ? getTranslated(context, "reissuable")
                      : getTranslated(context, "fixed"),
                )
              ]))
        ]),
      ),
      onTap: () {
        _listItemTapped(row);
      },
    ));
  }

  Future _listItemTapped(Token token) async {
    print("00000" + token.currencyCode.toString());
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CurrencyManageScreen(token: token),
    ));
    tokens = getTokensList();
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'updateSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "token_updated_success")),
              duration: const Duration(seconds: 3));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _createButtonTapped() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateCurrencyScreen(),
    ));
    tokens = getTokensList();
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "token_created_success")),
              duration: const Duration(seconds: 3));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
