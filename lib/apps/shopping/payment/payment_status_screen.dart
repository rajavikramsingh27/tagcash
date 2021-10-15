import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/shopping/models/history.dart';
import 'package:tagcash/apps/shopping/user/shop_history_detail_screen.dart';
import 'package:tagcash/components/loading.dart';

import '../shopping_list_screen.dart';

class PaymentStatusScreen extends StatefulWidget {
  final bool paymentStatus;
  List<History> getHistoryData = new List<History>();
  final String shopId, shopTitle, paymentMessage, transactionId, isType;

  PaymentStatusScreen(
      {Key key,
      this.getHistoryData,
      this.shopId,
      this.shopTitle,
      this.paymentStatus,
      this.paymentMessage,
      this.transactionId,
      this.isType})
      : super(key: key);

  @override
  _PaymentStatusScreenState createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                builder: (context) => ShoppingListScreen(
                    moduleCode: "TAG Shopping", selectedPage: 0)),
          );
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Icon(
                        widget.paymentStatus == true
                            ? Icons.thumb_up_alt_rounded
                            : Icons.thumb_down_alt_rounded,
                        size: 150,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      child: Text(
                          widget.paymentStatus == true
                              ? "Payment Successful!"
                              : "Oh no! \n Something went wrong",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1.apply()),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                          widget.paymentStatus == true
                              ? widget.isType == '1'
                                  ? widget.paymentMessage
                                  : 'Your transaction ID is : ' +
                                      widget.transactionId +
                                      '\n' +
                                      widget.paymentMessage
                              : widget.paymentMessage,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyText2.apply()),
                    ),
                    SizedBox(height: 32),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        onPressed: () async {
                          widget.paymentStatus == true
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShopHistoryDetailScreen(
                                              shopId: widget
                                                  .getHistoryData[0].shop_id
                                                  .toString(),
                                              shopTitle:
                                                  widget
                                                      .getHistoryData[0].title,
                                              deliveryStatus:
                                                  widget.getHistoryData[0]
                                                      .delivery_status,
                                              getHistoryData:
                                                  widget.getHistoryData[0].item,
                                              isType: '2')),
                                ).then((val) => val
                                  ? Navigator.of(context).pushReplacement(
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              ShoppingListScreen(
                                                  moduleCode: "TAG Shopping",
                                                  selectedPage: 0)),
                                    )
                                  : null)
                              : Navigator.of(context).pop();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            widget.paymentStatus == true
                                ? "Order Detail"
                                : "Try Again",
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
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ));
  }
}
