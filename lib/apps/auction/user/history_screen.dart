import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/auction/models/liveauction.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

class HistoryScreen extends StatefulWidget {

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = false;
  List<LiveAuction> getHistoryAuctionList = new List<LiveAuction>();
  List<LiveAuction> getFinalHistoryAuctionList = new List<LiveAuction>();
  String nowCommunityID = '0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
        .getActivePerspective() ==
        'community') {
      nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData.id.toString();
    } else{
      nowCommunityID = Provider.of<UserProvider>(context, listen: false)
          .userData.id.toString();
    }

    getHistoryAuctionData();

  }

  void getHistoryAuctionData() async {
    getHistoryAuctionList.clear();
    getFinalHistoryAuctionList.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/soldList');
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getHistoryAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      for(var i = 0; i < getHistoryAuctionList.length; i++) {

        if(getHistoryAuctionList[i].seller_id == nowCommunityID || getHistoryAuctionList[i].buyer_id == nowCommunityID){
          LiveAuction liveAuction = new LiveAuction('','','','','','','','','','','','','','','','','','','','','','','','','','');
          liveAuction.id = getHistoryAuctionList[i].id.toString();
          liveAuction.product_name = getHistoryAuctionList[i].product_name.toString();
          liveAuction.product_description = getHistoryAuctionList[i].product_description.toString();
          liveAuction.currency = getHistoryAuctionList[i].currency.toString();
          liveAuction.image = getHistoryAuctionList[i].image;
          liveAuction.start_date_time = getHistoryAuctionList[i].start_date_time.toString();
          liveAuction.end_date_time = getHistoryAuctionList[i].end_date_time.toString();
          liveAuction.current_date_time = getHistoryAuctionList[i].current_date_time.toString();
          liveAuction.time_left = getHistoryAuctionList[i].time_left.toString();
          liveAuction.latest_bid = getHistoryAuctionList[i].latest_bid.toString();
          liveAuction.seller_id = getHistoryAuctionList[i].seller_id.toString();
          liveAuction.seller_name = getHistoryAuctionList[i].seller_name.toString();
          liveAuction.buyer_id = getHistoryAuctionList[i].buyer_id.toString();
          liveAuction.buyer_name = getHistoryAuctionList[i].buyer_name.toString();
          liveAuction.delivery_price = getHistoryAuctionList[i].delivery_price.toString();
          liveAuction.bid_amount_per_unit = getHistoryAuctionList[i].bid_amount_per_unit.toString();
          liveAuction.is_watch = getHistoryAuctionList[i].is_watch.toString();
          liveAuction.is_highest_bidder = getHistoryAuctionList[i].is_highest_bidder.toString();
          liveAuction.auction_type = getHistoryAuctionList[i].auction_type.toString();
          liveAuction.finish_date = getHistoryAuctionList[i].finish_date.toString();
          liveAuction.reserve_price = getHistoryAuctionList[i].reserve_price.toString();
          liveAuction.owner_details = getHistoryAuctionList[i].owner_details.toString();
          liveAuction.images = getHistoryAuctionList[i].images;
          liveAuction.biddetails = getHistoryAuctionList[i].biddetails;
          getFinalHistoryAuctionList.add(liveAuction);

          print(getFinalHistoryAuctionList.length);
        }
      }

      setState(() {
        isLoading = false;
      });

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
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child:ListView.builder(
                      itemCount: getFinalHistoryAuctionList.length,
                      itemBuilder: (context, i){
                        return InkWell(
                          onTap: (){
                          },
                          child: Card(
                            color: Color(0xFFfcf9f9),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      child: Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Flexible(
                                                          flex: 10,
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  getFinalHistoryAuctionList[i].product_name,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.normal),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  nowCommunityID == getFinalHistoryAuctionList[i].seller_id?
                                                                  'Sold ' + dateParse(getFinalHistoryAuctionList[i].end_date_time):
                                                                  nowCommunityID == getFinalHistoryAuctionList[i].buyer_id?
                                                                  'Bought ' + dateParse(getFinalHistoryAuctionList[i].end_date_time) : '',
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.normal),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ),
                                                        Flexible(
                                                          flex: 1,
                                                          child: Container(
                                                            child: Container(
                                                              margin: EdgeInsets.only(top: 5.0),
                                                              child: FDottedLine(
                                                                color: kPrimaryColor,
                                                                height: 45.0,
                                                                strokeWidth: 2.0,
                                                                dottedLength: 5.0,
                                                                space: 1.0,
                                                              ),
                                                            ),
                                                          )
                                                        ),
                                                        Flexible(
                                                            flex: 5,
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    getFinalHistoryAuctionList[i].currency + ' ' + getFinalHistoryAuctionList[i].latest_bid,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        color: nowCommunityID == getFinalHistoryAuctionList[i].seller_id?
                                                                        Colors.black54 :
                                                                        nowCommunityID == getFinalHistoryAuctionList[i].buyer_id?
                                                                        kPrimaryColor : Colors.black54,
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                        ),

                                                      ],
                                                    )
                                                ),
                                              )
                                            ],
                                          )
                                      )
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                )

              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
  String dateParse(String date){
    DateTime parseDt = DateTime.parse(date);
    var newFormat = DateFormat("dd MMMM yyyy");
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }
}
