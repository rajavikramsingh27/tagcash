import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/item/new_tax_screen.dart';
import 'package:tagcash/apps/invoicing/models/add_item.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class AddItemScreen extends StatefulWidget {
  final String user_id, name, desc, price, tax, income_account, txt_id, qty, edittype;
  final List<Tax> getTaxData;

  AddItemScreen(
      {Key key,
      this.user_id,
      this.name,
      this.desc,
      this.price,
      this.tax,
      this.income_account,
      this.txt_id,
        this.qty,
      this.getTaxData,
      this.edittype})
      : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState(
      user_id, name, desc, price, tax, income_account, txt_id, qty, getTaxData, edittype);
}

class _AddItemScreenState extends State<AddItemScreen>
    with SingleTickerProviderStateMixin {
  String user_id, name, desc, price, tax, income_account, txt_id, qty, edittype;
  List<Tax> getTaxData;
  var id;
  Timer timer;

  bool isLoading = false;

  TextEditingController _item_nameIdController = TextEditingController();
  TextEditingController _item_descController = TextEditingController();
  TextEditingController _item_quantityController = TextEditingController();
  TextEditingController _item_priceController = TextEditingController();
  TextEditingController _item_taxController = TextEditingController();

  AnimationController controller;
  Animation<double> scaleAnimation;
  var dialog_name = 'Consulting Income';
  var dialog_value = 'consulting_income';

  List<Tax> getData = new List<Tax>();
  List<AddItem> addItemData = new List<AddItem>();
  List<AddItem> getAddData = new List<AddItem>();

  List<Tax> getSelectedData = new List<Tax>();
  List<String> selectedtaxes = [];
  List<String> selectedtaxesid = [];
  List<String> selectedtaxesrate = [];
  List<String> sendidlist = [];

  Future<List<Tax>> itemList;

  int total_price;
  double ttl_tax = 0.0;
  double total_amount = 0.0;
  double totalAmount = 0.0;
  double total_tax = 0.0;


  _AddItemScreenState(String user_id, String name, String desc, String price,
      String tax, String income_account, String txt_id, String qty, List<Tax> getTaxData, String edittype) {
    this.user_id = user_id;
    this.name = name;
    this.desc = desc;
    this.price = price;
    this.tax = tax;
    this.income_account = income_account;
    this.txt_id = txt_id;
    this.qty = qty;
    this.getTaxData = getTaxData;
    this.edittype = edittype;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    setState(() {
      if (getTaxData.length != 0) {
        for (int i = 0; i < getTaxData.length; i++) {
          Tax tax = new Tax();
          tax.name = getTaxData[i].name;
          tax.id = getTaxData[i].id;
          tax.rate = getTaxData[i].rate;
          getSelectedData.add(tax);

        }

        for (int i = 0; i < getSelectedData.length; i++) {
          selectedtaxes.add(getSelectedData[i].name);
          selectedtaxesid.add(getSelectedData[i].id);
          selectedtaxesrate.add(getSelectedData[i].rate);

          var stringList =
          selectedtaxes.reduce((value, element) => value + ',' + element);
          _item_taxController.text = stringList;

          List<String> langList = [];
          for (String item in selectedtaxesid) {
            langList.add("\"" + item + "\"");
          }
          sendidlist = langList;
        }


      }

      print(getTaxData.length);

      _item_nameIdController.text = name;
      _item_descController.text = desc;
      _item_quantityController.text = qty;
      _item_priceController.text = price;
      _item_taxController.text = tax;
      id = txt_id;
      double d = double.parse(_item_priceController.text);

      int total_calculate = d.toInt() * int.parse(qty);

      total_price = total_calculate;

      if (income_account == 'consulting_income' ||
          income_account == 'Consulting Income') {
        dialog_name = 'Consulting Income';
      } else {
        dialog_name = 'Sales';
      }
      dialog_value = income_account;

      _item_nameIdController.selection = TextSelection.fromPosition(
          TextPosition(offset: _item_nameIdController.text.length));
      _item_descController.selection = TextSelection.fromPosition(
          TextPosition(offset: _item_descController.text.length));
      _item_priceController.selection = TextSelection.fromPosition(
          TextPosition(offset: _item_priceController.text.length));
    });

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 5));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });
    itemList = loadStaffCommunities();
    controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('total_amount' + total_amount.toString());

  }

  Future<List<Tax>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/listTax');

    List responseList = response['result'];

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
    } else {}

    getData = responseList.map<Tax>((json) {
      return Tax.fromJson(json);
    }).toList();

    return getData;
  }

  void editItemPressed() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = user_id;
    apiBodyObj['name'] = _item_nameIdController.text;
    apiBodyObj['desc'] = _item_descController.text;
    apiBodyObj['price'] = _item_priceController.text;
    apiBodyObj['tax_id'] = sendidlist.toString();
    apiBodyObj['income_account'] = dialog_value;

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/EditItem', apiBodyObj);

    if (response['status'] == 'success') {

      if(edittype == '0'){

        SharedPreferences pref = await SharedPreferences.getInstance();

        AddItem itm = new AddItem('', '', '', '', '', '');
        itm.id = user_id;
        itm.qty = _item_quantityController.text;

        addItemData.add(itm);


        pref.setString('userData', json.encode(itm));

        Navigator.pop(context, true);

      } else{
        SharedPreferences pref = await SharedPreferences.getInstance();
        AddItem itm = new AddItem(
            user_id,
            _item_nameIdController.text,
            _item_descController.text,
            _item_priceController.text,
            _item_quantityController.text,
            dialog_value);
        itm.id = user_id;
        itm.name = _item_nameIdController.text;
        itm.desc = _item_descController.text;
        itm.price = total_price.toString();
        itm.qty = _item_quantityController.text;
        itm.income_account = dialog_value;
        itm.tax_id = selectedtaxesid;

        addItemData.add(itm);


        pref.setString('userData', json.encode(itm));
        Navigator.pop(context, true);
      }

      setState(() {
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  addStringToSF(String add_customer_name, String add_customer_email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('add_customer_name', add_customer_name);
    prefs.setString('add_customer_email', add_customer_email);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    setState(() {
      ttl_tax = 0.0;
      total_amount = 0.0;
      totalAmount = 0.0;
      total_tax = 0.0;

    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Item'),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.done),
                onPressed: () async {
                  editItemPressed();

                }),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(child: addItemModule()),
                Container(child: calculateAmount()),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Widget addItemModule() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _item_nameIdController,
                          decoration: InputDecoration(
                            labelText: 'Name*',
                          ),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _item_descController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller: _item_quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                ),
                                style: TextStyle(
                                    color: kUserBackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                                onChanged: (content) {
                                  setState(() {
                                    _item_quantityController.text;
                                    int qty = int.parse(_item_quantityController.text);
                                    double d = double.parse(_item_priceController.text);
                                    int price = d.toInt();
                                    total_price = qty * price;
                                    print(total_price);
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: TextField(
                                controller: _item_priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Price*',
                                ),
                                style: TextStyle(
                                    color: kUserBackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                                onChanged: (content) {
                                  setState(() {
                                    _item_priceController.text;
                                    int qty = int.parse(_item_quantityController.text);
                                    double d = double.parse(_item_priceController.text);
                                    int price = d.toInt();
                                    total_price = qty * price;
                                    print(total_price);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: InkWell(
                                child: TextField(
                                  enabled: false,
                                  readOnly: true,
                                  controller: _item_taxController,
                                  decoration: InputDecoration(
                                    labelText: 'Select a tax',
                                  ),
                                  style: TextStyle(
                                      color: kUserBackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _TaxDialog(
                                          taxData: getData,
                                          taxSelectedData: getSelectedData,
                                          selectedCities: selectedtaxes,
                                          selectedTaxId: selectedtaxesid,
                                          selectedTaxRate: selectedtaxesrate,
                                          onSelectedCitiesListChanged: (cities) {
                                          },
                                          onSelectedTaxIdListChanged: (cities) {
                                          },
                                          onSelectedTaxRateListChanged: (cities) {},
                                          onSelectedTaxListChanged: (cities) {
                                            getSelectedData = cities;
                                            setState(() {
                                              if (getSelectedData.length != 0){
                                                selectedtaxes.clear();
                                                selectedtaxesid.clear();
                                                selectedtaxesrate.clear();

                                                for (int i = 0; i < getSelectedData.length; i++) {
                                                  selectedtaxes.add(getSelectedData[i].name);
                                                  selectedtaxesid.add(getSelectedData[i].id);
                                                  selectedtaxesrate.add(getSelectedData[i].rate);

                                                  var stringList =
                                                  selectedtaxes.reduce((value, element) => value + ',' + element);
                                                  _item_taxController.text = stringList;

                                                  List<String> langList = [];
                                                  for (String item in selectedtaxesid) {
                                                    langList.add("\"" + item + "\"");
                                                  }
                                                  sendidlist = langList;
                                                  getTotal(total_price);
                                                }

                                                print(sendidlist);

                                              } else{
                                                sendidlist.clear();
                                                _item_taxController.text = '';
                                              }

                                            });
                                          },
                                        );
                                      });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Income account',
                                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                      ),
                                    ),
                                    InkWell(
                                      child: Container(
                                          margin: EdgeInsets.only(top: 5, bottom: 5),
                                          decoration: new BoxDecoration(
                                              color: Color(0xfff2f3f5),
                                              border: Border.all(
                                                  color: Color(0xFFACACAC), width: 0.5),
                                              borderRadius: BorderRadius.circular(5.0)),
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        dialog_name,
                                                        style: TextStyle(
                                                            color: kUserBackColor,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.normal),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      FaIcon(
                                                        FontAwesomeIcons.angleDown,
                                                        size: 16,
                                                        color: Color(0xFFACACAC),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          )),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => incomeModule(),
                                        );
                                      },
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }

  Widget calculateAmount() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _item_quantityController.text +
                        ' x ' +
                        _item_priceController.text,
                    style: TextStyle(
                        fontSize: 16,
                        color: kUserBackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    total_price.toString(),
                    style: TextStyle(
                        fontSize: 16,
                        color: kUserBackColor,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
                width: MediaQuery.of(context).size.width,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedtaxes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      child: Text(selectedtaxes[index] +
                                          ' ' +
                                          selectedtaxesrate[index] +
                                          '%',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: kUserBackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(percentage1Calculate(
                                        selectedtaxesrate[index],
                                        total_price),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: kUserBackColor,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {});
                        },
                      ),
                    )
                  ],
                )),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(top: 5),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            'Amount',
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        )

                      ],

                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child:Text(
                            getTotal(total_price),
                            style: TextStyle(
                                color: kUserBackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],

                    ),
                  ),
                ],
              ),
            ),
            edittype == '1'?
            Container(
              width: MediaQuery.of(context).size.width,
              child: ButtonTheme(
                height: 40,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: RaisedButton(
                  color: kPrimaryColor,
                  onPressed: () async {

                    SharedPreferences pref = await SharedPreferences.getInstance();
                    AddItem itm = new AddItem('', '', '', '', '', '');
                    itm.id = '';
                    itm.qty = '';

                    addItemData.add(itm);

                    pref.setString('userData', json.encode(itm));

                    pref.setString('deleteItemData', user_id);
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Remove Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

            ):  Container(

            ),

          ],
        ),
      ),
    );
  }

  String percentage1Calculate(String ratee, int price) {
    int rate = int.parse(ratee);
    double total = (rate / 100) * price;
    ttl_tax = ttl_tax + total;
    print("ttl_tax_ " + ttl_tax.toString());
    double doubleVar = price.toDouble();
    total_amount = ttl_tax + doubleVar;
    print("ttl_anount_ " + total_amount.toString());
    return total.toStringAsFixed(2);
  }

  String getTotal(int price){

    if(selectedtaxes.length == 0){
      totalAmount = total_price.toDouble();
    } else{

      for(int i=0; i<getSelectedData.length; i++){
        int rate = int.parse(getSelectedData[i].rate);
        double total = (rate / 100) * price;
        total_tax = total_tax + total;
        print("total_tax " + total_tax.toString());
        double doubleVar = price.toDouble();
        totalAmount = total_tax + doubleVar;
        print("ttl_anount_ " + totalAmount.toString());
      }
    }


    return totalAmount.toStringAsFixed(2);
  }


  void autoPress() {
    timer = new Timer(const Duration(seconds: 2), () {
      print("This line will print after two seconds");
    });
  }

  Widget incomeModule() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
            scale: scaleAnimation,
            child: Stack(
              children: [
                Container(
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: Container(
                      height: 80,
                      width: 250,
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Consulting Income',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                dialog_name = 'Consulting Income';
                                dialog_value = 'consulting_income';
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                          Divider(),
                          InkWell(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Sales',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                dialog_name = 'Sales';
                                dialog_value = 'sales';
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )),
                ),
              ],
            )),
      ),
    );
  }
}

