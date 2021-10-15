import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/biller_setup/models/biller_category.dart';
import 'package:tagcash/apps/biller_setup/models/merchant_biller.dart';
import 'package:tagcash/apps/pay_bills/models/biller_merchant.dart';
import 'package:tagcash/apps/pay_bills/models/biller_tagcash_favorites.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'dart:convert';

TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);

class PayBillsTagcashScreen extends StatefulWidget {
  @override
  _PayBillsTagcashScreenState createState() => _PayBillsTagcashScreenState();
}

class _PayBillsTagcashScreenState extends State<PayBillsTagcashScreen> {
  Future<List<BillerCategory>> billersCategoryListData;
  BillerCategory selectedBillerCategory;
  Future<List<BillerMerchant>> billersMerchantsListData;
  BillerMerchant selectedBillerMerchant;
  Future<List<MerchantBiller>> merchantBillerListData;
  MerchantBiller selectedMerchantBiller;
  final List<TextEditingController> _controllers = List();
  final codeController = TextEditingController();
  List<String> billerData = [];
  int walletId = 0;
  final _formKey1 = GlobalKey<FormState>();
  final globalKey = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();

  final _merchantIdController = TextEditingController();
  final amountController = TextEditingController();
  final otherDataController = TextEditingController();
  int activeStatus = 0;
  bool _isLoading = false;
  bool _isBillersLoading = true;
  bool _noBillers = true;
  bool _favSelected = false;
  int merchantId = 0;
  List<BillerTagcashFavorites> favoritesList = [];

  @override
  void initState() {
    super.initState();
    billersCategoryListData = billersCategoryListLoad();

    checkFavorites();
  }

  Future<List<BillerCategory>> billersCategoryListLoad() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Category/List');

    setState(() {
      _isLoading = false;
    });
    List responseList = response['result'];

    List<BillerCategory> getData = responseList.map<BillerCategory>((json) {
      return BillerCategory.fromJson(json);
    }).toList();

