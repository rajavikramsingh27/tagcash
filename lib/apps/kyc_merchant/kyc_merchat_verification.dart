import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'models/merchat_extras_status.dart';
import 'models/merchant_verify_level.dart';

bool isKycVerifyMerchant;
TabController tabController;

class MerchantVerifyScreen extends StatefulWidget {
  _MerchantVerifyState createState() => _MerchantVerifyState();
}

class _MerchantVerifyState extends State<MerchantVerifyScreen> {
  var verificationLevel;
  bool isLoading = false;

  void initState() {
    verificationLevel = "";
    getKYCVerifiedLevel();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getKYCVerifiedLevel() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/GetLevel', apiBodyObj);
    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      setState(() {
        MerchantVerifyLevel merchantData =
            MerchantVerifyLevel.fromJson(response['result']);
        verificationLevel = merchantData.verificationLevel;
        // kycParentMerchantId = merchantData.kycParentMerchantId;
        if (verificationLevel == 1) {
          isKycVerifyMerchant = true;
        } else if (verificationLevel == 0) {
          isKycVerifyMerchant = false;
        }
      });
    }
  }

  Widget build(BuildContext context) {
    if (verificationLevel == "") {
      return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Kyc Verification',
        ),
        body: Container(
          child: isLoading ? Center(child: Loading()) : SizedBox(),
        ),
      );
    } else {
      return Scaffold(
        body: MerchantVerifyKycState(),
      );
    }
  }
}

class MerchantVerifyKycState extends StatefulWidget {
  _MerchantVerifyState2 createState() => _MerchantVerifyState2();
}

class _MerchantVerifyState2 extends State<MerchantVerifyKycState>
    with SingleTickerProviderStateMixin {
  List<String> categories;

  List<Tab> tabs = [];

  bool isLoading = false;

  @override
  void initState() {
    tabs.clear();
    categories = [];

    if (isKycVerifyMerchant == true) {
      categories = ["VERIFIED", "EXTRA"];

      tabController = TabController(
          length: categories.length, vsync: this, initialIndex: 0);
    }
    if (isKycVerifyMerchant == false) {
      categories = ["INFO", "DOCS", "EXTRA"];

      tabController = TabController(
          length: categories.length, vsync: this, initialIndex: 0);
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isLoading ? Center(child: Loading()) : SizedBox();
    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppTopBar(
            title: getTranslated(context, "kyc_verification_txt"),
            appBar: AppBar(
                bottom: TabBar(
              controller: tabController,
              tabs: List<Widget>.generate(categories.length, (int index) {
                return new Tab(
                    child: Text(
                  categories[index],
                ));
              }),
            )),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              // children:[
              if (categories.length != 0) ...[
                if (isKycVerifyMerchant == true) ...[
                  KYCMerchantVerifyPage(),
                  KYCMerVerifyExtraPage(),
                ],
                if (isKycVerifyMerchant == false) ...[
                  KYCMerchantInfoVerification(),
                  KYCMerchantDocsVerification(),
                  KYCMerVerifyExtraPage(),
                ]
              ],

              // ],
            ],
          ),
        ),
      ),
    );
  }
}

class KYCMerchantVerifyPage extends StatefulWidget {
  @override
  KYCMerchantVerifyState createState() => KYCMerchantVerifyState();
}

