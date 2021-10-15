import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/merchant.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'merchant_detail_screen.dart';
import 'models/merchant_category.dart';

class MerchantsListScreen extends StatefulWidget {
  @override
  _MerchantsListScreenState createState() => _MerchantsListScreenState();
}

class _MerchantsListScreenState extends State<MerchantsListScreen> {
  Future<List<Merchant>> merchantsStaffList;
  bool isLoading = false;

  int nowCommunityID = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      nowCommunityID =
          Provider.of<MerchantProvider>(context, listen: false).merchantData.id;
    }

    merchantsStaffList = loadStaffCommunities();
  }

  Future<List<Merchant>> loadStaffCommunities() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request('user/staffof');

    List responseList = response['result'];

    List<Merchant> getData = responseList.map<Merchant>((json) {
      return Merchant.fromJson(json);
    }).toList();

    setState(() {
      isLoading = false;
    });

    return getData;
  }

  void createMerchantClick() {
    if (Provider.of<UserProvider>(context, listen: false)
        .userData
        .kycVerified) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: kBottomSheetShape,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CreateMerchant(),
                ),
              ),
            );
          }).then((value) {
        if (value != null) {
          switchPerspective(value.toString());
        }
      });
    } else {
      showSimpleDialog(context,
          title: 'KYC',
          message: 'KYC verification is required to create business.');
    }
  }

  switchClickHandler(Merchant merchant) {
    if (nowCommunityID != merchant.communityId) {
      switchPerspective(merchant.communityId.toString());
    }
  }

  switchPerspective(String communitySwitchID) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('perspective/switch/' + communitySwitchID);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      Provider.of<PerspectiveProvider>(context, listen: false)
          .setActivePerspective(responseMap['type']);

      setState(() {
        nowCommunityID = int.parse(responseMap['id']);
      });

      communityDetailsLoad();
    } else {
      if (response['error'] == "kyc_verification_failed") {
        kycErrorAlertShow();
      }
    }
  }

  kycErrorAlertShow() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('KYC verification '),
            content:
                Text('KYC verification is required for switching to business.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  backToLogin();
                },
                child: Text(
                  'OK',
                ),
              )
            ],
          );
        });
  }

  backToLogin() {
    Navigator.of(context).pop();
  }

  communityDetailsLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request(
        'community/details/' + nowCommunityID.toString());

    if (response['status'] == 'success') {
      MerchantData merchantData = MerchantData.fromJson(response['result']);

      Provider.of<MerchantProvider>(context, listen: false)
          .setMerchantData(merchantData);

      // _model.nowCommunityRoleType = resultObj.role.role_type;
      // _model.nowCommunityRoleName = resultObj.role.role_name;

      // tagEvents.emit("rolePermissionGet");

      goToHomePage();
    }
  }

  void goToHomePage() {
    setState(() {
      isLoading = false;
    });

    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Business',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createMerchantClick(),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: merchantsStaffList,
        builder:
            (BuildContext context, AsyncSnapshot<List<Merchant>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: ListTile(
                        title: Text(
                          snapshot.data[index].communityName,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              snapshot.data[index].communityId.toString(),
                            ),
                            SizedBox(width: 10),
                            snapshot.data[index].kycVerified
                                ? Text(
                                    'VERIFIED',
                                    style: TextStyle(color: Colors.green),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        trailing:
                            nowCommunityID != snapshot.data[index].communityId
                                ? ElevatedButton(
                                    onPressed: () {
                                      switchClickHandler(snapshot.data[index]);
                                    },
                                    child: Text('SWITCH'),
                                  )
                                : SizedBox(),
                      ),
                    );
                  },
                )
              : Center(child: Loading());
        },
      ),
    );
  }
}

class CreateMerchant extends StatefulWidget {
  const CreateMerchant({
    Key key,
  }) : super(key: key);

  @override
  _CreateMerchantState createState() => _CreateMerchantState();
}

class _CreateMerchantState extends State<CreateMerchant> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _nameController = TextEditingController();

  String countryCode;
  String countryId;
  String categoryId;

  Future<List<MerchantCategory>> categoryOptions;

  @override
  void initState() {
    super.initState();
    categoryOptions = loadCategoryOptionsList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    UserData userData =
        Provider.of<UserProvider>(context, listen: false).userData;
    countryCode = userData.countryCode;
    countryId = userData.countryId.toString();
  }

  Future<List<MerchantCategory>> loadCategoryOptionsList() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('Category/list');

    List responseList = response['result'];

    List<MerchantCategory> getData = responseList.map<MerchantCategory>((json) {
      return MerchantCategory.fromJson(json);
    }).toList();

    return getData;
  }

  void onCountryChange(Map country) {
    countryId = country['id'];
  }

  void newMerchantCreate() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['community_name'] = _nameController.text;
    apiBodyObj['country_id'] = countryId;
    apiBodyObj['category_id'] = categoryId;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/create', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, response['community_id']);
      showSnackBar('Business Created Successfully');
    } else {
      if (response['error'] == 'community_name_already_used') {
        showSimpleDialog(context,
            title: 'Business Name',
            message:
                'The business name is already being used. Please try another name.');
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CREATE BUSINESS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Business Name',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value)) {
                    return 'Please enter Business Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CountriesFormField(
                labelText: 'Select country',
                initialCountryCode: countryCode,
                onChanged: (country) {
                  if (country != null) {
                    onCountryChange(country);
                  }
                },
              ),
              SizedBox(height: 20),
              FutureBuilder(
                  future: categoryOptions,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<MerchantCategory>> snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? DropdownButtonFormField<MerchantCategory>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: const OutlineInputBorder(),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            icon: Icon(Icons.arrow_downward),
                            items: snapshot.data
                                .map<DropdownMenuItem<MerchantCategory>>(
                                    (MerchantCategory value) {
                              return DropdownMenuItem<MerchantCategory>(
                                value: value,
                                child: Text(
                                  value.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Select Category';
                              }
                              return null;
                            },
                            onChanged: (MerchantCategory newValue) {
                              categoryId = newValue.id.toString();
                            })
                        : Center(child: Loading());
                  }),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('CREATE BUSINESS'),
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    newMerchantCreate();
                  }
                },
              ),
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
