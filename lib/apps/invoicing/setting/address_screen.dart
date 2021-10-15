import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/models/country.dart';
import 'package:tagcash/apps/invoicing/models/state.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class AddressScreen extends StatefulWidget {
  String address1,
      address2,
      country,
      state,
      city,
      zipcode,
      country_id,
      state_id;

  AddressScreen(
      {Key key,
      this.address1,
      this.address2,
      this.country,
      this.state,
      this.city,
      this.zipcode,
      this.country_id,
      this.state_id})
      : super(key: key);

  @override
  _AddessScreenState createState() => _AddessScreenState(
      address1, address2, country, state, city, zipcode, country_id, state_id);
}

class _AddessScreenState extends State<AddressScreen> {
  String address1, address2, country, state, city, zipcode;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _address1Controller = new TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _selectcountryController = TextEditingController();
  TextEditingController _selectstateController = TextEditingController();
  TextEditingController _selectcityController = TextEditingController();
  TextEditingController _postalcodeController = TextEditingController();

  bool isLoading = false;
  Future<List<Country>> itemList;
  List<Country> getData = new List<Country>();

  String selectcountry = '';
  List<String> selectedcountry = [];
  List<String> selectedcountryid = [];
  List<String> selectedstate = [];
  List<String> selectedstateid = [];

  var countryId;
  var stateId;

  _AddessScreenState(
      String address1,
      String address2,
      String country,
      String state,
      String city,
      String zipcode,
      String country_id,
      String state_id) {
    this.address1 = address1;
    this.address2 = address2;
    this.country = country;
    this.state = state;
    this.city = city;
    this.zipcode = zipcode;
    this.countryId = country_id;
    this.stateId = state_id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _address1Controller.text = address1;
      _address2Controller.text = address2;
      _selectcountryController.text = country;
      _selectstateController.text = state;
      _selectcityController.text = city;
      _postalcodeController.text = zipcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Address',
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
          controller: _address1Controller,
          decoration: new InputDecoration(labelText: 'Address line 1'),
        ),
        SizedBox(
          height: 15,
        ),
        TextField(
          controller: _address2Controller,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: new InputDecoration(labelText: 'Address line 2'),
        ),
        SizedBox(
          height: 15,
        ),
        InkWell(
          child: TextField(
            enabled: false,
            readOnly: true,
            controller: _selectcountryController,
            style: TextStyle(fontWeight: FontWeight.normal),
            decoration: new InputDecoration(
                labelText: 'Select Country',
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded)),
          ),
          onTap: () {
            FocusScope.of(context).unfocus();
            selectedcountry.clear();
            showDialog(
                context: context,
                builder: (context) {
                  return _CountryDialog(
                    selectcountry: selectcountry,
                    selectedCountry: selectedcountry,
                    selectedCountryId: selectedcountryid,
                    onSelectedCountryListChanged: (cities) {
                      selectedcountry = cities;
                      print(selectedcountry);
                      setState(() {
                        var stringList = selectedcountry
                            .reduce((value, element) => value + element);
                        _selectcountryController.text = stringList;
                      });
                    },
                    onSelectedCountryIdChanged: (cities) {
                      selectedcountryid = cities;
                      print(selectedcountryid);
                      setState(() {
                        var countryidList = selectedcountryid
                            .reduce((value, element) => value + element);
                        countryId = countryidList;
                        print(countryId);
                      });
                    },
                  );
                });

            print(selectcountry);
          },
        ),
        Container(
          child: _selectcountryController.text != ''
              ? Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        child: TextField(
                          enabled: false,
                          readOnly: true,
                          controller: _selectstateController,
                          style: TextStyle(fontWeight: FontWeight.normal),
                          decoration: new InputDecoration(
                              labelText: 'Select State',
                              suffixIcon:
                                  Icon(Icons.keyboard_arrow_down_rounded)),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          selectedstate.clear();
                          showDialog(
                              context: context,
                              builder: (context) {
                                return _StateDialog(
                                  selectedState: selectedstate,
                                  country_name: _selectcountryController.text,
                                  selectedStateId: selectedstateid,
                                  onSelectedCountryListChanged: (cities) {
                                    selectedstate = cities;
                                    print(selectedstate);
                                    setState(() {
                                      var stringList = selectedstate.reduce(
                                          (value, element) => value + element);
                                      _selectstateController.text = stringList;
                                    });
                                  },
                                  onSelectedStateIdChanged: (cities) {
                                    selectedstateid = cities;
                                    print(selectedstateid);
                                    setState(() {
                                      var stringList = selectedstateid.reduce(
                                          (value, element) => value + element);
                                      stateId = stringList;
                                    });
                                  },
                                );
                              });

                          print(selectcountry);
                        },
                      )
                    ],
                  ),
                )
              : Container(),
        ),
        SizedBox(
          height: 15,
        ),
        TextField(
          controller: _selectcityController,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: new InputDecoration(labelText: 'City'),
        ),
        SizedBox(
          height: 15,
        ),
        TextField(
          controller: _postalcodeController,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: new InputDecoration(labelText: 'Postal/Zip code'),
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
              if (_address1Controller.text == '' ||
                  _address2Controller.text == '' ||
                  _selectcountryController.text == '' ||
                  _selectstateController.text == '' ||
                  _selectcityController.text == '' ||
                  _postalcodeController.text == '') {
                showSimpleDialog(context,
                    title: 'Attention',
                    message: 'Plase fill all required field to continue!');
              } else {
                addStringToSF(
                    _address1Controller.text,
                    _address2Controller.text,
                    _selectcountryController.text,
                    countryId.toString(),
                    _selectstateController.text,
                    stateId,
                    _selectcityController.text,
                    _postalcodeController.text);

                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Save Address',
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

addStringToSF(
    String address_1,
    String address_2,
    String country,
    String country_id,
    String state,
    String state_id,
    String city,
    String postal_code) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('config_add_address1', address_1);
  prefs.setString('config_add_address2', address_2);
  prefs.setString('config_add_country_addressCountry', country);
  prefs.setString('config_add_country_addressCountryId', country_id);
  prefs.setString('config_add_state_addressState', state);
  prefs.setString('config_add_state_addressStateId', state_id);
  prefs.setString('config_add_city', city);
  prefs.setString('config_add_zipCode', postal_code);
}

class _CountryDialog extends StatefulWidget {
  _CountryDialog(
      {this.selectcountry,
      this.onSelectedCountryListChanged,
      this.onSelectedCountryIdChanged,
      this.selectedCountry,
      this.selectedCountryId});

  String selectcountry = '';
  ValueChanged<List<String>> onSelectedCountryListChanged;
  ValueChanged<List<String>> onSelectedCountryIdChanged;

  final List<String> selectedCountry;
  final List<String> selectedCountryId;

  @override
  _CountryDialogState createState() => _CountryDialogState();
}

class _CountryDialogState extends State<_CountryDialog> {
  Future<List<Country>> itemList;
  String _selectcountry = '';
  List<Country> getData = new List<Country>();
  bool isLoading = false;
  List<String> _tempSelectedCountry = [];
  List<String> _tempSelectedCountryId = [];
  @override
  void initState() {
    _tempSelectedCountry = widget.selectedCountry;
    _tempSelectedCountryId = widget.selectedCountryId;
    _selectcountry = widget.selectcountry;
//    itemList = loadStaffCommunities();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // memberDataList = {} as Future<List<Merchant>>;
    itemList = loadStaffCommunities();
  }

  Future<List<Country>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('country/getcountries');

    List responseList = response['result'];

    getData = responseList.map<Country>((json) {
      return Country.fromJson(json);
    }).toList();

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 100, bottom: 100),
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
                          'Select Country',
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
                Expanded(
                  child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(height: 1),
                      shrinkWrap: true,
                      itemCount: getData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final cityName = getData[index];
                        return InkWell(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              padding: EdgeInsets.all(10),
                              child: Text(cityName.country_name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFF535353))),
                            ),
                            onTap: () async {
                              _tempSelectedCountry.add(cityName.country_name);
                              _tempSelectedCountryId
                                  .add(cityName.id.toString());
                              Navigator.of(context).pop();
                              widget.onSelectedCountryListChanged(
                                  _tempSelectedCountry);
                              widget.onSelectedCountryIdChanged(
                                  _tempSelectedCountryId);
                            });
                      }),
                ),
              ],
            ),
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}

