import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/auction/models/biddetail.dart';
import 'package:tagcash/apps/auction/models/liveauction.dart';
import 'package:tagcash/apps/chat/screens/ConversationScreen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class LiveAuctionDetailScreen extends StatefulWidget {
  List<BidDetail> getBidList = new List<BidDetail>();
  final String auctionId, auctionName, auctionCurrency, auctionReservePrice,
      auctionImage, auctionSeller, auctionSellerId, auctionEnd, bidAmount, isWatch, latestBid, highestBidder;

  LiveAuctionDetailScreen({Key key, this.auctionId, this.auctionName, this.auctionCurrency, this.auctionReservePrice,
    this.auctionImage, this.auctionSeller, this.auctionEnd, this.auctionSellerId, this.bidAmount, this.isWatch, this.latestBid, this.getBidList, this.highestBidder}) : super(key: key);

  @override
  _LiveAuctionDetailScreenState createState() =>
      _LiveAuctionDetailScreenState();
}

class _LiveAuctionDetailScreenState extends State<LiveAuctionDetailScreen> {
  TextEditingController _bidController = TextEditingController();
  bool isLoading = false;
  String isWatch = '0';
  String currentBid = '';
  String userId = '';
  String nowCommunityID = '0';

  List<LiveAuction> getLiveAuctionList = new List<LiveAuction>();
  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLiveAuctionDetailData();

  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void getLiveAuctionDetailData() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['auction_id'] = widget.auctionId;
    apiBodyObj['type'] = 'live';

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/AuctionDetails', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getLiveAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
      });

      isWatch = getLiveAuctionList[0].is_watch;
     /* if(widget.getBidList.isNotEmpty){
        for(int i = 0; i<widget.getBidList.length; i++){
          if(widget.getBidList[i].bid_amount == widget.latestBid){
            currentBid = widget.getBidList[i].bid_amount;
            userId = widget.getBidList[i].user_id;
          }
        }
      }*/

      if(getLiveAuctionList[0].biddetails.isNotEmpty){
        for(int i = 0; i<getLiveAuctionList[0].biddetails.length; i++){
          if(getLiveAuctionList[0].biddetails[i].bid_amount == getLiveAuctionList[0].current_bid){
            currentBid = getLiveAuctionList[0].biddetails[i].bid_amount;
            userId = getLiveAuctionList[0].biddetails[i].user_id;
          }
        }
      }

      _timer = new Timer.periodic(Duration(seconds: 5),
              (Timer timer) => getCroneLiveAuctionDetailData());

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCroneLiveAuctionDetailData() async {

    Map<String, String> apiBodyObj = {};
    apiBodyObj['auction_id'] = widget.auctionId;
    apiBodyObj['type'] = 'live';

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/AuctionDetails', apiBodyObj);
    if (response['status'] == 'success') {
      List responseList = response['result'];
      getLiveAuctionList = responseList.map<LiveAuction>((json) {
        return LiveAuction.fromJson(json);
      }).toList();


      isWatch = getLiveAuctionList[0].is_watch;

      if(getLiveAuctionList[0].biddetails.isNotEmpty){
        for(int i = 0; i<getLiveAuctionList[0].biddetails.length; i++){
          if(getLiveAuctionList[0].biddetails[i].bid_amount == getLiveAuctionList[0].current_bid){
            currentBid = getLiveAuctionList[0].biddetails[i].bid_amount;
            userId = getLiveAuctionList[0].biddetails[i].user_id;
          }
        }
      }
      setState(() {
      });

    } else {

    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
        .getActivePerspective() ==
        'community') {
      nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData.id.toString();
    } else{
    nowCommunityID = Provider.of<UserProvider>(context, listen: false)
        .userData.id.toString();
    }

    print('got userId: $nowCommunityID');
  }

  getLogo() {
    return NetworkImage(
        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image");
  }

  void bidAuction() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['auction_id'] = widget.auctionId;
    apiBodyObj['bid_amount'] = _bidController.text;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/Bid', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        Navigator.pop(context, true);
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

  void watchStatus(String flag) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['auction_id'] = widget.auctionId;
    apiBodyObj['status'] = flag;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/StatusChange', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        isWatch = flag;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  void deleteAuction() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.auctionId;

    Map<String, dynamic> response =
    await NetworkHelper.request('Auction/Delete', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
        Navigator.pop(context, true);
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
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'AUCTION',
      ),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              child:           Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLiveAuctionList.isNotEmpty?
                      getLiveAuctionList[0].product_name:'',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .apply(fontSizeDelta: 5),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seller',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Currency',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Fees',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Reserve',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Bids',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Current Bid',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Ends In',
                              style: Theme.of(context).textTheme.subtitle1.apply(),
                            ),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              getLiveAuctionList[0].owner_details['name']:'',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 20),
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              getLiveAuctionList[0].currency:'',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 20),
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              getLiveAuctionList[0].bidding_fees_by == 'buyer'?
                                  'Buyer': 'Seller':'',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 20),
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              'YES(' + getLiveAuctionList[0].reserve_price + ')':'',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 20),
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              getLiveAuctionList[0].biddetails.length.toString():'',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  getLiveAuctionList.isNotEmpty?
                                  getLiveAuctionList[0].currency + ' '+ currentBid:'',
                                  style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                                  textAlign: TextAlign.start,
                                ),
                                getLiveAuctionList.isNotEmpty?
                                getLiveAuctionList[0].is_highest_bidder == '1'?
                                Text(
                                  ' - ',
                                  style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                                  textAlign: TextAlign.start,
                                ) :Container():Container(),
                                getLiveAuctionList.isNotEmpty?
                                getLiveAuctionList[0].is_highest_bidder == '1'?
                                Text(
                                  '(YOU)',
                                  style: new TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.start,
                                ) : Container() : Container(),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              getLiveAuctionList.isNotEmpty?
                              getLiveAuctionList[0].end_in : '',
                              style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: 2),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                        child: Row(
                          children: [
                            nowCommunityID != widget.auctionSellerId?
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                onTap: (){
                                  Map<String, dynamic> userData = {};
                                  userData['id'] = getLiveAuctionList[0].owner_details['id'];
                                  userData['user_email'] = '';
                                  userData['name'] = getLiveAuctionList[0].owner_details['name'];
                                  userData['user_firstname'] = getLiveAuctionList[0].owner_details['name'];;
                                  userData['user_lastname'] = getLiveAuctionList[0].owner_details['name'];;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetailUserScreen(userData: userData),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Icon(
                                    Icons.comment_bank_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size:50,
                                  ),
//                          child: FaIcon(FontAwesomeIcons.solidCommentAlt, size: 35, color: Colors.grey),
                                ),
                              )

                            ):Container(),
                            nowCommunityID != widget.auctionSellerId?
                            SizedBox(width: 20):Container(),
                            Flexible(
                                flex: 3,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    onPressed: () async {
                                      if(isWatch == '0'){
                                        watchStatus('1');
                                      }else{
                                        watchStatus('0');
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                      side: BorderSide(
                                          color: isWatch == '0'
                                              ? Theme.of(context).primaryColor
                                              : kUserBackColor),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 15, bottom: 15),
                                      child: Text(
                                        isWatch == '0' ? "WATCH" : "WATCHING",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    color: isWatch == '0'
                                        ? Theme.of(context).primaryColor
                                        : kUserBackColor,
                                  ),
                                )),
                            SizedBox(width: 10),

                            nowCommunityID != widget.auctionSellerId?
                            Flexible(
                                flex: 2,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if(_bidController.text == ''){
                                        showSimpleDialog(context,
                                            title: 'Attention',
                                            message: 'Please bid value');
                                      } else{
                                        if(currentBid != ''){
                                          if(int.parse(_bidController.text) <= int.parse(currentBid)){
                                            print('currentBid + 1');
                                            showSimpleDialog(context,
                                                title: 'Attention',
                                                message: 'Please enter higher price');
                                          }else{
                                            bidAuction();
                                          }
                                        } else{
                                          if(int.parse(_bidController.text) <= int.parse(getLiveAuctionList[0].reserve_price)){
                                            print('currentBid + 1');
                                            showSimpleDialog(context,
                                                title: 'Attention',
                                                message: 'Please enter higher price');
                                          }else{
                                            bidAuction();
                                          }
                                        }

                                      }

                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                      side: BorderSide(
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 15, bottom: 15),
                                      child: Text(
                                        "BID",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )): Flexible(
                                flex: 3,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FlatButton(
                                    onPressed: () async {
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
                                          deleteAuction();
                                        },
                                      );

                                      AlertDialog alert = AlertDialog(
                                        title: Text(""),
                                        content: Text('Are you sure you want to delete this auction?'),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                      side: BorderSide(
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.only(top: 15, bottom: 15),
                                      child: Text(
                                        "DELETE",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )),
                            nowCommunityID != widget.auctionSellerId?
                            SizedBox(width: 10):Container(),
                            nowCommunityID != widget.auctionSellerId?
                            Flexible(
                              flex: 3,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: TextField(
                                  controller: _bidController,
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 20),
                                    hintText: "BID",
                                    hintStyle: TextStyle(
                                        fontSize: 18.0, color: Color(0xFFACACAC)),
                                  ),
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.normal),
                                ),
                              ),
                            ):Container(),
                          ],
                        )),
                    nowCommunityID != widget.auctionSellerId?
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          'add higher price here than bid',
                          style: Theme.of(context).textTheme.bodyText2.apply(fontSizeDelta: -2),
                        ),
                      )
                    ):Container(),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){
                        widget.auctionImage != ''?
                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                RedeemConfirmationScreen(url: widget.auctionImage))) : Container();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: widget.auctionImage != ''?
                              NetworkImage(
                                  widget.auctionImage)
                                  : NetworkImage(
                                  "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                          ),
                        ),
                        width: 120.0,
                        height: 120.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class RedeemConfirmationScreen extends StatelessWidget {
  String url;

  RedeemConfirmationScreen({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.80), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/1,
                    height: MediaQuery.of(context).size.height/1,
                    child: PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      imageProvider:  NetworkImage(
                          url),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 100, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear, size: 25,color: Colors.white),
                            onPressed:(){
                              Navigator.pop(context, true);
                            },
                          )
                        ],
                      )
                  ),
                ],
              )
            ],
          )
      ),
    );
  }
}
