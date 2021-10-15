import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'address_screen.dart';
import 'contact_screen.dart';

class InfoTabScreen extends StatefulWidget {
  @override
  _InfoTabScreenState createState() => _InfoTabScreenState();
}

class _InfoTabScreenState extends State<InfoTabScreen> {
  bool isLoading = false;

  String company = '',
      address1 = '',
      address2 = '',
      city = '',
      zipcode = '',
      country = '',
      country_id = '',
      state = '',
      state_id = '';
  String main = '', mobile = '', website = '';

  List<String> selectedcompany = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConfig();
  }

  addStringToSF(String company) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_company', company);
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
        company = jsonn[0]['company'];
        address1 = jsonn[0]['address'][0]['address1'];
        address2 = jsonn[0]['address'][0]['address2'];
        city = jsonn[0]['address'][0]['city'];
        zipcode = jsonn[0]['address'][0]['zipCode'];
        country = jsonn[0]['address'][0]['country']['addressCountry'];
        country_id =
            jsonn[0]['address'][0]['country']['addressCountryId'].toString();
        state = jsonn[0]['address'][0]['state']['addressState'];
        state_id = jsonn[0]['address'][0]['state']['addressStateId'];
        main = jsonn[0]['contact'][0]['main'];
        mobile = jsonn[0]['contact'][0]['mobile'];
        website = jsonn[0]['contact'][0]['website'];
      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Company/Business',
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(company,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _ColumnDialog(
                            title_label: 'Company / Business',
                            title_name: company,
                            selectedText: selectedcompany,
                            onTextChanged: (cities) {
                              selectedcompany = cities;
                              var str_Name = selectedcompany
                                  .reduce((value, element) => value + element);
                              setState(() {
                                company = str_Name;
                                addStringToSF(company);
                              });
                            },
                          );
                        });
                  },
                ),
                Divider(),
                InkWell(
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address',
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "$address1\n$address2\n$country\n$state\n$city\n$zipcode",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (context) => AddressScreen(
                                  address1: address1,
                                  address2: address2,
                                  country: country,
                                  state: state,
                                  city: city,
                                  zipcode: zipcode,
                                  country_id: country_id,
                                  state_id: state_id,
                                )))
                        .then((val) => val ? getAddressData() : null);
                  },
                ),
                Divider(),
                InkWell(
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Contact',
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Main: $main\nMobile: $mobile\nWebsite: $website",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .apply(color: Color(0xFFACACAC))),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (context) => ContactScreen(
                                  main: main,
                                  mobile: mobile,
                                  website: website,
                                )))
                        .then((val) => val ? getContactData() : null);
                  },
                )
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }

  getContactData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    setState(() {
      main = prefs.getString('config_contact_main');
      mobile = prefs.getString('config_contact_mobile');
      website = prefs.getString('config_contact_website');
    });
  }

  getAddressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String

    setState(() {
      address1 = prefs.getString('config_add_address1');
      address2 = prefs.getString('config_add_address2');
      city = prefs.getString('config_add_city');
      zipcode = prefs.getString('config_add_zipCode');
      country = prefs.getString('config_add_country_addressCountry');
      country_id = prefs.getString('config_add_country_addressCountryId');
      state = prefs.getString('config_add_state_addressState');
      state_id = prefs.getString('config_add_state_addressStateId');
    });
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
                      'Change Info',
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
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
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
                          child: Text(
                            'OK',
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