class _StateDialog extends StatefulWidget {
  _StateDialog(
      {this.onSelectedCountryListChanged,
      this.onSelectedStateIdChanged,
      this.selectedState,
      this.selectedStateId,
      this.country_name});
  ValueChanged<List<String>> onSelectedCountryListChanged;
  ValueChanged<List<String>> onSelectedStateIdChanged;
  final List<String> selectedState;
  final List<String> selectedStateId;
  String country_name;

  @override
  _StateDialogState createState() => _StateDialogState();
}

class _StateDialogState extends State<_StateDialog> {
  Future<List<Stat>> itemList;
  List<Stat> getData = new List<Stat>();
  bool isLoading = false;
  List<String> _tempSelectedState = [];
  List<String> _tempSelectedStateId = [];
  @override
  void initState() {
    _tempSelectedState = widget.selectedState;
    _tempSelectedStateId = widget.selectedStateId;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    itemList = loadStaffCommunities();
  }

  Future<List<Stat>> loadStaffCommunities() async {
    print('loadStaffCommunities');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['country_name'] = widget.country_name;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/getStateByCountry', apiBodyObj);

    List responseList = response['result'];

    getData = responseList.map<Stat>((json) {
      return Stat.fromJson(json);
    }).toList();

    if (response['status'] == 'success') {
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

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 100, bottom: 100),
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
                          'Select State',
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
                Expanded(
                  child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(height: 1),
                      shrinkWrap: true,
                      itemCount: getData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final cityName = getData[index];
                        return InkWell(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              padding: EdgeInsets.all(10),
                              child: Text(cityName.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .apply(color: Color(0xFF535353))),
                            ),
                            onTap: () async {
                              _tempSelectedState.add(cityName.name);
                              _tempSelectedStateId.add(cityName.state_id);
                              Navigator.of(context).pop();
                              widget.onSelectedCountryListChanged(
                                  _tempSelectedState);
                              widget.onSelectedStateIdChanged(
                                  _tempSelectedStateId);
                            });
                      }),
                ),
              ],
            ),
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
