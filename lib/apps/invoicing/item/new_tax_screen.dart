import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class NewTaxScreen extends StatefulWidget {

  @override
  _NewTaxScreenState createState() => _NewTaxScreenState();

}

class _NewTaxScreenState extends State<NewTaxScreen> with SingleTickerProviderStateMixin{


  TextEditingController _tax_name_IdController = TextEditingController();
  TextEditingController _tax_rate_IdController = TextEditingController();
  TextEditingController _tax_number_IdController = TextEditingController();


  Future<List<Tax>> itemList;
  List<Tax> getData = new List<Tax>();
  bool isLoading = false;
  bool isRecoverable = false;
  bool isCompound = false;

  String recoverable = 'false';
  String compound = 'false';

  @override
  void initState() {
    super.initState();

  }


  void taxPressed() async {

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _tax_name_IdController.text;
    apiBodyObj['rate'] = _tax_rate_IdController.text;
    apiBodyObj['tax_id'] = _tax_number_IdController.text;
    apiBodyObj['recoverable'] = recoverable;
    apiBodyObj['compound'] = compound;


    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/addTax', apiBodyObj);

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
    // TODO: implement build
    return Scaffold(
      appBar:  AppBar(
        title: Text('New Tax'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              taxPressed();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                  child: merchantModule()),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      )


    );

  }

  Widget merchantModule(){
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
                          controller: _tax_name_IdController,
                          decoration: InputDecoration(
                            labelText: 'Tax name*',

                          ),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),

                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _tax_rate_IdController,
                          decoration: InputDecoration(
                            labelText: 'Tax rate*',
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          keyboardType: TextInputType.number,
                          controller: _tax_number_IdController,
                          decoration: InputDecoration(
                            labelText: 'Tax number / ID',
                          ),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 10),

                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text('This is recoverable tax',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: kUserBackColor,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),

                              Container(
                                child:Switch(
                                  value: isRecoverable,
                                  onChanged: (value) {
                                    setState(() {
                                      recoverable = value.toString();
                                      isRecoverable = value;
                                    });
                                  },
                                  activeTrackColor:kMerchantBackColor,
                                  activeColor: kPrimaryColor,
                                ),
                              )
                            ],
                          ),
                        ),

                        Container(
                          child: Text('A tax is recoverable if you can deduct the tax that you\'ve paid from the tax that you have collected.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text('This is compound tax',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: kUserBackColor,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),

                              Container(
                                child:Switch(
                                  value: isCompound,
                                  onChanged: (value) {
                                    setState(() {
                                      compound = value.toString();
                                      isCompound = value;
                                    });
                                  },
                                  activeTrackColor:kMerchantBackColor,
                                  activeColor: kPrimaryColor,
                                ),
                              )
                            ],
                          ),
                        ),

                        Container(
                          child: Text('A compound tax or sracked tax, is calculated on top of a primary tax.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
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

}
