import 'package:intl/intl.dart';

class Advert {
  String id;
  String userId;
  String userType;
  String campaignTitle;
  String videoUrl;
  String lat;
  String lng;
  String radius;
  String maxSpend;
  String imageName;
  int consumed;
  String activeStatus;
  String createdDate;

  Advert(
      {this.id,
      this.userId,
      this.userType,
      this.campaignTitle,
      this.videoUrl,
      this.lat,
      this.lng,
      this.radius,
      this.maxSpend,
      this.imageName,
      this.consumed,
      this.activeStatus,
      this.createdDate});

  Advert.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userType = json['user_type'];
    campaignTitle = json['campaign_title'];
    videoUrl = json['video_url'];
    lat = json['lat'];
    lng = json['lng'];
    radius = json['radius'];
    maxSpend = json['max_spend'];
    imageName = json['image_name'];
    consumed = json['consumed'];
    activeStatus = json['active_status'];
    DateFormat formatter = DateFormat('d MMM yyyy');
    var parsedDate = DateTime.parse(json['created_date']);
    String formatted = formatter.format(parsedDate);
    createdDate = formatted;
    //createdDate = json['created_date'];
  }
}
