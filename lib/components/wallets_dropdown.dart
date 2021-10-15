import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';

class WalletsDropdown extends StatefulWidget {
  final void Function(Wallet) onSelected;
  final ValueNotifier<String> currencyCode;

  const WalletsDropdown({Key key, this.onSelected, this.currencyCode})
      : super(key: key);

  @override
  _WalletsDropdownState createState() => _WalletsDropdownState();
}

class _WalletsDropdownState extends State<WalletsDropdown> {
  Future<List<Wallet>> walletsListData;
  Wallet walletSelected;

  @override
  void initState() {
    super.initState();
    walletsListData = allWalletListLoad();
  }

  setSelectedWallet() {
    walletsListData.then((value) {
      for (var item in value) {
        if (widget.currencyCode.value == item.walletId.toString()) {
          walletSelected = item;
        }
      }
    });
  }

  Future<List<Wallet>> allWalletListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    apiBodyObj['wallet_type'] = '[0,1,3]';

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          builder: (BuildContext context, String value, Widget child) {
            if (widget.currencyCode.value != null) {
              setSelectedWallet();
            }

            return SizedBox();
          },
          valueListenable: widget.currencyCode,
        ),
        Container(
          child: FutureBuilder(
              future: walletsListData,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? DropdownButtonFormField<Wallet>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Wallet',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: const OutlineInputBorder(),
                        ),
                        value: walletSelected,
                        icon: Icon(Icons.arrow_downward),
                        items: snapshot.data
                            .map<DropdownMenuItem<Wallet>>((Wallet value) {
                          return DropdownMenuItem<Wallet>(
                            value: value,
                            child: Text(
                              value.currencyCode,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (Wallet newValue) =>
                            widget.onSelected(newValue),
                      )
                    : Center(child: Loading());
              }),
        ),
      ],
    );
  }
}
