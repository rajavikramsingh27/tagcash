import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';

class OwnWalletSelect extends StatefulWidget {
  OwnWalletSelect({
    Key key,
    @required this.currencyCode,
    this.disabled,
    this.onChange,
  });

  final String currencyCode;
  final bool disabled;

  final void Function(Wallet) onChange;

  @override
  State createState() => new OwnWalletSelectState();
}

class OwnWalletSelectState extends State<OwnWalletSelect> {
  String currencyCode;
  bool disabled;

  List<Wallet> walletsList = [];

  void initState() {
    super.initState();
    // currencyCode = currencyCode ?? "";
    currencyCode = widget.currencyCode ?? "";
    disabled = widget.disabled ?? false;
  }

  Future<List<Wallet>> getWalletList() async {
    if (walletsList.length == 0) {
      Map<String, dynamic> response =
          await NetworkHelper.request('wallet/list');

      if (response["status"] == "success") {
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletsList = getData;
        return getData;
      }
    }
    return walletsList;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      height: 44,
      minWidth: 100,
      onPressed: () async {
        final result = await showDialog(
            context: context,
            builder: (BuildContext context) => paymentWalletDialog(context));
        if (result) {
          setState(() => {});
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        //side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            (widget.currencyCode == null ||
                    widget.currencyCode == 'null' ||
                    widget.currencyCode.isEmpty)
                ? getTranslated(context, "select_wallet")
                : widget.currencyCode,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      color: Theme.of(context).primaryColor,
    );
  }

  Widget paymentWalletDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 15.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: popupElements(context),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  popupElements(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Center(
          child: Text(
            getTranslated(context, 'choose_wallet'),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
              fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(
          height: 3.0,
        ),
        Center(
          child: SizedBox(
            width: 40,
            height: 2.5,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        Container(
          height: 360.0, // Change as per your requirement
          // width: 300.0, // Change as per your requirement
          child: FutureBuilder<List<Wallet>>(
            future: getWalletList(),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              if (snapshot.hasData) {
                List<Wallet> data = snapshot.data;
                return buildWalletList(data);
              }
              return Center(
                child: new SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: const CircularProgressIndicator()),
              );
            },
          ),
        ),
      ],
    );
  }

  ListView buildWalletList(data) {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: data.length,
        itemBuilder: (context, i) {
          return buildWalletRow(data[i]);
        });
  }

  buildWalletRow(Wallet row) {
    return Card(
        child: ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      title: Text(
        row.walletName,
      ),
      subtitle: Text(row.currencyCode),
      onTap: () {
        setState(() {
          currencyCode = row.currencyCode;
        });
        widget.onChange(row);
        Navigator.of(context).pop(true);
      },
    ));
  }
}
