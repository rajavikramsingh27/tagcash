import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/biller_setup/models/biller_category.dart';
import 'package:tagcash/apps/biller_setup/models/merchant_biller.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'dart:convert';

TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);

class BillerSetupCreateScreen extends StatefulWidget {
  final MerchantBiller merchantBiller;

  const BillerSetupCreateScreen({Key key, this.merchantBiller})
      : super(key: key);

  @override
  _BillerSetupCreateScreenState createState() =>
      _BillerSetupCreateScreenState();
}

class _BillerSetupCreateScreenState extends State<BillerSetupCreateScreen> {
  Future<List<BillerCategory>> billersCategoryListData;
  BillerCategory selectedBillerCategory;
  Future<List<Wallet>> walletListData;
  Wallet wallet;
  final List<TextEditingController> _controllers = List();
  final codeController = TextEditingController();
  List<String> billerData = [];
  int walletId = 0;
  final _formKey1 = GlobalKey<FormState>();
  final globalKey = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();

  int activeStatus = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    billersCategoryListData = billersCategoryListLoad();
    walletListData = allWalletListLoad();

    if (widget.merchantBiller != null) {
      titleController.text = widget.merchantBiller.title;
      for (int i = 0; i < widget.merchantBiller.billerData.length; i++) {
        setState(() {
          //billerData.add('');
          billerData
              .add(widget.merchantBiller.billerData[i].displayName.toString());
        });
      }
      activeStatus = widget.merchantBiller.status;
    }
  }

  Future<List<BillerCategory>> billersCategoryListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('Category/List');
    List responseList = response['result'];

    List<BillerCategory> getData = responseList.map<BillerCategory>((json) {
      return BillerCategory.fromJson(json);
    }).toList();
    if (widget.merchantBiller != null) {
      for (BillerCategory r in getData) {
        if (r.id == widget.merchantBiller.categoryId)
          selectedBillerCategory = r;
      }
    }
    return getData;
  }

  Widget _getBillerCategoryList() {
    return FutureBuilder(
        future: billersCategoryListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<BillerCategory>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<BillerCategory>(
                  isExpanded: true,
                  hint: Text("Select Category"),
                  value: selectedBillerCategory,
                  onChanged: (BillerCategory value) {
                    setState(() {
                      selectedBillerCategory = value;
                    });
                  },
                  items: snapshot.data.map((BillerCategory billerCategory) {
                    return DropdownMenuItem<BillerCategory>(
                      value: billerCategory,
                      child: Text(billerCategory.name),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Biller Setup',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child:
                Consumer<ThemeProvider>(builder: (context, themeStat, child) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getBillerCategoryList(),
                      SizedBox(
                        height: 10,
                      ),
                      _getWalletList(),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter title',
                          labelText: 'Title',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter title';
                          }
                          if (isNumeric(value)) {
                            return 'Please don\'t enter a number as title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text("Add field"),
                          color: Colors.black,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              billerData.add('');
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          //padding: const EdgeInsets.all(8),
                          itemCount: billerData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return singleItemList(index);
                          }),
                      // MyStatefulWidget2(),

                      SizedBox(height: 10),
                      (widget.merchantBiller == null)
                          ? SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text("SAVE"),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey1.currentState.validate()) {
                                    if (selectedBillerCategory == null) {
                                      final snackBar = SnackBar(
                                          content:
                                              Text('Please select a Category'),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    } else if (wallet == null) {
                                      final snackBar = SnackBar(
                                          content:
                                              Text('Please select a Currency'),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    } else if (billerData.length == 0) {
                                      final snackBar = SnackBar(
                                          content: Text('Please add Field'),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    } else
                                      saveBillerHandler();
                                  }
                                },
                              ),
                            )
                          : Row(
                              children: [
                                (activeStatus == 1)
                                    ? Expanded(
                                        child: RaisedButton(
                                          child: Text("LIVE"),
                                          color: Colors.green[700],
                                          textColor: Colors.white,
                                          onPressed: () {
                                            changeActiveStatusHandler();
                                          },
                                        ),
                                        flex: 1,
                                      )
                                    : Expanded(
                                        child: RaisedButton(
                                          child: Text("DISABLE"),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            changeActiveStatusHandler();
                                          },
                                        ),
                                        flex: 1,
                                      ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: RaisedButton(
                                    child: Text("DELETE"),
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.black,
                                    textColor:
                                        Provider.of<ThemeProvider>(context)
                                                .isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _DeleteBillerDialog(
                                              onDSuccess: (value) {
                                                deleteBillerHandler();
                                              },
                                            );
                                          });
                                    },
                                  ),
                                  flex: 1,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: RaisedButton(
                                    child: Text("UPDATE"),
                                    color: kPrimaryColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      if (_formKey1.currentState.validate()) {
                                        if (selectedBillerCategory == null) {
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  'Please select a Category'),
                                              duration:
                                                  const Duration(seconds: 3));
                                          globalKey.currentState
                                              .showSnackBar(snackBar);
                                        } else if (wallet == null) {
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  'Please select a Currency'),
                                              duration:
                                                  const Duration(seconds: 3));
                                          globalKey.currentState
                                              .showSnackBar(snackBar);
                                        } else if (billerData.length == 0) {
                                          final snackBar = SnackBar(
                                              content: Text('Please add Field'),
                                              duration:
                                                  const Duration(seconds: 3));
                                          globalKey.currentState
                                              .showSnackBar(snackBar);
                                        } else
                                          saveBillerHandler();
                                      }
                                    },
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              );
            }),
          ),
          _isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: Loading()))
              : SizedBox(),
        ],
      ),
    );
  }

  Widget singleItemList(int index) {
//    _controllers.add(new TextEditingController());
//    _controllers[index].text = billerData[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: TextFormField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: billerData[index],
                    selection: new TextSelection.collapsed(
                        offset: billerData[index].length))),
                onChanged: (String text) {
                  //billerData[index] = json.encode(text);
                  billerData[index] = text;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter field';
                  }
                  if (isNumeric(value)) {
                    return 'Please don\'t enter a number as field';
                  }
                  return null;
                },
              )),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.delete),
            color: kPrimaryColor,
            iconSize: 24,
            tooltip: 'Delete',
            onPressed: () {
              setState(() {
                billerData.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<List<Wallet>> allWalletListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';
    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/list', apiBodyObj);

    List responseList = response['result'];

    List<Wallet> getData = responseList.map<Wallet>((json) {
      return Wallet.fromJson(json);
    }).toList();
    if (widget.merchantBiller != null) {
      for (Wallet w in getData) {
        if (w.currencyCode == widget.merchantBiller.currency) {
          wallet = w;
        }
      }
    }
    return getData;
  }

  Widget _getWalletList() {
    return FutureBuilder(
        future: walletListData,
        builder: (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<Wallet>(
                  isExpanded: true,
                  hint: Text("Select Currency"),
                  value: wallet,
                  onChanged: (Wallet value) {
                    setState(() {
                      wallet = value;
                    });
                  },
                  items: snapshot.data.map((Wallet wallet) {
                    return DropdownMenuItem<Wallet>(
                      value: wallet,
                      child: Text(wallet.currencyCode),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  saveBillerHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['title'] = titleController.text.toString();
    apiBodyObj['category_id'] = selectedBillerCategory.id.toString();
    apiBodyObj['currency'] = wallet.currencyCode.toString();

    List<String> data = [];
    for (var i = 0; i < billerData.length; i++) {
      data.add(json.encode(billerData[i]));
    }
    apiBodyObj['billing_data'] = data.toString();

    Map<String, dynamic> response;
    if (widget.merchantBiller == null)
      response = await NetworkHelper.request('BillerSetup/create', apiBodyObj);
    else {
      apiBodyObj['id'] = widget.merchantBiller.id;
      response = await NetworkHelper.request('BillerSetup/edit', apiBodyObj);
    }
    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });

      if (widget.merchantBiller == null) {
        Navigator.of(context).pop({'status': 'createSuccess'});
      } else {
        Navigator.of(context).pop({'status': 'updateSuccess'});
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (widget.merchantBiller == null) {
        final snackBar = SnackBar(
            content: Text('Failed to create Biller'),
            duration: const Duration(seconds: 3));
        globalKey.currentState.showSnackBar(snackBar);
      } else {
        String str = 'Failed to update Biller';
        if (response['error'] == 'invalid_biller') str = 'Invalid biller';
        final snackBar =
            SnackBar(content: Text(str), duration: const Duration(seconds: 3));
        globalKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  deleteBillerHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['id'] = widget.merchantBiller.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('billerSetup/delete', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop({'status': 'deleteSuccess'});
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "invalid biller id") {
        err = "Invalid biller ID.";
      } else
        err = "Failed to delete Biller";
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  changeActiveStatusHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['id'] = widget.merchantBiller.id;
    if (activeStatus == 0)
      apiBodyObj['status'] = 1;
    else
      apiBodyObj['status'] = 0;
    Map<String, dynamic> response;
    response =
        await NetworkHelper.request('BillerSetup/LiveDisable', apiBodyObj);
    if (response['status'] == 'success') {
      String result;
      if (response['result'] == "biller_Disbale") {
        result = "Biller Disabled.";
      } else
        result = "Biller Enabled.";
      setState(() {
        _isLoading = false;
        if (response['result'] == 'biller_Disbale')
          activeStatus = 0;
        else
          activeStatus = 1;
      });
      final snackBar =
          SnackBar(content: Text(result), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    } else {
      setState(() {
        _isLoading = false;
      });
      String err;
      if (response['error'] == "invalid biller id") {
        err = "Invalid biller ID.";
      } else
        err = "Failed to delete Biller";
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class _DeleteBillerDialog extends StatefulWidget {
  _DeleteBillerDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DeleteLoanDialogState createState() => _DeleteLoanDialogState();
}

class _DeleteLoanDialogState extends State<_DeleteBillerDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        //cancelPledgeHandler();
        widget.onDSuccess('success');
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text("Delete Biller"),
      content: Text("Would you like to delete the Biller?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
