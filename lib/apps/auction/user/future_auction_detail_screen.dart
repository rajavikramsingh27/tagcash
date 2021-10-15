import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class FutureAuctionDetailScreen extends StatefulWidget {
  final String auctionId, auctionName, auctionImage, auctionSeller, auctionStartDate, isWatch;

  const FutureAuctionDetailScreen({Key key, this.auctionId, this.auctionName, this.auctionImage,
    this.auctionSeller, this.auctionStartDate, this.isWatch}) : super(key: key);

  @override
  _FutureAuctionDetailScreenState createState() =>
      _FutureAuctionDetailScreenState();
}

class _FutureAuctionDetailScreenState extends State<FutureAuctionDetailScreen> {

  bool isLoading = false;
  String isWatch = '0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isWatch = widget.isWatch;
  }

  getLogo() {
    return NetworkImage(
        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image");
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  widget.auctionName,
                  style: Theme.of(context).textTheme.subtitle1.apply(),
                ),
                SizedBox(height: 20),
                Container(
                  child: Row(
                    children: [
                      Container(
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
                    ],
                  ),
                ),
                SizedBox(height: 30),
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
                          'Reserve',
                          style: Theme.of(context).textTheme.subtitle1.apply(),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Starts',
                          style: Theme.of(context).textTheme.subtitle1.apply(),
                        ),
                      ],
                    ),
                    SizedBox(width: 80),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.auctionSeller,
                          style: new TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'YES',
                          style: new TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 20),
                        Text(
                          widget.auctionStartDate,
                          style: new TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 50),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child:  FlatButton(
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
                          color: isWatch == '0'?
                          Theme.of(context).primaryColor : kUserBackColor),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        isWatch == '0'?
                        "WATCH" : "WATCHING",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    color: isWatch == '0'?
                    Theme.of(context).primaryColor : kUserBackColor,
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
}
