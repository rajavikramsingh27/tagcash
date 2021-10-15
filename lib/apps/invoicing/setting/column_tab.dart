import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';


class ColumnTabScreen extends StatefulWidget {
  @override
  _ColumnTabScreenState createState() => _ColumnTabScreenState();
}

class _ColumnTabScreenState extends State<ColumnTabScreen> {
  bool isLoading = false;

  String items = '', units = '', price = '', amount = '', name_desc = '';
  String radioButtonItem = 'merchant';
  int id = 1;

  bool hide_units = false, hide_price = false, hide_amount = false;
  List<String> selectedtax = [];


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getConfig();
  }

  addStringToSF(String items, String units, String price, String amount, String name_desc, bool hide_units, bool hide_price, bool hide_amount)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_col_Items', items);
    prefs.setString('config_col_Units', units);
    prefs.setString('config_col_Price', price);
    prefs.setString('config_col_Amount', amount);
    prefs.setString('config_name_desc', name_desc);
    prefs.setBool('config_unit_hideUnits', hide_units);
    prefs.setBool('config_unit_hidePrice', hide_price);
    prefs.setBool('config_unit_hideAmount', hide_amount);


  }

  void getConfig() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/getConfig');


    if (response['status'] == 'success') {
      var jsonn = response['result'];

      setState(() {
        items = jsonn[0]['columns_titles'][0]['Items'];
        units = jsonn[0]['columns_titles'][0]['Units'];
        price = jsonn[0]['columns_titles'][0]['Price'];
        amount = jsonn[0]['columns_titles'][0]['Amount'];
        name_desc = jsonn[0]['name_desc'];
        hide_units = jsonn[0]['unit_price']['hideUnits'];
        hide_price = jsonn[0]['unit_price']['hidePrice'];
        hide_amount = jsonn[0]['unit_price']['hideAmount'];

        if(name_desc == 'showBoth'){
          radioButtonItem = 'showBoth';
          id = 1;
        } else if(name_desc == 'hideName'){
          radioButtonItem = 'hideName';
          id = 2;
        } else if(name_desc == 'hideDescription'){
          radioButtonItem = 'hideDescription';
          id = 3;
        }

      });

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


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Column Titles',
                              style: TextStyle(
                                fontSize: 12,
                                color: kPrimaryColor,
                              )),
                          SizedBox(
                            height: 10,
                          ),

                          GestureDetector(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Items',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kUserBackColor,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(
                                      items,
                                      style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC))
                                  ),
                                ],
                              ),
                            ),
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _ColumnDialog(
                                      title_label: 'Items',
                                      title_name: items,
                                      selectedText:selectedtax,
                                      onTextChanged: (cities) {
                                        selectedtax = cities;
                                        var str_Name = selectedtax.reduce((value, element) => value + element);
                                        setState(() {
                                          items = str_Name;
                                          addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                        });
                                      },
                                    );
                                  });
                            },
                          ),
                          Divider(),

                          GestureDetector(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Units',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kUserBackColor,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(
                                      units,
                                      style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ),
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _ColumnDialog(
                                      title_label: 'Units',
                                      title_name: units,
                                      selectedText:selectedtax,
                                      onTextChanged: (cities) {
                                        selectedtax = cities;
                                        var str_Name = selectedtax.reduce((value, element) => value + element);
                                        setState(() {
                                          units = str_Name;
                                          addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                        });
                                      },
                                    );
                                  });
                            },
                          ),

                          Divider(),

                          GestureDetector(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Price',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kUserBackColor,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(
                                      price,
                                      style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ),
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _ColumnDialog(
                                      title_label: 'Price',
                                      title_name: price,
                                      selectedText:selectedtax,
                                      onTextChanged: (cities) {
                                        selectedtax = cities;
                                        var str_Name = selectedtax.reduce((value, element) => value + element);
                                        setState(() {
                                          price = str_Name;
                                          addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                        });
                                      },
                                    );
                                  });
                            },
                          ),
                          Divider(),

                          GestureDetector(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kUserBackColor,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(
                                      amount,
                                      style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ),
                            onTap: (){

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _ColumnDialog(
                                      title_label: 'Amount',
                                      title_name: amount,
                                      selectedText:selectedtax,
                                      onTextChanged: (cities) {
                                        selectedtax = cities;
                                        var str_Name = selectedtax.reduce((value, element) => value + element);
                                        setState(() {
                                          amount = str_Name;
                                          addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                        });
                                      },
                                    );
                                  });
                            },
                          ),

                          Divider(),
                          Text(
                              'Name/Description',
                              style: TextStyle(
                                fontSize: 12,
                                color: kPrimaryColor,
                              )),
                          SizedBox(
                            height: 15,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: kMerchantBackColor,
                                  ), //set the dark theme or write your own theme
                                  child:
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 20, width: 20,
                                              child: Radio(
                                                activeColor: kMerchantBackColor ,
                                                value: 1,
                                                groupValue: id,
                                                onChanged: (val) {
                                                  setState(() {
                                                    radioButtonItem = 'showBoth';
                                                    addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    id = 1;
                                                  });
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Show both',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 25),
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 20, width: 20,
                                              child: Radio(
                                                activeColor: kMerchantBackColor ,
                                                value: 2,
                                                groupValue: id,
                                                onChanged: (val) {
                                                  setState(() {
                                                    radioButtonItem = 'hideName';
                                                    addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    id = 2;
                                                  });
                                                },
                                              ),
                                            ),

                                            SizedBox(
                                              width: 5,
                                            ),

                                            Text(
                                              'Hide name',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 25),
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 20, width: 20,
                                              child: Radio(
                                                activeColor: kMerchantBackColor ,
                                                value: 3,
                                                groupValue: id,
                                                onChanged: (val) {
                                                  setState(() {
                                                    radioButtonItem = 'hideDescription';
                                                    addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    id = 3;
                                                  });
                                                },
                                              ),
                                            ),

                                            SizedBox(
                                              width: 5,
                                            ),

                                            Text(
                                              'Hide description',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 25),
                                        Text(
                                            'Units/Price/Amount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: kPrimaryColor,
                                            )),
                                        SizedBox(
                                            height: 15),
                                        Row(
                                          children: [
                                            SizedBox(
                                                height: 20, width: 20,
                                                child: Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  value: hide_units,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      hide_units = val;
                                                      addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    });
                                                  },
                                                )
                                            ),

                                            SizedBox(
                                              width: 5,
                                            ),

                                            Text(
                                              'Hide units',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),

                                        Divider(height: 25),

                                        Row(
                                          children: [
                                            SizedBox(
                                                height: 20, width: 20,
                                                child: Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  value: hide_price,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      hide_price = val;
                                                      addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    });
                                                  },
                                                )
                                            ),

                                            SizedBox(
                                              width: 5,
                                            ),

                                            Text(
                                              'Hide price',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 25),

                                        Row(
                                          children: [
                                            SizedBox(
                                                height: 20, width: 20,
                                                child: Checkbox(
                                                  activeColor: kPrimaryColor,
                                                  value: hide_amount,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      hide_amount = val;
                                                      addStringToSF(items, units, price, amount, radioButtonItem, hide_units, hide_price, hide_amount);
                                                    });
                                                  },
                                                )
                                            ),

                                            SizedBox(
                                              width: 5,
                                            ),

                                            Text(
                                              'Hide amount',
                                              style: new TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  )
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    isLoading ? Center(child: Loading()) : SizedBox(),
    ],
    ),
    );
  }
}




