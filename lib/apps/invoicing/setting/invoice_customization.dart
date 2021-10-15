import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/setting/style_tab.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'column_tab.dart';
import 'info_tab.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  @override
  _InvoicecustomizationScreenState createState() => _InvoicecustomizationScreenState();
}

class _InvoicecustomizationScreenState extends State<InvoiceCustomizationScreen>
    with SingleTickerProviderStateMixin{

  TabController _controller;
  bool isLoading = false;

  String id, colour, logo_url, company, name_desc;
  var tamplat;
  var address;
  var contact;
  var columns_titles;
  var unit_price;

  var tamplate1;
  var address1;
  var contac1;
  var columns_titles1;

  List<String> templatelist = [];
  List<String> addresslist = [];
  List<String> contactlist = [];
  List<String> columntitlelist = [];



  @override
  void initState() {
    // TODO: implement initState

    super.initState();


    _controller = new TabController(
      length: 3,
      vsync: this,
    );
  }

  getSFData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tamplate_index = prefs.getString('config_tmp_index');
    String tamplate_path = prefs.getString('config_tmp_path');
    String tamplate_layout = prefs.getString('config_tmp_layout');
    String tamplate_name = prefs.getString('config_tmp_name');
    String tamplate_label = prefs.getString('config_tmp_label');

    String address_address1 = prefs.getString('config_add_address1');
    String address_address2 = prefs.getString('config_add_address2');
    String address_city = prefs.getString('config_add_city');
    String address_zipcode = prefs.getString('config_add_zipCode');
    String address_country = prefs.getString('config_add_country_addressCountry');
    String address_country_id = prefs.getString('config_add_country_addressCountryId');
    String address_state = prefs.getString('config_add_state_addressState');
    String address_state_id = prefs.getString('config_add_state_addressStateId');

    String contact_main = prefs.getString('config_contact_main');
    String contact_mobile = prefs.getString('config_contact_mobile');
    String contact_website = prefs.getString('config_contact_website');

    String col_items = prefs.getString('config_col_Items');
    String col_units = prefs.getString('config_col_Units');
    String col_price = prefs.getString('config_col_Price');
    String col_amount = prefs.getString('config_col_Amount');

    bool unit_hideamount = prefs.getBool('config_unit_hideAmount');
    bool unit_hideprice = prefs.getBool('config_unit_hidePrice');
    bool unit_hideunits = prefs.getBool('config_unit_hideUnits');



    //Return String
    id = prefs.getString('config_id');
    colour = prefs.getString('config_colour');
    logo_url = prefs.getString('config_logo_url');
    tamplat = '[{"index" : "$tamplate_index","path" : "$tamplate_path","layout" : "$tamplate_layout","name" : "$tamplate_name","label" : "$tamplate_label",}],';
    company = prefs.getString('config_company');
    address = '[{"address1" : "$address_address1", "address2" : "$address_address2", "city" : "$address_city", "zipCode" : "$address_zipcode", "country": {"addressCountry": "$address_country","addressCountryId": $address_country_id},"state": {"addressState": "$address_state","addressStateId": "$address_state_id"}}],';
    contact = '[{"main" : "$contact_main", "mobile" : "$contact_mobile", "website" : "$contact_website"}],';
    columns_titles = '[{"Items" : "$col_items", "Units" : "$col_units", "Price" : "$col_price", "Amount" : "$col_amount"}],';
    name_desc = prefs.getString('config_name_desc');
    unit_price = '{"hideAmount": $unit_hideamount,"hidePrice": $unit_hideprice,"hideUnits": $unit_hideunits}';

    print(id);
    print(colour);
    print(logo_url);
    print(company);
    print(address);
    print(contact);
    print(columns_titles);
    print(name_desc);
    print(unit_price);

    var tamplate1 = '{"index" : "$tamplate_index", "path" : "$tamplate_path","layout" : "$tamplate_layout","name" : "$tamplate_name","label" : "$tamplate_label"}';
    var address_1 = '{"address1" : "$address_address1", "address2" : "$address_address2","city" : "$address_city","zipCode" : "$address_zipcode","country" : {"addressCountry" : "$address_country","addressCountryId" : "$address_country_id"},"state" : {"addressState" : "$address_state","addressStateId" : "$address_state_id"}}';
    var contact1 = '{"main" : "$contact_main", "mobile" : "$contact_mobile","website" : "$contact_website"}';
    var column_title1 = '{"Items" : "$col_items", "Units" : "$col_units","Price" : "$col_price","Amount" : "$col_amount"}';

    templatelist.add("$tamplate1");
    addresslist.add("$address_1");
    contactlist.add("$contact1");
    columntitlelist.add("$column_title1");

    setConfig();

  }

  void setConfig() async {


    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;
    apiBodyObj['colour'] = colour;
    apiBodyObj['logo_url'] = logo_url;
    apiBodyObj['tamplate'] = templatelist.toString();
    apiBodyObj['company'] = company;
    apiBodyObj['address'] = addresslist.toString();
    apiBodyObj['contact'] = contactlist.toString();
    apiBodyObj['columns_titles'] = columntitlelist.toString();
    apiBodyObj['name_desc'] = name_desc;
    apiBodyObj['unit_price'] = unit_price;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/setConfig', apiBodyObj);

    print(unit_price);
//
    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context,true);

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Customization'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
            ),
            onPressed: () {
              getSFData();
            },
          ),
        ],

      ),
      body:  Column(
        children: [
          Container(
            decoration: new BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: TabBar(
              controller: _controller,
              unselectedLabelColor:  Color(0xFFACACAC),
              labelColor:  kUserBackColor,
              indicatorWeight: 3,
              indicatorColor:  kPrimaryColor,
              tabs: const <Tab>[
                const Tab(text: 'STYLE'),
                const Tab(text: 'INFO'),
                const Tab(text: 'COLUMNS'),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 0.5,
            color: Color(0xFFACACAC),
          ),
          Flexible(child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                new StyleTabScreen(),
                new InfoTabScreen(),
                new ColumnTabScreen(),
              ],
            ),
          )),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      )
    );
  }



}

