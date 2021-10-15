import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/lending/lending_terms_and_conditions.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:path/path.dart' as path;

class LendingCreateScreen extends StatefulWidget {
  @override
  _LendingCreateScreenState createState() => _LendingCreateScreenState();
}

class _LendingCreateScreenState extends State<LendingCreateScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final collateralController = TextEditingController();
  final firstTransferDateController = TextEditingController();
  bool _firstDateSelected = false;
  bool _payTwiceAMonthSelected = false;
  bool _setCollateralSelected = false;
  bool _checkTermsAndConditions = false;
  var interestRate = '';
  var interestRateSelected = '';
  String duration = '3 months';
  var firstTransferDateSelected = '';
  var txtCalculate = "CALCULATE TOTAL REPAYMENT";
  List<FileItem> files = [];
  String fileName;
  String notes = '';
//'Set the percentage interest you want to offer for a loan, with the time to pay it back. Once the loan is approved, a 3% fee is charged on the total amount, before the loan is transferred to your wallet. The first payment is due 30 days after the initial amount has been transferred to you, but the interest is calculated on the outstanding balance on a daily basis. Early payment will result in less interest being charged.',
  final durations = {
    '3 months': '3 months',
    '6 months': '6 months',
    '9 months': '9 months',
    '12 months': '12 months'
  };
  var html =
      """ <p>Please read this Terms and Conditions carefully as a defined agreement between</p>\r\n\r\n<p><strong>YOU</strong> and <strong>TAGCASH LTD. INC.</strong></p>\r\n\r\n<p>By electronically agreeing to these, you have read and fully understand all the terms and conditions in this agreement. Failure to do so, Tagcash Ltd. Inc. will <strong>NOT</strong> be held liable for any loss or damages that are covered by this agreement.</p>\r\n\r\n<p> </p>\r\n\r\n<p><strong>Loan Application Requirements:</strong></p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>Account MUST be Level 3 KYC verified;</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Consecutive 3-month wallet transactions; and</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Account must not have an <strong>on-going loan</strong> or<strong> loan default records</strong>.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p> </p>\r\n\r\n<p>1. LOAN REQUEST</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>Are subject for approval.</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>No Guarantee for posted loan requests. Tagcash does not warrant or guarantee that loan requests will be funded.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p>2. LOAN TERM</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>Borrowers can request a loan payable within: Three (3) / Six (6) / Nine (9) or Twelve (12) months.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p>3. Not Completed/Accepted Loan</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>If the Pledged amount is not accepted by the borrower it will automatically be returned to the Wallet after Thirty (30) days .</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p>4. BORROWER</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>Should have completed all the requirements upon request</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Pledged amount should be accepted once it reached the “request amount”</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p>5. LENDER</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>Enters into any loan on his/her Free Will and must have gone through KYC verification up to or at least Level 3 to participate in one or more transactions;</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Any Pledged amount will be considered as Locked Balance, which is Not allowed to be consumed in other wallet services (<em>i.e send/transfer,pay bills or buy load</em>);</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>A 10% fee will be deducted from the total paid interest.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p>6. FEES</p>\r\n\r\n<ol>\r\n\t<li>\r\n\t<p>3% completion fee deducted from the total amount received</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>10% fee is deducted from the total interest paid</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Fees or interest are not refundable</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Interest is set by the Borrower</p>\r\n\t</li>\r\n</ol>\r\n\r\n<p>7. PAYMENT</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>On Due date - Term of loan is set to be paid every Thirty (30) days (Wallet should have enough balance for the due amount as automatic deduction will occur).</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Late Payment - Interest will be added on the next payment due. Amount paid will be deducted from the total principal amount. Account will be on hold and needs to notify Tagcash if it has been paid to unhold it.</p>\r\n\t</li>\r\n\t<li>\r\n\t<p>Early Payment - Interest is computed based on the difference between the last date of payment and the current date of payment. Amount paid will be deducted from the total principal amount and the due amount for the month will be recomputed for settlement.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p> </p>\r\n\r\n<p>8.<strong> Unpaid dues will cause a hold on the User's account until it is settled. </strong></p>\r\n\r\n<p>9. Loan Issue/Concern</p>\r\n\r\n<ul>\r\n\t<li>\r\n\t<p>must be reported within 3 business days with supporting documentation. The Tagcash team will investigate within 5 business days. If the update is not given within the turnaround time, Tagcash team must notify the user of the date of completion.</p>\r\n\t</li>\r\n</ul>\r\n\r\n<p> </p>\r\n\r\n<p>For any questions or further inquiries you may contact us at:</p>\r\n\r\n<p><em><strong>Phone:</strong></em><em> +63 (02) 8804 2486 and +63 (02) 7955 7081</em></p>\r\n\r\n<p><em><strong>E-mail:</strong></em><em> <a href="mailto:info@tagcash.com">info@tagcash.com</a></em> / <em><a href="mailto:accounts@tagcash.com">accounts@tagcash.com</a>.</em></p>\r\n\r\n<p>Or visit us: <em>Unit 2108 88 Corporate Center 141 Valero St., Makati City </em></p>\r\n\r\n<p> </p>\r\n\r\n<p>You may also follow our Social Media accounts:</p>\r\n\r\n<p><strong>Facebook</strong> > <em>facebook.com/tagcashrewards;</em></p>\r\n\r\n<p><strong>Twitter</strong> > <em>twitter.com/tagcashwallet; </em></p>\r\n\r\n<p><strong>Instagram </strong>> <em>instagram.com/tagcashph</em>.</p>\r\n\r\n<p> </p>\r\n""";
  String termsAndConditions = '';

  @override
  void initState() {
    super.initState();
    txtCalculate = getTranslated(context, "calculate_total_repayment");
    getTermsAndConditions();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    amountController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    collateralController.dispose();
    firstTransferDateController.dispose();
    super.dispose();
  }

  Future<String> getInterestRate() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetInterestRates');

    if (response['status'] == 'success') {
      var interestRate = response['result']['interest_rates'];
      this.interestRateSelected =
          this.interestRate = interestRate[0].toString();
      return interestRate[0].toString();
    }
    return '';
  }

  getTermsAndConditions() async {
    print('getTermsAndConditions');

    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/GetTermsAndConditions');

    String termsAndConditions = response['result'];

    this.termsAndConditions = termsAndConditions;
    print(this.termsAndConditions);
    setState(() {
      this.notes = response['notes'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "crowd_lending"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                          decoration: InputDecoration(
                            hintText: getTranslated(context, "enter_amount"),
                            labelText: getTranslated(context, "amount"),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return getTranslated(
                                  context, "please_enter_amount");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          Container(
                            width: 130,
                            child: DropdownButtonFormField(
                              // value: _ratingController,
                              items: durations.entries
                                  .map<DropdownMenuItem<String>>(
                                      (MapEntry<String, String> e) =>
                                          DropdownMenuItem<String>(
                                            value: e.key,
                                            child: Text(e.value),
                                          ))
                                  .toList(),
                              decoration: InputDecoration(
                                hintText: '3 months',
                                filled: true,
                                errorStyle: TextStyle(color: Colors.yellow),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  duration = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: new BoxDecoration(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('@'),
                            ),
                          ),
                          SizedBox(width: 10),
                          _setCollateralSelected
                              ? Text("2 % interest",
                                  style: Theme.of(context).textTheme.subtitle1)
                              : _InterestRateWidget(
                                  getInterestRate().asStream()),
                        ]),
                        CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _firstDateSelected,
                          title: Text(getTranslated(
                              context, "set_first_transfer_date")),
                          onChanged: (bool value) {
                            setState(() {
                              _firstDateSelected = value;
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                        if (_firstDateSelected)
                          TextFormField(
                              controller: firstTransferDateController,
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    context, "enter_first_transfer_date"),
                                labelText: getTranslated(
                                    context, "first_transfer_date"),
                              ),
                              validator: (value) {
                                if (value.isEmpty && _firstDateSelected) {
                                  return getTranslated(context,
                                      "please_enter_first_transfer_date");
                                }
                                return null;
                              },
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now()
                                      .add(new Duration(days: 30)),
                                  initialDate: DateTime.now()
                                      .add(new Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(new Duration(days: 40)),
                                );
                                if (date != null) {
                                  print(date);
                                  final DateFormat formatterTxt =
                                      DateFormat('dd-MM-yyyy');
                                  final String formattedTxt =
                                      formatterTxt.format(date);
                                  firstTransferDateController.text =
                                      formattedTxt;
                                  final DateFormat formatterVal =
                                      DateFormat('yyyy-MM-dd');
                                  final String formattedVal =
                                      formatterVal.format(date);
                                  firstTransferDateSelected = formattedVal;
                                }
                              }),
                        SizedBox(width: 10),
                        CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _payTwiceAMonthSelected,
                          title:
                              Text(getTranslated(context, "pay_twice_a_month")),
                          onChanged: (bool value) {
                            setState(() {
                              _payTwiceAMonthSelected = value;
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                        SizedBox(width: 10),
                        CheckboxListTile(
                          //checkColor: Colors.red[600],
                          activeColor: kPrimaryColor,
                          value: _setCollateralSelected,
                          title: Text(getTranslated(context, "set_collateral")),
                          onChanged: (bool value) {
                            setState(() {
                              _setCollateralSelected = value;
                              if (_setCollateralSelected) {
                                interestRateSelected = '2';
                              } else {
                                interestRateSelected = interestRate;
                              }
//                            widget.onSelectedAnonymousChanged(_anonymousSelected);
                            });
                          },
                          controlAffinity: ListTileControlAffinity
                              .leading, //  <-- leading Checkbox
                        ),
                        SizedBox(width: 10),
                        if (_setCollateralSelected)
                          Row(
                            children: [
                              Text(
                                'BTC',
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: collateralController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: false),
                                  decoration: InputDecoration(
                                    hintText: getTranslated(
                                        context, "enter_collateral"),
                                    labelText:
                                        getTranslated(context, "collateral"),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty &&
                                        _setCollateralSelected) {
                                      return getTranslated(
                                          context, "please_enter_collateral");
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text('$txtCalculate'),
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.black,
                            textColor:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                            onPressed: () {
                              if (_formKey1.currentState.validate())
                                getTotalRepaymentHandler();
                            },
                          ),
                        ),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: getTranslated(context, "enter_title"),
                            labelText: getTranslated(context, "title"),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return getTranslated(
                                  context, "please_enter_title");
                            }
                            if (isNumeric(value)) {
                              return getTranslated(context,
                                  "please_dont_enter_a_number_as_title");
                            }
                            return null;
                          },
                        ),
                        SizedBox(width: 10),
                        TextFormField(
                          controller: descriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText:
                                getTranslated(context, "enter_description"),
                            labelText: getTranslated(context, "description"),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return getTranslated(
                                  context, "please_enter_description");
                            }
                            if (isNumeric(value)) {
                              return getTranslated(context,
                                  "please_dont_enter_number_as_description");
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),

                        GestureDetector(
                          onTap: () => selectFileClicked(),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 100,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.add_circle_sharp,
                                    size: 18,
                                    color: kPrimaryColor,
                                  ),
                                  SizedBox(width: 10),
                                  Text(getTranslated(context, "attach_file")),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        // Expanded(
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            //padding: const EdgeInsets.all(8),
                            itemCount: files.length,
                            itemBuilder: (BuildContext context, int index) {
                              return FileRowItem(files[index].fileName,
                                  onDelete: () => removeItem(index));
                            }),
                        SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.info_outline,
                              color: kPrimaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(notes, style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 30),
                        Row(children: [
                          Checkbox(
                            activeColor: kPrimaryColor,
                            value: _checkTermsAndConditions,
                            onChanged: (bool value) {
                              setState(() {
                                _checkTermsAndConditions = value;
                              });
                            },
                          ),
                          new Text(
                            getTranslated(context, "i_agree_to_the"),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                              child: new Text(
                                getTranslated(context, "terms_and_conditions"),
                                style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo),
                              ),
                              onTap: () {
                                setState(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LendingTermsandConditionsScreen(
                                                  termsAndCondtions:
                                                      termsAndConditions)));
                                });
                              }),
                        ]),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text(getTranslated(context, "create")),
                            color: kPrimaryColor,
                            textColor: Colors.white,
                            onPressed: () {
//                              if (_formKey1.currentState.validate()) {
//                                _formKey1.currentState.save();
                              _formKey1.currentState.validate();
                              if (_formKey2.currentState.validate()) {
                                if (interestRateSelected == '') {
                                  final snackBar = SnackBar(
                                      content: Text(getTranslated(context,
                                          "interest_rate_should_not_be_empty")),
                                      duration: const Duration(seconds: 3));
                                  globalKey.currentState.showSnackBar(snackBar);
                                } else if (_checkTermsAndConditions == false) {
                                  final snackBar = SnackBar(
                                      content: Text(getTranslated(context,
                                          "please_agree_to_the_terms_and_conditions")),
                                      duration: const Duration(seconds: 3));
                                  globalKey.currentState.showSnackBar(snackBar);
                                } else
                                  createLendRequestHandler();
                              }
                            },
                          ),
                        ),
