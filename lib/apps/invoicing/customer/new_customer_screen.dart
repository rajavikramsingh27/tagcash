import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/customer/shiping_deails_screen.dart';
import 'package:tagcash/apps/invoicing/models/search_merchant.dart';
import 'package:tagcash/apps/invoicing/models/search_user.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'add_address_screen.dart';

class NewCustomerScreen extends StatefulWidget {
  @override
  _NewCustomerScreenState createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends State<NewCustomerScreen> {
  FocusNode focusNode = FocusNode();

  var type = 'merchant';
  String radioItem = '';
  String radioButtonItem = 'merchant';

  // Group Value for Radio Button.
  int id = 1;

  TextEditingController _merchant_IdController = TextEditingController();
  TextEditingController _CustomerController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _accountnumberController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();

  var morefield = 'no';
  bool isLoading = false;
  String add_address_1,
      add_address_2,
      add_country,
      add_country_id,
      add_state,
      add_state_id,
      add_city,
      add_postal_code;

  String shipping_shipcontroller,
      shipping_phone,
      shipping_address_1,
      shipping_address_2,
      shipping_city,
      shipping_postal_code,
      shipping_country,
      shipping_country_id,
      shipping_state,
      shipping_state_id,
      shipping_deliver;
  var addressed;
  var shippingdetail;

  List<String> userId = [];
  List<String> userName = [];
  List<String> userEmail = [];
  List<String> userMobile = [];
  List<String> userType = [];

  getAddressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    add_address_1 = prefs.getString('address_address_1');
    add_address_2 = prefs.getString('address_address_2');
    add_country = prefs.getString('address_country');
    add_country_id = prefs.getString('address_country_id');
    add_state = prefs.getString('address_state');
    add_state_id = prefs.getString('address_state_id');
    add_city = prefs.getString('address_city');
    add_postal_code = prefs.getString('address_postal_code');

    print(add_address_1);
    print(add_address_2);
    print(add_country);
    print(add_country_id);
    print(add_state);
    print(add_state);
    print(add_city);
    print(add_postal_code);

    return add_address_2;
  }

  getShippingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    shipping_shipcontroller = prefs.getString('shipping_ship_controller');
    shipping_phone = prefs.getString('shipping_phone');
    shipping_address_1 = prefs.getString('shipping_address_1');
    shipping_address_2 = prefs.getString('shipping_address_2');
    shipping_city = prefs.getString('shipping_city');
    shipping_postal_code = prefs.getString('shipping_postal_code');
    shipping_country = prefs.getString('shipping_country');
    shipping_country_id = prefs.getString('shipping_country_id');
    shipping_state = prefs.getString('shipping_state');
    shipping_state_id = prefs.getString('shipping_state_id');
    shipping_deliver = prefs.getString('shipping_deliver');

    print(shipping_shipcontroller);

