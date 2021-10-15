import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/shopping/components/custom_input_formatter.dart';
import 'package:tagcash/apps/shopping/components/payment_card.dart';
import 'package:tagcash/apps/shopping/models/history.dart';
import 'package:tagcash/apps/shopping/payment/payment_service.dart';
import 'package:tagcash/apps/shopping/payment/payment_status_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'existing_cards.dart';

class CreateNewCardScreen extends StatefulWidget {
  String amount, currency, shopId, shopTitle, addressId, paymentType;

  CreateNewCardScreen(
      {Key key,
      this.amount,
      this.currency,
      this.shopId,
      this.shopTitle,
      this.addressId,
      this.paymentType})
      : super(key: key);

  @override
  CreateNewCardScreenState createState() => CreateNewCardScreenState();
}

class CreateNewCardScreenState extends State<CreateNewCardScreen> {
  bool isLoading = false;
  bool _loading = false;
  List<History> getHistoryData = new List<History>();

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var dateController = new TextEditingController();
  var cvvController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidateMode = AutovalidateMode.disabled;

  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        _onCreateCard();
        break;
      case 1:
        Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) => ExistingCardsScreen(
                  amount: widget.amount,
                  currency: widget.currency,
                  shopId: widget.shopId,
                  shopTitle: widget.shopTitle,
                  addressId: widget.addressId,
                  paymentType: widget.paymentType)),
        );
        break;
    }
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new CircularProgressIndicator(),
              SizedBox(height: 15),
              Text("Please Wait",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Payment in progress",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            ],
          ),
        ));
      },
    );
  }

  void _onCreateCard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: StatefulBuilder(builder: (context, StateSetter setState) {
          return Container(
              padding: EdgeInsets.all(10),
              height: 280,
              child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: new ListView(
                    children: <Widget>[
                      new SizedBox(
                        height: 20.0,
                      ),
                      new TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          new LengthLimitingTextInputFormatter(16),
                          new CardNumberInputFormatter()
                        ],
                        controller: numberController,
                        decoration: new InputDecoration(
//                                icon: CardUtils.getCardIcon(_paymentCard.type),
                            hintText: '1234 1234 1234 1234',
                            labelText: 'Card number',
                            errorMaxLines: 2),
                        onSaved: (String value) {
                          print('onSaved = $value');
                          print(
                              'Num controller has = ${numberController.text}');
                          setState(() {
                            _paymentCard.number =
                                CardUtils.getCleanedNumber(value);
                          });
                        },
                        validator: CardUtils.validateCardNum,
                      ),
                      new SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(4),
                                new CardMonthInputFormatter()
                              ],
                              controller: dateController,
                              decoration: new InputDecoration(
                                  isDense: true,
                                  hintText: 'MM/YY',
                                  labelText: 'Expiration date',
                                  errorMaxLines: 2),
                              validator: CardUtils.validateDate,
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                List<int> expiryDate =
                                    CardUtils.getExpiryDate(value);
                                _paymentCard.month = expiryDate[0];
                                _paymentCard.year = expiryDate[1];
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(3),
                              ],
                              controller: cvvController,
                              decoration: new InputDecoration(
                                  isDense: true,
                                  hintText: 'CVV',
                                  labelText: 'CVV',
                                  errorMaxLines: 2),
                              validator: CardUtils.validateCVV,
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                _paymentCard.cvv = int.parse(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        child: _getPayButton(),
                      )
                    ],
                  )));
        }));
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  Widget _getPayButton() {
    return new RaisedButton(
      onPressed: _validateInputs,
      child: new Text(
        'SAVE',
        style: const TextStyle(fontSize: 14.0),
      ),
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
    } else {
      form.save();
      Navigator.pop(context);
      // Encrypt and send send payment details to payment gateway
      payViaNewCard(context, numberController.text, dateController.text,
          cvvController.text);
    }
  }

  payViaNewCard(BuildContext context, String cardNumber, String cardDate,
      String cardCVV) async {
    setState(() {
      _onLoading();
    });
    int ttl = int.parse(widget.amount);
    double pertotal = (2 / 100) * ttl;
    int appCharge = pertotal.toInt();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('AppCharge', appCharge.toString());

    var split = cardDate.split(new RegExp(r'(/)'));
    // The value before the slash is the month while the value to right of
    // it is the year.
    int month = int.parse(split[0]);
    int year = int.parse(split[1]);

    var response = await StripeService.payWithNewCard(
        amount: widget.amount,
        currency: 'USD',
        cardNumber: cardNumber,
        cardMonth: month.toString(),
        cardYear: year.toString(),
        cardCVV: cardCVV);

    response.success == true
        ? saveCard(
            response.success,
            response.message,
            response.id,
            response.brand,
            response.country,
            response.expMonth,
            response.expYear,
            response.last4,
            response.name,
            response.cvv)
        : Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentStatusScreen(
                    shopId: widget.shopId,
                    shopTitle: widget.shopTitle,
                    paymentStatus: response.success,
                    paymentMessage: response.message)),
          );
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  void saveCard(
      bool status,
      String message,
      String transactionId,
      String brand,
      String country,
      String expMonth,
      String expYear,
      String last4,
      String name,
      String cvv) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['brand'] = brand;
    apiBodyObj['country'] = country;
    apiBodyObj['exp_month'] = expMonth;
    apiBodyObj['exp_year'] = expYear;
    apiBodyObj['last_four'] = last4;
    apiBodyObj['name'] = cvv;
    /*if(name == null){
      apiBodyObj['name'] = 'test';
    } else{
      apiBodyObj['name'] = name;
    }*/

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/CreateCard', apiBodyObj);

    if (response['status'] == 'success') {
      addOrder(status, message, transactionId);
    } else {
      Navigator.pop(context);
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']['error']);
    }
  }

  void addOrder(bool status, String message, String transactionId) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shopId;
    apiBodyObj['address_id'] = widget.addressId;
    apiBodyObj['transaction_id'] = transactionId;
    apiBodyObj['payment_type'] = widget.paymentType;

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/Order', apiBodyObj);

    if (response['status'] == 'success') {
      getOrderList(status, message, transactionId);
    } else {
      Navigator.pop(context);
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']['error']);
    }
  }

  void getOrderList(bool status, String message, String transactionId) async {
    Map<String, dynamic> response =
        await NetworkHelper.request('shop/UserOrder');


    if (response['status'] == 'success') {
      if (response['list'] != null) {
        List responseList = response['list'];

        getHistoryData = responseList.map<History>((json) {
          return History.fromJson(json);
        }).toList();

        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(
                  getHistoryData: getHistoryData,
                  paymentStatus: status,
                  paymentMessage: message,
                  transactionId: transactionId,
                  isType: '2')),
        ).then((val) => val ? Navigator.pop(context, true) : null);
      } else {}
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Pay'),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    Icon icon;
                    Text text;

                    switch (index) {
                      case 0:
                        icon =
                            Icon(Icons.add_circle, color: theme.primaryColor);
                        text = Text('Pay via new card');
                        break;
                      case 1:
                        icon =
                            Icon(Icons.credit_card, color: theme.primaryColor);
                        text = Text('Pay via existing card');
                        break;
                    }

                    return InkWell(
                      onTap: () {
                        onItemPress(context, index);
                      },
                      child: ListTile(
                        title: text,
                        leading: icon,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        color: theme.primaryColor,
                      ),
                  itemCount: 2),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
