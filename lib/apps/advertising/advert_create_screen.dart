import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/advertising/advert_pick_location_screen.dart';
import 'package:tagcash/apps/advertising/models/advert.dart';
import 'package:tagcash/apps/advertising/models/advert_price.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/image_select_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:location/location.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

enum AdType { image, video }

class AdvertCreateScreen extends StatefulWidget {
  final Advert advert;

  const AdvertCreateScreen({Key key, this.advert}) : super(key: key);

  @override
  _AdvertCreateScreenState createState() => _AdvertCreateScreenState();
}

class _AdvertCreateScreenState extends State<AdvertCreateScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController();
  final maxSpendController = TextEditingController();
  final videoUrlController = TextEditingController();
  final maxViewsController = TextEditingController();
  Location location = Location();
  LocationData _locationData;
  bool locationAvailable = false;
  String imgUrl = null;
  List<int> _receiptFile;
  String activeStatus = "0";
  bool _addLocation = false;
  AdType adType = AdType.image;
  bool _enabled = true;
  String perViewPrice = '';
  String lat = "0.0";
  String lon = "0.0";
  Future<List<AdvertWallet>> advertWalletListData;
  AdvertWallet selectedAdvertWallet;
  String walletId;

  @override
  void initState() {
    super.initState();
    checkLocation();
    if (widget.advert != null) {
//      titleController.text = widget.advert.campaignTitle;
//      latitudeController.text = widget.advert.lat;
//      longitudeController.text = widget.advert.lng;
//      radiusController.text = widget.advert.radius;
//      maxSpendController.text = widget.advert.maxSpend;
//      videoUrlController.text = widget.advert.videoUrl;
//      imgUrl = widget.advert.imageName;
      getAdvertDetails();
      _enabled = false;
    } else {
      advertWalletListData = advertWalletsLoad();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    maxSpendController.dispose();
    videoUrlController.dispose();
    maxViewsController.dispose();
    super.dispose();
  }

  checkLocation() async {
    // _isLoading = true;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      locationAvailable = true;
    });
    latitudeController.text = _locationData.latitude.toStringAsFixed(4);
    lat = _locationData.latitude.toString();
    longitudeController.text = _locationData.longitude.toStringAsFixed(4);
    lon = _locationData.longitude.toString();
  }

  Future _pickLocationTapped() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AdvertPickLocationScreen(),
    ));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          String latitude =
              double.parse(results['latitude']).toStringAsFixed(4);
          String longitude =
              double.parse(results['longitude']).toStringAsFixed(4);
          latitudeController.text = latitude;
          lat = results['latitude'].toString();
          longitudeController.text = longitude;
          lon = results['longitude'].toString();
        }
      });
    }
  }

  void getAdvertDetails() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['id'] = widget.advert.id;
    Map<String, dynamic> response = await NetworkHelper.request(
        'Advertisement/GetCampaignDetailsFromId', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];
      titleController.text = responseMap['campaign_title'];
      if (responseMap['lat'] == '' && responseMap['lng'] == '') {
        _addLocation = false;
      } else {
        _addLocation = true;
        latitudeController.text =
            double.parse(responseMap['lat']).toStringAsFixed(4);
        longitudeController.text =
            double.parse(responseMap['lng']).toStringAsFixed(4);
        radiusController.text = responseMap['radius'];
      }
      maxSpendController.text = responseMap['remaining_spend'];
      maxViewsController.text = responseMap['max_views'];
      videoUrlController.text = responseMap['video_url'];
      activeStatus = responseMap['active_status'];
      imgUrl = responseMap['image_name'];
      if (videoUrlController.text != "") {
        adType = AdType.video;
        imgUrl = null;
      } else if (imgUrl != "") {
        adType = AdType.image;
      }
      walletId = responseMap['wallet_charge_id'];
      advertWalletListData = advertWalletsLoad();
    }
  }

  Future<List<AdvertWallet>> advertWalletsLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('Advertisement/GetPerViewPrice');
    setState(() {
      this.perViewPrice = response['message'];
    });
    List responseList = response['adverts_wallet_ids'];

    List<AdvertWallet> getData = responseList.map<AdvertWallet>((json) {
      return AdvertWallet.fromJson(json);
    }).toList();
    if (walletId == null)
      selectedAdvertWallet = getData[0];
    else {
      for (AdvertWallet wallet in getData) {
        if (wallet.walletId == walletId) selectedAdvertWallet = wallet;
      }
    }
    return getData;
  }

  Widget _getAdvertPriceList() {
    return FutureBuilder(
        future: advertWalletListData,
        builder:
            (BuildContext context, AsyncSnapshot<List<AdvertWallet>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<AdvertWallet>(
                  isExpanded: true,
                  hint: Text(getTranslated(context, "select_wallet")),
                  value: selectedAdvertWallet,
                  onChanged: (AdvertWallet value) {
                    setState(() {
                      //walletId = value.id.toString();
                      selectedAdvertWallet = value;
//            widget.onWalletSelected(selectedWallet);
                    });
                  },
                  items: snapshot.data.map((AdvertWallet advertWallet) {
                    return DropdownMenuItem<AdvertWallet>(
                      value: advertWallet,
                      child: Text(advertWallet.walletCode),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(color: Colors.yellow),
                  ),
                )
              : Container();
        });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "advertising"),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perViewPrice,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 10),
                    _getAdvertPriceList(),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText:
                            getTranslated(context, "enter_ad_campaign_title"),
                        labelText: getTranslated(context, "ad_campaign_title"),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return getTranslated(
                              context, "please_enter_ad_campaign_title");
                        }
                        if (isNumeric(value)) {
                          return getTranslated(context,
                              "please_dont_enter_number_ad_campaign_title");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Radio(
                          value: AdType.image,
                          groupValue: adType,
                          onChanged: typeChangeHandler,
                        ),
                        Text(
                          getTranslated(context, "ad_image"),
                        ),
                        Radio(
                          value: AdType.video,
                          groupValue: adType,
                          onChanged: typeChangeHandler,
                        ),
                        Text(
                          getTranslated(context, "ad_video"),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    (adType == AdType.image)
                        ? ImageSelectFormField(
                            icon: Icon(Icons.add_photo_alternate),
                            labelText: getTranslated(context, "advertisement"),
                            hintText: getTranslated(context, "upload_ad"),
                            source: ImageFrom.both,
                            imageURL: imgUrl,
                            crop: true,
                            onChanged: (img) {
                              if (img != null) {
                                _receiptFile = img;
                                //_formKey.currentState.validate();
                              }
                            },
                          )
                        : TextFormField(
                            controller: videoUrlController,
                            decoration: InputDecoration(
                              hintText:
                                  getTranslated(context, "enter_video_url"),
                              labelText: getTranslated(context, "video_url"),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return getTranslated(
                                    context, "please_enter_video_url");
                              }
                              if (!Uri.parse(value).isAbsolute)
                                return getTranslated(
                                    context, "please_enter_a_valid_video_url");
                              return null;
                            },
                          ),
//                    SizedBox(width: 10),
//                    SizedBox(
//                      width: double.infinity,
//                      child: RaisedButton(
//                        child: Text(
//                            "UPLOAD AD 40px high x 360px wide - JPG or GIF"),
//                        color: kPrimaryColor,
//                        textColor: Colors.white,
//                        onPressed: () {
//                          //if (_formKey.currentState.validate())
//                          //saveCouponHandler();
//                        },
//                      ),
//                    ),
                    SizedBox(width: 10),
//                    CheckboxListTile(
//                      //checkColor: Colors.red[600],
//                      activeColor: kPrimaryColor,
//                      value: _addLocation,
//                      title: Text("Add Location"),
//                      onChanged: (bool value) {
//                        setState(() {
//                          _addLocation = value;
//                          //widget.onSelectedAnonymousChanged(_anonymousSelected);
//                        });
//                      },
//                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: _addLocation,
                          onChanged: (bool value) {
                            setState(() {
                              _addLocation = value;
                              //widget.onSelectedAnonymousChanged(_anonymousSelected);
                            });
                          },
                        ),
                        // SizedBox(width: 10),
                        Text(getTranslated(context, "add_location"))
                      ],
                    ),

                    if (_addLocation)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          Row(
                            children: [
                              IconButton(
                                icon: new Icon(
                                  Icons.add_location,
                                  size: 36,
                                  color: kPrimaryColor,
                                ),
                                highlightColor: Colors.pink,
                                onPressed: () {
                                  _pickLocationTapped();
                                },
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: latitudeController,
                                  enabled: false,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: false),
                                  decoration: InputDecoration(
                                    hintText:
                                        getTranslated(context, "latitude"),
                                    labelText:
                                        getTranslated(context, "latitude"),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return getTranslated(
                                          context, "enter_location");
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: longitudeController,
                                  enabled: false,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: false),
                                  decoration: InputDecoration(
                                    hintText:
                                        getTranslated(context, "longitude"),
                                    labelText:
                                        getTranslated(context, "longitude"),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return getTranslated(
                                          context, "enter_location");
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: radiusController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: false),
                                  decoration: InputDecoration(
                                    hintText: getTranslated(context, "radius"),
                                    labelText: getTranslated(context, "radius"),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return getTranslated(
                                          context, "enter_radius");
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: maxViewsController,
                            enabled: _enabled,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: false),
                            decoration: InputDecoration(
                              hintText:
                                  getTranslated(context, "max_views_per_user"),
                              labelText:
                                  getTranslated(context, "max_views_per_user"),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return getTranslated(
                                    context, "enter_max_views_per_user");
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            controller: maxSpendController,
                            enabled: _enabled,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: false),
                            decoration: InputDecoration(
                              hintText: getTranslated(context, "max_spend"),
                              labelText: getTranslated(context, "max_spend"),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return getTranslated(
                                    context, "please_enter_max_spend");
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    //SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.advert != null)
                          (activeStatus == '1')
                              ? Expanded(
                                  child: RaisedButton(
                                    child:
                                        Text(getTranslated(context, "active")),
                                    color: Colors.green[700],
                                    textColor: Colors.white,
                                    onPressed: () {
                                      changeActiveStatusHandler();
                                    },
                                  ),
                                  flex: 2,
                                )
                              : Expanded(
                                  child: RaisedButton(
                                    child: Text(
                                        getTranslated(context, "not_active")),
                                    color: Colors.black,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      changeActiveStatusHandler();
                                    },
                                  ),
                                  flex: 3,
                                ),
                        if (widget.advert != null) SizedBox(width: 10),
                        Expanded(
                          child: RaisedButton(
                            child: Text(getTranslated(context, "cancel")),
                            color: Colors.grey[600],
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          flex: 2,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: RaisedButton(
                            child: Text(getTranslated(context, "save")),
                            color: kPrimaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (widget.advert == null) {
                                  if (adType == AdType.image) {
                                    if (_receiptFile != null)
                                      saveAdvertHandler();
                                    else {
                                      final snackBar = SnackBar(
                                          content: Text(getTranslated(context,
                                              "please_upload_ad_image")),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    }
                                  } else {
                                    saveAdvertHandler();
                                  }
                                } else {
                                  //saveAdvertHandler();
                                  if (adType == AdType.image) {
                                    if (_receiptFile != null || imgUrl != null)
                                      saveAdvertHandler();
                                    else {
                                      final snackBar = SnackBar(
                                          content: Text(getTranslated(context,
                                              "please_upload_ad_image")),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    }
                                  } else {
                                    saveAdvertHandler();
                                  }
                                }
                              }
                            },
                          ),
                          flex: 2,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: Loading()))
              : SizedBox(),
        ],
      ),
    );
  }

  void typeChangeHandler(AdType value) {
    setState(() {
      adType = value;
    });
  }

  saveAdvertHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    if (widget.advert != null) {
      apiBodyObj['update_id'] = widget.advert.id;
    }
    apiBodyObj['campaign_title'] = titleController.text.toString();
    if (_addLocation) {
      apiBodyObj['lat'] = lat;
      apiBodyObj['lng'] = lon;
      apiBodyObj['radius'] = radiusController.text.toString();
    } else {
      apiBodyObj['lat'] = "";
      apiBodyObj['lng'] = "";
      apiBodyObj['radius'] = "";
    }
    apiBodyObj['max_spend'] = maxSpendController.text.toString();
    apiBodyObj['max_views'] = maxViewsController.text.toString();
    apiBodyObj['pay_wallet_id'] = selectedAdvertWallet.walletId;
    if (adType == AdType.image) {
      if (_receiptFile != null) {
        apiBodyObj['image'] = base64Encode(_receiptFile);
      }
    } else if (adType == AdType.video) {
      apiBodyObj['video_url'] = videoUrlController.text.toString();
    }
    Map<String, dynamic> response;
    if (widget.advert != null) {
      response = await NetworkHelper.request(
          'Advertisement/UpdateAdCampaign', apiBodyObj);
    } else
      response =
          await NetworkHelper.request('Advertisement/AddCampaign', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      if (widget.advert != null)
        Navigator.of(context).pop({'status': 'updateSuccess'});
      else
        Navigator.of(context).pop({'status': 'createSuccess'});
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "switch_to_community_perspective") {
        err = getTranslated(context, "switch_to_merchant_perspective");
      } else if (response['error'] == "failed_to_add_the_campaign") {
        err = getTranslated(context, "failed_to_add_campaign");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "id_is_required") {
        err = getTranslated(context, "id_is_required");
      } else if (response['error'] == "campaign_title_is_required") {
        err = getTranslated(context, "campaign_title_is_required");
      } else if (response['error'] == "ad_details_not_found") {
        err = getTranslated(context, "ad_details_not_found");
      } else if (response['error'] == "lat_is_required") {
        err = getTranslated(context, "location_not_found");
      } else if (response['error'] == "lng_is_required") {
        err = getTranslated(context, "location_not_found");
      } else if (response['error'] == "radius_is_required") {
        err = getTranslated(context, "radius_is_required");
      } else if (response['error'] == "max_spend_is_required") {
        err = getTranslated(context, "max_spend_is_required");
      } else if (response['error'] == "max_spend_should_be_numeric") {
        err = getTranslated(context, "max_spend_numeric");
      } else if (response['error'] == "both_image_and_video_is_not_allowed") {
        err = getTranslated(context, "both_image_video_not_allowed");
      } else if (response['error'] ==
          "lat_should_be_numeric_either_float_or_double") {
        err = getTranslated(context, "location_shouldbe_double");
      } else if (response['error'] ==
          "lng_should_be_numeric_either_float_or_double") {
        err = getTranslated(context, "location_shouldbe_double");
      } else if (response['error'] == "merchant_is_not_verified") {
        err = getTranslated(context, "merchant_is_not_verified");
      } else if (response['error'] == "radius_should_be_numeric") {
        err = getTranslated(context, "radius_numeric");
      } else if (response['error'] == "insufficient_php_or_tag_balance") {
        err = getTranslated(context, "insufficient_php_tag_balance");
      } else if (response['error'] == "failed_to_update_promised_balance") {
        err = getTranslated(context, "failed_update_promised_balance");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  changeActiveStatusHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['id'] = widget.advert.id;
    Map<String, dynamic> response;
    response = await NetworkHelper.request(
        'Advertisement/ChangeActiveStatus', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        activeStatus = response['active_status'];
      });
      final snackBar = SnackBar(
          content: Text(getTranslated(context, "success_change_active_status")),
          duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "switch_to_community_perspective") {
        err = getTranslated(context, "switch_to_merchant_perspective");
      } else if (response['error'] == "failed") {
        err = getTranslated(context, "failed");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "id_is_required") {
        err = getTranslated(context, "id_is_required");
      } else if (response['error'] == "ad_details_not_found") {
        err = getTranslated(context, "ad_details_not_found");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}
