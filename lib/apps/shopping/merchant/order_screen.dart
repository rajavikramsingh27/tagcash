import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/shopping/models/merchant_order.dart';
import 'package:tagcash/apps/shopping/models/shop_merchant.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';


class OrderListScreen extends StatefulWidget {
  final ShopMerchant shop;

  const OrderListScreen({Key key, this.shop}) : super(key: key);

  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  var isLoading = false;

  var _value = 1;
  var status = 'no';
  String emptyMessage = '';

  List<MerchantOrder> getOrderData = new List<MerchantOrder>();

  @override
  void initState() {
    super.initState();
    getOrderList();
  }

  void getOrderList() async {
    emptyMessage = '';
    getOrderData.clear();
    setState(() {
      isLoading = true;
    });

    final postData = {
      "shop_id" : widget.shop.id.toString(),
      "delivery_status" : status,
    };

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/OwnerOrder', postData);

    if (response['status'] == 'success') {
      if(response['list'] != null){

        List responseList = response['list'];
        getOrderData = responseList.map<MerchantOrder>((json) {
          return MerchantOrder.fromJson(json);
        }).toList();
        setState(() {
          isLoading = false;
        });
      } else{
        emptyMessage = 'No Order Found';
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addOrderDeliver(transaction_id, isOrderType) async {
    setState(() {
      isLoading = true;
    });

    final postData = {
      "delivered_by" : 'transaction',
      "id" : transaction_id,
      "delivery_status" : isOrderType,
    };

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/Deliver', postData);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getOrderList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Radio(
                                  value: 1,
                                  groupValue: _value,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                      status = 'no';
                                      getOrderList();
                                    });
                                  },
                                ),
                              )
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _value = 1;
                                status = 'no';
                                getOrderList();
                              });
                            },
                            child: Text("To Deliver", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      SizedBox(width: 50),
                      Row(
                        children: [
                          Container(
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Radio(
                                  value: 2,
                                  groupValue: _value,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                      status = 'yes';
                                      getOrderList();
                                    });
                                  },
                                ),
                              )
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _value = 2;
                                status = 'yes';
                                getOrderList();
                              });
                            },
                            child: Text("Delivered", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(width: 50),
                      Row(
                        children: [
                          Container(
                              child: SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Radio(
                                  value: 3,
                                  groupValue: _value,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                      status = 'cancel';
                                      getOrderList();
                                    });
                                  },
                                ),
                              )
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _value = 3;
                                status = 'cancel';
                                getOrderList();
                              });
                            },
                            child: Text("Cancelled", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  getOrderData.length != 0?
                  Expanded(
                    child: ListView.builder(
                        itemCount: getOrderData.length,
                        itemBuilder: (context, index){
                          return InkWell(
                            onTap: (){
                            },
                            child: Card(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        children: [
                                          Text(
                                            getOrderData[index].items[0].shipping_address['first_name'].toString(),
                                            style: Theme.of(context).textTheme.subtitle1.apply(),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            ' - '+ getOrderData[index].items[0].shipping_address['phone'].toString(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        getOrderData[index].items[0].shipping_address['address'].toString() + ', ' + getOrderData[index].items[0].shipping_address['city'].toString(),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),

                                      Text(
                                        'Order placed: ' + dateFormate(getOrderData[index].order_date),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),
                                      Text(
                                        'Total: ' + getOrderData[index].grand_total.toString() + ' - '+ 'Payment ' +  getOrderData[index].items[0].payment_type.toString(),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.start,
                                      ),

                                      SizedBox(height: 10),

                                      ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: getOrderData[index].items.length,
                                          itemBuilder: (context, i){
                                            return Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.0
                                                      ),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 12,
                                                      minHeight: 12,
                                                    ),
                                                    child: new Text(
                                                      getOrderData[index].items[i].qty.toString(),
                                                      style: new TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),

                                                  SizedBox(width:10),
                                                  Text(
                                                    getOrderData[index].items[i].productName,
                                                    style: Theme.of(context).textTheme.subtitle1.apply(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      ),
                                      SizedBox(height: 10),
                                      getOrderData[index].delivery_status == 'no'?
                                          Row(
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      addOrderDeliver(getOrderData[index].transaction_id, 'yes');
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(3.0),
                                                      side: BorderSide(
                                                          color: Theme.of(context).primaryColor),
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                      child: Text(
                                                        "DELIVER",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Flexible(
                                                flex: 1,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      addOrderDeliver(getOrderData[index].transaction_id, 'cancel');
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(3.0),
                                                      side: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsets.only(top: 10, bottom: 10),
                                                      child: Text(
                                                        "CANCEL",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ) : getOrderData[index].delivery_status == 'yes' ?
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: FlatButton(
                                          onPressed: () async {

                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3.0),
                                            side: BorderSide(
                                                color: Colors.grey),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(
                                              "DELIVERED",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          color: Colors.grey,
                                        ),
                                      ) :  Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: FlatButton(
                                          onPressed: () async {

                                          },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3.0),
                                            side: BorderSide(
                                                color: Colors.grey),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text(
                                              "CANCELLED",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          color: Colors.grey,
                                        ),
                                      )

                                    ],
                                  ),
                                )
                            ),
                          );
                        }
                    )
                  ) : Expanded(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6.apply(),
                            ),
                          ],
                        )
                    ),
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }

  String dateFormate(String date) {
    var formatter = new DateFormat('dd MMM hh:mm');
    String d = formatter.format(DateTime.parse(date)); //set formate
    return d.toString();
  }
}