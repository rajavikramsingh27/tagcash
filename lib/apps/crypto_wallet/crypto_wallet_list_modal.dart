import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tagcash/apps/crypto_wallet/crypto_wallet_add_token.dart';
import 'package:tagcash/apps/crypto_wallet/models/WalletDataModel.dart';

class WalletListModal extends StatefulWidget {
  final List<Wallets> walletList;
  final Function onWalletClick;

  WalletListModal(this.walletList, this.onWalletClick);

  @override
  _WalletListModal createState() => _WalletListModal(walletList, onWalletClick);
}

class _WalletListModal extends State<WalletListModal> {
  final List<Wallets> walletList;
  final Function onWalletClick;
  _WalletListModal(this.walletList, this.onWalletClick);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Coins & Tokens',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontSize: 20),
                ),
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.add,
                  size: 20,
                ),
                label: Text(
                  'Add',
                  textScaleFactor: 1,
                ),
                color: Colors.grey.withOpacity(.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          showAddTokenModal(context));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: walletList.length,
              itemBuilder: (BuildContext context, int index) {
                return Slidable(
                  key: ValueKey(index),
                  actionPane: SlidableDrawerActionPane(),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(walletList.elementAt(index).name),
                        Text(
                          ' (${walletList.elementAt(index).symbol})',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerRight,
                                child:
                                    Text(walletList.elementAt(index).balance)))
                      ],
                    ),
                    subtitle: Text(walletList.elementAt(index).chain),
                    leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: FittedBox(
                                child: (walletList.elementAt(index).image !=
                                        null)
                                    ? Image.network(
                                        walletList.elementAt(index).image)
                                    : Text(
                                        walletList.elementAt(index).symbol)))),
                    onTap: () {
                      onWalletClick(walletList.elementAt(index));
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
        ),
      ],
    );
  }
}