class _ColumnDialog extends StatefulWidget {

  _ColumnDialog({
    this.title_label,
    this.title_name,
    this.selectedText,
    this.onTextChanged,
  });

  final String title_label;
  final String title_name;
  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;


  @override
  _ColumnDialogState createState() => _ColumnDialogState();
}

class _ColumnDialogState extends State<_ColumnDialog> {
  TextEditingController _titleController = TextEditingController();
  List<String> _tempSelectedTxt = [];
  String title_label;

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;
    title_label = widget.title_label;
    _titleController.text = widget.title_name;

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
                              child:Icon(
                                Icons.close,
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },)
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child:  Text(
                      'Column Title',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),



                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _titleController,
                style: TextStyle(fontWeight: FontWeight.normal),
                decoration: new InputDecoration(labelText: title_label),
              ),
            ),

            Container(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kUserBackColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('CANCEL',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),

                  Flexible(child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kPrimaryColor,
                        onPressed: () {
                          _tempSelectedTxt.clear();
                          var title = _titleController.text;
                          _tempSelectedTxt.add(title);
                          widget.onTextChanged(_tempSelectedTxt);
                          Navigator.of(context).pop();
                        },
                        child: Text('OK',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),)

                ],
              ),
            )
          ],
        ),
      ),
    );

  }

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }
}