class _TaxDialog extends StatefulWidget {
  _TaxDialog({
    this.taxData,
    this.taxSelectedData,
    this.selectedCities,
    this.selectedTaxId,
    this.selectedTaxRate,
    this.onSelectedCitiesListChanged,
    this.onSelectedTaxIdListChanged,
    this.onSelectedTaxRateListChanged,
    this.onSelectedTaxListChanged,
  });

  List<Tax> taxData = new List<Tax>();

  List<Tax> taxSelectedData = new List<Tax>();
  final List<String> selectedCities;
  final List<String> selectedTaxId;
  final List<String> selectedTaxRate;

  final ValueChanged<List<String>> onSelectedCitiesListChanged;
  final ValueChanged<List<String>> onSelectedTaxIdListChanged;
  final ValueChanged<List<String>> onSelectedTaxRateListChanged;
  final ValueChanged<List<Tax>> onSelectedTaxListChanged;

  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  List<String> _tempSelectedCities = [];
  List<String> _tempSelectedId = [];
  List<String> _tempSelectedRate = [];
  List<Tax> _taxSelectedData = new List<Tax>();

  @override
  void initState() {
    _tempSelectedCities = widget.selectedCities;
    _tempSelectedId = widget.selectedTaxId;
    _tempSelectedRate = widget.selectedTaxRate;
    _taxSelectedData = widget.taxSelectedData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Select applicable tax(es)',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
           Expanded(child: Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.taxData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final cityName = widget.taxData[index];
                        return Container(
                          child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: kPrimaryColor,
                              checkColor: Colors.white,
                              title: Text(cityName.name),
                              value: _tempSelectedId.contains(cityName.id),
                              onChanged: (bool value) {
                                if (value) {
                                  if (!_tempSelectedId.contains(cityName.id)) {
                                    setState(() {
                                      Tax tax = new Tax();
                                      tax.id = cityName.id;
                                      tax.name = cityName.name;
                                      tax.rate = cityName.rate;
                                      _taxSelectedData.add(tax);

                                      _tempSelectedCities.add(cityName.name);
                                      _tempSelectedId.add(cityName.id);
                                      _tempSelectedRate.add(cityName.rate);
                                    });
                                  }
                                } else {
                                  if (_tempSelectedId.contains(cityName.id)) {
                                    setState(() {
                                      Tax tax = new Tax();
                                      tax.id = cityName.id;
                                      tax.name = cityName.name;
                                      tax.rate = cityName.rate;
                                      _taxSelectedData.removeWhere((item) => item.id == cityName.id);
                                      _tempSelectedCities.removeWhere(
                                              (String city) => city == cityName.name);
                                      _tempSelectedId.removeWhere(
                                              (String city) => city == cityName.id);
                                      _tempSelectedRate.removeWhere(
                                              (String city) => city == cityName.rate);
                                    });
                                  }
                                }

                              }),
                        );
                      }),
                )),

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: ButtonTheme(
                      minWidth: 40,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kPrimaryColor,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (context) => NewTaxScreen()),
                          );
                        },
                        child: Text(
                          'CREATE NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kUserBackColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'CANCEL',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: RaisedButton(
                          padding: EdgeInsets.all(8),
                          color: kPrimaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedCitiesListChanged(
                                _tempSelectedCities);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget.onSelectedTaxRateListChanged(_tempSelectedRate);
                            widget.onSelectedTaxListChanged(_taxSelectedData);
                          });
                          },
                          child: Text(
                            'APPLY TAX',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            softWrap: false,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
