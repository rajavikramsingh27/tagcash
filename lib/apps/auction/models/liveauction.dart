import 'biddetail.dart';

class LiveAuction {
  String id;
  String product_name;
  String product_description;
  String currency;
  String image;
  String start_date_time;
  String end_date_time;
  String current_date_time;
  String time_left;
  String latest_bid;
  String seller_id;
  String seller_name;
  String buyer_id;
  String buyer_name;
  String delivery_price;
  String bid_amount_per_unit;
  String is_watch;
  String is_highest_bidder;
  String auction_type;
  String finish_date;
  String reserve_price;
  String end_in;
  String current_bid;
  String bidding_fees_by;
  String bidding_fees;
  var owner_details;
  List<String> images;
  List<BidDetail> biddetails;

  LiveAuction(
      this.id,
        this.product_name, this.product_description, this.currency, this.image, this.start_date_time,
        this.end_date_time, this.current_date_time, this.time_left, this.latest_bid, this.seller_id,
        this.seller_name, this.buyer_id, this.buyer_name, this.delivery_price, this.bid_amount_per_unit, this.is_watch,
        this.is_highest_bidder, this.auction_type, this.finish_date, this.reserve_price, this.end_in,
        this.current_bid, this.bidding_fees_by, this.bidding_fees, this.owner_details, [this.images, this.biddetails]);

  LiveAuction.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    product_name = json['product_name'];
    product_description = json['product_description'].toString();
    currency = json['currency'].toString();
    if(json['owner_details'] != '' && json['owner_details'] != null){
      owner_details = json['owner_details'];
    }
    if(json['image'] == null){
      image = "";
      var img= "";
      images = new List<String>();
      images.add(img);
    }else{
      image = json['image'][0].toString();
      var imagee = json['image'];
      images = new List<String>.from(imagee);
    }
    if(json['bid_details'] != '' && json['bid_details'] != null){
      var tagObjsJson = json['bid_details'] as List;
      biddetails = tagObjsJson.map<BidDetail>((json) {
        return BidDetail.fromJson(json);
      }).toList();
    }

    start_date_time = json['start_date_time'].toString();
    end_date_time = json['end_date_time'].toString();
    current_date_time = json['current_date_time'].toString();
    time_left = json['time_left'].toString();
    latest_bid = json['latest_bid'].toString();
    seller_id = json['seller_id'].toString();
    seller_name = json['seller_name'].toString();
    buyer_id = json['buyer_id'].toString();
    buyer_name = json['buyer_name'].toString();
    delivery_price = json['delivery_price'].toString();
    bid_amount_per_unit = json['bid_amount_per_unit'].toString();
    is_watch = json['is_watch'].toString();
    is_highest_bidder = json['is_highest_bidder'].toString();
    auction_type = json['auction_type'].toString();
    finish_date = json['finish_date'].toString();
    reserve_price = json['reserve_price'].toString();
    end_in = json['end_in'].toString();
    current_bid = json['current_bid'].toString();
    bidding_fees_by = json['bidding_fees_by'].toString();
    bidding_fees = json['bidding_fees'].toString();
  }

}