    return shipping_shipcontroller;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void addCustomerPressed() async {
    setState(() {
      isLoading = true;
    });

    if (add_address_1 == null) {
      addressed = '';
    } else {
      addressed =
          '{"address1" : "$add_address_1", "address2" : "$add_address_2",  "country": {"addressCountry": "$add_country","addressCountryId": $add_country_id},"state": {"addressState": "$add_state","addressStateId": "$add_state_id"},"city": "$add_city","zipCode": "$add_postal_code"}';
    }

    if (shipping_shipcontroller == null) {
      shippingdetail = '';
    } else {
      shippingdetail =
          '{"address1" : "$shipping_address_1", "address2" : "$shipping_address_2",  "country": {"shippingAddressCountry": "$shipping_country","shippingAddressCountryId": $shipping_country_id},"city": "$shipping_city","zipCode": "$shipping_postal_code","shipToContact": "$shipping_shipcontroller","phone": "$shipping_phone","instructions": "$shipping_deliver"}';
    }

    Map<String, String> apiBodyObj = {};
    apiBodyObj['customer_name'] = _CustomerController.text;
    apiBodyObj['email'] = _emailController.text;
    apiBodyObj['contact_name'] = _contactController.text;
    apiBodyObj['phone_no'] = _phoneController.text;
    apiBodyObj['mobile_no'] = _mobileController.text;
    apiBodyObj['address'] = addressed;
    apiBodyObj['shipping_details'] = shippingdetail;
    apiBodyObj['accounting_number'] = _accountnumberController.text;
    apiBodyObj['website'] = _websiteController.text;
    apiBodyObj['merchant_id'] = _merchant_IdController.text;
    apiBodyObj['type'] = radioButtonItem;

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/AddCustomer', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      Navigator.pop(context, true);
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
        appBar: AppBar(
          title: Text('New Customer'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
              ),
              onPressed: () {
                if (radioButtonItem == 'merchant') {
                  if (_merchant_IdController.text == '' ||
                      _CustomerController.text == '' ||
                      _emailController.text == '' ||
                      _contactController.text == '' ||
                      _phoneController.text == '') {
                    showSimpleDialog(context,
                        title: 'Attention',
                        message: 'Plase fill all required field to continue!');
                  } else {
                    addCustomerPressed();
                  }
                } else {
                  if (_CustomerController.text == '' ||
                      _emailController.text == '' ||
                      _contactController.text == '' ||
                      _phoneController.text == '') {
                    showSimpleDialog(context,
                        title: 'Attention',
                        message: 'Plase fill all required field to continue!');
                  } else {
                    addCustomerPressed();
                  }
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(child: merchantModule()),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Widget merchantModule() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
            child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: kMerchantBackColor,
                    ), //set the dark theme or write your own theme
                    child: Row(
                      children: <Widget>[
                        Radio(
                          activeColor: kMerchantBackColor,
                          value: 1,
                          groupValue: id,
                          onChanged: (val) {
                            setState(() {
                              radioButtonItem = 'merchant';
                              id = 1;
                            });
                          },
                        ),
                        Text(
                          'Business/TagCash User',
                          style: new TextStyle(fontSize: 13.0),
                        ),
                        Radio(
                          activeColor: kMerchantBackColor,
                          value: 2,
                          groupValue: id,
                          onChanged: (val) {
                            setState(() {
                              radioButtonItem = 'other';
                              id = 2;
                            });
                          },
                        ),
                        Text(
                          'Other User',
                          style: new TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    radioButtonItem == 'merchant'
                        ? Stack(
                            alignment: Alignment.centerRight,
                            children: <Widget>[
                              TextField(
                                focusNode: focusNode,
                                controller: _merchant_IdController,
                                decoration: InputDecoration(
                                  labelText: 'Business ID, email or address',
                                  icon: Icon(Icons.person),
                                ),
                                style: TextStyle(
                                    color: kUserBackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                              IconButton(
                                  icon: FaIcon(FontAwesomeIcons.search,
                                      color: Color(0xFF535353), size: 18),
                                  onPressed: () {
                                    var str_Id,
                                        str_Name,
                                        str_Email,
                                        str_Mobile,
                                        str_Type;
                                    focusNode.unfocus();
                                    focusNode.canRequestFocus = false;
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return _UserDialog(
                                            id: userId,
                                            name: userName,
                                            email: userEmail,
                                            mobile: userMobile,
                                            type: userType,
                                            onSelectedidChanged: (id) {
                                              userId = id;
                                              str_Id = userId.reduce(
                                                  (value, element) =>
                                                      value + element);
                                            },
                                            onSelectednameChanged: (name) {
                                              userName = name;
                                              str_Name = userName.reduce(
                                                  (value, element) =>
                                                      value + element);
                                            },
                                            onSelectedemailChanged: (email) {
                                              userEmail = email;
                                              str_Email = userEmail.reduce(
                                                  (value, element) =>
                                                      value + element);
                                            },
                                            onSelectedmobileChanged: (mobile) {
                                              userMobile = mobile;
                                              str_Mobile = userMobile.reduce(
                                                  (value, element) =>
                                                      value + element);
                                            },
                                            onSelectedtypeChanged: (type) {
                                              userType = type;
                                              str_Type = userType.reduce(
                                                  (value, element) =>
                                                      value + element);

                                              setState(() {
                                                radioButtonItem = str_Type;
                                                _merchant_IdController.text =
                                                    str_Id;
                                                _CustomerController.text =
                                                    str_Name;
                                                _contactController.text =
                                                    str_Name;
                                                _emailController.text =
                                                    str_Email;
                                                if (str_Mobile != 'null') {
                                                  _mobileController.text =
                                                      str_Mobile;
                                                }
                                              });
                                            },
                                          );
                                        });
//                          FocusScope.of(context).unfocus();
                                    focusNode.canRequestFocus = true;
                                  }),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 10),
                    TextField(
                      controller: _CustomerController,
                      decoration: InputDecoration(
                        labelText: 'Customer*',
                        icon: Icon(Icons.account_circle),
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(left: 40),
                      child: Text(
                        'Business or person',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: Color(0xFFACACAC)),
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email*',
                        icon: Icon(Icons.email),
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Name*',
                        icon: Icon(Icons.person),
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Phone*',
                        icon: Icon(Icons.call),
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Mobile',
                        icon: Icon(Icons.call),
                      ),
                      style: TextStyle(
                          color: kUserBackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    Container(
                      child: morefield == 'yes'
                          ? address()
                          : GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 40, top: 10),
                                child: Text(
                                  'MORE FIELDS',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff203354),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  morefield = 'yes';
                                });
                              },
                            ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, top: 10),
                      child: Text(
                        '* Indicats required field',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: Color(0xFFACACAC)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget address() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Divider(),
          ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Align(
                child: Text(
                  "Address",
                  style: TextStyle(
                      color: Color(0xff203354),
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
                ),
                alignment: Alignment(-1.1, 0),
              ),
              leading: Icon(Icons.location_on),
              onTap: () async {
                FocusScope.of(context).unfocus();
                Navigator.of(context)
                    .push(
                      new MaterialPageRoute(
                          builder: (context) => AddAddressScreen()),
                    )
                    .then((val) => val ? getAddressData() : null);
              }),
          Divider(
            color: Color(0xFFACACAC),
            height: 10,
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Align(
              child: Text(
                "Shipping details",
                style: TextStyle(
                    color: Color(0xff203354),
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
              alignment: Alignment(-1.1, 0),
            ),
            leading: Icon(Icons.local_shipping),
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context)
                  .push(
                    new MaterialPageRoute(
                        builder: (context) => ShippingDetailScreen()),
                  )
                  .then((val) => val ? getShippingData() : null);
            },
          ),
          Divider(
            color: Color(0xFFACACAC),
            height: 10,
          ),
          TextField(
            controller: _accountnumberController,
            decoration: InputDecoration(
              labelText: 'Accounting number',
              icon: FaIcon(FontAwesomeIcons.infoCircle),
            ),
            style: TextStyle(
                color: kUserBackColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
          TextField(
            controller: _websiteController,
            decoration: InputDecoration(
              labelText: 'Website',
              icon: FaIcon(FontAwesomeIcons.globe),
            ),
            style: TextStyle(
                color: kUserBackColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

class _UserDialog extends StatefulWidget {
  _UserDialog({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.type,
    this.onSelectedidChanged,
    this.onSelectednameChanged,
    this.onSelectedemailChanged,
    this.onSelectedmobileChanged,
    this.onSelectedtypeChanged,
  });

  final List<String> id;
  final List<String> name;
  final List<String> email;
  final List<String> mobile;
  final List<String> type;

  final ValueChanged<List<String>> onSelectedidChanged;
  final ValueChanged<List<String>> onSelectednameChanged;
  final ValueChanged<List<String>> onSelectedemailChanged;
  final ValueChanged<List<String>> onSelectedmobileChanged;
  final ValueChanged<List<String>> onSelectedtypeChanged;

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  List<String> _tempSelectedId = [];
  List<String> _tempSelectedName = [];
  List<String> _tempSelectedEmail = [];
  List<String> _tempSelectedMobile = [];
  List<String> _tempSelectedType = [];

  @override
  void initState() {
    _tempSelectedId = widget.id;
    _tempSelectedName = widget.name;
    _tempSelectedEmail = widget.email;
    _tempSelectedMobile = widget.mobile;
    _tempSelectedType = widget.type;
    super.initState();
  }

  bool isLoading = false;
  String radioButtonItem = 'user';
  int id = 1;
  TextEditingController _searchuser_IdController = TextEditingController();
  TextEditingController _searchmerchant_IdController = TextEditingController();

  List<Search_User> getSerachUserData = new List<Search_User>();
  List<Search_Merchant> getSerachMerchantData = new List<Search_Merchant>();
  Future<List<Search_User>> userList;
  Future<List<Search_Merchant>> merchantList;

  Future<List<Search_User>> loadUser() async {
    print('loadStaffCommunities');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _searchuser_IdController.text;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    List responseList = response['result'];

    getSerachUserData = responseList.map<Search_User>((json) {
      return Search_User.fromJson(json);
    }).toList();

    if (response['status'] == 'success') {
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

    return getSerachUserData;
  }

  Future<List<Search_Merchant>> loadMerchant() async {
    print('loadStaffCommunities');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _searchmerchant_IdController.text;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    List responseList = response['result'];

    getSerachMerchantData = responseList.map<Search_Merchant>((json) {
      return Search_Merchant.fromJson(json);
    }).toList();

    if (response['status'] == 'success') {
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

    return getSerachMerchantData;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 50, bottom: 50),
          child: Dialog(
            insetPadding:
                EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 9,
                        child: Container(
                            margin: EdgeInsets.only(left: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                radioButtonItem == 'user'
                                    ? Text(
                                        'User ID, email or name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: kMerchantBackColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        'Business ID or Name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: kMerchantBackColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                              ],
                            )),
                      ),
                      Flexible(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            color: kMerchantBackColor,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: kMerchantBackColor,
                        ), //set the dark theme or write your own theme
                        child: Row(
                          children: <Widget>[
                            Radio(
                              activeColor: kMerchantBackColor,
                              value: 1,
                              groupValue: id,
                              onChanged: (val) {
                                setState(() {
                                  radioButtonItem = 'user';
                                  id = 1;
                                });
                              },
                            ),
                            Text(
                              'USER',
                              style: new TextStyle(fontSize: 14.0),
                            ),
                            Radio(
                              activeColor: kMerchantBackColor,
                              value: 2,
                              groupValue: id,
                              onChanged: (val) {
                                setState(() {
                                  radioButtonItem = 'merchant';
                                  id = 2;
                                });
                              },
                            ),
                            Text(
                              'BUSINESS',
                              style: new TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 20),
                  child: radioButtonItem == 'user'
                      ? TextField(
                          controller: _searchuser_IdController,
                          decoration: InputDecoration(
                              labelText: 'User ID, email or name',
                              suffixIcon: IconButton(
                                icon: FaIcon(FontAwesomeIcons.search,
                                    color: Color(0xFF535353), size: 18),
                                onPressed: () {
                                  if (_searchuser_IdController.text != '') {
                                    FocusScope.of(context).unfocus();
                                    userList = loadUser();
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              )),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )
                      : TextField(
                          controller: _searchmerchant_IdController,
                          decoration: InputDecoration(
                              labelText: 'Business ID or Name',
                              suffixIcon: IconButton(
                                icon: FaIcon(FontAwesomeIcons.search,
                                    color: Color(0xFF535353), size: 18),
                                onPressed: () {
                                  if (_searchmerchant_IdController.text != '') {
                                    FocusScope.of(context).unfocus();
                                    merchantList = loadMerchant();
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              )),
                          style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                ),
                Expanded(
                  child: radioButtonItem == 'user'
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: getSerachUserData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final user = getSerachUserData[index];
                            return InkWell(
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: kPrimaryColor,
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  new Radius.circular(2.0))),
                                          padding: EdgeInsets.all(5),
                                          child: FaIcon(
                                              FontAwesomeIcons.solidUser,
                                              size: 24,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(user.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .apply(
                                                      color:
                                                          Color(0xFF535353))),
                                        )),
                                      ],
                                    )),
                                onTap: () async {
                                  _tempSelectedId.add(user.id.toString());
                                  _tempSelectedName.add(user.name);
                                  _tempSelectedEmail.add(user.user_email);
                                  _tempSelectedMobile
                                      .add(user.user_mobile.toString());
                                  _tempSelectedType.add(radioButtonItem);
                                  widget.onSelectedidChanged(_tempSelectedId);
                                  widget
                                      .onSelectednameChanged(_tempSelectedName);
                                  widget.onSelectedemailChanged(
                                      _tempSelectedEmail);
                                  widget.onSelectedmobileChanged(
                                      _tempSelectedMobile);
                                  widget
                                      .onSelectedtypeChanged(_tempSelectedType);
                                  Navigator.of(context).pop();
                                });
                          })
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: getSerachMerchantData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final user = getSerachMerchantData[index];
                            return InkWell(
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: new BoxDecoration(
                                              color: kPrimaryColor,
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  new Radius.circular(2.0))),
                                          padding: EdgeInsets.all(5),
                                          child: FaIcon(FontAwesomeIcons.users,
                                              size: 24, color: Colors.white),
//                                  child: Icon(Icons.person, size: 24, color: Colors.white,),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                            child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(user.community_name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .apply(
                                                      color:
                                                          Color(0xFF535353))),
                                        )),
                                      ],
                                    )),
                                onTap: () async {
                                  _tempSelectedId.add(user.id.toString());
                                  _tempSelectedName.add(user.community_name);
                                  _tempSelectedEmail.add('');
                                  _tempSelectedMobile.add('');
                                  _tempSelectedType.add(radioButtonItem);

                                  widget.onSelectedidChanged(_tempSelectedId);
                                  widget
                                      .onSelectednameChanged(_tempSelectedName);
                                  widget.onSelectedemailChanged(
                                      _tempSelectedEmail);
                                  widget.onSelectedmobileChanged(
                                      _tempSelectedMobile);
                                  widget
                                      .onSelectedtypeChanged(_tempSelectedType);
                                  Navigator.of(context).pop();
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
