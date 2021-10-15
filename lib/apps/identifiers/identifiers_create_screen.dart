import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:tagcash/apps/identifiers/model/identifierdata.dart';
import 'package:tagcash/screens/qr_scan_screen.dart';
import 'package:nfc_manager/nfc_manager.dart';

class IdentifiersCreateScreen extends StatefulWidget {
  bool createValue = true;
  IdentifierData identifierData;

  IdentifiersCreateScreen(
      {@required this.createValue, @required this.identifierData});

  @override
  _IdentifiersCreateScreenState createState() =>
      _IdentifiersCreateScreenState(createValue, identifierData);
}

class _IdentifiersCreateScreenState extends State<IdentifiersCreateScreen> {
  IdentifierData identifierData;
  bool merchantPerspectiveFlag = true;
  bool createValue = true;
  String connectingType = "My Self";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;
  bool saveClickPossible = true;
  bool connectMySelfFlag = true;
  bool connectAnotherUserFlag = false;
  bool connectAnotherMerchantFlag = false;
  bool validMobilephoneFlag = false;
  String identifierId = null;
  String identifierUpdateDeleteValue = null;
  String linkedToTypeText = "";
  bool isIDEmailUserTextFormEnable = true;
  bool isIDMerchantTextFormEnable = true;

  TextEditingController _identifiernameController;
  TextEditingController _identifierValueController;
  TextEditingController _idemailanotheruserController;
  TextEditingController _idanothermerchantController;
  TextEditingController _mobilenumberPaymentConfirmationController;

  _IdentifiersCreateScreenState(createvalue, identifierData) {
    this.createValue = createvalue;
    this.identifierData = identifierData;
  }

  @override
  void initState() {
    super.initState();
    _identifiernameController = TextEditingController();
    _identifierValueController = TextEditingController();
    _idemailanotheruserController = TextEditingController();
    _mobilenumberPaymentConfirmationController = TextEditingController();
    _idanothermerchantController = TextEditingController();
    if (getPerspective() == "user") {
      merchantPerspectiveFlag = false;
    } else {
      merchantPerspectiveFlag = true;
    }
    if (createValue == false) {
      setIdentifierValues(identifierData);
    }
    nfcIdentifierProcess();
  }