    return getData;
  }

  Widget _getBillerCategoryList() {
    return FutureBuilder(
        future: billersCategoryListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<BillerCategory>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      DropdownButtonFormField<BillerCategory>(
                        isExpanded: true,
                        hint: Text("Select Category"),
                        value: selectedBillerCategory,
                        onChanged: (BillerCategory value) {
                          setState(() {
                            _isBillersLoading = true;
                            _noBillers = true;
                            _favSelected = false;
                            selectedBillerCategory = value;
                            billersMerchantsListData = billerMerchantsLoad();
                          });
                        },
                        items:
                            snapshot.data.map((BillerCategory billerCategory) {
                          return DropdownMenuItem<BillerCategory>(
                            value: billerCategory,
                            child: Text(billerCategory.name),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          errorStyle: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ])
              : Container();
        });
  }

  Future<List<BillerMerchant>> billerMerchantsLoad() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['category_id'] = selectedBillerCategory.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('billerSetup/GetMerchant', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    List responseList = response['result'];

    List<BillerMerchant> getData = responseList.map<BillerMerchant>((json) {
      return BillerMerchant.fromJson(json);
    }).toList();
    selectedBillerMerchant = getData[0];
    selectedBillerMerchant = null;
    selectedMerchantBiller = null;
    return getData;
  }

  Widget _getBillerMerchantsList() {
    return FutureBuilder(
        future: billersMerchantsListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<BillerMerchant>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      DropdownButtonFormField<BillerMerchant>(
                        isExpanded: true,
                        hint: Text("Select Merchant"),
                        value: selectedBillerMerchant,
                        onChanged: (BillerMerchant value) {
                          setState(() {
                            _isBillersLoading = true;
                            _noBillers = true;
                            selectedBillerMerchant = value;
                            _merchantIdController.text = "";
                            merchantBillerListData = merchantBillerListLoad(0);
                            merchantId = value.id;
                          });
                        },
                        items:
                            snapshot.data.map((BillerMerchant billerMerchant) {
                          return DropdownMenuItem<BillerMerchant>(
                            value: billerMerchant,
                            child: Text(billerMerchant.name.toString()),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          errorStyle: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ])
              : Container();
        });
  }

  Widget _getMerchantBillersList() {
    return FutureBuilder(
        future: merchantBillerListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<MerchantBiller>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          if (!snapshot.hasData) return Container();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<MerchantBiller>(
                  isExpanded: true,
                  hint: Text("Select Biller"),
                  value: selectedMerchantBiller,
                  onChanged: (value) {
                    setState(() {
                      amountController.text = '';
                      otherDataController.text = '';
                      selectedMerchantBiller = value;
                      billerData.clear();
                      for (int i = 0;
                          i < selectedMerchantBiller.billerData.length;
                          i++) {
                        billerData.add('');
                      }
                    });

                    //widget.onBillerSelected(selectedMerchantBiller);
                  },
                  items: snapshot.data.map((MerchantBiller merchantBiller) {
                    return DropdownMenuItem<MerchantBiller>(
                      value: merchantBiller,
                      child: Text(merchantBiller.title.toString()),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ]);
        });
  }

  Future<List<MerchantBiller>> merchantBillerListLoad(int id) async {
    setState(() {
      _isLoading = true;
      // _isBillersLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    Map<String, dynamic> response;
    if (id == 0) {
      apiBodyObj['merchant_id'] = selectedBillerMerchant.id;
      response =
          await NetworkHelper.request('billerSetup/MerchantBiller', apiBodyObj);
    } else {
      apiBodyObj['merchant_id'] = id;
      response =
          await NetworkHelper.request('billerSetup/searchbiller', apiBodyObj);
    }

    setState(() {
      _isLoading = false;
    });
    if (response['result'] == 'no_merchant_biller') {
      final snackBar = SnackBar(
          content: Text('No billers found'),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
      return [];
    }
    List responseList = response['result'];

    List<MerchantBiller> getData = responseList.map<MerchantBiller>((json) {
      return MerchantBiller.fromJson(json);
    }).toList();
    _isBillersLoading = false;
    selectedMerchantBiller = getData[0];
    selectedMerchantBiller = null;
    _noBillers = false;
    _merchantIdController.text = "";
    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _getBillerCategoryList(),
                    if (!_favSelected) _getBillerMerchantsList(),
                    //:Container(),
                    Center(
                      child: Text(
                        'OR ENTER BILLERID IF YOU KNOW IT',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      //padding: EdgeInsets.all(10),
                      child: TextField(
                          controller: _merchantIdController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    _favSelected = false;
                                    merchantBillerListData =
                                        merchantBillerListLoad(int.parse(
                                            _merchantIdController.text
                                                .toString()));
                                  });
                                },
                              ),
                              hintText: "Enter Merchant ID",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueAccent, width: 32.0),
                                  borderRadius: BorderRadius.circular(25.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 32.0),
                                  borderRadius: BorderRadius.circular(25.0)))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (!_isBillersLoading && !_favSelected)
                      _getMerchantBillersList(),
                    //:Container(),

//                      MerchantBillersList(
//                          merchantID: '$merchantId',
//                          onBillerSelected: (value) {
//
//                            selectedMerchantBiller = value;
//                            setState(() {
//                              for (int i = 0;
//                                  i < selectedMerchantBiller.billerData.length;
//                                  i++) {
//                                billerData.add('');
//                              }
//                            });
//                          },
//                          key: UniqueKey()),
                    SizedBox(
                      height: 10,
                    ),
                    if ((selectedMerchantBiller != null && !_noBillers) ||
                        _favSelected)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Divider(
                                color: Colors.black,
                              ),
                              RotationTransition(
                                turns: new AlwaysStoppedAnimation(45 / 360),
                                child: Container(
                                  height: 10.0,
                                  width: 10.0,
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            selectedMerchantBiller.ownerName.toString(),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                selectedMerchantBiller.currency,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: amountController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: false),
                                  decoration: InputDecoration(
                                    hintText:
                                        getTranslated(context, 'enter_amount'),
                                    labelText: getTranslated(context, 'amount'),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return getTranslated(
                                          context, 'enter_valid_amount');
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              //padding: const EdgeInsets.all(8),
                              itemCount:
                                  selectedMerchantBiller.billerData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return singleItemList(
                                    selectedMerchantBiller.billerData[index],
                                    index);
                              }),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: otherDataController,
                            decoration: InputDecoration(
                              hintText: 'Other Data',
                              labelText: 'Other Data',
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              child: Text("PAY BILL"),
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                if (_formKey1.currentState.validate()) {
                                  payBillHandler();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    if (favoritesList.length > 0)
                      Text(
                        "FAVORITES",
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: kPrimaryColor),
                      ),
                    SizedBox(
                      height: 15.0,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: favoritesList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              child: GestureDetector(
                                  onTap: () {
                                    //_listItemTapped(snapshot.data[index].id);
                                    setState(() {
                                      amountController.text =
                                          favoritesList[index].amount;
                                      otherDataController.text =
                                          favoritesList[index].otherData;
                                      selectedBillerMerchant =
                                          favoritesList[index]
                                              .selectedBillerMerchant;
                                      billerData.clear();
                                      for (int i = 0;
                                          i <
                                              favoritesList[index]
                                                  .selectedMerchantBiller
                                                  .billerData
                                                  .length;
                                          i++) {
                                        billerData.add('');
                                      }
                                      selectedMerchantBiller =
                                          favoritesList[index]
                                              .selectedMerchantBiller;
                                      _favSelected = true;
                                      billerData = (jsonDecode(
                                                  favoritesList[index]
                                                      .billerValue)
                                              as List<dynamic>)
                                          .cast<String>();
//                                        selectedBiller =
//                                            favoritesList[index].biller;
//                                        selectedBillerTag =
//                                            favoritesList[index].billerTag;
//                                        if (favoritesList[index].billerTag ==
//                                            "PAGIBIG") {
//                                          for (int i = 0;
//                                          i <
//                                              pagIbigPaymentOptionsList
//                                                  .length;
//                                          i++) {
//                                            if (pagIbigPaymentOptionsList[i]
//                                                .value ==
//                                                favoritesList[index]
//                                                    .paymentOption) {
//                                              pagibigPaymentOption =
//                                              pagIbigPaymentOptionsList[i];
//                                            }
//                                          }
//                                          for (int i = 0;
//                                          i < pagIbigPaymentTypeList.length;
//                                          i++) {
//                                            if (pagIbigPaymentTypeList[i]
//                                                .value
//                                                .toString() ==
//                                                favoritesList[index]
//                                                    .secondField) {
//                                              pagibigPaymentType =
//                                              pagIbigPaymentTypeList[i];
//                                            }
//                                          }
//                                          isPagIbib = true;
                                    });
                                  },
                                  child: FavoriteRowItem(
                                      favoritesList[index].name, onDelete: () {
                                    setState(() {
                                      favoritesList.removeAt(index);
                                      saveFavorite();
                                    });
                                  })));
                        })
                  ],
                ),
              ),
            ),
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

  Widget singleItemList(BillerData billData, int index) {
//    _controllers.add(new TextEditingController());
//    _controllers[index].text = billerData[index];

    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: TextFormField(
          controller: TextEditingController.fromValue(TextEditingValue(
              text: billerData[index],
              selection: new TextSelection.collapsed(
                  offset: billerData[index].length))),
          onChanged: (String text) {
            billerData[index] = text;
          },
          decoration: InputDecoration(
            hintText: billData.displayName.toString(),
            labelText: billData.displayName.toString(),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter biller data';
            }
            return null;
          },
        ));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  void saveFavorite() async {
    String encodedData = BillerTagcashFavorites.encode(favoritesList);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('biller_tagcash_favorites', encodedData);
  }

  void checkFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String billerFavorites = prefs.getString('biller_tagcash_favorites') ?? '';

    if (billerFavorites == '') {
    } else {
      List<BillerTagcashFavorites> getData =
          BillerTagcashFavorites.decode(billerFavorites);
      setState(() {
        favoritesList = getData;
      });
    }
  }

  void backToCreate() {
//    selectedBiller = "Select Service";
//    selectedBillerTag = "";
//    accountNoOrBillerData = "Account Number (or biller data)";
//    otherData = "Other data (if needed)";
    amountController.text = "";
    otherDataController.text = "";
    billerData.clear();
    for (int i = 0; i < selectedMerchantBiller.billerData.length; i++) {
      billerData.add('');
    }
//    _secondFieldTextController.text = "";
//    _serviceTextController.text = "";
//    fromDateController.text = "";
//    toDateController.text = "";
//    fromDateSelected = '';
//    toDateSelected = '';
//    isPagIbib = false;
//    pagibigPaymentType = null;
//    pagibigPaymentOption = null;
  }

  payBillHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['amount'] = amountController.text.toString();
    apiBodyObj['biller_id'] = selectedMerchantBiller.id.toString();
    apiBodyObj['merchant_id'] = selectedMerchantBiller.ownerId.toString();
    apiBodyObj['other_data'] = otherDataController.text.toString();
    List<String> data = [];

    for (var i = 0; i < selectedMerchantBiller.billerData.length; i++) {
      apiBodyObj[selectedMerchantBiller.billerData[i].slug.toString()] =
          billerData[i];
    }

    Map<String, dynamic> response;
    response = await NetworkHelper.request('BillerSetup/PayBill', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        _isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _ResultDialog(
              paymentSuccess: true,
              amount: amountController.text.toString() +
                  " " +
                  selectedMerchantBiller.currency,
              onPayMore: (value) {
                setState(() {
                  backToCreate();
                });
              },
              saveAsFavorite: (value) {
                setState(() {
                  BillerTagcashFavorites b;
                  b = new BillerTagcashFavorites(
                    biller: selectedMerchantBiller.id.toString(),
                    amount: amountController.text.toString(),
                    name: value,
                    merchantId: selectedMerchantBiller.ownerId.toString(),
                    merchantName: selectedMerchantBiller.ownerName.toString(),
                    merchantCurrency: selectedMerchantBiller.currency,
                    selectedBillerMerchant: selectedBillerMerchant,
                    selectedMerchantBiller: selectedMerchantBiller,
                    billerValue: jsonEncode(billerData),
                    otherData: otherDataController.text.toString(),
                  );

                  favoritesList.add(b);
                  saveFavorite();
                  backToCreate();
                });
              },
            );
          });
    } else {
      setState(() {
        _isLoading = false;
      });

      String err = '';
      if (response['status'] == 'failed') {
        err = response['error'];
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _ResultDialog(
              paymentSuccess: false,
              amount: err,
              onPayMore: (value) {
                setState(() {
                  backToCreate();
                });
              },
              saveAsFavorite: (value) {},
            );
          });
    }
  }
}

