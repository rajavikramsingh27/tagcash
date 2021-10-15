import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/models/address.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

class ShopEditAddressScreen extends StatefulWidget {
  final String addressId, editName, editPhone, editAddress, editCity, editPostalCode;

  const ShopEditAddressScreen({Key key, this.addressId, this.editName, this.editPhone, this.editAddress, this.editCity, this.editPostalCode}) : super(key: key);

  @override
  _ShopEditAddressScreenState createState() => _ShopEditAddressScreenState();
}

class _ShopEditAddressScreenState extends State<ShopEditAddressScreen> {

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

    nameController.text = widget.editName;
    phoneController.text = widget.editPhone;
    addressController.text = widget.editAddress;
    cityController.text = widget.editCity;
    postalCodeController.text = widget.editPostalCode;

  }

  void editAddress() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.addressId;
    apiBodyObj['name'] = nameController.text;
    apiBodyObj['address'] = addressController.text;
    apiBodyObj['phone'] = phoneController.text;
    apiBodyObj['postal_code'] = postalCodeController.text;
    apiBodyObj['city'] = cityController.text;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/UpdateAddress', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: const Text('Address updated successfully.'),
            actions: [
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
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
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        'Edit Address',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      Container(
                          child: Column(
                            children: [
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
                              SizedBox(height: 20),
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
                              SizedBox(height: 20),
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
                              SizedBox(height: 20),
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
                              SizedBox(height: 50),
                              Container(
                                child: Row(
                                  children: [

                                    Flexible(
                                        flex: 2,
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
                                                editAddress();
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
                                                "UPDATE",
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