//                      Expanded(
//                        child: Text(
//                            'Total to pay/repaid: ' +
//                                totalPaidAmount.toString(),
//                            style: TextStyle(fontWeight: FontWeight.bold)),
//                      ),
                      ],
                    ),
                  ),
                ],
              ),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: Loading()))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      //print("hiiii"+index.toString());
      files.removeAt(index);
    });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        String fileName = result.files.single.name;
        files.add(new FileItem(
            fileName: fileName, fullFileName: result.files.single.path));
      });
    }
  }

  createLendRequestHandler() async {
    print("createLendRequestHandler " + interestRateSelected);
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['title'] = titleController.text.toString();
    apiBodyObj['description'] = descriptionController.text.toString();
    apiBodyObj['amount'] = amountController.text.toString();
    apiBodyObj['duration'] = duration.toString();

    if (_setCollateralSelected) {
      interestRateSelected = '2';
    } else {
      interestRateSelected = interestRate;
    }

    apiBodyObj['interest_percent'] = interestRateSelected.toString();
    if (_firstDateSelected)
      apiBodyObj['first_transfer_date'] = firstTransferDateSelected;
    if (_payTwiceAMonthSelected) apiBodyObj['pay_twice_a_month'] = '1';
    if (_setCollateralSelected) {
      apiBodyObj['collateral_type'] = 'btc_collateral';
      apiBodyObj['collateral_value'] = collateralController.text.toString();
    } else {
      apiBodyObj['collateral_type'] = 'none';
      apiBodyObj['collateral_value'] = '0';
    }
    apiBodyObj['disable_3_month_limit'] = '1';
    apiBodyObj['wallet_id'] = '1';
    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/create', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      if (files.length == 0)
        Navigator.of(context).pop({'status': 'success'});
      else {
        bool isLastFile = false;
        for (var i = 0; i < files.length; i++) {
          if (i == (files.length - 1)) isLastFile = true;
          uploadDoc(response['lend_id'], files[i], isLastFile);
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "you_are_blocked_to_request_the_loan") {
        err = getTranslated(context, "you_are_blocked_to_request_the_loan");
      } else if (response['error'] == "amount_should_be_numeric") {
        err = getTranslated(context, "amount_should_be_numeric");
      } else if (response['error'] == "amount_required") {
        err = getTranslated(context, "amount_is_required");
      } else if (response['error'] ==
          "duration_should_be_3_months_or_6_months_or_9_months_or_12_months") {
        err = getTranslated(context,
            "duration_should_be_3_months_or_6_months_or_9_months_or_12_months");
      } else if (response['error'] == "duration_is_required") {
        err = getTranslated(context, "please_select_a_duration");
      } else if (response['error'] == "interest_percent_is_required") {
        err = getTranslated(context, "interest_percent_is_required");
      } else if (response['error'] == "description_is_required") {
        err = getTranslated(context, "description_is_required");
      } else if (response['error'] == "collateral_type_is_required") {
        err = getTranslated(context, "collateral_type_is_required");
      } else if (response['error'] == "wallet_id_is_required") {
        err = getTranslated(context, "please_select_a_wallet");
      } else if (response['error'] ==
          "lending_request_charge_transfer_failed") {
        err = getTranslated(context, "lending_request_charge_transfer_failed");
      } else if (response['error'] ==
          "insufficient_lending_request_charge_amount") {
        err = getTranslated(
            context, "insufficient_lending_request_charge_amount");
      } else if (response['error'] ==
          "amount_requested_exceeded_last_3_month_incoming_limit") {
        err = getTranslated(context, "amount_requested_exceeded") +
            response['max_amount_can_request'] +
            ".";
      } else if (response['error'] == "merchant_is_not_verified") {
        err = getTranslated(context, "merchant_is_not_verified");
      } else if (response['error'] == "fee_amount_transfer_failed") {
        err = getTranslated(context, "fee_amount_transfer_failed");
      } else if (response['error'] == "insufficient_fee_amount") {
        err = getTranslated(context, "insufficient_fee_amount");
      } else if (response['error'] == "maximum_amount_can_request") {
        err = getTranslated(context, "insufficient_collateral_value");
      } else if (response['error'] ==
          "please_enter_a_valid_first_transfer_date_format") {
        err =
            getTranslated(context, "please_enter_a_valid_first_transfer_date");
      } else if (response['error'] ==
          "first_transfer_date_should_be_higher_than_one_month_from_current_date") {
        err = getTranslated(context,
            "first_transfer_date_should_be_1_month_ahead_of_todays_date");
      } else if (response['error'] == "user_is_not_level_3_verified") {
        err = getTranslated(
            context, "you_must_be_level_3_verified_to_create_a_lend_request");
      } else if (response['error'] ==
          "you_have_outstanding_loan_you_cannot_ask_for_another_one_till_been_paid_off") {
        err = getTranslated(context, "you_have_an_outstanding_loan");
      } else if (response['error'] == "insuffcient_btc_balance") {
        err = getTranslated(context, "you_have_insufficient_btc_balance");
      } else if (response['error'] == "exceeded_maximum_first_transfer_date") {
        err = getTranslated(
            context, "you_have_exceeded_maximum_first_transfer_date");
      } else
        err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  getTotalRepaymentHandler() async {
    print("getTotalRepaymentHandler " + interestRateSelected);
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['amount_requested'] = amountController.text.toString();
    apiBodyObj['months'] = duration.toString();
    apiBodyObj['interest'] = interestRateSelected.toString();
    if (_payTwiceAMonthSelected) apiBodyObj['pay_twice_a_month'] = '1';
    Map<String, dynamic> response = await NetworkHelper.request(
        'PeerToPeer/GetTotalRepayAmount', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      txtCalculate = getTranslated(context, "total_repayment") +
          ": " +
          response['total'].toString();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  uploadDoc(String id, FileItem fileItem, bool isLastFile) async {
    setState(() {
      isLoading = true;
    });
    print(id + " " + fileItem.fullFileName);
    File tempFile = File(fileItem.fullFileName);
    List<int> receiptImageBytes = tempFile.readAsBytesSync();
    var apiBodyObj = {};
    apiBodyObj['lend_request_id'] = id;
    apiBodyObj['file_data'] = base64Encode(receiptImageBytes);
    apiBodyObj['file_name'] = fileItem.fileName;

    Map<String, dynamic> response =
        await NetworkHelper.request('PeerToPeer/UploadLendFiles', apiBodyObj);

    if (response['status'] == 'success') {
      if (isLastFile) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop({'status': 'success'});
      }
    } else {
      setState(() {
        isLoading = false;
      });
      String err;
      if (response['error'] == "file_name_is_required") {
        err = getTranslated(context, "file_name_is_required");
      } else if (response['error'] == "file_data_is_required") {
        err = getTranslated(context, "file_data_is_required");
      } else if (response['error'] == "failed_to_upload_the_lend_file") {
        err = getTranslated(context, "failed_to_upload_the_file");
      } else if (response['error'] == "request_not_completed") {
        err = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "lend_request_id_is_required") {
        err = getTranslated(context, "lend_request_id_is_required");
      } else
        err = response['error'];

      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class _InterestRateWidget extends StatefulWidget {
  _InterestRateWidget(this.stream);

  final Stream<String> stream;

  @override
  State<StatefulWidget> createState() => _InterestRateWidgetState();
}

class _InterestRateWidgetState extends State<_InterestRateWidget> {
  String text;

  @override
  void initState() {
    widget.stream.listen((String data) {
      setState(() {
        text = data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (text == null)
      return Row(children: [
        SizedBox(
          child: new CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          height: 15.0,
          width: 15.0,
        ),
        SizedBox(width: 5),
        Text(getTranslated(context, "calculating_interest"))
      ]);
    else
      return Text(text + getTranslated(context, "percent_interest"),
          style: Theme.of(context).textTheme.subtitle1);
  }
}

class FileItem {
  String fileName;
  String fullFileName;

  FileItem({this.fileName, this.fullFileName});
}

class FileRowItem extends StatelessWidget {
  final String fileName;

  final VoidCallback onDelete;

  FileRowItem(this.fileName, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Icon(Icons.file_present),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: kPrimaryColor,
              iconSize: 24,
              tooltip: getTranslated(context, "delete"),
              onPressed: this.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
