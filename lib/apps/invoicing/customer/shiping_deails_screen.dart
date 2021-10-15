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

class ShippingDetailScreen extends StatefulWidget {
  var shipping_detail;

  ShippingDetailScreen({
    Key key,
    this.shipping_detail,
  }) : super(key: key);

  @override
  _ShippingDetailScreenState createState() =>
      _ShippingDetailScreenState(shipping_detail);
}

class _ShippingDetailScreenState extends State<ShippingDetailScreen> {
  var shipping_detail;

  TextEditingController _ship_to_contactController =
      new TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _postalcodeController = TextEditingController();
  TextEditingController _selectcountryController = TextEditingController();
  TextEditingController _selectstateController = TextEditingController();
  TextEditingController _deliveryController = TextEditingController();

  bool isSwitched = false;
  String selectcountry = '';

  List<String> selectedcountry = [];
  List<String> selectedcountryid = [];
  List<String> selectedstate = [];
  List<String> selectedstateid = [];

  var countryId;
  var stateId;

  _ShippingDetailScreenState(shipping_detail) {
    this.shipping_detail = shipping_detail;
    print(shipping_detail);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      if (shipping_detail != null) {
        isSwitched = true;
        _ship_to_contactController.text = shipping_detail['shipToContact'];
        _phoneController.text = shipping_detail['phone'];
        _address1Controller.text = shipping_detail['address1'];
        _address2Controller.text = shipping_detail['address2'];
        _cityController.text = shipping_detail['city'];
        _postalcodeController.text = shipping_detail['zipCode'];
        _selectcountryController.text =
            shipping_detail['country']['shippingAddressCountry'];
        _deliveryController.text = shipping_detail['instructions'];
        countryId = shipping_detail['country']['shippingAddressCountryId'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Shipping details',
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                shipping(),
                Container(
                  child: isSwitched == true ? shippingaddress() : Container(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget shipping() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(
                'Use same info as billing',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
                activeTrackColor: kMerchantBackColor,
                activeColor: kPrimaryColor,
              ),
            )
          ],
        ),
        Divider(
          color: Color(0xFFACACAC),
          height: 10,
        ),
      ],
    ));
  }

  Widget shippingaddress() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: TextStyle(fontWeight: FontWeight.normal),
          controller: _ship_to_contactController,
          decoration: new InputDecoration(labelText: 'Ship to contact*'),
        ),
        SizedBox(
          height: 15,
        ),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: new InputDecoration(labelText: 'Phone'),
        ),
        SizedBox(
          height: 15,
        ),
        TextField(
          controller: _address1Controller,
          style: TextStyle(fontWeight: FontWeight.normal),
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
        TextField(
          controller: _cityController,
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
          controller: _deliveryController,
          style: TextStyle(fontWeight: FontWeight.normal),
          decoration: new InputDecoration(labelText: 'Delivery instructions'),
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
              if (_ship_to_contactController.text == '' ||
                  _phoneController.text == '' ||
                  _address1Controller.text == '' ||
                  _address2Controller.text == '' ||
                  _cityController.text == '' ||
                  _postalcodeController.text == '' ||
                  _selectcountryController.text == '' ||
                  _selectstateController.text == '' ||
                  _deliveryController.text == '') {
                showSimpleDialog(context,
                    title: 'Attention',
                    message: 'Plase fill all required field to continue!');
              } else {
                addStringToSF(
                    _ship_to_contactController.text,
                    _phoneController.text,
                    _address1Controller.text,
                    _address2Controller.text,
                    _cityController.text,
                    _postalcodeController.text,
                    _selectcountryController.text,
                    countryId.toString(),
                    _selectstateController.text,
                    stateId,
                    _deliveryController.text);

                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Save Shipping Details',
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

  addStringToSF(
      String ship_controller,
      String phone,
      String address_1,
      String address_2,
      String city,
      String postal_code,
      String country,
      String country_id,
      String state,
      String state_id,
      String deliver) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shipping_ship_controller', ship_controller);
    prefs.setString('shipping_phone', phone);
    prefs.setString('shipping_address_1', address_1);
    prefs.setString('shipping_address_2', address_2);
    prefs.setString('shipping_city', city);
    prefs.setString('shipping_postal_code', postal_code);
    prefs.setString('shipping_country', country);
    prefs.setString('shipping_country_id', country_id);
    prefs.setString('shipping_state', state);
    prefs.setString('shipping_state_id', state_id);
    prefs.setString('shipping_deliver', deliver);
  }
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
