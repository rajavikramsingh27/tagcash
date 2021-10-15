class Agent {
  int id;
  int userId;
  int userType;
  String locationName;
  String address;
  var latitude;
  var longitude;
  List<WorkDetails> workDetails;
  String maxTopup;
  String maxCashout;
  String notes;

  Agent(
      {this.id,
        this.userId,
        this.userType,
        this.locationName,
        this.address,
        this.latitude,
        this.longitude,
        this.workDetails,
        this.maxTopup,
        this.maxCashout,
        this.notes});

  Agent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userType = json['user_type'];
    locationName = json['location_name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    if (json['work_details'] != null) {
      workDetails = new List<WorkDetails>();
      json['work_details'].forEach((v) {
        workDetails.add(new WorkDetails.fromJson(v));
      });
    }
    maxTopup = json['max_topup'].toString();
    maxCashout = json['max_cashout'].toString();
    if (json['notes'] != null) {
      notes = json['notes'];
    } else {
      notes = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_type'] = this.userType;
    data['location_name'] = this.locationName;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.workDetails != null) {
      data['work_details'] = this.workDetails.map((v) => v.toJson()).toList();
    }
    data['max_topup'] = this.maxTopup;
    data['max_cashout'] = this.maxCashout;
    data['notes'] = this.notes;
    return data;
  }
}

class WorkDetails {
  String day;
  String fromTime;
  String toTime;

  WorkDetails({this.day, this.fromTime, this.toTime});

  WorkDetails.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    return data;
  }
}
