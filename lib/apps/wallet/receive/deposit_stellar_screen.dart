import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DepositStellarScreen extends StatefulWidget {
  final Wallet wallet;

  const DepositStellarScreen({Key key, this.wallet}) : super(key: key);

  @override
  _DepositStellarScreenState createState() => _DepositStellarScreenState();
}

class _DepositStellarScreenState extends State<DepositStellarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  TextEditingController _newAddressController;

  Future<List> addressAddedList;

  bool editingMode = false;
  String stellerAddressDefault = '';
  String memoTextDefault = '';
  String stellerAddressDomain;
  String stellerNameEditId;

  @override
  void initState() {
    super.initState();

    _newAddressController = TextEditingController();

    if (AppConstants.getServer() == 'beta') {
      stellerAddressDomain = "test.tagcash.com";
    } else {
      stellerAddressDomain = "tagcash.com";
    }

    stellerDefaultAddressLoad();
    stellerAddressListLoad();
  }

  @override
  void dispose() {
    _newAddressController.dispose();
    super.dispose();
  }

  Future stellerDefaultAddressLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/ReceivingAddresses');

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      List responseList = response['result'];

      responseList.forEach((item) {
        if (item['id'] == '16') {
          setState(() {
            stellerAddressDefault = item['receiving_address'];
          });
        }
      });

      String memoText;
      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        memoText = "U" +
            Provider.of<UserProvider>(context, listen: false)
                .userData
                .id
                .toString();
      } else {
        memoText = "C" +
            Provider.of<MerchantProvider>(context, listen: false)
                .merchantData
                .id
                .toString();
      }
      setState(() {
        memoTextDefault = memoText;
      });
    }
  }

  void stellerAddressListLoad() {
    addressAddedList = addressAddedLoad();
  }

  Future<List> addressAddedLoad() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request('stellar/me');

    setState(() {
      isLoading = false;
    });
    List responseList = response['result'];

    return responseList;
  }

  void addressCopyClicked() {
    Clipboard.setData(ClipboardData(text: stellerAddressDefault));
    showSnackBar(getTranslated(context, 'copied_clipboard'));
  }

  void memoCopyClicked() {
    Clipboard.setData(ClipboardData(text: memoTextDefault));
    showSnackBar(getTranslated(context, 'copied_clipboard'));
  }

  void addressEditClicked(data) {
    editingMode = true;
    _newAddressController.text = data['user_nickname'].toString();
    stellerNameEditId = data['record_id'].toString();
    addressCreateProcess();
  }

  void addressAddClicked() {
    editingMode = false;
    addressCreateProcess();
  }

  void addressCreateProcess() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newAddressController,
                            decoration: InputDecoration(
                              labelText: 'Nickname',
                            ),
                          ),
                        ),
                        Text('*$stellerAddressDomain')
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(editingMode
                          ? getTranslated(context, 'update')
                          : getTranslated(context, 'save')),
                      onPressed: () {
                        Navigator.pop(context);
                        newAddressSave();
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void newAddressSave() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    String apiUrl;

    if (editingMode) {
      apiUrl = "stellar/updateaddress";
      apiBodyObj['record_id'] = stellerNameEditId;
    } else {
      apiUrl = "stellar/createaddress";
      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        apiBodyObj['user_id'] =
            Provider.of<UserProvider>(context, listen: false)
                .userData
                .id
                .toString();
        apiBodyObj['user_type'] = 'U';
      } else {
        apiBodyObj['user_id'] =
            Provider.of<MerchantProvider>(context, listen: false)
                .merchantData
                .id
                .toString();
        apiBodyObj['user_type'] = 'C';
      }

      apiBodyObj['domain'] = stellerAddressDomain;
    }

    apiBodyObj['user_nickname'] = _newAddressController.text;
    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      stellerAddressListLoad();
      if (editingMode) {
        showSnackBar(getTranslated(context, 'nickname_updated_successfully'));
      } else {
        showSnackBar(getTranslated(context, 'nickname_added_successfully'));
      }
    } else {
      if (response['error'].containsKey('user_nickname')) {
        showSnackBar(getTranslated(context, 'nickname_already_exist'));
      }
    }
  }

  void addressDeleteClicked(data) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['record_id'] = data['record_id'].toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('stellar/deleteaddress', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      stellerAddressListLoad();
      showSnackBar(getTranslated(context, 'nickname_deleted_successfully'));
    }
  }

  void showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              Text(getTranslated(context, 'send_to_this_address')),
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                title: Text(stellerAddressDefault),
                trailing: IconButton(
                  icon: Icon(Icons.copy_outlined),
                  onPressed: () => addressCopyClicked(),
                ),
              ),
              Text(getTranslated(context, 'steller_deposit_one')),
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                title: Text(memoTextDefault),
                trailing: IconButton(
                  icon: Icon(Icons.copy_outlined),
                  onPressed: () => memoCopyClicked(),
                ),
              ),
              Text(getTranslated(context, 'steller_deposit_two')),
              Text(getTranslated(context, 'steller_deposit_three')),
              SizedBox(height: 20),
              FutureBuilder(
                future: addressAddedList,
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              elevation: 3,
                              child: ListTile(
                                title: Text(snapshot.data[index]
                                            ['user_nickname']
                                        .toString() +
                                    '*' +
                                    snapshot.data[index]['domain']),
                                onTap: () =>
                                    addressEditClicked(snapshot.data[index]),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => addressDeleteClicked(
                                      snapshot.data[index]),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(getTranslated(context, 'add_nickname')),
                onPressed: () => addressAddClicked(),
              )
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
