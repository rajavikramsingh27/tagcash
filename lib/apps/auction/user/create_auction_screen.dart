import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/auction/components/custom_drop_down.dart';
import 'package:tagcash/apps/auction/models/auctioncategory.dart';
import 'package:tagcash/apps/auction/models/fees.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class CreateAuctionScreen extends StatefulWidget {
  @override
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  bool isLoading = false, isImage = false;
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  TextEditingController _bidController = TextEditingController();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _reservePriceController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _daysController = TextEditingController();
  TextEditingController _hoursController = TextEditingController();

  bool now = true;
  String auctionNow = '1';

  List<AuctionCategory> getAuctionCategoryList = new List<AuctionCategory>();
  List<CustomDropdownMenuItem<AuctionCategory>> _dropdownMenuItems1;
  List<AuctionCategory> categoryData = [];
  AuctionCategory _selectedAuctionCategory;

  List<Wallet> walletData = [];
  List<CustomDropdownMenuItem<Wallet>> _dropdownMenuItems2;
  Wallet _selectedCurrency;

  int start_hour, end_hour;

  List<CustomDropdownMenuItem<Fees>> _dropdownMenuItems;
  Fees _selectedFees;
  List<Fees> _fees = Fees.getDelivery();

//  Images
  File imageFile;
  List<String> _logoList = [];
  List<String> _logoUrlList = [];
  int logoindex;
  String bidding_fees_by;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bidController.text = '0.01';
    List<CustomDropdownMenuItem<Fees>> buildDropdownMenuItems(
        List companies) {
      List<CustomDropdownMenuItem<Fees>> items = List();
      for (Fees company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(
              company.name,
              style: TextStyle(fontSize: 14),
            ),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems = buildDropdownMenuItems(_fees);
    _selectedFees = _dropdownMenuItems[0].value;

    getAuctionCategory();
    getWalletData();
  }


  void getAuctionCategory() async {
    getAuctionCategoryList.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['app_id'] = '6';

    Map<String, dynamic> response =
        await NetworkHelper.request('Auction/GetAuctionCategories', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getAuctionCategoryList = responseList.map<AuctionCategory>((json) {
        return AuctionCategory.fromJson(json);
      }).toList();

      categoryData = getAuctionCategoryList;
      List<CustomDropdownMenuItem<AuctionCategory>> buildDropdownMenuItems(
          List companies) {
        List<CustomDropdownMenuItem<AuctionCategory>> items = List();
        for (AuctionCategory company in companies) {
          items.add(
            CustomDropdownMenuItem(
              value: company,
              child: Text(
                company.category_name,
              ),
            ),
          );
        }
        return items;
      }

      _dropdownMenuItems1 = buildDropdownMenuItems(categoryData);
      _selectedAuctionCategory = _dropdownMenuItems1[0].value;

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<List<Wallet>> getWalletData () async{
    setState(() {
      isLoading = true;
    });
    print('============================getting wallets============================');
    if(walletData.length==0) {
      Map<String, dynamic> response = await NetworkHelper.request(
          'wallet/list');

      if (response["status"] == "success") {
        setState(() {
          isLoading = false;
        });
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletData = getData;

        List<CustomDropdownMenuItem<Wallet>> buildDropdownMenuItems(
            List companies) {
          List<CustomDropdownMenuItem<Wallet>> items = List();
          for (Wallet company in companies) {
            items.add(
              CustomDropdownMenuItem(
                value: company,
                child: Text(
                  company.currencyCode,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            );
          }
          return items;
        }

        _dropdownMenuItems2 = buildDropdownMenuItems(walletData);
        _selectedCurrency = _dropdownMenuItems2[0].value;

        return getData;
      }
    }
    return walletData;
  }

  void createAuctionData(String auctionStartDate, String auctionStartTime, String currencyCode,
      String itemCategory, String startNow, String bidding_fees_by, String bidding_fees) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = _nameController.text;
    apiBodyObj['description'] = _descriptionController.text;
    apiBodyObj['reserve_price'] = _reservePriceController.text;
    apiBodyObj['auction_start_date'] = auctionStartDate;
    apiBodyObj['auction_start_time'] = auctionStartTime;
    apiBodyObj['auction_duration_days'] = _daysController.text;
    apiBodyObj['auction_duration_hours'] = _hoursController.text;
    apiBodyObj['currency_code'] = currencyCode;
    apiBodyObj['item_category'] = itemCategory;
    apiBodyObj['start_now'] = startNow;
    apiBodyObj['bidding_fees_by'] = bidding_fees_by;
    apiBodyObj['bidding_fees'] = bidding_fees;


    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/create', apiBodyObj);
    if (response['status'] == 'success') {
      String id = response['auction_id'].toString();
      if(_logoList.length != 0){
        for(int i = 0; i < _logoList.length; i++){
          uploadImage(id,_logoList[i]);
        }
      }
      setState(() {
        Timer(Duration(seconds: 5), () {
          isLoading = false;
          Navigator.pop(context, true);
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadImage(id, image) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['auction_id'] = id;
    apiBodyObj['image'] = image;

    Map<String, dynamic> response =
    await NetworkHelper.request('auction/Uploadimage', apiBodyObj);

    if (response['status'] == 'success') {
      print('upload_image' + response['status']);

    } else {

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'AUCTIONS',
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: enableAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Stack(
          children: [
            Container(
              child:SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                        leading: Icon(Icons.add_circle_outlined,
                            size: 28, color: Colors.green),
                        title: Align(
                          child: Text('Add Auction Images',
                              style: Theme.of(context).textTheme.subtitle1.apply()),
                          alignment: Alignment(-1.2, 0),
                        ),
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  showdiag(context, selectedImageContent(_getLogoFromGallary), '0'));
                        },
                      ),
                      _logoUrlList.length != 0?
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _logoList.length,
                        itemBuilder: (BuildContext context, int index){
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: getLogo(_logoUrlList[index]),
                              ),
                            ),
                            width: 60.0,
                            height: 60.0,
                            child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  width:20,
                                  height:20,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel, color: kPrimaryColor),
                                    onPressed: () {
                                      setState(() {
                                        _logoList.removeAt(index);
                                        _logoUrlList.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                        ),

                      ):Container(),
                      _logoUrlList.length != 0?
                      SizedBox(height: 20):Container(),
                      Container(
                          decoration: new BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CustomDropdownButton(
                                  isExpanded: true,
                                  value: _selectedAuctionCategory,
                                  items: _dropdownMenuItems1,
                                  hint: Container(
                                      child: Text('Category')),
                                  underline: Container(),
                                  onChanged: (val) {
                                    FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                    if (currentFocus.canRequestFocus) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    }
                                    setState(() {
                                      _selectedAuctionCategory = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          decoration: new BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CustomDropdownButton(
                                  isExpanded: true,
                                  value: _selectedCurrency,
                                  items: _dropdownMenuItems2,
                                  hint: Container(
                                      child: Text('PHP')),
                                  underline: Container(),
                                  onChanged: (val) {
                                    FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                    if (currentFocus.canRequestFocus) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    }
                                    setState(() {
                                      _selectedCurrency = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: Container(
                                  decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFFACACAC), width: 0.5),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  width: MediaQuery.of(context).size.width,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        CustomDropdownButton(
                                          isExpanded: true,
                                          value: _selectedFees,
                                          items: _dropdownMenuItems,
                                          hint: Container(
                                              child: Text('Category')),
                                          underline: Container(),
                                          onChanged: (val) {
                                            FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                            if (currentFocus.canRequestFocus) {
                                              FocusScope.of(context)
                                                  .requestFocus(new FocusNode());
                                            }
                                            setState(() {
                                              _selectedFees = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  controller: _bidController,
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 20),
                                    hintText: "0.01",
                                    hintStyle: TextStyle(
                                        fontSize: 18.0, color: Color(0xFFACACAC)),
                                  ),
                                  validator: (value) {
                                    if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                                      return 'Value required';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.normal),
                                ),
                            ),)
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20),
                          hintText: "Name",
                          hintStyle:
                          TextStyle(fontSize: 18.0, color: Color(0xFFACACAC)),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                            return 'Name required';
                          }
                          return null;
                        },
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),

                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20),
                          hintText: "Description",
                          hintStyle:
                          TextStyle(fontSize: 18.0, color: Color(0xFFACACAC)),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                            return 'Description required';
                          }
                          return null;
                        },
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _reservePriceController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 20),
                          hintText: "Reserve price (0 if none)",
                          hintStyle:
                          TextStyle(fontSize: 18.0, color: Color(0xFFACACAC)),
                        ),
                        validator: (value) {
                          if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                            return 'Reserve price required';
                          }
                          return null;
                        },
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Auction Start',
                              style: Theme.of(context).textTheme.subtitle1.apply()),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    activeColor: kPrimaryColor,
                                    value: now,
                                    onChanged: (val) {
                                      setState(() {
                                        now = val;
                                        if (now == true) {
                                          auctionNow = '1';
                                        } else {
                                          auctionNow = '0';
                                        }
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Now',
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      auctionNow == '0'?
                      SizedBox(height: 10) : Container(),
                      auctionNow == '0'?
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _startDateController,
                                readOnly: true,
                                enableInteractiveSelection: true,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20),
                                  hintText: "Start Date",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Color(0xFFACACAC)),
                                ),
                                validator: (value) {
                                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                                    return 'Start Date required';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                                onTap: () {
                                  _showDatePicker();
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                readOnly: true,
                                enableInteractiveSelection: true,
                                controller: _startTimeController,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20),
                                  hintText: "Start Time",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Color(0xFFACACAC)),
                                ),
                                validator: (value) {
                                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                                    return 'Start Time required';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                                onTap: () {
                                  _showStartTimePicker();
                                },
                              ),
                            ),
                          )
                        ],
                      ):Container(),
                      SizedBox(height: 45),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Auction Duration',
                            style: Theme.of(context).textTheme.subtitle1.apply()),
                      ]),
                      SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _daysController,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20),
                                  hintText: "Days",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Color(0xFFACACAC)),
                                ),
                                validator: (value) {
                                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                                    return 'Days required';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _hoursController,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20),
                                  hintText: "Hours",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Color(0xFFACACAC)),
                                ),
                                validator: (value) {
                                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                                    return 'Hours required';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width,
                        child: FlatButton(
                          onPressed: () async {
                            setState(() {
                              enableAutoValidate = true;
                            });
                            if (_formKey.currentState.validate()) {
                              if(_selectedFees.name == 'Bidding Fee Paid by Buyer'){
                                bidding_fees_by = 'buyer';
                              }else{
                                bidding_fees_by = 'seller';
                              }
                              if(auctionNow == '1'){
                                DateTime now = DateTime.now();
                                String formattedDate = DateFormat('dd-MM-yyyy').format(now);
                                String formattedTime = DateFormat('kk:mm').format(now);
                                print(formattedDate);
                                print(formattedTime);

                                createAuctionData(formattedDate, formattedTime, _selectedCurrency.currencyCode, _selectedAuctionCategory.id, auctionNow, bidding_fees_by,_bidController.text);
                              } else{
                                createAuctionData(_startDateController.text, _startTimeController.text, _selectedCurrency.currencyCode,  _selectedAuctionCategory.id, auctionNow, bidding_fees_by,_bidController.text);
                              }

                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          child: Container(
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: Text(
                              "CREATE",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      )
    );
  }

  getLogo(String url){
    if(url!=null && url!=''){
      return url != null
          ? FileImage(File(url))
          :NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }else{
      return NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }
  }

  _showDatePicker() async {
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 0)),
        lastDate: DateTime(2100));
    int dd = picker.day;
    String ddd;
    if (dd < 9) {
      ddd = '0' + dd.toString();
    } else {
      ddd = dd.toString();
    }

    int mm = picker.month;
    String mmm;
    if (mm < 9) {
      mmm = '0' + mm.toString();
    } else {
      mmm = mm.toString();
    }

    int yy = picker.year;
    setState(() {
      _startDateController.text = '$ddd-$mmm-$yy';
    });
  }

  _showStartTimePicker() async {
    var picker =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
        start_hour = picker.hour;
        _startTimeController.text = _addLeadingZeroIfNeeded(picker.hour) +
            ':' +
            _addLeadingZeroIfNeeded(picker.minute);

    });
  }

  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10) return '0$value';
    return value.toString();
  }

  Widget showdiag(BuildContext context, data, String dialogType) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: dialogType == '0'?
        dialogContent(context, data)
            : data,
      ),
    );
  }

  Widget dialogContent(BuildContext context, data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: data,
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectedImageContent(call) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              "Select Image",//getTranslated(context, 'select_image'),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Center(
            child: SizedBox(
              width: 40,
              height: 2.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: (){
                call("camera");
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Take a pic",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: (){
                call();
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Select Picture",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height:20.0),
        ],
      ),
    );
  }
  Future<void> _getLogoFromGallary([type]) async {
    var selectedLogo;
    if(type=="camera"){
      selectedLogo = await ImagePicker().getImage(
        source: ImageSource.camera,
      );
    }else{
      selectedLogo = await ImagePicker().getImage(
        source: ImageSource.gallery,
      );
    }

    if (selectedLogo != null) {
      setState(() {
        _cropImage(selectedLogo.path, selectedLogo);
      });
    }

  }

  Future<Null> _cropImage(String path, var selectedImage) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        /*   aspectRatioPresets: Platform.isAndroid
            ? [
         *//* CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,*//*
          CropAspectRatioPreset.ratio16x9
        ]
            : [
        *//*  CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9*//*
          CropAspectRatioPreset.ratio16x9
        ],*/
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

      print(decodedImage.width);
      print(decodedImage.height);

      List<int> imageBytes = imageFile.readAsBytesSync();

      String imageB64 = base64Encode(imageBytes);

      setState(() {
        isImage = true;
        _logoList.add(imageB64);
        _logoUrlList.add(imageFile.path);
//        _logoList.insert(logoindex, img2base64(imageFile));
//        _logoUrlList.insert(logoindex, imageFile.path);
      });
      print(File(imageFile.path).readAsBytes());
    }
  }

  img2base64(image){
    File imageFile = new File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

}
