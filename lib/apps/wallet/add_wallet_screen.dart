import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/currency_utils.dart';
import 'models/wallet_types.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({Key key}) : super(key: key);

  @override
  _AddWalletScreenState createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  bool isLoading = false;
  TextEditingController _searchInputController = TextEditingController();
  bool isSearching = false;

  List<WalletTypes> allWallets;
  List<WalletTypes> walletsListData;

  @override
  void initState() {
    super.initState();
    allWallets = [];
    walletsListData = [];

    allWalletListLoad();
  }

  @override
  void dispose() {
    _searchInputController.dispose();
    super.dispose();
  }

  allWalletListLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    apiBodyObj['wallet_type_json_array'] = '[0,4]';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/types', apiBodyObj);

    isLoading = false;

    List responseList = response['result'];

    List<WalletTypes> getData = responseList.map<WalletTypes>((json) {
      return WalletTypes.fromJson(json);
    }).toList();

    allWallets = getData;
    walletsListData = getData;
    setState(() {});
  }

  void onSearch(String value) {
    String searchTerm = value.toLowerCase();

    if (value.isNotEmpty) {
      List<WalletTypes> _filtered = [];
      _filtered.addAll(allWallets);

      _filtered.retainWhere((wallet) {
        String currencyCode = wallet.currencyCode.toLowerCase();
        if (currencyCode.contains(searchTerm)) {
          return true;
        }
        String walletName = wallet.walletName.toLowerCase();
        if (walletName.contains(searchTerm)) {
          return true;
        }
        return false;
      });

      setState(() {
        isSearching = true;
        walletsListData = _filtered;
      });
    } else {
      setState(() {
        isSearching = false;
        walletsListData = allWallets;
      });
    }
  }

  void stopSearching() {
    setState(() {
      _searchInputController.clear();
      isSearching = false;
    });
    onSearch('');
  }

  void walletSelectClick(WalletTypes selectWallet) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['wallet_type_id'] = selectWallet.walletId;

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/create', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      // Map responseMap = response['result'];

      Navigator.pop(context, true);
      Fluttertoast.showToast(
          msg: getTranslated(context, 'account_added_successfully'));
    } else {
      if (response['error'] == 'duplicate_wallet') {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'),
            message: getTranslated(context, 'account_already_available'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: TextField(
          controller: _searchInputController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: getTranslated(context, 'search_currency'),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white30),
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          textInputAction: TextInputAction.search,
          onChanged: onSearch,
        ),
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    stopSearching();
                  },
                )
              : SizedBox(),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: walletsListData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(walletsListData[index].currencyCode),
                  subtitle: Text(walletsListData[index].walletName),
                  leading: walletsListData[index].walletTypeNumeric == '0'
                      ? CurrencyUtils.countryCodeToImage(
                          walletsListData[index].currencyCode)
                      : CircleAvatar(
                          child: FittedBox(
                              child: Text(walletsListData[index].currencyCode)),
                        ),
                  onTap: () {
                    walletSelectClick(walletsListData[index]);
                  },
                );
              }),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
