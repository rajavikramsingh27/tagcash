import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/file_pick_form_field.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:path/path.dart' as path;

class KYCCustomsLimitsPage extends StatefulWidget {
  @override
  _KYCCustomsLimitsState createState() => _KYCCustomsLimitsState();
}

class _KYCCustomsLimitsState extends State<KYCCustomsLimitsPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<USINGDURATION> _durationTime = USINGDURATION.getDuration();
  List<DropdownMenuItem<USINGDURATION>> _durationMenuItems;
  USINGDURATION _selectedDuration;

  List<EMPLOYMENTTYPE> _emplomentType = EMPLOYMENTTYPE.getEmploymentType();
  List<DropdownMenuItem<EMPLOYMENTTYPE>> _emplomentMenuItems;
  EMPLOYMENTTYPE _selectedEmployment;

  bool isLoading = false;
  bool enableAutoValidate = false;
  var kycProofofAddressVerifyStatus;
  File _receiptFile;
  bool isLogoVisible = false;
  bool document1 = false;
  bool document2 = false;
  bool document1Uploaded = false;
  bool document2Uploaded = false;
  bool isPoliticalPosition = false;
  bool isElected = false;
  int typeIndex;
  var oftenType;
  var jobType;
  final amount = TextEditingController();
  final extraNote = TextEditingController();
  @override
  void initState() {
    document1 = false;
    document2 = false;
    _durationMenuItems = buildDropdownMenuItems(_durationTime);
    _selectedDuration = _durationMenuItems[0].value;
    oftenType = _selectedDuration.value;

    _emplomentMenuItems = buildEmplymentMenuItems(_emplomentType);
    _selectedEmployment = _emplomentMenuItems[0].value;
    jobType = _selectedEmployment.name;
    typeIndex = 0;

    super.initState();
  }

  @override
  void dispose() {
    amount.dispose();
    extraNote.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<USINGDURATION>> buildDropdownMenuItems(
      List durationTypes) {
    List<DropdownMenuItem<USINGDURATION>> items = List();
    for (USINGDURATION obj in durationTypes) {
      items.add(
        DropdownMenuItem(
          value: obj,
          child: Text(obj.name),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<EMPLOYMENTTYPE>> buildEmplymentMenuItems(
      List emplymentTypes) {
    List<DropdownMenuItem<EMPLOYMENTTYPE>> items = List();
    for (EMPLOYMENTTYPE obj in emplymentTypes) {
      items.add(
        DropdownMenuItem(
          value: obj,
          child: Text(obj.name),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(USINGDURATION selectedCompany) {
    setState(() {
      _selectedDuration = selectedCompany;
      oftenType = _selectedDuration.value;
    });
  }

  onChangeDropdownItemtwo(EMPLOYMENTTYPE selectedCompany) {
    setState(() {
      _selectedEmployment = selectedCompany;
      jobType = _selectedEmployment.name;
    });
  }

  void setPickedFIle(File pickedFile) {
    document1 = true;
    Map<String, dynamic> fileData;

    if (pickedFile != null) {
      var file = pickedFile;
      String basename = path.basename(file.path);

      fileData = {};
      fileData['key'] = 'data';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
      uploadFile(fileData);
    }
  }

  void setPickedFIle2(File pickedFile) {
    document2 = true;
    Map<String, dynamic> fileData;

    if (pickedFile != null) {
      var file = pickedFile;
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
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await NetworkHelper.request(
        'verification/Upload', apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      if (document1 == true) {
        document1Uploaded = true;
      }
      if (document2 == true) {
        document2Uploaded = true;
      }
    } else {
      if (response['error'] == 'email_verification_pending') {
        showMessage('Email verification is pending');
      } else if (response['error'] == 'sms_verification_pending') {
        showMessage('SMS verification is pending');
      } else if (response['error'] == 'already_data_approved') {
        showMessage('Already approved');
      } else if (response['error'] == 'data_waiting_for_approval') {
        showMessage('Data is waiting approval');
      } else if (response['error'] == 'pending_approval') {
        showMessage('Upload pending approval');
      } else {
        showMessage(response['error']);
      }
    }
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      typeIndex = value;

      switch (typeIndex) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  submitForVerificationClickHandler() async {
    if (document1Uploaded == false) {
      showMessage('Please upload document ');
      return;
    }
    if (document2Uploaded == false) {
      showMessage('Please upload document');
      return;
    }
    var apiBodyObj = {};
    apiBodyObj['amount'] = amount.text.toString();
    apiBodyObj['extra_note'] = extraNote.text.toString();
    apiBodyObj['how_often_using'] = oftenType.toString();
    apiBodyObj['job_type'] = jobType.toString();
    if (isPoliticalPosition == true) {
      apiBodyObj['elected_to_political_position'] = "1";
    } else {
      apiBodyObj['elected_to_political_position'] = "0";
    }

    if (isElected == true) {
      apiBodyObj['friend_elected_to_political_position'] = "1";
    } else {
      apiBodyObj['friend_elected_to_political_position'] = "0";
    }

    if (typeIndex == 0) {
      apiBodyObj['using_tagcash'] = "personal";
    } else {
      apiBodyObj['using_tagcash'] = "business";
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/Level5Data', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      setState(() {
        showMessage('Information has been submitted');
        Navigator.pop(context, true);
      });
    } else {
      if (response['error'] == 'email_verification_pending') {
        showMessage('Email verification is pending');
      } else if (response['error'] == 'sms_verification_pending') {
        showMessage('SMS verification is pending');
      } else if (response['error'] == 'already_data_approved') {
        showMessage('Already approved');
      } else if (response['error'] == 'pending_approval') {
        showMessage('Upload pending approval');
      } else if (response['error'] == 'data_waiting_for_approval') {
        showMessage('Data is waiting approval');
      } else {
        showMessage('Failed to submit data');
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Custom Limits',
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                Text(
                  "UPLOAD 2 DOCUMENTS SHOWING INCOME",
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "EG: Bank Statements within last 3 months, payslips, tax returns, sales of stocks, shares or property within the last 6 months or anything that shows source of funds",
                ),
                SizedBox(height: 10),
                document1Uploaded
                    ? CustomButton(
                        label: 'UPLOADED',
                        color: Colors.green,
                      )
                    : FilePickFormField(
                        icon: Icon(Icons.note),
                        onChanged: (newFile) {
                          if (newFile != null) {
                            setPickedFIle(newFile);
                          }
                        },
                        validator: (img) {
                          if (img == null) {
                            return 'Please select a document';
                          }
                          return null;
                        },
                        hintText: 'Select first document',
                        labelText: "Upload document",
                      ),
                SizedBox(height: 10),
                document2Uploaded
                    ? CustomButton(
                        label: 'UPLOADED',
                        color: Colors.green,
                      )
                    : FilePickFormField(
                        icon: Icon(Icons.note),
                        onChanged: (newFile) {
                          if (newFile != null) {
                            setPickedFIle2(newFile);
                          }
                        },
                        validator: (img) {
                          if (img == null) {
                            return 'Please select a document';
                          }
                          return null;
                        },
                        hintText: 'Select second document',
                        labelText: "Upload document",
                      ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text(
                      "Have you ever been elected to a political position?"),
                  value: isPoliticalPosition,
                  onChanged: (newValue) {
                    setState(() {
                      isPoliticalPosition = newValue;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("Has a friend or relative ever been elected?"),
                  value: isElected,
                  onChanged: (newValue) {
                    setState(() {
                      isElected = newValue;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 10),
                Text(
                  "Using Tagcash For?",
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.left,
                ),
                Row(
                  children: [
                    Radio(
                      groupValue: typeIndex,
                      focusColor: Colors.black,
                      activeColor: Colors.black,
                      value: 0,
                      onChanged: _handleRadioValueChange,
                    ),
                    new Text('Personal'),
                    Radio(
                        groupValue: typeIndex,
                        focusColor: Colors.black,
                        activeColor: Colors.black,
                        value: 1,
                        onChanged: _handleRadioValueChange),
                    new Text('Business'),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "How often do you use Tagcash?",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                DropdownButtonFormField(
                  value: _selectedDuration,
                  items: _durationMenuItems,
                  onChanged: onChangeDropdownItem,
                ),
                SizedBox(height: 20),
                Text(
                  "Employment?",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(
                  height: 4,
                ),
                DropdownButtonFormField(
                  value: _selectedEmployment,
                  items: _emplomentMenuItems,
                  onChanged: onChangeDropdownItemtwo,
                ),
                SizedBox(height: 20),
                Text(
                  "How much money (in PHP) is or will be going in and out of your Tagcash account each month?",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                TextFormField(
                  controller: amount,
                  decoration: new InputDecoration(labelText: 'Amount'),
                  validator: (amount) {
                    if (amount.isEmpty) {
                      return 'Amount is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  minLines: 3,
                  maxLines: null,
                  controller: extraNote,
                  decoration: new InputDecoration(
                      labelText: 'Why do you need to increase your limit?'),
                  validator: (extraNote) {
                    if (extraNote.isEmpty) {
                      return 'Amount is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('SUBMIT FOR VERIFICATION'),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      submitForVerificationClickHandler();
                    }
                  },
                ),
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class USINGDURATION {
  int intex;
  String name;
  String value;

  USINGDURATION(this.intex, this.name, this.value);

  static List<USINGDURATION> getDuration() {
    return <USINGDURATION>[
      USINGDURATION(0, 'Daily', 'daily'),
      USINGDURATION(1, 'Weekly', 'weekly'),
      USINGDURATION(2, 'Monthly', 'monthly'),
    ];
  }
}

class EMPLOYMENTTYPE {
  int value;
  String name;

  EMPLOYMENTTYPE(this.value, this.name);

  static List<EMPLOYMENTTYPE> getEmploymentType() {
    return <EMPLOYMENTTYPE>[
      EMPLOYMENTTYPE(0, 'Employed'),
      EMPLOYMENTTYPE(1, 'Registered Business Owner'),
      EMPLOYMENTTYPE(2, 'Freelance'),
      EMPLOYMENTTYPE(3, 'Retired'),
      EMPLOYMENTTYPE(3, 'Unemployed'),
    ];
  }
}
