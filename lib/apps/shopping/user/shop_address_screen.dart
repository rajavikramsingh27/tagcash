import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/models/address.dart';
import 'package:tagcash/apps/shopping/user/shop_edit_address_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

class ShopAddressScreen extends StatefulWidget {

  @override
  _ShopAddressScreenState createState() => _ShopAddressScreenState();
}

class _ShopAddressScreenState extends State<ShopAddressScreen> {

  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();

  List<Address> getAddressData = new List<Address>();

  @override
  void initState() {
    super.initState();
    getAddressList();
  }

  void getAddressList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/GetAddress');

    if (response['status'] == 'success') {
      if(response['list'] != null){

        List responseList = response['list'];
        if(responseList!= null){
          getAddressData = responseList.map<Address>((json) {
            return Address.fromJson(json);
          }).toList();

          setState(() {
            isLoading = false;
          });

        }
      } else{
      }

    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']);
    }
  }

  void addAddress() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = nameController.text;
    apiBodyObj['address'] = addressController.text;
    apiBodyObj['phone'] = phoneController.text;
    apiBodyObj['postal_code'] = postalCodeController.text;
    apiBodyObj['city'] = cityController.text;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/AddAddress', apiBodyObj);

    if (response['status'] == 'success') {
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      cityController.clear();
      postalCodeController.clear();
      setState(() {
        isLoading = false;
      });
      getAddressList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteAddress(String id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/DeleteAddress', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getAddressList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void markAddress(String id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/MarkAddressAsDefault', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
              'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text('TAG Shopping'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home_outlined,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Add Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.sentences,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter
                                ],
                                decoration: InputDecoration(
                                  labelText:
                                  "Name", //getTranslated(context, 'amount'),
                                ),
                              ),

                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText:
                                  "Phone", //getTranslated(context, 'amount'),
                                ),
                              ),

                              TextFormField(
                                controller: addressController,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.sentences,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter
                                ],
                                decoration: InputDecoration(
                                  labelText:
                                  "Address", //getTranslated(context, 'amount'),
                                ),
                              ),

                              Row(
                                children: [
                                  Flexible(
                                    flex:2,
                                    child: Container(
                                      child: TextFormField(
                                        controller: cityController,
                                        keyboardType: TextInputType.text,
                                        textCapitalization: TextCapitalization.sentences,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .singleLineFormatter
                                        ],
                                        decoration: InputDecoration(
                                          labelText:
                                          "City", //getTranslated(context, 'amount'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex:1,
                                    child: Container(
                                      child: TextFormField(
                                        controller: postalCodeController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          labelText:
                                          "ZIP/PC", //getTranslated(context, 'amount'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 3,
                                        child:Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: FlatButton(
                                            onPressed: () async {
                                              FocusScope.of(context).unfocus();
                                              if(nameController.text == ''){
                                                showSimpleDialog(context,
                                                    title: 'Attention',
                                                    message: 'Name required.');
                                              }else if(phoneController.text == ''){
                                                showSimpleDialog(context,
                                                    title: 'Attention',
                                                    message: 'Phone required.');
                                              }else if(addressController.text == ''){
                                                showSimpleDialog(context,
                                                    title: 'Attention',
                                                    message: 'Address required.');
                                              }else if(cityController.text == ''){
                                                showSimpleDialog(context,
                                                    title: 'Attention',
                                                    message: 'City required.');
                                              }else if(postalCodeController.text == ''){
                                                showSimpleDialog(context,
                                                    title: 'Attention',
                                                    message: 'Postal Code required.');
                                              } else{
                                                addAddress();
                                              }

                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(3.0),
                                              side: BorderSide(
                                                  color: Theme.of(context).primaryColor),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text(
                                                "ADD",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              )

                            ],
                          )
                      ),

                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: getAddressData.length,
                          itemBuilder: (context, i){
                            return InkWell(
                              onTap: (){
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex:5,
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                child:Text(
                                                  getAddressData[i].name + '\n'
                                                      + getAddressData[i].phone + '\n'
                                                      + getAddressData[i].address + '\n'
                                                      + getAddressData[i].city + '\n',
                                                  maxLines: 5,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(context,
                                                            MaterialPageRoute(builder: (context) => ShopEditAddressScreen(addressId: getAddressData[i].id, editName: getAddressData[i].name, editPhone: getAddressData[i].phone,
                                                                editAddress: getAddressData[i].address, editCity: getAddressData[i].city, editPostalCode: getAddressData[i].postal_code)
                                                            )).then((val)=>val? getAddressList():null);
                                                        },
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 25.0,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Widget cancelButton = FlatButton(
                                                            child: Text("No"),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          );
                                                          Widget continueButton = FlatButton(
                                                            child: Text("Yes"),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                              deleteAddress(getAddressData[i].id);
                                                            },
                                                          );

                                                          AlertDialog alert = AlertDialog(
                                                            title: Text(""),
                                                            content: Text('Are you sure you want to delete this address?'),
                                                            actions: [
                                                              continueButton,
                                                              cancelButton,

                                                            ],
                                                          );
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return alert;
                                                            },
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 25.0,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            markAddress(getAddressData[i].id);
                                          },
                                          child: Text(
                                            'CHOOSE ADDRESS ',
                                            maxLines: 5,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )

                                      ],
                                    ),
                                  ),
                                ),
                              )
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
}
