class MessageInboxOutboxData {
  String id;
  String nickName;
  String countryName;
  String cityName;
  String description;
  String age;
  int genderId;
  String profileUrl;
  int readStatus;
  String lastMessageType;
  var lastMessage;
  String updatedDate;
  int onlineStatus;

  MessageInboxOutboxData(
      {this.id,
        this.nickName,
        this.countryName,
        this.cityName,
        this.description,
        this.age,
        this.genderId,
        this.profileUrl,
        this.readStatus,
        this.lastMessageType,
        this.lastMessage,
        this.onlineStatus,
        this.updatedDate});

  MessageInboxOutboxData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    countryName = json['country_name'];
    cityName = json['city_name'];
    description = json['description'];
    age = json['age'];
    genderId = json['gender_id'];
    profileUrl = json['profile_url'];
    readStatus = json['read_status'];
    onlineStatus = json['online_status'];
    lastMessageType = json['last_message_type'];
    lastMessage = json['last_message'];
    updatedDate = json['updated_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nick_name'] = this.nickName;
    data['country_name'] = this.countryName;
    data['city_name'] = this.cityName;
    data['description'] = this.description;
    data['age'] = this.age;
    data['gender_id'] = this.genderId;
    data['profile_url'] = this.profileUrl;
    data['read_status'] = this.readStatus;
    data['last_message_type'] = this.lastMessageType;
    data['last_message'] = this.lastMessage;
    data['updated_date'] = this.updatedDate;
    data['online_status'] = this.onlineStatus;
    return data;
  }
}