class MerchantBillersList extends StatefulWidget {
  final String merchantID;
  final Function(MerchantBiller) onBillerSelected;

  //final Function(bool) onBillerLoading;

  const MerchantBillersList({Key key, this.merchantID, this.onBillerSelected})
      : super(key: key);

  @override
  _MerchantBillersListState createState() => _MerchantBillersListState();
}

class _MerchantBillersListState extends State<MerchantBillersList> {
  Future<List<MerchantBiller>> merchantBillerListData;
  MerchantBiller selectedMerchantBiller;

  List<String> billerData = [];

  @override
  void initState() {
    merchantBillerListData =
        merchantBillerListLoad(widget.merchantID.toString());

    super.initState();
  }

  Future<List<MerchantBiller>> merchantBillerListLoad(String id) async {
//    setState(() {
//      _isLoading = true;
//      _isBillersLoading = true;
//    });

    //widget.onBillerLoading(true);
    Map<String, dynamic> apiBodyObj = {};
    Map<String, dynamic> response;
    if (id == 0) {
      apiBodyObj['merchant_id'] = id;
      response =
          await NetworkHelper.request('billerSetup/MerchantBiller', apiBodyObj);
    } else {
      apiBodyObj['merchant_id'] = id;
      response =
          await NetworkHelper.request('billerSetup/searchbiller', apiBodyObj);
    }
    List responseList = response['result'];

    List<MerchantBiller> getData = responseList.map<MerchantBiller>((json) {
      return MerchantBiller.fromJson(json);
    }).toList();
    return getData;
  }

