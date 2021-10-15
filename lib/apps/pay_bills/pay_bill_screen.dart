import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/pay_bills/models/biller.dart';
import 'package:tagcash/apps/pay_bills/models/biller_favorites.dart';
import 'package:tagcash/apps/pay_bills/models/pagibig_payment_option.dart';
import 'package:tagcash/apps/pay_bills/models/pagibig_payment_type.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';

class PayBillScreen extends StatefulWidget {
  PayBillScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _PayBillsState createState() => _PayBillsState();
}

class _PayBillsState extends State<PayBillScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _amountTextController = TextEditingController();
  TextEditingController _firstFieldController = TextEditingController();
  TextEditingController _secondFieldTextController = TextEditingController();
  TextEditingController _serviceTextController = TextEditingController();

  TextEditingController fromDateController = TextEditingController();
  var fromDateSelected = '';
  TextEditingController toDateController = TextEditingController();
  var toDateSelected = '';

  final _formKey1 = GlobalKey<FormState>();

  bool isLoading = false;

//  List billerList = [];
//  List newDataList = [];
  //List<Biller> billerList;
  //List<Biller> newDataList;

  List<Biller> billerList = [];
  List<Biller> filterBillerList = [];
  List<PagibigPaymentOption> pagIbigPaymentOptionsList = [];
  List<PagibigPaymentType> pagIbigPaymentTypeList = [];
  List<BillerFavorites> favoritesList = [];
  String selectedBiller = "Select Service";
  String selectedBillerTag = "";
  bool isPagIbib = false;
  String accountNoOrBillerData = "Account Number (or biller data)";
  String otherData = "Other data (if needed)";
  PagibigPaymentType pagibigPaymentType;
  PagibigPaymentOption pagibigPaymentOption;

  Future<List<Biller>> billersLoad() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('credit/billerList');

    List responseList = response['data'];
    setState(() {
      isLoading = false;
    });
    List<Biller> getData = responseList.map<Biller>((json) {
      return Biller.fromJson(json);
    }).toList();
    setState(() {
      filterBillerList = billerList = getData;
    });

    String encodedData = Biller.encode(getData);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paybill_billers', encodedData);
    return getData;
  }

  Future<List<PagibigPaymentOption>> pagIbigPaymentOptionsLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('credit/PagIBIGPaymentOption');

    List responseList = response['result'];
    List<PagibigPaymentOption> getData =
        responseList.map<PagibigPaymentOption>((json) {
      return PagibigPaymentOption.fromJson(json);
    }).toList();
    setState(() {
      pagIbigPaymentOptionsList = getData;
    });
    String encodedData = PagibigPaymentOption.encode(getData);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paybill_payment_options', encodedData);
    return getData;
  }

  Future<List<PagibigPaymentType>> pagIbigPaymentTypesLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('credit/PagIBIGPaymentType');

    List responseList = response['result'];
    List<PagibigPaymentType> getData =
        responseList.map<PagibigPaymentType>((json) {
      return PagibigPaymentType.fromJson(json);
    }).toList();
    setState(() {
      pagIbigPaymentTypeList = getData;
    });
    String encodedData = PagibigPaymentType.encode(getData);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paybill_payment_types', encodedData);
    return getData;
  }

  @override
  void initState() {
    super.initState();
    checkPagIbibPaymentOptions();
    checkPagIbibPaymentTypes();
    checkBillers();
    checkFavorites();
  }

  void checkBillers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String billers = prefs.getString('paybill_billers') ?? '';

    if (billers == '') {
      billersLoad();
    } else {
      List<Biller> getData = Biller.decode(billers);
      setState(() {
        filterBillerList = billerList = getData;
      });
    }
  }

  void checkPagIbibPaymentOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String payBillPaymentOptions =
        prefs.getString('paybill_payment_options') ?? '';

    if (payBillPaymentOptions == '') {
      pagIbigPaymentOptionsLoad();
    } else {
      List<PagibigPaymentOption> getData =
          PagibigPaymentOption.decode(payBillPaymentOptions);
      setState(() {
        pagIbigPaymentOptionsList = getData;
      });
    }
  }

  void checkPagIbibPaymentTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String payBillPaymentTypes = prefs.getString('paybill_payment_types') ?? '';

    if (payBillPaymentTypes == '') {
      pagIbigPaymentTypesLoad();
    } else {
      List<PagibigPaymentType> getData =
          PagibigPaymentType.decode(payBillPaymentTypes);
      setState(() {
        pagIbigPaymentTypeList = getData;
      });
    }
  }

  void checkFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String billerFavorites = prefs.getString('biller_favorites') ?? '';

    if (billerFavorites == '') {
    } else {
      List<BillerFavorites> getData = BillerFavorites.decode(billerFavorites);
      setState(() {
        favoritesList = getData;
      });
    }
  }

  void clearBillers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('paybill_billers');
    prefs.remove('paybill_payment_options');
    prefs.remove('paybill_payment_types');
    backToCreate();
    checkPagIbibPaymentOptions();
    checkPagIbibPaymentTypes();
    checkBillers();
  }

  void backToCreate() {
    selectedBiller = "Select Service";
    selectedBillerTag = "";
    accountNoOrBillerData = "Account Number (or biller data)";
    otherData = "Other data (if needed)";
    _amountTextController.text = "";
    _firstFieldController.text = "";
    _secondFieldTextController.text = "";
    _serviceTextController.text = "";
    fromDateController.text = "";
    toDateController.text = "";
    fromDateSelected = '';
    toDateSelected = '';
    isPagIbib = false;
    pagibigPaymentType = null;
    pagibigPaymentOption = null;
  }

  void saveFavorite() async {
    String encodedData = BillerFavorites.encode(favoritesList);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('biller_favorites', encodedData);
  }

  payBillHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['amount'] = _amountTextController.text.toString();
    apiBodyObj['firstField'] = _firstFieldController.text.toString();
    apiBodyObj['biller'] = selectedBillerTag;
    apiBodyObj['transfer_wallet_id'] = "1";

    if (!isPagIbib) {
      apiBodyObj['secondField'] = _secondFieldTextController.text.toString();
    } else {
      apiBodyObj['secondField'] = pagibigPaymentType.value;
      apiBodyObj['payment_option'] = pagibigPaymentOption.value;
      apiBodyObj['from_date'] = fromDateSelected;
      apiBodyObj['to_date'] = toDateSelected;
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('credit/payBills', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _ResultDialog(
              paymentSuccess: true,
              amount: _amountTextController.text.toString() + " PHP",
              onPayMore: (value) {
                setState(() {
                  backToCreate();
                });
              },
              saveAsFavorite: (value) {
                setState(() {
                  BillerFavorites b;
                  if (isPagIbib)
                    b = new BillerFavorites(
                        biller: selectedBiller,
                        billerTag: selectedBillerTag,
                        amount: _amountTextController.text,
                        name: value,
                        firstField: _firstFieldController.text.toString(),
                        secondField: pagibigPaymentType.value.toString(),
                        paymentOption: pagibigPaymentOption.value,
                        serviceCharge: _serviceTextController.text.toString());
                  else
                    b = new BillerFavorites(
                        biller: selectedBiller,
                        billerTag: selectedBillerTag,
                        amount: _amountTextController.text,
                        name: value,
                        firstField: _firstFieldController.text.toString(),
                        secondField: _secondFieldTextController.text.toString(),
                        paymentOption: '',
                        serviceCharge: _serviceTextController.text.toString());
                  favoritesList.add(b);
                  saveFavorite();
                  backToCreate();
                });
              },
            );
          });
    } else {
      setState(() {
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white70,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      child: RawMaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.grey)),
                          fillColor: Color(0xFFDDDADA),
                          splashColor: Colors.grey,
                          child: ListTile(
                            trailing: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[700],
                              size: 32,
                            ),
                            title: Text(selectedBiller),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _SelectBillerDialog(
                                      billerList: billerList,
                                      onItemSelected: (value) {
                                        setState(() {
                                          //textHolder = value;
                                          selectedBiller = value.description;
                                          selectedBillerTag = value.billerTag;
                                          accountNoOrBillerData =
                                              value.firstField;
                                          otherData = value.secondField;
                                          _serviceTextController.text =
                                              value.serviceCharge.toString();
                                          if (selectedBillerTag == "PAGIBIG") {
                                            isPagIbib = true;
                                          } else {
                                            isPagIbib = false;
                                          }

                                          _amountTextController.text = "";
                                          _firstFieldController.text = "";
                                          _secondFieldTextController.text = "";
                                          fromDateController.text = "";
                                          toDateController.text = "";
                                          fromDateSelected = '';
                                          toDateSelected = '';
                                          pagibigPaymentType = null;
                                          pagibigPaymentOption = null;
                                        });
                                      },
                                    );
                                  });
                            },
                            //onTap: ()=> payBillDialog(data));
                          ))),
                  SizedBox(
                    width: 5.0,
                  ),
                  IconButton(
                      icon: Icon(Icons.refresh, color: kPrimaryColor, size: 36),
                      onPressed: () {
                        clearBillers();
                      })
                ]),
                SizedBox(
                  height: 15.0,
                ),
                Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _amountTextController,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, 'enter_amount'),
                          labelText: getTranslated(context, 'amount'),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslated(context, 'enter_valid_amount');
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _firstFieldController,
                        decoration: InputDecoration(
                          hintText: accountNoOrBillerData,
                          labelText: accountNoOrBillerData,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter ' + accountNoOrBillerData;
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      (!isPagIbib)
                          ? TextFormField(
                              controller: _secondFieldTextController,
                              decoration: InputDecoration(
                                hintText: otherData,
                                labelText: otherData,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter ' + otherData;
                                }
                                return null;
                              },
                            )
                          : DropdownButtonFormField<PagibigPaymentType>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Payment Types',
                                filled: true,
                                fillColor: Colors.white,
                                errorStyle: TextStyle(color: Colors.yellow),
                              ),
                              value: pagibigPaymentType,
                              items: pagIbigPaymentTypeList
                                  .map<DropdownMenuItem<PagibigPaymentType>>(
                                      (PagibigPaymentType value) {
                                return DropdownMenuItem<PagibigPaymentType>(
                                  value: value,
                                  child: Text(
                                    value.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (PagibigPaymentType newValue) {
                                setState(
                                  () {
                                    pagibigPaymentType = newValue;
                                  },
                                );
                              },
                            ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _serviceTextController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Service charge',
                          labelText: 'Service charge',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Service charge';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      if (isPagIbib)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              DropdownButtonFormField<PagibigPaymentOption>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Payment Options',
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorStyle: TextStyle(color: Colors.yellow),
                                ),
                                value: pagibigPaymentOption,
                                items: pagIbigPaymentOptionsList.map<
                                        DropdownMenuItem<PagibigPaymentOption>>(
                                    (PagibigPaymentOption value) {
                                  return DropdownMenuItem<PagibigPaymentOption>(
                                    value: value,
                                    child: Text(
                                      value.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (PagibigPaymentOption newValue) {
                                  setState(
                                    () {
                                      pagibigPaymentOption = newValue;
                                    },
                                  );
                                },
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextFormField(
                                  controller: fromDateController,
                                  decoration: InputDecoration(
                                    hintText: 'From date',
                                    labelText: 'From Date',
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter from date';
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      final DateFormat formatterTxt =
                                          DateFormat('MM-yyyy');
                                      final String formattedTxt =
                                          formatterTxt.format(date);
                                      fromDateController.text = formattedTxt;
                                      final DateFormat formatterVal =
                                          DateFormat('MM yyyy');
                                      final String formattedVal =
                                          formatterVal.format(date);
                                      fromDateSelected = formattedVal;
                                    }
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextFormField(
                                  controller: toDateController,
                                  decoration: InputDecoration(
                                    hintText: 'To date',
                                    labelText: 'To Date',
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter to date';
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      initialDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      final DateFormat formatterTxt =
                                          DateFormat('MM-yyyy');
                                      final String formattedTxt =
                                          formatterTxt.format(date);
                                      toDateController.text = formattedTxt;
                                      final DateFormat formatterVal =
                                          DateFormat('MM yyyy');
                                      final String formattedVal =
                                          formatterVal.format(date);
                                      toDateSelected = formattedVal;
                                    }
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                            ]),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () {
                            if (_formKey1.currentState.validate())
                              payBillHandler();
                          },
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          color: kPrimaryColor,
                          child:
                              Text('PAY BILLS', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.0,
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
                                  _amountTextController.text =
                                      favoritesList[index].amount;
                                  _firstFieldController.text =
                                      favoritesList[index].firstField;
                                  selectedBiller = favoritesList[index].biller;
                                  selectedBillerTag =
                                      favoritesList[index].billerTag;
                                  if (favoritesList[index].billerTag ==
                                      "PAGIBIG") {
                                    for (int i = 0;
                                        i < pagIbigPaymentOptionsList.length;
                                        i++) {
                                      if (pagIbigPaymentOptionsList[i].value ==
                                          favoritesList[index].paymentOption) {
                                        pagibigPaymentOption =
                                            pagIbigPaymentOptionsList[i];
                                      }
                                    }
                                    for (int i = 0;
                                        i < pagIbigPaymentTypeList.length;
                                        i++) {
                                      if (pagIbigPaymentTypeList[i]
                                              .value
                                              .toString() ==
                                          favoritesList[index].secondField) {
                                        pagibigPaymentType =
                                            pagIbigPaymentTypeList[i];
                                      }
                                    }
                                    isPagIbib = true;
                                  } else {
                                    _secondFieldTextController.text =
                                        favoritesList[index].secondField;
                                    isPagIbib = false;
                                  }
                                  _serviceTextController.text =
                                      favoritesList[index].serviceCharge;
                                });
                              },
                              child: FavoriteRowItem(favoritesList[index].name,
                                  onDelete: () {
                                setState(() {
                                  favoritesList.removeAt(index);
                                  saveFavorite();
                                });
                              })));
                    })
              ],
            ),
            isLoading
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: Loading()))
                : SizedBox(),
          ],
        ),
      ),
    )));
  }
}