  void setIdentifierValues(identifierData) {
    isIDEmailUserTextFormEnable =
        false; //In identifier updation we cant edit ID,Email
    isIDMerchantTextFormEnable =
        false; //In identifier updation we cant edit ID,Email
    _identifiernameController.text = identifierData.identifierName.toString();
    _identifierValueController.text = identifierData.identifierValue.toString();
    identifierId = identifierData.id;
    if ((identifierData.linkedByType == 1) ||
        (identifierData.linkedByType == 2)) {
      identifierUpdateDeleteValue = "deleteonly";
      if (identifierData.linkedByType == 1) {
        _idemailanotheruserController.text = identifierData.userId.toString();
      } else {
        _idanothermerchantController.text = identifierData.userId.toString();
      }
    } else if ((identifierData.linkedByType == null) ||
        (identifierData.linkedByType == 0)) {
      identifierUpdateDeleteValue = "updateanddelete";
      linkedToTypeText = "Self";
    } else {
      identifierUpdateDeleteValue = "deleteonly";
    }
    if (identifierData.linkedByType == 1) {
      if (getPerspective() == "merchant") {
        connectAnotherUserFlag = true;
        linkedToTypeText = "Identifier Created For Another User";
      } else {
        linkedToTypeText = "Identifier Created By Another Business";
      }
    } else if (identifierData.linkedByType == 2) {
      int nowCommunityID =
          Provider.of<MerchantProvider>(context, listen: false).merchantData.id;
      if (nowCommunityID == identifierData.merchantId) {
        connectAnotherMerchantFlag =
            true; //here we make this flag to TRUE for showing ID of Business
        linkedToTypeText = "Identifier Created for Another Business";
      } else {
        linkedToTypeText = "Identifier Created By Another Business";
        _idanothermerchantController.text = identifierData.merchantId;
      }
    } else if (identifierData.linkedByType == "") {
      if (getPerspective() == "merchant") {
        identifierUpdateDeleteValue = "updateanddelete";
        linkedToTypeText = "Identifier Created By Business Self";
      } else {
        identifierUpdateDeleteValue = "updateanddelete";
        linkedToTypeText = "Identifier Created By User Self";
      }
    }
    if (identifierData.mobileNo != null) {
      _mobilenumberPaymentConfirmationController.text =
          identifierData.mobileNo.toString();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    _identifiernameController.dispose();
    _identifierValueController.dispose();
    _idemailanotheruserController.dispose();
    _idanothermerchantController.dispose();
    _mobilenumberPaymentConfirmationController.dispose();
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Color(0xFFe44933),
      content: Text(message),
    ));
  }

  void nfcIdentifierProcess() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) ;

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var identifier = tag.data['nfca']['identifier'];

      final String tagId =
          identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
      _identifierValueController.text = tagId.toString();
    });
  }

  stopNfcScan() {
    NfcManager.instance.stopSession();
  }

  void scanIdentifierQrClickHandler() async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanScreen(
          returnScan: true,
        ),
      ),
    );
    _identifierValueController.text = result.toString();
  }

  void doIdentifierDeleteProcess() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = identifierId;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Identifiers/delete', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      showSnackBar(getTranslated(context, "identifiers_createsuccess"));
      stopNfcScan();
      Navigator.of(context).pop(true);
    } else {
      showSnackBar(getTranslated(context, 'identifiers_deletefailed'));
    }
  }

  void doCreateUpdateIdentifierforUser() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['identifier_name'] = _identifiernameController.text;
    apiBodyObj['identifier'] = _identifierValueController.text;
    setState(() {
      isLoading = true;
    });
    if (createValue) {
      Map<String, dynamic> response =
          await NetworkHelper.request('Identifiers/create', apiBodyObj);
      setState(() {
        isLoading = false;
      });
      if (response["status"] == "success") {
        showSnackBar(getTranslated(context, "identifiers_createsuccess"));
        stopNfcScan();
        Navigator.of(context).pop(true);
      } else {
        if (response['error'] == 'identifiers already exist') {
          showSnackBar(getTranslated(context, 'identifiers_alreadycreated'));
        } else {
          showSnackBar(getTranslated(context, 'identifiers_failed'));
        }
      }
    } else {
      apiBodyObj['id'] = identifierId;
      Map<String, dynamic> response =
          await NetworkHelper.request('Identifiers/update', apiBodyObj);
      setState(() {
        isLoading = false;
      });
      if (response["status"] == "success") {
        stopNfcScan();
        Navigator.of(context).pop(true);
      } else {
        if (response['error'] == 'identifiers already exist') {
          showSnackBar(getTranslated(context, 'identifiers_alreadycreated'));
        } else {
          showSnackBar(getTranslated(context, 'identifiers_failed'));
        }
      }
    }
  }

  validateId(id) {
    Pattern pattern = r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]';
    RegExp regex = new RegExp(pattern);
    if ((id.contains(regex))) {
      return (true);
    }
    return (false);
  }

  void getUserIdfromEmail(emailInput, identifierapiBodyObject) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = emailInput;
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      List responseList = response['result'];
      var userId = responseList[0]['id'].toString();
      identifierapiBodyObject['user_id'] = userId.toString();
      doIdentifierCreateProcess(identifierapiBodyObject);
    }
  }

  void doIdentifierCreateProcess(identifierapiBodyObject) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await NetworkHelper.request(
        'Identifiers/create', identifierapiBodyObject);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      showSnackBar(getTranslated(context, "identifiers_createsuccess"));
      stopNfcScan();
      Navigator.of(context).pop(true);
    } else {
      if (response['error'] == 'identifiers already exist') {
        showSnackBar(getTranslated(context, "identifiers_alreadycreated"));
      } else {
        showSnackBar(getTranslated(context, 'identifiers_failed'));
      }
    }
  }

  void identifierSaveClickHandler() {
    if (Validator.isRequired(_mobilenumberPaymentConfirmationController.text,
        allowEmptySpaces: false)) {
      if (!Validator.isMobile(
          _mobilenumberPaymentConfirmationController.text)) {
        showSnackBar(
            getTranslated(context, 'identifiers_entervalidmobilenumber'));
        return;
      } else {
        validMobilephoneFlag = true;
      }
    } else {
      validMobilephoneFlag = false;
    }

    if (getPerspective() == "merchant") {
      if (createValue) {
        if (connectAnotherUserFlag) {
          //Merchant selected another user option
          if (Validator.isEmail(_idemailanotheruserController.text)) {
            //Merchant selected another user email id option
            Map<String, String> apiBodyObj = {};
            apiBodyObj['identifier_name'] = _identifiernameController.text;
            apiBodyObj['identifier'] = _identifierValueController.text;
            apiBodyObj['user_type'] = "1";
            if (validMobilephoneFlag) {
              apiBodyObj['mobile_no'] =
                  _mobilenumberPaymentConfirmationController.text;
            }
            getUserIdfromEmail(_idemailanotheruserController.text, apiBodyObj);
          } else if (validateId(_idemailanotheruserController.text)) {
            Map<String, String> apiBodyObj = {};
            apiBodyObj['identifier_name'] = _identifiernameController.text;
            apiBodyObj['identifier'] = _identifierValueController.text;
            apiBodyObj['user_type'] = "1";
            apiBodyObj['user_id'] = _idemailanotheruserController.text;
            if (validMobilephoneFlag) {
              apiBodyObj['mobile_no'] =
                  _mobilenumberPaymentConfirmationController.text;
            }
            doIdentifierCreateProcess(apiBodyObj);
          } else {
            showSnackBar(getTranslated(context, 'identifiers_validemailorid'));
          }
        }
        if (connectAnotherMerchantFlag) {
          if (validateId(_idanothermerchantController.text)) {
            Map<String, String> apiBodyObj = {};
            apiBodyObj['identifier_name'] = _identifiernameController.text;
            apiBodyObj['identifier'] = _identifierValueController.text;
            apiBodyObj['user_type'] = "2";
            apiBodyObj['user_id'] = _idanothermerchantController.text;
            if (validMobilephoneFlag) {
              apiBodyObj['mobile_no'] =
                  _mobilenumberPaymentConfirmationController.text;
            }
            doIdentifierCreateProcess(apiBodyObj);
          } else {
            showSnackBar(getTranslated(context, 'identifiers_validmerchantid'));
          }
        }
        if (connectMySelfFlag) {
          Map<String, String> apiBodyObj = {};
          apiBodyObj['identifier_name'] = _identifiernameController.text;
          apiBodyObj['identifier'] = _identifierValueController.text;
          if (validMobilephoneFlag) {
            apiBodyObj['mobile_no'] =
                _mobilenumberPaymentConfirmationController.text;
          }
          doIdentifierCreateProcess(apiBodyObj);
        }
      } else {
        Map<String, String> apiBodyObj = {};
        apiBodyObj['identifier_name'] = _identifiernameController.text;
        apiBodyObj['identifier'] = _identifierValueController.text;
        apiBodyObj['id'] = identifierId;
        if (validMobilephoneFlag) {
          apiBodyObj['mobile_no'] =
              _mobilenumberPaymentConfirmationController.text;
        }
        doIdentifierUpdateProcess(apiBodyObj);
      }
    } else {
      doCreateUpdateIdentifierforUser();
    }
  }

  doIdentifierUpdateProcess(apiBodyObj) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Identifiers/update', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Navigator.of(context).pop(true);
    } else {
      if (response['error'] == 'identifiers already exist') {
        showSnackBar(getTranslated(context, "identifiers_alreadycreated"));
      } else {
        showSnackBar(getTranslated(context, 'identifiers_failed'));
      }
    }
  }

  String getPerspective() {
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      return "user";
    } else {
      return "merchant";
    }
  }

  void showConnectionTypeIdEmail(type) {
    if (type == "My Self") {
      connectMySelfFlag = true;
      connectAnotherUserFlag = false;
      connectAnotherMerchantFlag = false;
    } else if (type == "Another User") {
      connectMySelfFlag = false;
      connectAnotherUserFlag = true;
      connectAnotherMerchantFlag = false;
    } else {
      connectMySelfFlag = false;
      connectAnotherUserFlag = false;
      connectAnotherMerchantFlag = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.

    Widget userIdentifierLayout() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          createValue
              ? SizedBox()
              : Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    linkedToTypeText,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      );
    }

    Widget merchantIdentifierLayout() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          createValue
              ? Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    getTranslated(context, 'identifiers_userconnected'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
              : Text(
                  linkedToTypeText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          //SizedBox(height: 10),
          createValue
              ? DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                  ),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 18,
                  elevation: 12,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  value: connectingType,
                  onChanged: (String newValue) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    connectingType = newValue;
                    showConnectionTypeIdEmail(connectingType);
                  },
                  items: <String>["My Self", "Another User", "Another Business"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.toString(),
                      ),
                    );
                  }).toList(),
                )
              : SizedBox(),
          SizedBox(height: 10),
          connectAnotherUserFlag
              ? TextFormField(
                  enabled: isIDEmailUserTextFormEnable,
                  controller: _idemailanotheruserController,
                  decoration: InputDecoration(
                    labelText: 'ID, email',
                    hintText:
                        getTranslated(context, 'identifiers_enteridoremail'),
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                      return getTranslated(
                          context, 'identifiers_validemailorid');
                    }
                    return null;
                  },
                )
              : SizedBox(),
          connectAnotherMerchantFlag
              ? TextFormField(
                  enabled: isIDMerchantTextFormEnable,
                  controller: _idanothermerchantController,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    hintText: 'ID',
                  ),
                  validator: (value) {
                    if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                      return getTranslated(context, 'identifiers_validid');
                    }
                    return null;
                  },
                )
              : SizedBox(),
          SizedBox(height: 10),
          Text(
            getTranslated(context, 'identifiers_optionalmobilenumber'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: _mobilenumberPaymentConfirmationController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText:
                  getTranslated(context, 'identifiers_mobilephonenumber'),
              hintText: getTranslated(context, 'identifiers_enterphonenumber'),
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Create',
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              autovalidateMode: enableAutoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: ListView(children: [
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _identifiernameController,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Identifier name',
                      hintText: 'identifier name',
                    ),
                    validator: (value) {
                      if (!Validator.isRequired(value)) {
                        return getTranslated(
                            context, 'identifiers_valididentifiername');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _identifierValueController,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: 'QR Code',
                            hintText: 'identifier RFID,QR Code',
                          ),
                          validator: (value) {
                            if (!Validator.isRequired(value)) {
                              return getTranslated(
                                  context, 'identifiers_qrcodeornfc');
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.qr_code,
                          size: 40,
                        ),
                        onPressed: () {
                          scanIdentifierQrClickHandler();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      getTranslated(context, 'identifiers_qrortapnfc'),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //
                  merchantPerspectiveFlag
                      ? merchantIdentifierLayout()
                      : userIdentifierLayout(),
                  SizedBox(height: 10),
                  if (createValue == true)
                    CustomButton(
                      label: getTranslated(context, 'save'),
                      onPressed: saveClickPossible
                          ? () {
                              setState(() {
                                enableAutoValidate = true;
                              });
                              if (_formKey.currentState.validate()) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                identifierSaveClickHandler();
                              }
                            }
                          : null,
                    )
                  else
                    Column(
                      children: <Widget>[
                        ConditionalSwitch.single<String>(
                          context: context,
                          valueBuilder: (BuildContext context) =>
                              identifierUpdateDeleteValue,
                          caseBuilders: {
                            'deleteonly': (BuildContext context) => Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        label: "DELETE",
                                        onPressed: () {
                                          doIdentifierDeleteProcess();
                                        },
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                            'updateanddelete': (BuildContext context) =>
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: CustomButton(
                                        label: 'UPDATE',
                                        onPressed: saveClickPossible
                                            ? () {
                                                setState(() {
                                                  enableAutoValidate = true;
                                                });
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          FocusNode());
                                                  identifierSaveClickHandler();
                                                }
                                              }
                                            : null,
                                      )),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: CustomButton(
                                          label: "DELETE",
                                          onPressed: () {
                                            doIdentifierDeleteProcess();
                                          },
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          },
                          fallbackBuilder: (BuildContext context) =>
                              Text('Self'),
                        ),
                      ],
                    )
                ]),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
