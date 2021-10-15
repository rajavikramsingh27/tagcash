import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/models/country.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/constants.dart';

class ContactScreen extends StatefulWidget {
  String main, mobile, website;

  ContactScreen({Key key, this.main,this.mobile,this.website,}): super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState(main, mobile, website);
}

class _ContactScreenState extends State<ContactScreen> {
  var addressed;
  String main, mobile, website;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _mainController = new TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();

  bool isLoading = false;
  Future<List<Country>> itemList;
  List<Country> getData = new List<Country>();

  _ContactScreenState(String main, String mobile, String website){
    this.main = main;
    this.mobile = mobile;
    this.website = website;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _mainController.text = main;
      _mobileController.text = mobile;
      _websiteController.text = website;
    });

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Contact',
        ),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  total(),
                ],
              ),
            )
          ],
        ));
  }


  Widget total() {
    return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(fontWeight: FontWeight.normal),
              controller: _mainController,
              decoration: new InputDecoration(labelText: 'Main'),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: new InputDecoration(labelText: 'Mobile'),
            ),
            SizedBox(
              height: 15,
            ),

            TextField(
              controller: _websiteController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: new InputDecoration(labelText: 'Website'),
            ),
            SizedBox(
              height: 15,
            ),

            ButtonTheme(
              height: 45,
              minWidth: MediaQuery.of(context).size.width,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: RaisedButton(
                color: kPrimaryColor,
                onPressed: () {
                  if(_mainController.text == '' || _mobileController.text == '' || _websiteController.text == ''){
                    showSimpleDialog(context,
                        title: 'Attention',
                        message: 'Plase fill all required field to continue!');
                  } else{
                    addStringToSF(_mainController.text,
                        _mobileController.text,
                        _websiteController.text);

                    Navigator.pop(context, true);

                  }
                },
                child: Text(
                  'Set Contact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

addStringToSF(String main, String mobile, String website) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('config_contact_main', main);
  prefs.setString('config_contact_mobile', mobile);
  prefs.setString('config_contact_website', website);
}