  Widget _getMerchantBillersList() {
    return FutureBuilder(
        future: merchantBillerListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<MerchantBiller>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          if (!snapshot.hasData) return Container();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<MerchantBiller>(
                  isExpanded: true,
                  hint: Text("Select Biller"),
                  value: selectedMerchantBiller,
                  onChanged: (value) {
                    setState(() {
                      selectedMerchantBiller = value;
//                      for (int i = 0;
//                          i < selectedMerchantBiller.billerData.length;
//                          i++) {
//                        billerData.add('');
//                      }
                    });

                    widget.onBillerSelected(selectedMerchantBiller);
                  },
                  items: snapshot.data.map((MerchantBiller merchantBiller) {
                    return DropdownMenuItem<MerchantBiller>(
                      value: merchantBiller,
                      child: Text(merchantBiller.title.toString()),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return _getMerchantBillersList();
  }
}

class _ResultDialog extends StatefulWidget {
  _ResultDialog(
      {this.paymentSuccess, this.amount, this.onPayMore, this.saveAsFavorite});

  bool paymentSuccess = false;
  String amount = "";
  ValueChanged<String> onPayMore;
  ValueChanged<String> saveAsFavorite;

  @override
  _ResultDialogState createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  TextEditingController _nameTextController = TextEditingController();

  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
        contentPadding: EdgeInsets.all(5.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (widget.paymentSuccess)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Text(
                          "BILL PAYMENT CONFIRMED",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.green[700]),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          widget.amount,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              .copyWith(color: Colors.green[700]),
                        ),
                      ])
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Text(
                          "Transaction Failed",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          widget.amount,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: kPrimaryColor),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Icon(
                          Icons.report_rounded,
                          color: kPrimaryColor,
                          size: 32,
                        ),
                      ]),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  widget.onPayMore("success");
                  Navigator.of(context).pop();
                },
                textColor: Colors.white,
                padding: EdgeInsets.all(10.0),
                color: kPrimaryColor,
                child: Text('PAY MORE BILLS', style: TextStyle(fontSize: 16)),
              ),
            ),
            if (widget.paymentSuccess)
              Form(
                key: _formKey2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _nameTextController,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          if (_formKey2.currentState.validate()) {
                            widget.saveAsFavorite(_nameTextController.text);
                            Navigator.of(context).pop();
                          }
                        },
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        color: kPrimaryColor,
                        child: Text('SAVE TO FAVORITE',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ));
  }
}

class FavoriteRowItem extends StatelessWidget {
  final String name;

  //final int id;
  final VoidCallback onDelete;

  FavoriteRowItem(this.name, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
                icon: Icon(Icons.delete),
                color: kPrimaryColor,
                iconSize: 24,
                tooltip: 'Delete',
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DeleteFavoriteDialog(
                          onDSuccess: (value) {
                            this.onDelete();
                          },
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}

class DeleteFavoriteDialog extends StatefulWidget {
  DeleteFavoriteDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  DeleteFavoriteDialogState createState() => DeleteFavoriteDialogState();
}

class DeleteFavoriteDialogState extends State<DeleteFavoriteDialog> {
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
      title: Text("Delete Favorite"),
      content: Text("Would you like to delete your Favorite?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
