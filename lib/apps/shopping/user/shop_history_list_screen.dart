import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/shopping/models/history.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'shop_history_detail_screen.dart';


class ShopHistoryListScreen extends StatefulWidget {

  @override
  _ShopHistoryListScreenState createState() => _ShopHistoryListScreenState();
}

class _ShopHistoryListScreenState extends State<ShopHistoryListScreen> {
  bool isLoading = false;
  List<History> getHistoryData = new List<History>();

  @override
  void initState() {
    super.initState();
    getOrderList();
  }

  void getOrderList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/UserOrder');


    if (response['status'] == 'success') {
      if(response['list'] != null){
        List responseList = response['list'];

        getHistoryData = responseList.map<History>((json) {
          return History.fromJson(json);
        }).toList();
      } else{
        setState(() {
          isLoading = false;
        });
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              child: ListView.builder(
                itemCount: getHistoryData.length,
                itemBuilder: (context, index){
                  return InkWell(
                    onTap: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ShopHistoryDetailScreen(shopId: getHistoryData[index].shop_id.toString(), shopTitle: getHistoryData[index].title,
                            deliveryStatus: getHistoryData[index].delivery_status, getHistoryData: getHistoryData[index].item,isType: '1')),
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Flexible(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            getHistoryData[index].title,
                                            style: Theme.of(context).textTheme.subtitle1.apply()
                                        ),

                                        Text(
                                            getHistoryData[index].grand_total + ' ' + getHistoryData[index].shop_currency_code,
                                            style: Theme.of(context).textTheme.subtitle1.apply()
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Order placed ' + dateFormate(getHistoryData[index].order_date),
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    Text(
                                      getHistoryData[index].delivery_status == 'no'?
                                      'Total - '+ getHistoryData[index].grand_total + ' '+ getHistoryData[index].shop_currency_code + ' - '+ 'In Transit'
                                          : getHistoryData[index].delivery_status == 'yes'?
                                           'Total - '+ getHistoryData[index].grand_total + ' '+ getHistoryData[index].shop_currency_code + ' - '+ 'Delivered':
                                           'Total - '+ getHistoryData[index].grand_total + ' '+ getHistoryData[index].shop_currency_code + ' - '+ 'Cancelled',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              )
              ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }

  String dateFormate(String date) {
    var formatter = new DateFormat('dd MMM yyyy');
    String d = formatter.format(DateTime.parse(date)); //set formate
    return d.toString();
  }
}