class KYCMerchantVerifyState extends State<KYCMerchantVerifyPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: Center(
          child: Text(
            getTranslated(context, "kyc_verified"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}

class KYCMerchantInfoVerification extends StatefulWidget {
  @override
  KYCMerchantInfoVerificationState createState() =>
      KYCMerchantInfoVerificationState();
}

class KYCMerchantInfoVerificationState
    extends State<KYCMerchantInfoVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  int _radioValue;
  var business_type;
  bool isLoading = false;
  bool isEnableRadioBtn = false;
  var kycMerchDataVerifyStatus;
  var kycMerchDataHashKey;
  bool transferClickPossible = true;
  int nowCommunityID = 0;
  var country_code;

  final businessNameTxt = TextEditingController();
  final websiteURL = TextEditingController();
  final officeAdress = TextEditingController();
  final natureOfBusiness = TextEditingController();
  final dailyMaximValue = TextEditingController();
  final monthlyMinValue = TextEditingController();

  void _handleRadioValueChange(int value) {
    if (isEnableRadioBtn == true) {
      setState(() {
        _radioValue = value;
        if (_radioValue == 0) {
          business_type = "corporation";
        } else {
          business_type = "single";
        }

        switch (_radioValue) {
          case 0:
            break;
          case 1:
            break;
        }
      });
    } else {
      var msg = getTranslated(context, "kyc_philippines_available");
      showMessage(msg);
    }
  }

  void updateVerification() {
    setState(() {
      kycMerchDataVerifyStatus = "new";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      nowCommunityID =
          Provider.of<MerchantProvider>(context, listen: false).merchantData.id;
    }

    // memberDataList = {} as Future<List<Merchant>>;
  }

  void initState() {
    _radioValue = 0;
    country_code = 236;
    getKYCMerchantVerifiedData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    businessNameTxt.dispose();
    websiteURL.dispose();
    officeAdress.dispose();
    natureOfBusiness.dispose();
    dailyMaximValue.dispose();
    monthlyMinValue.dispose();
  }

  getKYCMerchantVerifiedData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('community/GetMerchantKycData', apiBodyObj);
    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      setState(() {
        var verifyStatus = response['result'];
        if (verifyStatus["status"] == "pending") {
          kycMerchDataVerifyStatus = verifyStatus["status"];
        } else if (verifyStatus["status"] == "unapproved") {
          kycMerchDataVerifyStatus = verifyStatus["status"];
        } else if (verifyStatus["status"] == "approved") {
          kycMerchDataVerifyStatus = verifyStatus["status"];
          kycMerchDataHashKey = verifyStatus["data_hash"];
        } else {
          kycMerchDataVerifyStatus = "new";
          // getCompanyRegsterImage();

        }
      });
    } else if (response["error"] == "info_missing") {
      setState(() {
        kycMerchDataVerifyStatus = "new";
      });
    }
  }

  void submitMerchantInfoDetail() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      var apiBodyObj = {};
      apiBodyObj['community_id'] = nowCommunityID.toString();
      apiBodyObj['business_name'] = businessNameTxt.text.toString();
      apiBodyObj['company_website'] = websiteURL.text.toString();
      apiBodyObj['office_address'] = officeAdress.text.toString();
      apiBodyObj['country'] = country_code.toString();
      apiBodyObj['business_type'] = business_type.toString();
      apiBodyObj['business_nature'] = natureOfBusiness.text.toString();
      apiBodyObj['daily_maximum'] = dailyMaximValue.text.toString();
      apiBodyObj['monthly_maximum'] = monthlyMinValue.text.toString();
      apiBodyObj['status'] = "0";

      Map<String, dynamic> response =
          await NetworkHelper.request('community/MerchantKycData/', apiBodyObj);
      setState(() {
        isLoading = false;
      });
      if (response["status"] == "success") {
        setState(() {
          getKYCMerchantVerifiedData();
        });
      }
    } else {}
  }

  void onCountryChange(Map country) {
    setState(() {
      _radioValue = 0;
      country_code = country['id'];
      print(country_code + "Id");
      if (country_code == "174") {
        isEnableRadioBtn = true;
      } else {
        isEnableRadioBtn = false;
      }
    });
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[600]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(8),
        child: Stack(
          children: [
            if (kycMerchDataVerifyStatus == "new") ...[
              Form(
                key: _formKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  // padding: EdgeInsets.all(kDefaultPadding),

                  children: [
                    TextFormField(
                      controller: businessNameTxt,
                      decoration: new InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_business_name")),
                      validator: (businessNameTxt) {
                        if (businessNameTxt.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_business_name_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    TextFormField(
                      controller: websiteURL,
                      decoration: new InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_company_website")),
                      validator: (websiteURL) {
                        if (websiteURL.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_company_website_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    TextFormField(
                      controller: officeAdress,
                      decoration: new InputDecoration(
                          labelText: getTranslated(context, "kyc_address")),
                      validator: (officeAdress) {
                        if (officeAdress.isEmpty) {
                          var msg =
                              getTranslated(context, "kyc_address_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    CountriesFormField(
                      labelText: getTranslated(context, "kyc_select_country"),
                      // initialCountryCode: 'PH',
                      onChanged: (country) {
                        if (country != null) {
                          onCountryChange(country);
                        }
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Radio(
                          groupValue: _radioValue,
                          focusColor: Colors.black,
                          activeColor: Colors.black,
                          value: 0,
                          onChanged: _handleRadioValueChange,
                        ),
                        new Text(getTranslated(context, "Corporation")),
                        Radio(
                            groupValue: _radioValue,
                            focusColor: Colors.black,
                            activeColor: Colors.black,
                            value: 1,
                            onChanged: _handleRadioValueChange),
                        new Text(getTranslated(context, "kyc_sole_trader")),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    TextFormField(
                      controller: natureOfBusiness,
                      decoration: new InputDecoration(
                          labelText:
                              getTranslated(context, "kyc_nature_business")),
                      validator: (natureOfBusiness) {
                        if (natureOfBusiness.isEmpty) {
                          var msg = getTranslated(
                              context, "kyc_nature_business_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    TextFormField(
                      controller: dailyMaximValue,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: new InputDecoration(
                          labelText: getTranslated(
                              context, "kyc_estimated_inwards_daily_maximum")),
                      validator: (dailyMaximValue) {
                        if (dailyMaximValue.isEmpty) {
                          var msg = getTranslated(context,
                              "kyc_estimated_inwards_daily_maximum_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    TextFormField(
                      controller: monthlyMinValue,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: new InputDecoration(
                          labelText: getTranslated(context,
                              "kyc_estimated_inwards_monthly_maximum")),
                      validator: (monthlyMinValue) {
                        if (monthlyMinValue.isEmpty) {
                          var msg = getTranslated(context,
                              "kyc_estimated_inwards_monthly_maximum_require");
                          return msg;
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    CustomButton(
                      label: getTranslated(context, "kyc_submit_details"),
                      onPressed: transferClickPossible
                          ? () {
                              setState(() {
                                enableAutoValidate = true;
                              });
                              if (_formKey.currentState.validate()) {
                                submitMerchantInfoDetail();
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
            if (kycMerchDataVerifyStatus == "pending") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_pending_verification"),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (kycMerchDataVerifyStatus == "unapproved") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      color: Colors.red,
                      label: getTranslated(context, "kyc_verification_faild"),
                      onPressed: transferClickPossible
                          ? () {
                              setState(() {
                                enableAutoValidate = true;
                              });
                              if (_formKey.currentState.validate()) {
                                updateVerification();
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            if (kycMerchDataVerifyStatus == "approved") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_verified"),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      )),
    );
  }
}

class KYCMerchantDocsVerification extends StatefulWidget {
  @override
  KYCMerchantDocsVerificationState createState() =>
      KYCMerchantDocsVerificationState();
}

class KYCMerchantDocsVerificationState
    extends State<KYCMerchantDocsVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Future<List<MerchatExtrasStatus>> merchantUploadDocsList;
  var countryCode;
  var businesstype;
  bool isLoading = false;
  bool isNewDocsUpload;
  File _pickedFile;
  void initState() {
    getKYCMerchantVerifiedData();
    super.initState();
  }

  getKYCMerchantVerifiedData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response =
        await NetworkHelper.request('community/GetMerchantKycData', apiBodyObj);
    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      setState(() {
        var verifyStatus = response['result'];
        countryCode = verifyStatus["country"];
        businesstype = verifyStatus["business_type"];
        merchantUploadDocsList = getMerchantUploadDocsStatus();
      });
    } else if (response["error"] == "info_missing") {
      setState(() {
        _isDocsUploded(context);
      });
    }
  }

  Future<List<MerchatExtrasStatus>> getMerchantUploadDocsStatus() async {
    setState(() {
      isLoading = true;
    });
    var merchantDatas;
    // countryCode = 1;
    Map<String, String> apiBodyObj = {};
    if (countryCode == 174) {
      if (businesstype == "corporation") {
        merchantDatas = [
          "company_registration",
          "mayors_permitt",
          "bir_form_2303",
          "gis_or_beneficial_owners_list",
          "secretary_certificate"
        ];
      } else {
        merchantDatas = [
          "company_registration",
          "mayors_permitt",
          "bir_form_2303"
        ];
      }
    } else if (countryCode == 236) {
      merchantDatas = [
        "company_registration",
        "mayors_permitt",
        "bir_form_2303",
        "gis_or_beneficial_owners_list",
        "ein_proof_from_irs"
      ];
    } else {
      merchantDatas = [
        "company_registration",
        "mayors_permitt",
        "bir_form_2303",
        "gis_or_beneficial_owners_list",
        "tax_vat_gst_registration"
      ];
    }

    // var merchantDatasJson = JSON.stringify(merchantDatas);
    String merchantDatasJson = jsonEncode(merchantDatas);
    apiBodyObj['verification_type'] = merchantDatasJson;

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/status', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
        // isNewDocsUpload = true;
      });
      List responseList = response['result'];
      // final List<ExpenseData> newList = List();
      // var newList = responseList.map((model) => ExpenseData.fromJson(model)).toList();
      List<MerchatExtrasStatus> getData =
          responseList.map<MerchatExtrasStatus>((json) {
        return MerchatExtrasStatus.fromJson(json);
      }).toList();

      return getData;
    } else {
      setState(() {
        isLoading = false;
        //  isNewDocsUpload = false;
      });
    }
    return [];
  }

  String fileName;
  String fileDetails;
  void uploadCertificateFile(verificationType) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      fileName = result.files.single.name;
      fileDetails = '';
      setPickedFIle(file, verificationType);
    }
  }

  void setPickedFIle(File imageFile, verificationType) {
    setState(() {
      _pickedFile = imageFile;
    });
    Map<String, dynamic> fileData;
    if (_pickedFile != null) {
      var file = _pickedFile;
      String basename = path.basename(file.path);

      fileData = {};
      fileData['key'] = 'data';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
      uploadFile(fileData, verificationType);
    }
  }

  uploadFile(fileData, verificationType) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['upload_type'] = verificationType.toString();
    // apiBodyObj['data'] = fileData;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await NetworkHelper.request(
        'verification/Upload', apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      merchantUploadDocsList = getMerchantUploadDocsStatus();
    } else {}
  }

  historyDetails(obj) {
    var kk;
    if (obj == "company_registration") {
      kk = getTranslated(context, "kyc_company_registration_document");
    } else if (obj == "mayors_permitt") {
      kk = getTranslated(context, "kyc_mayors_permit");
    } else if (obj == "bir_form_2303") {
      kk = getTranslated(context, "kyc_bir_form_2303");
    } else if (obj == "gis_or_beneficial_owners_list") {
      kk = getTranslated(context, "kyc_gis_beneficial_owners_list");
    } else if (obj == "secretary_certificate") {
      kk = getTranslated(context, "kyc_secretary_certificate");
    } else if (obj == "ein_proof_from_irs") {
      kk = getTranslated(context, "kyc_ein_proof_from_irs");
    } else if (obj == "tax_vat_gst_registration") {
      kk = getTranslated(context, "kyc_tax_vat_gst_registration");
    }
    return kk;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FilePickFormField(
      //icon: Icon(Icons.note),
      //     labelText: 'Receipt',
      //   hintText: 'Please add receipt image',
      // ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Stack(
            children: [
              ListView(
                children: [
                  //if(isNewDocsUpload == true)...[
                  FutureBuilder(
                    future: merchantUploadDocsList,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MerchatExtrasStatus>> snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              padding: new EdgeInsets.all(7.0),
                              itemBuilder: (BuildContext context, int index) {
                                return new GestureDetector(
                                  onTap: () {
                                    if (snapshot.data[index].status ==
                                        "unapproved") {
                                      uploadCertificateFile(snapshot
                                          .data[index].verificationType);
                                    } else if (snapshot.data[index].status ==
                                        "update_please") {
                                      uploadCertificateFile(snapshot
                                          .data[index].verificationType);
                                    }
                                  },
                                  //child:Padding(
                                  // padding: const EdgeInsets.all(8.0),

                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      if (snapshot.data[index].status ==
                                          "pending") ...[
                                        Center(
                                          child: Text(
                                            historyDetails(snapshot
                                                .data[index].verificationType),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                label: getTranslated(context,
                                                    "kyc_pending_verification"),
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (snapshot.data[index].status ==
                                          "unapproved") ...[
                                        Center(
                                          child: Text(
                                            historyDetails(snapshot
                                                .data[index].verificationType),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                        ),

                                        // SizedBox(height: 1,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                label: getTranslated(context,
                                                    "kyc_verification_faild"),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (snapshot.data[index].status ==
                                          "approved") ...[
                                        Center(
                                          child: Text(
                                            historyDetails(snapshot
                                                .data[index].verificationType),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                label: getTranslated(
                                                    context, "kyc_verified"),
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (snapshot.data[index].status ==
                                          "update_please") ...[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                label: historyDetails(snapshot
                                                    .data[index]
                                                    .verificationType),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]
                                    ],
                                    // ),
                                  ),
                                );
                              },
                            )
                          : SizedBox();
                    },
                  ),
                  //  ]else if(isNewDocsUpload == false)...[

                  //  ],
                ],
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ),
      ),
    );

    //Header Container
  }

  void _isDocsUploded(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new AlertDialog(
          title: new Text(getTranslated(context, "kyc_info")),
          content: new Text(getTranslated(context, "kyc_info_msg")),
          actions: <Widget>[
            new FlatButton(
              child: new Text(getTranslated(context, "ok")),
              onPressed: () {
                Navigator.of(context).pop();
                tabController.index = 0;
              },
            ),
          ],
        ),
      );
    });
  }
}

class KYCMerVerifyExtraPage extends StatefulWidget {
  @override
  KYCMerVerifyExtraState createState() => KYCMerVerifyExtraState();
}

class KYCMerVerifyExtraState extends State<KYCMerVerifyExtraPage> {
  Future<List<MerchatExtrasStatus>> merchatExtraDocsList;
  bool isLoading = false;
  File _pickedFile;
  void initState() {
    merchatExtraDocsList = getMerchatExtraDocsList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String fileName;
  String fileDetails;
  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      fileName = result.files.single.name;
      fileDetails = '';
      setPickedFIle(file);
    }
  }

  void setPickedFIle(File imageFile) {
    setState(() {
      _pickedFile = imageFile;
    });
    Map<String, dynamic> fileData;
    if (_pickedFile != null) {
      var file = _pickedFile;
      String basename = path.basename(file.path);

      fileData = {};
      fileData['key'] = 'data';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
      uploadFile(fileData);
    }
  }

  uploadFile(fileData) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['upload_type'] = "extras";
    // apiBodyObj['data'] = fileData;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await NetworkHelper.request(
        'verification/Upload', apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      merchatExtraDocsList = getMerchatExtraDocsList();
    } else {}
  }

  Future<List<MerchatExtrasStatus>> getMerchatExtraDocsList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['verification_type'] = "extras";

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/status', apiBodyObj);

    if (response["status"] == "success") {
      setState(() {
        isLoading = false;
      });
      List responseList = response['result'];
      // final List<ExpenseData> newList = List();
      // var newList = responseList.map((model) => ExpenseData.fromJson(model)).toList();
      List<MerchatExtrasStatus> getData =
          responseList.map<MerchatExtrasStatus>((json) {
        return MerchatExtrasStatus.fromJson(json);
      }).toList();

      return getData;
    } else {
      setState(() {
        isLoading = false;
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Stack(
              children: [
                ListView(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Text(
                        getTranslated(context, "kyc_extra_msg"),
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomButton(
                            label: getTranslated(context, "kyc_upload"),
                            onPressed: selectFileClicked,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder(
                      future: merchatExtraDocsList,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<MerchatExtrasStatus>> snapshot) {
                        if (snapshot.hasError) print(snapshot.error);
                        return snapshot.hasData
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new GestureDetector(
                                      onTap: () {},
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          if (snapshot.data[index].status ==
                                              "pending") ...[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: CustomButton(
                                                    label: getTranslated(
                                                        context,
                                                        "kyc_pending_verification"),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ] else if (snapshot
                                                  .data[index].status ==
                                              "unapproved") ...[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: CustomButton(
                                                    label: getTranslated(
                                                        context,
                                                        "kyc_verification_faild"),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ] else if (snapshot
                                                  .data[index].status ==
                                              "approved") ...[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: CustomButton(
                                                    label: getTranslated(
                                                        context,
                                                        "kyc_verified"),
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]
                                        ],
                                      ));
                                },
                              )
                            : SizedBox();
                      },
                    ),
                  ],
                ),
                isLoading ? Center(child: Loading()) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
