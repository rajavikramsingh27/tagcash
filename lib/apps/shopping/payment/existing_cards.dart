import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/shopping/models/card.dart';
import 'package:tagcash/apps/shopping/models/history.dart';
import 'package:tagcash/apps/shopping/payment/payment_service.dart';
import 'package:tagcash/apps/shopping/payment/payment_status_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class ExistingCardsScreen extends StatefulWidget {
  String amount, currency, shopId, shopTitle, addressId, paymentType;

  ExistingCardsScreen(
      {Key key,
      this.amount,
      this.currency,
      this.shopId,
      this.shopTitle,
      this.addressId,
      this.paymentType})
      : super(key: key);

  @override
  ExistingCardsScreenState createState() => ExistingCardsScreenState();
}

class ExistingCardsScreenState extends State<ExistingCardsScreen> {
  bool isLoading = false;
  List<CardDetail> getCardData = new List<CardDetail>();
  List<History> getHistoryData = new List<History>();

  @override
  void initState() {
    super.initState();
    getCardList();
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

  void getCardList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('shop/ListCard');


    if (response['status'] == 'success') {
      if (response['list'] != null) {
        List responseList = response['list'];
        getCardData = responseList.map<CardDetail>((json) {
          return CardDetail.fromJson(json);
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  void removeCard(int id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('shop/DeleteCard', apiBodyObj);


    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getCardList();
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  payViaExistingCard(BuildContext context, String cardNumber, String cardMonth,
      String cardYear, String cardCVV) async {
    setState(() {
      _onLoading();
    });

    int ttl = int.parse(widget.amount);
    double pertotal = (2 / 100) * ttl;
    int appCharge = pertotal.toInt();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('AppCharge', appCharge.toString());

    var response = await StripeService.payViaExistingCard(
        amount: widget.amount,
        currency: 'USD',
        cardNumber: cardNumber,
        cardMonth: cardMonth,
        cardYear: cardYear,
        cardCVV: cardCVV);

    response.success == true
        ? addOrder(response.success, response.message, response.id)
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
      setState(() {
        isLoading = false;
      });

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
      } else {
        Navigator.pop(context);
      }
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose existing card'),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: getCardData.length,
                itemBuilder: (BuildContext context, int index) {
                  var card = getCardData[index];
                  return Container(
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            payViaExistingCard(
                                context,
                                getCardData[index].last_four.toString(),
                                getCardData[index].exp_month.toString(),
                                getCardData[index].exp_year.toString(),
                                getCardData[index].name);
                          },
                          child: CreditCardWidget(
                            cardNumber: getCardData[index].last_four.toString(),
                            expiryDate:
                                getCardData[index].exp_month.toString() +
                                    '/' +
                                    getCardData[index].exp_year.toString(),
                            cvvCode: getCardData[index].name,
                            cardHolderName: '',
                            showBackView: false,
                          ),
                        ),
                        InkWell(
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
                                  removeCard(getCardData[index].id);
                                },
                              );

                              AlertDialog alert = AlertDialog(
                                title: Text(""),
                                content: Text(
                                    'Are you sure you want to delete this card?'),
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
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Icon(Icons.cancel,
                                          size: 20,
                                          color:
                                              Theme.of(context).primaryColor)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
