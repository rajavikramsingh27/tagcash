import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'models/sub_merchant.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class SubMerchantScreen extends StatefulWidget {
  @override
  _SubMerchantScreenState createState() => _SubMerchantScreenState();
}

class _SubMerchantScreenState extends State<SubMerchantScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamController<List<SubMerchant>> _streamcontroller;
  List<SubMerchant> _merchants;

  bool isLoading = false;
  bool removeProcessing = false;

  @override
  void initState() {
    super.initState();

    _merchants = List<SubMerchant>();
    _streamcontroller = StreamController<List<SubMerchant>>.broadcast();

    merchantListLoad();
  }

  searchClicked(String searchKey) {
    print(searchKey);
    merchantListLoad(searchKey);
  }

  void merchantListLoad([String searchKey]) {
    if (searchKey != null) {
      _merchants = List<SubMerchant>();
      _streamcontroller.add(_merchants);
    }

    setState(() {
      isLoading = true;
    });

    appMerchantsListLoad(searchKey).then((res) {
      setState(() {
        isLoading = false;
      });

      if (res.length != 0) {
        _merchants.addAll(res);
      }

      _streamcontroller.add(_merchants);
    });
  }

  Future<List<SubMerchant>> appMerchantsListLoad(String searchKey) async {
    print(searchKey);

    Map<String, String> apiBodyObj = {};
    if (searchKey != null) {
      if (Validator.isNumber(searchKey)) {
        apiBodyObj['community_id'] = searchKey;
      } else {
        apiBodyObj['community_name'] = searchKey;
      }
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('Community/SubMerchants', apiBodyObj);

    List<SubMerchant> getData = List<SubMerchant>();
    List responseList = response['result'];

    if (responseList != null) {
      getData = responseList.map<SubMerchant>((json) {
        return SubMerchant.fromJson(json);
      }).toList();
    }

    return getData;
  }

  void addSubMerchantClicked() async {
    final result = await showModalBottomSheet(
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
                child: AddSubMerchant(),
              ),
            ),
          );
        });

    if (result != null) {
      _merchants = List<SubMerchant>();
      _streamcontroller.add(_merchants);

      merchantListLoad();
    }
  }

  merchantDetailClick(SubMerchant merchant) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 60,
                          child: Image.network(
                            AppConstants.getCommunityImagePath() +
                                merchant.id.toString(),
                          ),
                        ),
                        Text(
                          merchant.communityName,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          merchant.id.toString(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            removeMerchantClick(merchant);
                          },
                          child: Text('REMOVE'),
                        ),
                      ],
                    ),
                    removeProcessing ? Center(child: Loading()) : SizedBox(),
                  ],
                ),
              ),
            );
          });
        });
  }

  void removeMerchantClick(SubMerchant merchant) async {
    setState(() {
      removeProcessing = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['community_id'] = merchant.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Community/DeleteSubMerchant', apiBodyObj);

    setState(() {
      removeProcessing = false;
    });
    if (response['status'] == 'success') {
      // _merchants = List<SubMerchant>();
      // _streamcontroller.add(_merchants);

      // merchantListLoad();

      merchant.status = 'delete_request';
      showSnackBar(
          getTranslated(context, 'Sub business remove request submitted'));
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    Navigator.pop(context);
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        onSearch: searchClicked,
        title: 'Sub Business',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addSubMerchantClicked(),
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _streamcontroller.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<SubMerchant>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Opacity(
                          opacity:
                              snapshot.data[index].status == 'delete_request'
                                  ? .5
                                  : 1,
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                title: Text(snapshot.data[index].communityName),
                                subtitle:
                                    Text('ID : ${snapshot.data[index].id}'),
                                onTap: () {
                                  // if (snapshot.data[index].status !=
                                  //     'delete_request') {
                                  merchantDetailClick(snapshot.data[index]);
                                  // }
                                }),
                          ),
                        );
                      },
                    )
                  : SizedBox();
            },
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class AddSubMerchant extends StatefulWidget {
  const AddSubMerchant({
    Key key,
  }) : super(key: key);

  @override
  _AddSubMerchantState createState() => _AddSubMerchantState();
}

class _AddSubMerchantState extends State<AddSubMerchant> {
  final _idController = TextEditingController();
  int stackIndex = 0;
  bool isLoading = false;
  Map resultCommunity = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();

    super.dispose();
  }

  checkMerchantDetail() async {
    if (_idController.text.isEmpty) return;

    setState(() {
      stackIndex = 1;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _idController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];
      resultCommunity = responseList[0];

      if (resultCommunity['community_verified']['kyc_verified'] == true) {
        stackIndex = 0;

        showSimpleDialog(context,
            title: 'Verified Business',
            message: 'You cannot add a verified business as sub business.');
      } else {
        stackIndex = 2;
      }
    } else {
      stackIndex = 0;

      showMessage('The ID you entered is not valid');
    }
    setState(() {});
  }

  void confirmAddProcess() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['community_id'] = resultCommunity['id'].toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Community/AddSubMerchant', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
      showMessage('Sub business added successfully');
    } else {
      stackIndex = 0;

      if (response['error'] == 'already_kyc_verified') {
        showMessage('This business is already KYC verified');
      } else if (response['error'] == 'already_linked') {
        showMessage('This business is already a sub business');
      } else if (response['error'] == 'kyc_verification_failed') {
        showSimpleDialog(context,
            title: 'Error', message: 'Please check your verification status');
      } else {
        showMessage(getTranslated(context, 'error_occurred'));
      }
    }
    setState(() {});
  }

  showMessage(String message) {
    showSimpleDialog(context, title: '', message: message);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: stackIndex,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ADD SUB BUSINESS',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                icon: Icon(Icons.people_alt_outlined),
                labelText: 'Business ID',
              ),
              validator: (value) {
                if (!Validator.isAmount(value)) {
                  return 'Please enter valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                checkMerchantDetail();
              },
              child: Text('CONTINUE'),
            ),
          ],
        ),
        Center(child: Loading()),
        Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  child: Image.network(AppConstants.getCommunityImagePath() +
                      resultCommunity['id'].toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('User Name'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(width: 20),
                    ElevatedButton(
                      child: Text('ADD'),
                      onPressed: () => confirmAddProcess(),
                    )
                  ],
                ),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
      ],
    );
  }
}