class _SelectBillerDialog extends StatefulWidget {
  _SelectBillerDialog({this.billerList, this.onItemSelected});

  var rating;
  int id;

  List<Biller> billerList = [];
  ValueChanged<Biller> onItemSelected;

  @override
  _SelectBillerDialogState createState() => _SelectBillerDialogState();
}

class _SelectBillerDialogState extends State<_SelectBillerDialog> {
  bool isLoading = false;

  List<Biller> filterBillerList = [];
  TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterBillerList = widget.billerList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
        title: new Text(
          "Select Service",
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: kPrimaryColor),
        ),
        contentPadding: EdgeInsets.all(5.0),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchTextController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                onChanged: (value) {
                  // onItemChanged(value);

                  setState(() {
                    filterBillerList = widget.billerList
                        .where((u) => (u.description
                            .toLowerCase()
                            .contains(value.toLowerCase())))
                        .toList();
                  });
                },
              ),
            ),
//                      SizedBox(
//                        height: 30,
//                      ),
            Expanded(
              child: Material(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: filterBillerList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          //leading: FlutterLogo(size: 56.0),
                          title: Text(filterBillerList[index].description),
                          subtitle: Text(filterBillerList[index].billerTag),
                          onTap: () {
                            widget.onItemSelected(filterBillerList[index]);
                            Navigator.of(context).pop();
                          });
                    }),

                //}).toList(),
              ),
            ),
          ],
        ));
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
