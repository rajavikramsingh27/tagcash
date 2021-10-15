import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/invoicing/models/tax.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'new_tax_screen.dart';

class NewItemScreen extends StatefulWidget {

  @override
  _NewItemScreenState createState() => _NewItemScreenState();

}

class _NewItemScreenState extends State<NewItemScreen> with SingleTickerProviderStateMixin{

  TextEditingController _item_nameIdController = TextEditingController();
  TextEditingController _item_descController = TextEditingController();
  TextEditingController _item_priceController = TextEditingController();
  TextEditingController _item_taxController = TextEditingController();


  AnimationController controller;
  Animation<double> scaleAnimation;
  var dialog_name = 'Consulting Income';
  var dialog_value = 'consulting_income';
  var id;


  bool checkboxValueCity = false;

  List<Tax> getSelectedData = new List<Tax>();
  List<String> selectedtaxes = [];
  List<String> selectedtaxesid = [];
  List<String> sendidlist = [];

  Future<List<Tax>> itemList;
  List<Tax> getData = new List<Tax>();
  bool isLoading = false;

  final List<String> cities = new List<String>();


  @override
  void initState() {
    super.initState();

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

    // memberDataList = {} as Future<List<Merchant>>;
    itemList = loadStaffCommunities();
  }
  void addItemPressed() async {

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _item_nameIdController.text;
    apiBodyObj['desc'] = _item_descController.text;
    apiBodyObj['price'] = _item_priceController.text;
    apiBodyObj['tax_id'] = sendidlist.toString();
    apiBodyObj['income_account'] = dialog_value;


    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/AddItem', apiBodyObj);

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


  Future<List<Tax>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'invoicing/listTax');

    List responseList = response['result'];

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
    }else{

    }

    getData = responseList.map<Tax>((json) {
      return Tax.fromJson(json);
    }).toList();


    return getData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('New Item'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
            ),
            onPressed: () {
              addItemPressed();
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
        Flexible(child: Container(
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
                    TextField(
                      controller: _item_priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price*',
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 10),
                    InkWell(
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
                      onTap: (){
                        FocusScope.of(context).unfocus();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _TaxDialog(
                                  taxData: getData,
                                  taxSelectedData: getSelectedData,
                                  selectedCities: selectedtaxes,
                                  selectedTaxId: selectedtaxesid,
                                  onSelectedCitiesListChanged: (cities) {
                                  },
                                  onSelectedTaxIdListChanged: (cities) {
                                  },

                                  onSelectedTaxListChanged: (cities) {
                                    getSelectedData = cities;
                                    setState(() {
                                      if (getSelectedData.length != 0){
                                        selectedtaxes.clear();
                                        selectedtaxesid.clear();

                                        for (int i = 0; i < getSelectedData.length; i++) {
                                          selectedtaxes.add(getSelectedData[i].name);
                                          selectedtaxesid.add(getSelectedData[i].id);

                                          var stringList = selectedtaxes.reduce((value, element) => value + ',' + element);
                                          _item_taxController.text = stringList;

                                          List<String> langList = [];
                                          for (String item in selectedtaxesid) {
                                            langList.add("\"" + item + "\"");
                                          }
                                          sendidlist = langList;
                                        }

                                        print(sendidlist);

                                      } else{
                                        sendidlist.clear();
                                        _item_taxController.text = '';
                                      }

                                    });
                                  }
                              );
                            });
                      },),

                    SizedBox(height: 15),
                    Container(
                      child: Text('Income account',
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                      ),
                    ),
                    InkWell(
                      child:Container(
                          margin: EdgeInsets.only(top:5, bottom: 5),
                          decoration: new BoxDecoration(
                              color: Color(0xfff2f3f5),
                              border:
                              Border.all(color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  )
                              ),
                            ],
                          )),
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (_) => incomeModule(),
                        );
                      },),

                    Container(
                      child: Text('An income account is used for proper bookkeeping of your sales and to keep your reports accurate.',
                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
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

  Widget incomeModule(){
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
                          onTap: (){
                            setState(() {
                              dialog_name = 'Consulting Income';
                              dialog_value = 'consulting_income';
                            });
                            Navigator.of(context).pop();
                          },),

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
                          onTap: (){
                            setState(() {
                              dialog_name = 'Sales';
                              dialog_value = 'sales';
                            });
                            Navigator.of(context).pop();
                          },),
                      ],
                    )
                ),
              ),

            ],
          )

        ),
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
    this.onSelectedCitiesListChanged,
    this.onSelectedTaxIdListChanged,
    this.onSelectedTaxListChanged,
  });

  List<Tax> taxData = new List<Tax>();
  List<Tax> taxSelectedData = new List<Tax>();
  final List<String> selectedCities;
  final List<String> selectedTaxId;
  final ValueChanged<List<String>> onSelectedCitiesListChanged;
  final ValueChanged<List<String>> onSelectedTaxIdListChanged;
  final ValueChanged<List<Tax>> onSelectedTaxListChanged;


  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  List<String> _tempSelectedCities = [];
  List<String> _tempSelectedId = [];
  List<Tax> _taxSelectedData = new List<Tax>();

  @override
  void initState() {
    _tempSelectedCities = widget.selectedCities;
    _tempSelectedId = widget.selectedTaxId;
    _taxSelectedData = widget.taxSelectedData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        insetPadding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
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
                      'Select applicable tax(es)',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),



                ],
              ),
            ),
           Expanded(child:  Container(
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
                               });
                             }
                           }

                         }),
                   );
                 }),
           ),),

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: ButtonTheme(
                      minWidth: 40,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kPrimaryColor,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(builder: (context) => NewTaxScreen()),
                          );
                        },
                        child: Text('CREATE NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 10),
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
                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedCitiesListChanged(_tempSelectedCities);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget.onSelectedTaxListChanged(_taxSelectedData);
                          });
                        },
                        child: Text('APPLY TAX',
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
}

